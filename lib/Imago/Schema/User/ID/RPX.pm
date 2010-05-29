use MooseX::Declare;

class Imago::Schema::User::ID::RPX with Imago::Schema::Role::UserID {
    has identifier => (
        isa => "Str",
        is  => "ro",
        required => 1,
    );

    method id {
        $self->identifier;
    }
}

# ex: set sw=4 et:

1;

__END__
