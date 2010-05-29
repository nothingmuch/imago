use MooseX::Declare;

class Imago::Schema::User with MooseX::Clone {
    use Carp;
    use KiokuDB::Set; # type constraint
    use KiokuDB::Util qw(set);

    use Imago::Schema::User::Settings;
    use Imago::Web::Role;

    has identities => (
        traits => [qw(Clone)],
        isa => "KiokuDB::Set",
        coerce => 1,
        lazy_build => 1,
        reader => "_identities",
        handles => {
            identities => "members",
            add_identity => "insert",
            remove_identity => "remove",
        },
    );

    method _build_identities { return set() }

    has roles => (
        traits => [qw(Clone)],
        isa => "KiokuDB::Set",
        required => 1,
        coerce => 1,
        handles => {
            roles => "members",
            add_role => "insert",
            remove_role => "remove",
        },
    );

    method get_role ( Str $name ) {
        foreach my $role ( $self->roles ) {
            if ( $role->name eq $name ) {
                return $role;
            }
        }

        croak "No user role: $name";
    }

    has settings => (
        # FIXME clone?
        isa => "Imago::Schema::User::Settings",
        is  => "ro",
        default => sub { Imago::Schema::User::Settings->new },
    );

    method display_name {
        if ( $self->settings->has_display_name ) {   
            return $self->settings->display_name;
        } else {
            return "Anonymous"; # FIXME localizable?
        }
    }

    method new_identity (%args) { # ClassName :$class!, %args # FIXME slurpy
        my $class = delete $args{class};

        my $identity = $class->new(
            user => $self,
            %args,
        );

        if ( blessed($identity) and $identity->does("Imago::Schema::Role::UserID") ) {
            $self->add_identity($identity);
            return $identity;
        } else {
            croak "${class}->new(...) did not return an Imago::Schema::Role::UserID";
        }
    }
}

# ex: set sw=4 et:

1;

__END__
