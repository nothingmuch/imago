#!/usr/bin/perl

package Imago::Schema::Page;
use Moose;

use Imago::Schema::Page::Content;

use namespace::clean -except => 'meta';

with qw(KiokuDB::Role::ID);

sub kiokudb_object_id { "page:" . shift->id }

has id => (
	isa => "Str",
	is  => "ro",
	required => 1,
);

has [qw(en he)] => (
	isa => "Imago::Schema::Page::Content",
	is  => "ro",
	required => 1,
);

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
