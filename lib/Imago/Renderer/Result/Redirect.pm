#!/usr/bin/perl

package Imago::Renderer::Result::Redirect;
use Moose;

use namespace::clean -except => 'meta';

with qw(Imago::Renderer::Result);

has to => (
	isa => "Str",
	is  => "ro",
);

sub write_to_catalyst {
	my ( $self, $c ) = @_;

	$c->response->redirect( $c->to );
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
