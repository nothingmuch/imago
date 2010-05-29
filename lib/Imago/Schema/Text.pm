use MooseX::Declare;
use Imago::Types;

class Imago::Schema::Text extends Imago::Schema::MultiLingualString with KiokuDB::Role::ID::Digest {
    has type => (
        isa => "Str",
        is  => "ro",
        predicate => "has_type",
    );

    method digest_parts {
        return (
            $self->SUPER::digest_parts(),
            $self->type,
        );
    }
}

# ex: set sw=4 et:

1;

__END__
