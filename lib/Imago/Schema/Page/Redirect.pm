#!/usr/bin/perl

package Imago::Schema::Page::Redirect;
use Moose;

use Imago::Renderer::Result::Redirect;

use namespace::clean -except => 'meta';

with qw(Imago::Schema::Role::Page);

has to => (
	does => "Imago::Schema::Role::Page",
	is   => "ro",
	required => 1,
);

sub process {
	my ( $self, @args ) = @_;

	Imago::Renderer::Result::Redirect->new( @args, page => $self );
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
