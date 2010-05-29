use MooseX::Declare;

class Imago::Web::Renderer::Template {
    use Imago::Util qw(timed);

    use MooseX::MultiMethods;

    use Imago::Types;

    use Imago::View::Template::Factory;
    use Imago::View::BLOB::Thunk;

    has template_factory => (
        isa => "Imago::View::Template::Factory",
        is  => "ro",
        default => sub {
             Imago::View::Template::Factory->new(
                dir => "resc/templates", # FIXME abs path
            ),
        },
    );

    multi method render ( Imago::Web::Context $c, Imago::View::Fragment $elem ) {
        $elem->to_annotation(
            value => $self->process_template($c, $elem),
        );
    }

    multi method render ( Imago::Web::Context $c, Imago::View::Annotation $elem ) {
        $elem->clone(
            value => $self->render($c, $elem->value),
        );
    }

    multi method render ( Imago::Web::Context $c, $item ) {
        $self->process_template($c, $item);
    }

    method process_template ( Imago::Web::Context $c, $item ) {
        # fetch timestamps from template, $item etc?
        return Imago::View::BLOB::Thunk->new(
            type => "text/html",
            charset => "utf-8",
            thunk => sub {
                timed {
                    my $mapping = timed { $self->template_factory->process( # FIXME B::B attr
                            $item,
                            context => $c,
                            lang => $c->lang,
                        );
                    } "template->process";

                    my $zoom = timed { $mapping->to_zoom } "to zoom";

                    use Encode;
                    timed { "<!doctype html>\n" . Encode::encode_utf8( $zoom->to_html ) } "to html"; # FIXME to_fh
                } "template processing";
            },
        );
    }   
}

# ex: set sw=4 et:

1;

__END__

