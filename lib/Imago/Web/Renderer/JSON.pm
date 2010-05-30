use MooseX::Declare;

class Imago::Web::Renderer::JSON with Imago::Web::Renderer::Representation {
    use JSON;
    use Try::Tiny;

    has json => (
        isa => "Object",
        is  => "ro",
        default => sub {
            JSON->new->utf8->allow_blessed->convert_blessed->allow_nonref->pretty->space_after;
        }
    );

    method render ( Imago::Web::Context $c, $item ) {
        try {
            return Imago::View::BLOB->new(
                contents => $self->json->encode($item),
                type     => "application/json",
                charset  => "utf-8",
            );
        } catch {
            die "Can't render " . ref($item) . " as JSON: $_"; # FIXME real error with a code and everything
        }
    }
}

# ex: set sw=4 et:

1;

__END__

