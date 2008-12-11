#!/usr/bin/perl

package Imago::Renderer::Result::Redirect;
use Moose;

use namespace::clean -except => 'meta';

with qw(Imago::Renderer::Result);

has page => (
	isa => "Imago::Schema::Page::Redirect",
	is  => "ro",
);

has to => (
	isa => "Str",
	is  => "ro",
	lazy_build => 1,
);

sub _build_to {
	my $self = shift;

	"/" . $self->page->to->id;
}

sub write_to_catalyst {
	my ( $self, $c ) = @_;

	$c->response->redirect( $self->to );
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
