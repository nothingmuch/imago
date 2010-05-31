use MooseX::Declare;

class Imago::Web {
    use MooseX::MultiMethods;

    use Try::Tiny;

    use Plack::Builder;
    use Plack::App::File;
    use Plack::Request;

    use Imago::Web::Action;

    use Path::Router;
    use Net::API::RPX;
    use Crypt::Util;

    use Imago::Types;

    use Imago::Web::Context;
    use Imago::Model::KiokuDB;
    use Imago::Web::Renderer;

    use Imago::Web::Role::Browse;
    
    has router => (
        isa => "Path::Router",
        is  => "ro",
        builder => "_build_router",
    );

    has keys => (
        traits => [qw(Hash)],
        isa => "HashRef",
        default => sub {
            use YAML::XS;
            YAML::XS::LoadFile("keys.yml"); # FIXME B::B
        },
        handles => {
            get_key => "get",
        },
    );

    method _build_router {
        my $r = Path::Router->new;

        $r->add_route('/rpx' =>
            defaults => {
                role => "login",
                type => "rpx",
            }
        );

        $r->add_route('/logout' =>
            defaults => {
                role => "logout",
            }
        );

        $r->add_route('/edit/:page' =>
            defaults => {
                role => "edit",
            },
        );

        $r->add_route('/set_lang/:lang' =>
            defaults => {
                role => "browse",
            },
        );

        $r->add_route('/:view_lang/:page' =>
            defaults => {
                role => "browse",
            },
        );

        $r->add_route('/:page' =>
            defaults => {
                role => "browse",
            },
        );

        $r->add_route('/' =>
            defaults => {
                role => "browse",
                page => "index",
            },
        );

        return $r;
    }

    has rpx => (
        isa => "Net::API::RPX",
        is  => "ro",
        lazy_build => 1,
    );

    method _build_rpx {
        Net::API::RPX->new( api_key => $self->get_key("rpx") );
    }

    has crypt => (
        isa => "Crypt::Util",
        is => "ro",
        builder => "_build_crypt",
    );

    method _build_crypt {
        Crypt::Util->new( default_key => $self->get_key("crypt") )
    }

    has model => (
        isa => "Imago::Model::KiokuDB",
        is  => "ro",
        builder => "_build_model",
    );

    method _build_model {
        Imago::Model::KiokuDB->new( dsn => "dbi:SQLite:db/kiokudb.sqlite" );
    }

    has renderer => (
        isa => "Imago::Web::Renderer",
        is  => "ro",
        builder => "_build_renderer",
    );

    method _build_renderer {
        Imago::Web::Renderer->new;
    }

    method to_app {
        # force loading of everything
        #use Module::Pluggable::Object;
        #Module::Pluggable::Object->new(
        #    search_path => "Imago",
        #    require => 1,
        #)->plugins;

        builder {
            #enable "Chunked";
            #enable "Deflater";

            mount "/favicon.ico" => builder {
                Plack::App::File->new(file => 'resc/static/favicon.ico', cache_control => "public", ttl => 7 * 24 * 3600 ); # FIXME B::B abs path
            };

            mount "/static" => builder {
                Plack::App::File->new(root => "resc/static", cache_control => "public", ttl => 7 * 24 * 3600 )->to_app; # FIXME B::B abs path
            };

            mount "/" => builder {
                return sub {
                    my $env = shift;

                    use Imago::Util qw(timed);
                    timed {

                    # FIXME retry if it fails
                    #$self->model->txn_do( scope => 1, body => sub {
                    my $s = $self->model->new_scope;
                        my $res = $self->handle_request(
                            Imago::Web::Context->new(
                                # FIXME B::B
                                plack_request => Plack::Request->new($env),
                                model => $self->model,
                                crypt => $self->crypt,
                                renderer => $self->renderer,
                                router => $self->router,
                                rpx => $self->rpx,
                            ),
                        );

                        return $res || [ 404, [], [] ];
                        #});
                    } "request cycle";
                };
            }
        };
    }

    method handle_request (Imago::Web::Context $c) {
        return $c->response->to_psgi;
    }
}

# ex: set sw=4 et:

1;

__END__
