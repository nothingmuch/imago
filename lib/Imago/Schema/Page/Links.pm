#!/usr/bin/perl

package Imago::Schema::Page::Links;
use Moose;

use namespace::clean -except => 'meta';

with qw(
	Imago::Schema::Role::Page
);

has links => (
	isa => "ArrayRef[Imago::Schema::Link]",
	is  => "ro",
	required => 1,
);

sub process {
	my ( $self, @args ) = @_;
	Imago::Renderer::Result::Page::Static->new( @args, page => $self ); # FIXME
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
