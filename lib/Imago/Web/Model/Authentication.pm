package Imago::Web::Model::Authentication;
use Moose;

use Imago::Web::Model::Authentication::UserWrapper;

use namespace::clean -except => "meta";

sub BUILDARGS {
    my ($class, $config, $app, $realm) = @_;

    return {
		app   => $app,
		realm => $realm,
		%$config,	
	};
}

sub from_session {
    my ( $self, $c, $id ) = @_;

    my $user = $c->model('kiokudb')->user($id);

    return Imago::Web::Model::Authentication::UserWrapper->new(
        user_object => $user,
    );        
}

sub find_user {
    my ( $self, $userinfo, $c ) = @_;

    my $id = $userinfo->{id};
    return $self->from_session($c, $id);
}

1;

