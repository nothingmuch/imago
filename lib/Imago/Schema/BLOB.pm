#!/usr/bin/perl

package Imago::Schema::BLOB;
use Moose;

use namespace::clean -except => 'meta';

with qw(Imago::Role::DigestID);

has body => (
    isa => "Str",
    is  => "ro",
    required => 1,
);

sub digest_parts { shift->body }

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
