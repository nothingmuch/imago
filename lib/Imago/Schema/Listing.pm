use MooseX::Declare;

class Imago::Schema::Listing with MooseX::Clone with KiokuDB::Role::ID::Digest {
    has items => (
        traits => [qw(Array)],
        isa => "ArrayRef[Object]",
        handles => {
            items => "elements",
            item  => "get",
        },
    );

    method reorder (ArrayRef[Int] @slice) {
        my @tail = $self->items;

        my @head = delete @tail[@slice];

        return $self->clone(
            items => [ @head, @tail ],
        );
    }

    method push (@new) {
        return $self->clone(
            items => [ $self->items, @new ],
        );
    }

    method unshift (@new) {
        return $self->clone(
            items => [ @new, $self->items ],
        );
    }

    # FIXME factory should really be renderer?
    method render (%args) {
        # Imago::Web::Context :$c!, Imago::View::Template::Factory :$factory!) {
        my ( $c, $factory ) = @args{qw(context factory)};

		# FIXME yuck
		HTML::Zoom->from_html(
			join "\n", map { $factory->process($_, %args)->to_zoom->to_html } $self->items
		);
    }

    method digest_parts {
        return $self->items;
    }

    method TO_JSON {
        return [ $self->items ],
    }
}

# ex: set sw=4 et:

1;

__END__

