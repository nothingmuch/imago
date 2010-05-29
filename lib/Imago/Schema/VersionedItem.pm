use MooseX::Declare;

class Imago::Schema::VersionedItem with KiokuDB::Role::ID {
    use Carp;
    use Imago::Schema::VersionedItem::Version;

    has id => (
        isa => "Str",
        is  => "ro",
        required => 1,
    );

    method kiokudb_object_id {
        return $self->id;
    }

    has version => (
        isa => "Imago::Schema::VersionedItem::Version",
        is  => "ro",
        writer => "_set_version",
        required => 1,
        coerce => 1,
        handles => [qw(item)],
    );

    method update (Object $item, @args ) {
        $self->_set_version( $self->new_version(@args) );
    }

    method new_version (Object $item, @args ) {
        $self->version->derive(
            item => $item,
            @args,
        );
    }

    method public_id {
        my $id = $self->id;

        if ( $id =~ s/^public:// ) {
            return $id;
        } else {
            croak "Not a public item";
        }
    }

    method id_for_public_item ($class: Str $id ) {
        return "public:$id";
    }

    method TO_JSON {
        return {
            id => $self->id,
            data => $self->item,
        };
    }
}

# ex: set sw=4 et:

1;

__END__

