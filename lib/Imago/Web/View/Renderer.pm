#!/usr/bin/perl

package Imago::Web::View::Renderer;
use Moose;

use Imago::Renderer;

use namespace::clean -except => 'meta';

BEGIN { extends qw(Moose::Object Catalyst::View) }

has renderer => (
	isa => "Imago::Renderer",
	is  => "ro",
	lazy_build => 1,
);

sub _build_renderer {
	Imago::Renderer->new,
}

sub process {
	my ( $self, $c, $page ) = @_;

	my $result = $self->renderer->process($page);

	$result->write_to_catalyst($c);
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
