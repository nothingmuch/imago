use MooseX::Declare;

class Imago::Schema::VersionedItem::Version with KiokuDB::Role::ID::Digest with MooseX::Clone {
    use KiokuDB::Class;
    use Moose::Util::TypeConstraints;

    use DateTime;

    coerce __PACKAGE__, from "Object", via { __PACKAGE__->new( item => $_ ) };

    has item => (
        traits => [qw(NoClone)],
        isa => "Object",
        is  => "ro",
        required => 1,
    );

    has previous => (
        traits => [qw(NoClone KiokuDB::Lazy)],
        isa => __PACKAGE__,
        is  => "ro",
        predicate => "has_previous",
    );

    has comment => (
        isa => "Str",
        is  => "ro",
        predicate => "has_comment",
    );

    has date => (
        traits => [qw(NoClone)],
        isa => "DateTime",
        is  => "ro",
        default => sub { DateTime->now },
    );

    has author => (
        traits => [qw(NoClone)],
        isa => "Imago::Schema::User",
        is  => "ro",
        predicate => "has_author",
    );

    method derive (%args) {
        $self->clone(
            previous => $self,
            %args,
        );
    }

    method digest_parts {
        return (
            $self->item,
            $self->previous,
            # $self->author, # FIXME KiokuDB::ID attr trait
            ($self->author ? ($self->author->identities)[0] : undef ),
            $self->date->iso8601,
            $self->comment,
        );
    }
}

# ex: set sw=4 et:

1;

__END__

