#!/usr/bin/perl

package Imago::Schema::Link;
use Moose;

use MooseX::Types::URI qw(Uri);

use namespace::clean -except => 'meta';

has [qw(title en_description he_description)] => (
	isa => "Str",
	is  => "ro",
	required => 1,
);

has uri => (
	isa => Uri,
	is  => "ro",
	coerce   => 1,
	required => 1,
);

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
