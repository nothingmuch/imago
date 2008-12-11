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
