#!/usr/bin/perl

package Imago::Role::DigestID;
use Moose::Role;

use Digest::SHA qw(sha1_hex);

use namespace::clean -except => 'meta';

with qw(KiokuDB::Role::ID);

sub kiokudb_object_id { shift->digest }

has digest => (
    isa => "Str",
    is  => "ro",
    lazy_build => 1,
);

requires 'digest_parts';

sub _build_digest {
    my $self = shift;

    sha1_hex( join ":",
        ref($self),
        map { ref($_) ? $_->kiokudb_object_id : $_ } $self->digest_parts,
    );
}

__PACKAGE__

__END__


