use MooseX::Declare;

class Imago::Web::AuthToken::User {
    use MooseX::MultiMethods;

    use JSON;

    use Crypt::Util;
    use CGI::Simple::Cookie;

    use Imago::Model::KiokuDB;
    use Imago::Schema::User;

    has data => (
        isa => "Str",
        is  => "ro",
        required => 1,
    );

    method new_from_user ($class: Imago::Model::KiokuDB $dir, Imago::Schema::User $user) {
        #warn "creating user auth token from $user";
        if ( $dir->live_objects->object_to_entry($user) ) {
            $class->new( data => encode_json( { id => $dir->object_to_id($user) } ) );
        } else {
            my $hash = $user->settings->as_hash;

            $class->new( data => encode_json( { settings => $user->settings->as_hash } ) );
        }
    }

    method new_from_cookie ($class: Crypt::Util $crypt, $cookie) {
        $class->new( data => $crypt->thaw_tamper_proof_string($cookie->value) );
    }

    method to_cookie (Crypt::Util $crypt, @args) {
        return CGI::Simple::Cookie->new(
            @args,
            -name => "auth_user",
            -value => $crypt->tamper_proof_string($self->data),
        ),
    }

    method get_user (Imago::Model::KiokuDB $dir) {
        my $data = decode_json($self->data);

        if ( my $id = $data->{id} ) {
            return $dir->lookup($id);
        } elsif ( my $settings = $data->{settings} ) {
            return $dir->new_anonymous_user( settings => Imago::Schema::User::Settings->new($settings) );
        } else {
            die "Invalid user token";
        }
    }

    multi method equals (Imago::Web::AuthToken::User $other) {
        #warn "equals?\n" . $self->data . "\n" . $other->data;
        $self->data eq $other->data;
    }

    multi method equals ($whatever) { return 0 }
}

# ex: set sw=4 et:

1;

__END__
