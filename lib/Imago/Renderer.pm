#!/usr/bin/perl

package Imago::Renderer;
use Moose;

use namespace::clean -except => 'meta';

sub process {
	my ( $self, $page, @args ) = @_;

	$page->process(@args);
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
