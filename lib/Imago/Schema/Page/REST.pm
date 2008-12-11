#!/usr/bin/perl

package Imago::Schema::Page::REST;
use Moose;

use namespace::clean -except => 'meta';

extends qw(Imago::Schema::Page);

sub process {
	my ( $self, %args ) = @_;

	my $method = lc($args{request}->method);

	warn "method: $method";

	if ( $self->can($method) ) {
		return $self->$method(%args);
	} else {
		$self->get(%args);
	}
}

sub get {
	my ( $self, @args ) = @_;
	$self->SUPER::process(@args);
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__

=pod

=head1 NAME

Imago::Schema::Page::REST - 

=head1 SYNOPSIS

	use Imago::Schema::Page::REST;

=head1 DESCRIPTION

=cut


