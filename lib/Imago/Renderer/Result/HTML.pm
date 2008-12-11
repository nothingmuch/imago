#!/usr/bin/perl

package Imago::Renderer::Result::HTML;
use Moose;

use Data::Dumper;
use Encode qw(encode);

use namespace::clean -except => 'meta';

with qw(Imago::Renderer::Result);

has page => (
	isa => "Imago::Schema::Page",
	is  => "ro",
);

has html => (
	isa => "Str",
	is  => "ro",
	lazy_build => 1,
);

sub _build_html {
	my $self = shift;

	"<html><head></head><body><pre>" . Dumper($self->page) . "</pre></body>";
}

sub write_to_catalyst {
	my ( $self, $c ) = @_;

	my $body = $self->html;

	$c->response->content_type( "text/html; charset=utf-8" );
	$c->response->body( encode( utf8 => $self->html ) );
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
