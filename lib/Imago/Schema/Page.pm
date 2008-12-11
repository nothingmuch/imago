#!/usr/bin/perl

package Imago::Schema::Page;
use Moose;

use namespace::clean -except => 'meta';

with qw(
	Imago::Schema::Role::Page
	Imago::Schema::Role::Page::Static
);

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
