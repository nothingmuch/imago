#!/usr/bin/perl

package Imago::Renderer;
use Moose;

use namespace::clean -except => 'meta';

has template_provider => (
	isa => "Imago::Renderer::TemplateProvider",
	is  => "ro",
	required => 1,
	handles => [qw(template)],
);

sub process {
	my ( $self, $page, @args ) = @_;

	$page->process(@args, renderer => $self);
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
