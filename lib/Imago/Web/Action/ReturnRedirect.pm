use MooseX::Declare;

role Imago::Web::Action::ReturnRedirect with Imago::Web::Action {
    use Imago::View::Redirection;

    use MooseX::Types::URI qw(Uri);

    has return => (
        isa => Uri,
        is  => "ro",
        coerce => 1,
        predicate => "has_return",
    );

    method return_redirection (Imago::Web::Context $c) {
        return Imago::View::Redirection->new(
            uri => $self->return_uri($c),
        );
    }

    method return_uri (Imago::Web::Context $c) {
        # we have an explicit return URI
        if ( $self->has_return ) {
            return $self->return;
        }

        my $base = $c->plack_request->base;

        # otherwise redirect back to the referring page
        #if ( my $ref = $c->plack_request->referer ) { # yuck, misspelled
        #   my $uri = URI->new_abs($ref, $base);

        #   if ( not $uri->rel($base)->eq($uri) ) {
        #       return URI->new($ref);
        #   }
        #}

        # otherwise the site root will do
        return $base;
    }

    method query_params {
        return (
            ( $self->has_return ? ( return => $self->return->as_string ) : () ),
        );
    }
}

# ex: set sw=4 et:

1;

__END__

