use MooseX::Declare;

class Imago::Model::KiokuDB extends KiokuX::Model {
    use Imago::Types;

    method get_user_from_tokens (@tokens) {
        # FIXME validate that all tokens are equivalent?
        foreach my $token ( @tokens ) {
            if ( my $user = $token->get_user($self) ) {
                return $user;
            }
        }
    }

    method identity_auth_token (Imago::Schema::Role::UserID $id) {
        return Imago::Web::AuthToken::UserID->new_from_identity($self, $id);
    }

    method user_auth_token (Imago::Schema::User $user) {
        return Imago::Web::AuthToken::User->new_from_user($self, $user);
    }

    method new_anonymous_user (@args) {
        my $user = $self->lookup("user:anonymous");

        # FIXME forces loading of sets to avoid missing ->clone on Set::Deferred
        # FIXME split up anon from normal users? $anon->reify(@args) ?
        return $user->clone(
            roles => [ $user->roles ],
            identities => [ ],
            @args,
        );
    }
}

# ex: set sw=4 et:

1;

__END__
