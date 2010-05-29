use MooseX::Declare;

class Imago::Web::Role::Logout with Imago::Web::Role {
    use Imago::Types;

    use MooseX::MultiMethods;
    use Carp;

    use HTML::Zoom;

    class Imago::Web::Action::Logout with Imago::Web::Action::ReturnRedirect {
        method path_router_args { return () }
    }

    method sort_order { 11 }

    method nav_items (Imago::Web::Context $c) {
        my $uri = $c->uri_for( $self->logout_action( return => $c->return_uri ) );
        return HTML::Zoom->from_html( sprintf q{Hello, %s, <a href="%s">Sign Out</a>}, $c->user->display_name, $uri );
    }

    method get_action ( Imago::Web::Context $c, :$method ) {
        my $return = $c->plack_request->param("return");

        $self->logout_action(
            defined($return) ? ( return => $return ) : (),
        );
    }

    method logout_action (@args) {
        Imago::Web::Action::Logout->new( role => $self, @args );
    }

    method invoke ( Imago::Web::Context $c, Imago::Web::Action::Logout $logout )  {
        return Imago::View::Annotation->new(
            exports => [
                map {
                    CGI::Simple::Cookie->new(
                        -name => $_->name,
                        -value => "",
                        -expires => "-1y",
                    )
                } $c->auth_cookies,
            ],
            value => $logout->return_redirection($c),
        );
    }
}

# ex: set sw=4 et:

1;

__END__
