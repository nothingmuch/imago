#!/usr/bin/perl

use strict;
use warnings;

use utf8;

use Test::More 'no_plan';

use ok 'Imago::Schema::Page::Content';
use ok 'Imago::Schema::Page';

my $obj = Imago::Schema::Page->new(
	id => "foo",
	he => Imago::Schema::Page::Content->new(
		title => "שלום",
		content => Imago::Schema::BLOB->new(
			body => "להל לה להלה"
		),
	),
	en => Imago::Schema::Page::Content->new(
		title => "Hello",
		content => Imago::Schema::BLOB->new(
			body => "moose laa"
		),
	),
);

is( $obj->kiokudb_object_id, "page:foo", "ID" );

is( $obj->en->title, "Hello", "title" );

ok( $obj->en->kiokudb_object_id, "en has ID" );

isnt( $obj->he->kiokudb_object_id, $obj->en->kiokudb_object_id, "IDs differ" );

