use MooseX::Declare;

use utf8;

class Imago::Web::Role::Login with Imago::Web::Role {
    use Imago::Types;

    use Encode qw(decode_utf8);
    use URI::Escape;
    use HTML::Entities;

    use Imago::View::Annotation;
    use Imago::Schema::User::ID::RPX;

    use Carp;

    use HTML::Zoom;
    use Net::API::RPX;

    class Imago::Web::Action::RPXLogin with Imago::Web::Action::ReturnRedirect {
        has token => (
            isa => "Str",
            is  => "ro",
            predicate => "has_token",
        );

        method query_params {
            return (
                ( $self->has_token ? ( token => $self->token ) : () ),
                $self->Imago::Web::Action::ReturnRedirect::query_params(),
            );
        }

        method path_router_args {
            return ( type => "rpx" );
        }
    }

    method sort_order { 10 }

    method nav_items (Imago::Web::Context $c) {
        my $rpx_uri = URI->new("https://imago.rpxnow.com/openid/v2/signin");

        # set the return URI
        my $uri = $c->uri_for( $self->rpx_action( return => $c->return_uri ) );
        $rpx_uri->query_param( token_url => $uri );

        Imago::View::Annotation->new(
            dependencies => [qw(rpx.js)],
            value =>
            $c->renderer->get_renderer_by_representation("html")->template_renderer->template_factory->new_template( # FIXME
                zoom => HTML::Zoom->from_html(q{<a class="rpxnow" onclick="return false;"></a>}),
                body => sub {
                    my ( $self, undef, %args ) = @_;

                    return (
                        sub { $_->select(".rpxnow")->add_attribute( href => "$rpx_uri" ) },
                        sub { $_->select(".rpxnow")->replace_content(
                            $self->process_for_zoom(
                                Imago::Schema::String->new(
                                    en => decode_utf8("Sign In"), # use utf8 doesn't force this
                                    he => "כניסה",
                                )->localize( $args{lang} ) # FIXME something better?
                            ),
                        ) },
                    );
                },
            ),
        );
    }

    method get_action ( Imago::Web::Context $c, :$type! where { $_ eq 'rpx' }, :$method ) {
        my $token = $c->plack_request->param("token");
        my $return = $c->plack_request->param("return");

        $self->rpx_action(
            defined($token)  ? ( token  => $token )  : (),
            defined($return) ? ( return => $return ) : (),
        );
    }

    method rpx_action (@args) {
        Imago::Web::Action::RPXLogin->new( role => $self, @args );
    }

    method get_user ( Imago::Web::Context $c, Imago::Web::Action::RPXLogin $rpx ) {
        if ( $rpx->token eq 'backdoor' ) {
            $c->model->lookup("user:nothingmuch"),
        } else {
            my $user_data = $c->rpx->auth_info({ token => $rpx->token });

            my $identifier = $user_data->{profile}{identifier};

            my $obj_id = Imago::Schema::User::ID::RPX->qualify_id($identifier);

            if ( my $identity = $c->model->lookup($obj_id) ) {
                return $identity->user;
            } else {
                return $self->reify_identity($c, $identifier, $user_data);
            }
        }
    }

    method reify_identity (Imago::Web::Context $c, Str $identifier, HashRef $user_data) {
        my $m = $c->model;

        my $user = $c->user;

        my $id = $user->new_identity(
            class => "Imago::Schema::User::ID::RPX",
            identifier => $identifier,
        );

        # FIXME other stuff?
        if ( !$user->settings->has_display_name and defined( my $name = $user_data->{profile}{displayName} ) ) {
            $user->settings->display_name($name);
        }

        if ( $c->user_in_storage ) {
            # shouldn't really happen until new authen methods are
            # supported (association of additional accounts)
            $m->insert($id);
            $m->update($user, $user->_identities); # FIXME $user->update? $model->update_user?
        } else {
            $user->remove_role( $user->get_role("login") );
            $user->add_role( $m->lookup("role:logout") );

            $m->insert($id, $user);
        }

        return $user;
    }

    method invoke ( Imago::Web::Context $c, Imago::Web::Action::RPXLogin $rpx )  {
        my $user = $self->get_user($c, $rpx);

        # FIXME this user is not the active user at any point in the request,
        # which is a bit weird, because all the rendering should be performed
        # as if it were (not that it matters for this simple redirect).
        # $c->clone( user => $user ) can be done, but the question is, what is
        # the action at that point? certainly not the login operation, as that
        # has already been done.

        return Imago::View::Annotation->new(
            exports => [
                $c->model->user_auth_token($user)->to_cookie($c->crypt),
            ],
            value => $rpx->return_redirection($c),
        );
    }
}

# ex: set sw=4 et:

1;

__END__
