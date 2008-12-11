#!/usr/bin/perl

use utf8;

package Imago::Script::Load;
use Moose;

use Imago::Backend::KiokuDB;
use Authen::Passphrase;

use namespace::clean -except => 'meta';

with qw(MooseX::Getopt);

has backend => (
	isa => "Imago::Backend::KiokuDB",
	is  => "ro",
	lazy_build => 1,
);

sub _build_backend { Imago::Backend::KiokuDB->new( extra_args => { create => 1 } ) }

sub run {
	my $self = shift;

	my $backend = $self->backend;

	$backend->txn_do(sub {
		my $scope = $backend->new_scope;

		$backend->insert(
			Imago::Schema::Page->new(
				id => "index",
				en => Imago::Schema::Page::Content->new(
					title => "main",
					content => Imago::Schema::BLOB->new(
						body => "[login](/login)",
					),
				),
				he => Imago::Schema::Page::Content->new(
					title => "ikari",
					content => Imago::Schema::BLOB->new(
						body => "bar",
					),
				),
			),
		),

		$backend->insert(
			Imago::Schema::Page->new(
				id => "foo",
				en => Imago::Schema::Page::Content->new(
					title => "foo",
					content => Imago::Schema::BLOB->new(
						body => "lala",
					),
				),
				he => Imago::Schema::Page::Content->new(
					title => "פוו",
					content => Imago::Schema::BLOB->new(
						body => "להלה",
					),
				),
			),
		),

		$backend->insert(
			Imago::Schema::User->new(
				id => "katrin",
				password => Authen::Passphrase->from_rfc2307(
					"{SSHA}Gn351bZjMhdoZO1pZxEWuchJ3ne9XGhZxElu6LfvN9lfio2ff8stVg=="
				),
				real_name => "Katrin Kogman-Appel",
			),
		);

		$backend->insert(
			Imago::Schema::Page::Login->new(
				en => Imago::Schema::Page::Content->new(
					title => "login",
					content => Imago::Schema::BLOB->new(
						body => <<HTML,
Please login

<form method="post">
	login: <input type="text" name="id" /> <br/>
	password: <input type="password" name="password" /> <br/>
</form>
HTML
					),
				),
				he => Imago::Schema::Page::Content->new(
					title => "login",
					content => Imago::Schema::BLOB->new(
						body => "נא להכנס למעכת",
					),
				),
			),
		);
	});
}

__PACKAGE__->new_with_options->run;

__END__
