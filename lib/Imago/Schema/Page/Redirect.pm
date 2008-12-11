#!/usr/bin/perl

package Imago::Schema::Page::Redirect;
use Moose;

use namespace::clean -except => 'meta';

has to => (
	isa => "Imago::Schema::Page|Imago::Schema::Page::Redirect",
	is  => "ro",
	required => 1,
);

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
