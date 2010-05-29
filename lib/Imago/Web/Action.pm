use MooseX::Declare;

role Imago::Web::Action {
    use Imago::Types;

    requires qw(path_router_args query_params);

    has method => (
        isa => "Str",
        is  => "ro",
        default => "GET",
    );

    has role => (
        does => "Imago::Web::Role",
        is   => "ro",
        required => 1,
    );

    method invoke (Imago::Web::Context $c) {
        $self->role->invoke($c, $self);
    }

    # FIXME very crude
    method equals (Imago::Web::Action $other) {
        use JSON;

        return (
            encode_json([
                [ $self->path_router_args ],
                [ $self->query_params ],
                $self->method,
            ])
            eq
            encode_json([
                [ $other->path_router_args ],
                [ $other->query_params ],
                $other->method,
            ])
        );
    }
}

# ex: set sw=4 et:

1;

__END__
