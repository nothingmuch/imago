#!/usr/bin/perl

package Imago::Schema::Role::Page::Static;
use Moose::Role;

use Imago::Schema::Page::Static::Content;
use Imago::Renderer::Result::Page::Static;

use namespace::clean -except => 'meta';

has [qw(en he)] => (
	isa => "Imago::Schema::Page::Static::Content",
	is  => "ro",
	required => 1,
	coerce => 1,
);

sub process {
	my ( $self, @args ) = @_;
	Imago::Renderer::Result::Page::Static->new( @args, page => $self );
}

__PACKAGE__

__END__
