#!/usr/bin/perl

package Imago::Schema::Page::Login;
use Moose;

use Imago::Renderer::Result::Redirect;

use namespace::clean -except => 'meta';

extends qw(Imago::Schema::Page::REST);

has '+id' => ( default => "login" );

sub post {
	my ( $self, %args ) = @_;

	my $c = $args{context};

	my $id       = $c->req->param("id");
    my $password = $c->req->param("password");

    my $user = eval {
        $c->authenticate({
            id       => $id,
            password => $password,
        });
    };

	if ( $user ) {
		Imago::Renderer::Result::Redirect->new( %args, to => "/" );
	} else {
		$self->get(
			%args,
			error => 1,
		);
	}
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
