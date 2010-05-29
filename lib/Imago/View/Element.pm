use MooseX::Declare;

class Imago::View::Element with MooseX::Clone {
    use Set::Object;
    use MooseX::Types::Set::Object;

    #use Imago::View::Annotation # circular dep, required below instead

    has value => (
        required => 1,
        is => "ro",
    );

    has [qw(exports dependencies)] => (
        isa => "Set::Object",
        is  => "ro",
        coerce => 1,
        lazy_build => 1,
    );

    method _build_dependencies { Set::Object->new }

    method _build_exports { Set::Object->new }

    method to_annotation (@args) {
        Imago::View::Annotation->new(
            dependencies => Set::Object->new( $self->dependencies->members ),
            exports      => Set::Object->new( $self->exports->members ),
            @args,
        );
    }
}

require Imago::View::Annotation; # circular dep

# ex: set sw=4 et:

1;

__END__
