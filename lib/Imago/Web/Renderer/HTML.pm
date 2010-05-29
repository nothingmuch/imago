use MooseX::Declare;

class Imago::Web::Renderer::HTML with Imago::Web::Renderer::Representation {
    use Imago::Util qw(timed);

    use Imago::Types;

    use Imago::Web::Renderer::Template;
    use Imago::Web::Renderer::Page::Full;
    use Imago::Web::Renderer::Page::Fragment;

    has template_renderer => (
        isa => "Imago::Web::Renderer::Template",
        is  => "ro",
        default => sub { Imago::Web::Renderer::Template->new },
    );

    has page_renderer => (
        isa => "Imago::Web::Renderer::Page::Full",
        is  => "ro",
        default => sub { Imago::Web::Renderer::Page::Full->new },
    );

    has fragment_renderer => (
        isa => "Imago::Web::Renderer::Page::Fragment",
        is  => "ro",
        default => sub { Imago::Web::Renderer::Page::Fragment->new },
    );

    method render ( Imago::Web::Context $c, $item ) {
        my $fragment = timed { $self->fragment_renderer->render($c, $item) } "fragment";

        my $page = timed { $self->page_renderer->render( $c, $fragment ) } "page";

        return timed { $self->template_renderer->render( $c, $page ) } "template";
    }
}

# ex: set sw=4 et:

1;

__END__

