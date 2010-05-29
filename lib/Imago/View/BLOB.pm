use MooseX::Declare;

class Imago::View::BLOB with Imago::View::Result {
    use Encode qw(encode);
    use MooseX::Types::Buf;
    use MooseX::Types::Moose qw(Str Int Object ArrayRef);
    use Moose::Util::TypeConstraints qw(enum);

    use Plack::MIME;

    use Carp;

    method BUILD {
        $self->type;
    }

    has contents => (
        isa => "Buf", # FIXME MX::Types
        is  => "ro",
        required => 1,
    );

    has type => (
        isa => "Buf",
        is  => "ro",
        lazy_build => 1,
    );

    has charset => (
        isa => Str,
        is  => "ro",
        predicate => "has_charset",
    );

    method _build_type {
        croak "Can't guess type without a filename" unless $self->has_name;

        if ( my $type = Plack::MIME->mime_type($self->name) ) {
            return $type;
        } else {
            croak "Can't guess type of filename " . $self->name;
        }
    }

    has name => (
        isa => Str,
        is  => "ro",
        predicate => "has_name",
    );

    has disposition => (
        isa => enum([qw(inline attachment)]),
        is  => "ro",
        predicate => "has_disposition",
    );

    method headers {
        return (
            $self->type_header,
            $self->length_header,
            $self->disposition_header,
        );
    }

    method length_header {
        return (
            "Content-Length" => length($self->contents),
        );
    }

    method disposition_header {
        return unless $self->has_disposition or $self->has_name;

        my $disposition = $self->disposition || "attachment";

        my $name = $self->name;

        $disposition .= "; filename=" . encode('MIME', $name);

        return "Content-Disposition" => $disposition;
    }

    method type_header {
        return (
            "Content-Type" => ( $self->has_charset ? sprintf("%s; charset=%s", $self->type, $self->charset) : $self->type ),
        );
    }
}

# ex: set sw=4 et:

__PACKAGE__

__END__

