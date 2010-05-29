use MooseX::Declare;

class Imago::View::Widget::Link {
    use Carp;
    use HTML::Entities;

    use Imago::Types;

    has action => (
        does => "Imago::Web::Action",
        is   => "ro",
        required => 1,
    );

    has content => (
        is => "ro",
        required => 1,
    );

    method BUILD {
        croak "Can't link to a non GET action" unless uc($self->action->method) eq 'GET';
    }

    # FIXME factory should really be renderer?
    method render (%args) {
        # Imago::Web::Context :$c!, Imago::View::Template::Factory :$factory!) {
        my ( $c, $factory ) = @args{qw(context factory)};

        #warn "remaining args: @_";
        #my %args;

        my $zoom = HTML::Zoom->from_html(
            sprintf(
                q{<a href="%s"></a>},
                encode_entities( $c->uri_for($self->action) ),
            ),
        )->select("a")->replace_content(
            $factory->process( $self->content, %args )
        );

        if ( $c->action->equals($self->action) ) {
            return $zoom->select("a")->add_attribute( class => "active" );
        } else {
            return $zoom;
        }
    }
}

# ex: set sw=4 et:

1;

__END__
