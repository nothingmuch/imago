#!/usr/bin/perl

package Imago::Schema::Nav;
use Moose;

use namespace::clean -except => 'meta';

has pages => (
	isa => "ArrayRef[Imago::Schema::Role::Page]",
	is  => "ro",
);

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
