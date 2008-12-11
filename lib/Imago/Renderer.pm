#!/usr/bin/perl

package Imago::Renderer;
use Moose;

use Imago::Renderer::Result::Redirect;
use Imago::Renderer::Result::HTML;

use namespace::clean -except => 'meta';

sub process {
	my ( $self, $page ) = @_;

	if ( $page->isa("Imago::Schema::Page::Redirect") ) {
		Imago::Renderer::Result::Redirect->new( to => $page->to );
	} else {
		Imago::Renderer::Result::HTML->new( page => $page );
	}
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
