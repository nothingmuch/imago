use MooseX::Declare;

class Imago::Web::Renderer with Imago::Web::Renderer::API {
    use Imago::Util qw(timed);

    use MooseX::MultiMethods;

    use Imago::Types;

    use Imago::Web::Renderer::HTTP;
    use Imago::Web::Renderer::HTML;
    use Imago::Web::Renderer::JSON;

    use Imago::View::Redirection;

    has http_renderer => (
        isa => "Imago::Web::Renderer::HTTP",
        is  => "ro",
        default => sub { Imago::Web::Renderer::HTTP->new },
    );

    has renderers => (
        traits => [qw(Array)],
        isa => "ArrayRef[Imago::Web::Renderer::Representation]",
        default => sub { [ Imago::Web::Renderer::HTML->new, Imago::Web::Renderer::JSON->new ] },
        handles => {
            renderers => "elements",
        }
    );

    has renderers_by_representation => (
        traits => [qw(Hash)],
        isa => "HashRef[Imago::Web::Renderer::Representation]",
        lazy_build => 1,
        handles => {
            renderer_by_representation => "get",
        },
    );

    method _build_renderers_by_representation {
        return {
            map { $_->representation => $_ } $self->renderers,
        };
    }

    multi method render (Imago::Web::Context $c, Imago::View::Response::HTTP $res) {
        return $res;
    }

    multi method render (Imago::Web::Context $c, $item ) {
        my $result = $self->render_to_result($c, $item);

        timed {
            $self->http_renderer->render($c, $result);
        } "http rendering";
    }

    # results are fully self contained renderable thingies, that can be made
    # directly into an HTTP response
    multi method render_to_result (Imago::Web::Context $c, Imago::View::Result $result ) {
        return $result;
    }

    multi method render_to_result (Imago::Web::Context $c, Imago::View::Annotation $ann ) {
        return $ann->clone(
            value => $self->render_to_result($c, $ann->value),
        );
    }

    multi method render_to_result (Imago::Web::Context $c, Imago::Schema::VersionedItem $page ) {
        # FIXME feels kind of hard coded...

        if ( $page->item->isa("Imago::Schema::Alias") ) {
            return Imago::View::Redirection->new(
                uri => $c->uri_for(
                    $c->user->get_role("browse")->get_action(
                        $c,
                        page => $page->item->to,
                    ),
                ),
            );
        } else {
            return $self->render_page($c, $page);
        }
    }

    multi method render_to_result (Imago::Web::Context $c, Object $whatever ) {
        # as a fallback try to render anything else as a page
        $self->render_page($c, $whatever);
    }

    method render_page (Imago::Web::Context $c, Object $whatever) {
        timed {
        my $renderer = $self->get_renderer_by_representation(lc($c->path_ext) || "html");

        $renderer->render($c, $whatever);
        } "render_page";
    }

    # FIXME make this a B::B thing?
    method get_renderer_by_representation ( Str $ext ) {
        $self->renderer_by_representation($ext) || die "Unknown representation, can't locate renderer: $ext";
    }
}

# ex: set sw=4 et:

1;

__END__
