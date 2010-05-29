package Imago::Schema::String;
use Moose;

use MooseX::Clone::Meta::Attribute::Trait::NoClone;

extends qw(Imago::Schema::MultiLingualString);

with qw(
    KiokuDB::Role::Intrinsic
    KiokuDB::Role::WithDigest
);

# not a MooseX::Declare class because of the has +digest is on a role attr
# this is done to skip serialization of the digest in intrinsic objects, where
# it serves no purpose but to compute the digest of containing objects
has "+digest" => ( traits => [qw(KiokuDB::DoNotSerialize NoClone)] );

__PACKAGE__->meta->make_immutable;

# ex: set sw=4 et:

__PACKAGE__

__END__
