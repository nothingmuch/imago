use MooseX::Declare;

class Imago::Schema::Link with KiokuDB::Role::ID::Digest with MooseX::Clone {
    use Imago::Types;
    use MooseX::Types::URI qw(Uri);

    has title => (
        isa => "Imago::Schema::String",
        is  => "ro",
        coerce => 1,
        predicate => "has_title",
    );

    has description => (
        isa => "Imago::Schema::TextOrHTML",
        is  => "ro",
        coerce => 1,
        predicate => "has_description",
    );

    has uri => (
        isa => Uri,
        is  => "ro",
        # required => 1, # FIXME fix the data
        coerce => 1,
    );

    method digest_parts {
        return (
            $self->title,
            $self->description,
            ( $self->uri ? $self->uri->as_string : undef ),
        );
    }

    method TO_JSON {
        return {
            ( $self->has_title ? ( title => $self->title ) : () ),
            ( $self->has_description ? ( description => $self->description ) : () ),
            ( $self->uri ? ( uri => $self->uri->as_string ) : () ),
        };
    }
}

# ex: set sw=4 et:

1;

__END__
