#!/usr/bin/perl

package Imago::Schema::Page::Signup;
use Moose;

use Captcha::reCAPTCHA;
use Authen::Passphrase::SaltedDigest;

use Imago::Renderer::Result::HTML;

use namespace::clean -except => 'meta';

with qw(
	Imago::Schema::Role::Page
	Imago::Schema::Role::Page::REST
);

has [qw(public_key private_key)] => (
	isa => "Str",
	is  => "ro",
	required => 1,
);

has recaptcha => (
	isa => "Captcha::reCAPTCHA",
	is  => "ro",
	required => 1,
	default => sub { Captcha::reCAPTCHA->new },
);

sub captcha_html {
	my $self = shift;
	
	$self->recaptcha->get_html($self->public_key);
}

sub check_recaptcha {
	my ( $self, %args ) = @_;

	my $r = $args{request};

    my $challenge = $r->param('recaptcha_challenge_field');
    my $response  = $r->param('recaptcha_response_field');

    $self->recaptcha->check_answer(
        $self->private_key,
        $r->address,
        $challenge,
        $response,
    );
}

sub process_get {
	my ( $self, %args ) = @_;

	{
		package Imago::Renderer::Result::HTML::Tags; # T::D exports 'meta', etc, need a new namespace

		use strict;
		use warnings;

		use Template::Declare::Tags 'HTML';

		return Imago::Renderer::Result::HTML->new(
			body => "" . html {
				head {
					title { "Sign Up" } # FIXME localize
				}
				body {
					div {
						form {
							attr { method => "post" },
							label { attr { for => "id" }, "Real Name: " },
							input { attr { type => "text", name => "real_name" } }, br{},
							label { attr { for => "id" }, "Username: " },
							input { attr { type => "text", name => "id" } }, br{},
							label { attr { for => "password" }, "Password: " },
							input { attr { type => "password", name => "password" } }, br{},
							label { attr { for => "password_confirm" }, "Confirm: " },
							input { attr { type => "password", name => "password_confirm" } }, br{},
							outs_raw($self->captcha_html),
							input { attr { type => "submit" } },
						},
					},
				},
			},
		);
	}
}

sub process_post {
	my ( $self, %args ) = @_;

	my $res = $self->check_recaptcha(%args);

	unless ( $res->{is_valid} ) {
		$self->process_get( %args, error => $res->{error} );
	} else {
		my $b = $args{context}->model("kiokudb");
		
		$b->txn_do(sub {
			$b->insert(
				Imago::Schema::User->new(
					%{ $args{request}->params },
					password => Authen::Passphrase::SaltedDigest->new(
						algorithm => "SHA-1",
						salt_random => 20,
						passphrase => $args{request}->params->{password},
					),
				),
			);
		});
	}
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
