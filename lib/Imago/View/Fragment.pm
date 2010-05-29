use MooseX::Declare;

class Imago::View::Fragment extends Imago::View::Element with MooseX::Param {
    use Carp;

    has '+value' => ( isa => "HashRef" );

    method init_params { $self->value }

    has [qw(additional_exports additional_dependencies)] => (
        traits => [qw(NoClone)],
        isa => "Set::Object",
        is  => "ro",
        coerce => 1,
        lazy => 1,
        default => sub { Set::Object->new },
    );

    has _sub_items => (
       traits => [qw(NoClone)],
        isa => "ArrayRef",
        is  => "ro",
        lazy_build => 1,
    );

    method _build__sub_items {
        my @items;

        # FIXME totally overkill
        use Data::Visitor::Callback;
        Data::Visitor::Callback->new(
            "Imago::View::Element" => sub { push @items, $_ },
        )->visit($self->value);

        return \@items;
    }

    method _build_dependencies {
        return $self->additional_dependencies->union(
            map { $_->dependencies }
                @{ $self->_sub_items },
        );
    }

    method _build_exports {
        return $self->additional_exports->union(
            map { $_->exports }
                @{ $self->_sub_items },
        );
    }
}

# ex: set sw=4 et:

1;

__END__
