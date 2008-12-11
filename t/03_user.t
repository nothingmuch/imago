#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use Authen::Passphrase::Clear;

use ok 'Imago::Schema::User';

my $user = Imago::Schema::User->new(
	id => "foo",
	password => Authen::Passphrase::Clear->new("foo"),
	real_name => "Foo Bar",
);

is( $user->kiokudb_object_id, "user:foo", "ID" );

ok( $user->check_password("foo"), "password" );

ok( !$user->check_password("bar"), "bad password" );


