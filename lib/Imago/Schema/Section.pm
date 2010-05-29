use MooseX::Declare;

class Imago::Schema::Section with KiokuDB::Role::ID::Digest with MooseX::Clone {
    use KiokuDB::Class;

	use Imago::Types;

    use Imago::Schema::String;

    has title => (
        isa => "Imago::Schema::String",
        is  => "ro",
        coerce => 1,
        required => 1,
    );

	has body => (
		isa => "Object",
		is  => "ro",
		required => 1,
	);

    sub digest_parts {
        my $self = shift;

        return ( $self->title, $self->body );
    }

    method TO_JSON {
        return {
            title => $self->title,
            body  => $self->body,
        },
    }
}

# ex: set sw=4 et:

1;

__END__

