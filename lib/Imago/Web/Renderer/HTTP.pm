use MooseX::Declare;

class Imago::Web::Renderer::HTTP {
    use MooseX::MultiMethods;

    use Imago::Types;

    use Imago::View::Response::HTTP;

    multi method render ( Imago::Web::Context $c, Imago::View::Element $elem ) {
        my @exports = $elem->exports->members;

        # FIXME other header types exist too...
        my @cookies = grep { blessed($_) && $_->isa("CGI::Simple::Cookie") } @exports;

        my $res = $self->render($c, $elem->value);

        return $res->add_cookies(@cookies);
    }

    multi method render ( Imago::Web::Context $c, $whatever ) {
        Imago::View::Response::HTTP->new_from_whatever($whatever);
    }
}

# ex: set sw=4 et:

1;

__END__

