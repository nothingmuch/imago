use MooseX::Declare;

use utf8;

class Imago::Web::Context with MooseX::Clone {
    use Imago::Util qw(timed);

    use CGI::Simple::Cookie;
    use Try::Tiny;

    use I18N::AcceptLanguage;

    use MooseX::Types::URI qw(Uri);

    use Imago::Web::AuthToken::User;
    use Imago::Web::AuthToken::UserID;

    # FIXME these are all IOC things from B::B

    has rpx => (
        isa => "Net::API::RPX",
        is  => "ro",
        required => 1,
    );

    has router => (
        isa => "Path::Router",
        is  => "ro",
        required => 1,
    );

    has crypt => (
        isa => "Crypt::Util",
        is  => "ro",
        required => 1,
    );

    has renderer => (
        isa => "Imago::Web::Renderer",
        is  => "ro",
        required => 1,
    );

    has model => (
        isa => "Imago::Model::KiokuDB",
        is  => "ro",
        required => 1,
    );

    method available_languages {
        return (
            en => "English",
            he => "עברית",
        );
    }

    has lang => (
        isa => "Str",
        is  => "ro",
        lazy_build => 1,
    );

    method _build_lang {
        if ( my $lang = $self->user->settings->lang ) {
            return $lang;
        } elsif ( my $accept = $self->header("Accept-Lanaguage") ) {
            # FIXME B::B
            return I18N::AcceptLanguage->new( defaultLanuage => "he" )->accepts(
                $accept,
                [qw(he en)],
            );
        } else {
            return "he";
        }
    }

    has plack_request => (
        is  => "ro",
        isa => "Plack::Request",
        required => 1,
        handles => [qw(header)],
    );

    has return_uri => (
        traits => [qw(NoClone)],
        isa => Uri,
        is  => "ro",
        lazy_build => 1,
    );

    method _build_return_uri {
        $self->uri_for( $self->action );
    }

    # FIXME B::B
    has representation_exts => (
        traits => [qw(Array)],
        isa => "ArrayRef[Str]",
        default => sub { [qw(html rss json) ] },
        handles => {
            representation_exts => "elements",
        },
    );

    has _rep_exts_re => (
        isa => "RegexpRef",
        is  => "ro",
        lazy_build => 1,
    );

    method _build__rep_exts_re {
        my $alts = join "|", map { quotemeta } $self->representation_exts;
        return qr{ \. ($alts) $ }x;
    }

    has [qw(path_basename path_ext)] => (
        isa => "Str",
        is  => "ro",
        lazy_build => 1,
    );

    method _build_path_basename {
        my $path = $self->plack_request->path;

        my $re = $self->_rep_exts_re;
        $path =~ s/$re//;

        return $path;
    }

    method _build_path_ext {
        my $path = $self->plack_request->path;

        if ( $path =~ $self->_rep_exts_re ) {
            return $1;
        } else {
            return "";
        }
    }

    method uri_for (Imago::Web::Action $action, @args) {
        my $path = $self->router->uri_for(
            role => $action->role->name,
            $action->path_router_args,
        ) or die "No URI in router for $self";

        return $self->uri_for_path( $path, [ $action->query_params ], @args );
    }

    method uri_for_path ( Str $path, ArrayRef $query_params, :$representation ) {
        my $uri = $self->plack_request->base->clone;

        $uri->path( $uri->path . $path . ( $representation ? ".$representation" : "" ) );

        if ( @$query_params ) {
            $uri->query_form(@$query_params);
        }

        return $uri;
    }

    has action => (
        traits => [qw(NoClone)],
        does => "Imago::Web::Action",
        is   => "ro",
        lazy_build => 1,
    );

    method _build_action {
        timed { $self->get_action( path => $self->path_basename, method => $self->plack_request->method ) } "Get action";
    }

    method get_action ( Str :$path, Str :$method = "GET" ) {
        exit if $path =~ /exit$/; # FIXME

        my $match = $self->router->match($path) or return; # 404

        my %args = %{ $match->mapping };

        my $role = $self->user->get_role(delete $args{role}) or die "forbidden"; # 403

        my $action = $role->get_action(
            $self,
            method => uc($self->plack_request->method),
            %args,
        ) or die "Forbidden";

        return $action;
    }

    has action_result => (
        traits => [qw(NoClone)],
        is => "ro",
        lazy_build => 1,
    );

    method _build_action_result {
        # FIXME try, defatalize user errors
        timed { $self->action->invoke($self) } "action application";
    }

    has response => (
        isa => "Imago::View::Response::HTTP",
        traits => [qw(NoClone)],
        is => "ro",
        lazy_build => 1,
    );

    method _build_response {
        timed { $self->renderer->render($self, $self->action_result) } "rendering";
    }

    method user_in_storage {
        return defined( $self->model->live_objects->object_to_entry($self->user) );
    }

    has user => (
        traits => [qw(NoClone)],
        isa => "Imago::Schema::User",
        is  => "ro",
        lazy_build => 1,
    );

    method _build_user {
        if ( my $user_token = $self->user_auth_token ) {
            if ( my $user = try { $self->model->get_user_from_tokens($self->user_auth_token) } ) {
                return $user;
            } else {
                #die "shouldn't happen";
            }
        }

        if ( my @id_tokens = $self->auth_tokens ) {
            # verified IDs might not have a user associated
            if ( my $user = try { $self->model->get_user_from_tokens(@id_tokens) } ){
                return $user;
            }
        }

        # otherwise generate a new user    
        return $self->model->new_anonymous_user;
    }

    has user_auth_token => (
        traits => [qw(NoClone)],
        isa => "Maybe[Imago::Web::AuthToken::User]",
        is  => "ro",
        lazy_build => 1,
    );

    method has_valid_user_auth_token { defined $self->user_auth_token }

    method _build_user_auth_token {
        if ( my $user_auth_cookie = $self->cookie("auth_user") ) {
            return try { Imago::Web::AuthToken::User->new_from_cookie( $self->crypt, $user_auth_cookie ) } catch {
                warn "error: $_";
                return undef;
            };
        } else {
            return undef;
        }
    }

    method generate_user_auth_token {
        $self->model->user_auth_token( $self->user );
    }

    has auth_tokens => (
        traits => [qw(NoClone Array)],
        isa => "ArrayRef[Imago::Web::AuthToken::UserID]",
        lazy_build => 1,
        handles => {
            auth_tokens => "elements",
        },
    );

    method _build_auth_tokens {
        my @auth_token_cookies = grep { $_->name =~ /^auth_id_/ } $self->cookies;
        
        return [ map {
            try { Imago::Web::AuthToken::UserID->new_from_cookie( $self->crypt, $_ ) };
        } @auth_token_cookies ];
    }

    has auth_cookies => (
        traits => [qw(Hash NoClone)],
        isa => "HashRef[CGI::Simple::Cookie]",
        lazy_build => 1,
        handles => {
            auth_cookie => "get",
            auth_cookies => "values",
        },
    );

    method _build_auth_cookies {
        return { map { $_->name => $_ } grep { $_->name =~ /^auth_(?:user$|id_)/ } $self->cookies };
    }

    has cookies => (
        traits => [qw(Hash NoClone)],
        isa => "HashRef[CGI::Simple::Cookie]",
        lazy_build => 1,
        handles => {
            cookie => "get",
            cookies => "values",
        },
    );

    method _build_cookies {
        return { CGI::Simple::Cookie->parse( $self->plack_request->env->{HTTP_COOKIE} ) };
    }
}

# ex: set sw=4 et:

1;

__END__
