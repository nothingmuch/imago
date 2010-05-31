use MooseX::Declare;

use utf8;

class Imago::Web::Role::Browse with Imago::Web::Role {
    use MooseX::MultiMethods;
    use Carp;

    use Imago::Types;

    use Imago::View::Widget::Link;

    class Imago::Web::Action::Page with Imago::Web::Action {
        use Moose::Util::TypeConstraints;

        has page => (
            isa => "Str",
            is  => "ro",
            required => 1,
        );

        #has "+method" => (
        #    isa => subtype("Str", where { uc($_) eq 'GET' }),
        #);

        method path_router_args {
            return (
                page => $self->page,
            );
        }

        method query_params { return }
    }

    class Imago::Web::Action::SetLang with Imago::Web::Action::ReturnRedirect {
        has lang => (
            isa => "Str",
            is  => "ro",
            required => 1,
        );

        method path_router_args {
            return (
                lang => $self->lang,
            );
        }
    }

    method sort_order { 1 }

    method language_widgets (Imago::Web::Context $c, %langs) {
        map {
            Imago::View::Widget::Link->new(
                action => $self->lang_action(
                    lang   => $_,
                    return => $c->action->isa("Imago::Web::Action::Page")
                        # twiddle URIs with explicit language here, otherwise
                        # fallback to return URI
                        ?   $c->uri_for_args(
                                path_args => {
                                    $c->action->path_router_args,
                                    view_lang => $_,
                                },
                            )
                        : $c->return_uri,
                ),
                content => $langs{$_},
            ),
        } keys %langs;
    }

    method nav_items (Imago::Web::Context $c) {
        map {
            Imago::View::Widget::Link->new(
                action => $self->get_action($c, page => $_ ),
                # FIXME horrible horrible horrible
                # make nav_items be a static list of things?
                content => ( $_->id =~ /about/ ? Imago::Schema::String->new( en => "Home", he => "דף הבית" ) : $_->item->title ),
            ),
        } $self->default_pages;
    }

    has default_pages => (
        traits => [qw(Array)],
        isa => "ArrayRef",
        default => sub { [] },
        handles => {
            default_pages => "elements",
            add_page => "push",
            splice_pages => "splice",
        },
    );

    multi method get_action (Imago::Web::Context $c, Str :$lang!, Str :$method) {
        my $return = $c->plack_request->param("return") || '/'; # FIXME referer?

        $self->lang_action(
            lang   => $lang,
            return => $return,
        );
    }

    # FIXME move SetLang to its own UserSettings role or something
    method lang_action (@args) {
        Imago::Web::Action::SetLang->new(
            role => $self,
            @args,
        );
    }

    multi method invoke (Imago::Web::Context $c, Imago::Web::Action::SetLang $lang) {
        my $user = $c->user;

        $user->settings->lang( $lang->lang );

        # FIXME $c->save_user helper method

        my $r = $lang->return_redirection($c);

        if ( $c->user_in_storage ) {
            $c->model->update($user);
            return $r;
        } else {
            return Imago::View::Annotation->new(
                exports => [
                    $c->generate_user_auth_token->to_cookie($c->crypt),
                ],
                value => $r,
            );
        }
    }

    multi method get_action (Imago::Web::Context $c, Imago::Schema::VersionedItem :$page!, Str :$method, Str :$view_lang ) {
        my %args; # FIXME slupry
        $self->get_action($c, %args, page => $page->public_id );
    }

    multi method get_action (Imago::Web::Context $c, Str :$page, Str :$method, Str :$view_lang ) {
        my %args; # FIXME slurpy

        return Imago::Web::Action::Page->new(
            %args,
            role => $self,
            page => $page,
        );
    }

    multi method invoke (Imago::Web::Context $c, Imago::Web::Action::Page $action) {
        my $id = Imago::Schema::VersionedItem->id_for_public_item($action->page);

        if ( my $page = $c->model->lookup($id) ) {
            return $page;
        } else {
            return Imago::View::Response::HTTP->new(
                status => 404,
                body   => "Not found",
            );
        }
    }
}

# ex: set sw=4 et:

1;

__END__
