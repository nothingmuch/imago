use MooseX::Declare;

class Imago::Web::Renderer::Page::Full {
    use Imago::Util qw(timed);

    use Imago::Types;

    use Imago::View::Fragment;

    # just wraps anything in the standard HTML page boilerplate
    # dependencies and exports take care of everythign else

    method render ( Imago::Web::Context $c, $resource_fragment ) {
        # FIXME move to somewhere more sensible (nav.pl?)
        my @nav = timed {
            map { $_->nav_items($c) }
                sort { $a->sort_order <=> $b->sort_order }
                    grep { $_->can("nav_items") } # FIXME WithNav and Sortable roles?
                        $c->user->roles;
        } "nav menu";

        my $lang_widget = timed { Imago::View::Fragment->new(
            value => {
                template => "langswitcher",
                languages => [
                    $c->user->get_role("browse")->language_widgets($c, $c->available_languages )
                ],
            },
        ) } "lang widget";

        my $nav_fragment = Imago::View::Fragment->new(
            value => {
                template => "nav",
                menu     => \@nav,
                langswitcher => $lang_widget,
            },
        );

        # the HTML renderer wraps this in a top level fragment for standard rendering
        # under an ajax request this would be omitted
        return Imago::View::Fragment->new(
            value => {
                template => "wrapper",
                contents => $resource_fragment,
                nav      => $nav_fragment,
            },
        );
    }
}

# ex: set sw=4 et:

1;

__END__

