#!/usr/bin/perl

package Imago::Web::View::Renderer;
use Moose;

use Imago::Renderer;
use Imago::Renderer::TemplateProvider;

use namespace::clean -except => 'meta';

BEGIN { extends qw(Moose::Object Catalyst::View) }

sub BUILDARGS {
	my ( $self, $app, $config ) = @_;
	return $config;
}

sub BUILD { shift->renderer }

has template_include_path => (
	isa => "ArrayRef",
	is  => "ro",
);

has template_provider => (
	isa => "Imago::Renderer::TemplateProvider",
	is  => "ro",
	lazy_build => 1,
);

sub _build_template_provider {
	my $self = shift;

	Imago::Renderer::TemplateProvider->new(
		include_path => $self->template_include_path,
	);
}

has renderer => (
	isa => "Imago::Renderer",
	is  => "ro",
	lazy_build => 1,
);

sub _build_renderer {
	my $self = shift;

	Imago::Renderer->new(
		template_provider => $self->template_provider,
	);
}

sub process {
	my ( $self, $c, $page ) = @_;

	my $result = $self->renderer->process(
		$page,
		context => $c,
		request => $c->request,
		lang    => ($c->request->param("lang") || 'en'), # FIXME $c->user? cookie? note scalar context
		( $c->user_exists ? ( user => $c->user->get_object ) : () ),
	);

	$result->write_to_catalyst($c);
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
