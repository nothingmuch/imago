#!/usr/bin/perl

package Imago::Schema::Page::Redirect;
use Moose;

use Imago::Renderer::Result::Redirect;

use namespace::clean -except => 'meta';

with qw(KiokuDB::Role::ID);

sub kiokudb_object_id { "page:" . shift->id }

has id => (
	isa => "Str",
	is  => "ro",
	required => 1,
);

has to => (
	isa => "Imago::Schema::Page|Imago::Schema::Page::Redirect",
	is  => "ro",
	required => 1,
);

sub process {
	my ( $self, @args ) = @_;

	Imago::Renderer::Result::Redirect->new( @args, page => $self );
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
