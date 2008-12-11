#!/usr/bin/perl

package Imago::Schema::Role::Page::REST;
use Moose::Role;

use namespace::clean -except => 'meta';

with qw(Imago::Schema::Role::Page);

requires "process_get";

sub process {
	my ( $self, %args ) = @_;

	my $method = "process_" . lc($args{request}->method);

	if ( $self->can($method) ) {
		return $self->$method(%args);
	} else {
		$self->process_get(%args);
	}
}

__PACKAGE__

__END__
