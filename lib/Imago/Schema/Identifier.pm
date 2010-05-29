use MooseX::Declare;

class Imago::Schema::Identifier with KiokuDB::Role::ID {
    has id => (
        isa => "Str",
        is  => "ro",
        required => 1,
    );

    method kiokudb_object_id { $self->id }

    has object => (
        isa => "Ref",
        is  => "ro",
        required => 1,
    );
}

# ex: set sw=4 et:

1;

__END__
