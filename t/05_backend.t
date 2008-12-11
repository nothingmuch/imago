#!/usr/bin/perl

use strict;
use warnings;

use utf8;

use Test::More 'no_plan';
use Test::Exception;

use ok 'Imago::Backend::KiokuDB';

use Test::TempDir;

my $dir = tempdir;

my $backend = Imago::Backend::KiokuDB->new(
	dsn => "bdb:dir=$dir",
	extra_args => { create => 1 },
);

lives_ok {
	$backend->txn_do(sub {
		my $scope = $backend->new_scope;

		$backend->insert(
			Imago::Schema::Page->new(
				id => "index",
				en => Imago::Schema::Page::Static::Content->new(
					title => "main",
					content => Imago::Schema::BLOB->new(
						body => "foo",
					),
				),
				he => Imago::Schema::Page::Static::Content->new(
					title => "ikari",
					content => Imago::Schema::BLOB->new(
						body => "bar",
					),
				),
			),
		),

		$backend->insert(
			Imago::Schema::Page->new(
				id => "foo",
				en => Imago::Schema::Page::Static::Content->new(
					title => "foo",
					content => Imago::Schema::BLOB->new(
						body => "lala",
					),
				),
				he => Imago::Schema::Page::Static::Content->new(
					title => "פוו",
					content => Imago::Schema::BLOB->new(
						body => "להלה",
					),
				),
			),
		),
	});
} "transaction lived";

{
	my $scope = $backend->new_scope;

	ok( my $index = $backend->index, "look up index" );

	ok( my $foo = $backend->page("foo"), "look up foo" );

	ok( !$backend->page("lalala"), "no lalala page" );

	is( $index->en->title, "main", "content" );
}


