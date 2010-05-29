use MooseX::Declare;

class Imago::Web::AuthToken::UserID {
    use MooseX::MultiMethods;

    use Imago::Model::KiokuDB;
    use Crypt::Util;
    use CGI::Simple::Cookie;
    use Digest::SHA1 qw(sha1_hex);

    has id => (
        isa => "Str",
        is  => "ro",
        required => 1,
    );

    method new_from_identity ($class: Imago::Model::KiokuDB $dir, Imago::Schema::Role::UserID $id) {
        $class->new( id => $dir->object_to_id($id) );
    }

    method new_from_cookie ($class: Crypt::Util $crypt, $cookie) {
        $class->new( id => $crypt->thaw_tamper_proof_string($cookie->value) );
    }

    method to_cookie (Crypt::Util $crypt, @args) {
        return CGI::Simple::Cookie->new(
            @args,
            -name => "auth_id_" . sha1_hex($self->id),
            -value => $crypt->tamper_proof_string($self->id),
        ),
    }

    method get_user (Imago::Model::KiokuDB $dir) {
        $dir->lookup($self->id);
    }

    multi method equals (Imago::Web::AuthToken::UserID $other) {
        $self->id eq $other->id;
    }

    multi method equals ($whatever) { return 0 }
    
}

# ex: set sw=4 et:

1;

__END__
