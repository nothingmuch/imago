use MooseX::Declare;

class Imago::View::Template {
    use Carp;

    use Imago::View::Mapping;

    has name => (
        isa => "Str",
        is  => "ro",
        predicate => "has_name",
    );

    has factory => (
        isa => "Imago::View::Template::Factory",
        is  => "ro",
        required => 1,
        weak_ref => 1,
        handles => [qw(process process_for_zoom)],
    );

    has zoom => (
        isa => "HTML::Zoom",
        is  => "ro",
    );

    has body => (
        isa => "CodeRef",
        is  => "ro",
    );

    method create_mapping ($item, @args) {
        my $body = $self->body;

        use Imago::Util qw(timed);

        timed {

        return Imago::View::Mapping->new(
            zoom => $self->zoom,
            mappings => [
                $self->$body(
                    $item,
                    @args,
                ),
            ],
        );
        } "template body";
    }
}

# ex: set sw=4 et:

1;

__END__
