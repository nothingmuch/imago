#!/usr/bin/perl

use strict;
use warnings;

use utf8;

use Test::More;

use ok 'Imago::Schema::Document';

my $p = Imago::Schema::Document->new(
    title => {
        en => "About",
        he => "אודות",
    },
    body => {
        en => "<p>some blurb</p>",
        he => "<p>שטויות</p>",
    },
);

isa_ok( $p, "Imago::Schema::Document" );

isa_ok( $p->title, "Imago::Schema::String" );
is( "".$p->title, "About", "title" );

done_testing;

# ex: set sw=4 et:

