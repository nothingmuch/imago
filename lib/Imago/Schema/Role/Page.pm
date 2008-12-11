#!/usr/bin/perl

package Imago::Schema::Role::Page;
use Moose::Role;

use namespace::clean -except => 'meta';

requires "process";

with qw(KiokuDB::Role::ID);

sub kiokudb_object_id { "page:" . shift->id }

has id => (
	isa => "Str",
	is  => "ro",
	required => 1,
);

__PACKAGE__

__END__


