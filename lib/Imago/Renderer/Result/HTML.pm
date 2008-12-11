#!/usr/bin/perl

package Imago::Renderer::Result::HTML;
use Moose;

use Encode qw(encode);

use namespace::clean -except => 'meta';

has body => (
	isa => "Str",
	is  => "ro",
	required => 1,
);

sub write_to_catalyst {
	my ( $self, $c ) = @_;

	$c->response->content_type( "text/html; charset=utf-8" );
	$c->response->body( encode( utf8 => $self->body ) );
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
