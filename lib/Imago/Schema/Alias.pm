use MooseX::Declare;

class Imago::Schema::Alias with KiokuDB::Role::ID::Digest {
    has to => (
        isa => "Imago::Schema::VersionedItem", # Imago::Schema::Role::Addressible ?
        is  => "ro",
    );

    method digest_parts {
        $self->to;
    }
}

# ex: set sw=4 et:

1;

__END__
