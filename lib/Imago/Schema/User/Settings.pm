use MooseX::Declare;

class Imago::Schema::User::Settings with MooseX::Clone with KiokuDB::Role::Intrinsic {
    has lang => (
        isa => "Str",
        is  => "rw",
        predicate => "has_lang",
    );

    has display_name => (
        isa => "Str", # FIXME localizable?
        is  => "rw",
        predicate => "has_display_name",
    );

    method as_hash {
        return {
            ( $self->has_lang ? ( lang => $self->lang ) : () ),
            ( $self->has_display_name ? ( display_name => $self->display_name ) : () ),
        },
    }

    method modified {
        scalar keys %{ $self->as_hash };
    }
}

# ex: set sw=4 et:

1;

__END__
