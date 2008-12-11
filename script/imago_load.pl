#!/usr/bin/perl

package Imago::Script::Load;

use Moose;

use Imago::Backend::KiokuDB;

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
						body => "foo",
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
	});
}

__PACKAGE__->new_with_options->run;

__END__
