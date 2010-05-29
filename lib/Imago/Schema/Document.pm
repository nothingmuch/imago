use MooseX::Declare;

class Imago::Schema::Document extends Imago::Schema::Section {
    use KiokuDB::Class;

    use Imago::Types;

    use Imago::Schema::HTML;

    has '+body' => (
        traits => [qw(KiokuDB::Lazy)],
        isa => "Imago::Schema::HTML",
        coerce => 1,
        required => 1,
    );

    method digest_parts {
        return ( $self->title, $self->body );
    }
}

# ex: set sw=4 et:

1;

__END__
