#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use utf8;

use ok 'Imago::Schema::String';
use ok 'Imago::Schema::Text';

foreach my $class ( qw(Imago::Schema::String Imago::Schema::Text) ) {

    my $s = $class->new( "en" => "Hello", "he" => "שלום" );

    isa_ok($s, $class);

    is("$s", "Hello", "Stringifies");

    is( $s->get("he"), "שלום", "explicit get" );

    ok( $s->digest, "has digest" );

    my $s2 = $s->add( "en-US" => "Howdy" );

    isa_ok( $s2, $class );

    isnt( $s2->digest, $s->digest, "digests differ" );
}

done_testing;

# ex: set sw=4 et:

