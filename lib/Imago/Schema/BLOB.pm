#!/usr/bin/perl

package Imago::Schema::BLOB;
use Moose;

use Moose::Util::TypeConstraints;

use namespace::clean -except => 'meta';

coerce( __PACKAGE__,
	from Str => via { __PACKAGE__->new( body => $_ ) },
);

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
