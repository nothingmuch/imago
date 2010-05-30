use utf8;

use MooseX::Declare;

class Imago::Script::InitDB with MooseX::Runnable with MooseX::Getopt {
    use Imago::Model::KiokuDB;

    use Imago::Schema::VersionedItem;
    use Imago::Schema::VersionedItem::Version;

    use Path::Class;
    use MooseX::YAML qw(LoadFile);

    use MooseX::Types::Path::Class qw(Dir File);

    has model => (
        isa => "Imago::Model::KiokuDB",
        is  => "ro",
        lazy_build => 1,
    );

    has clear => (
        isa => "Bool",
        is  => "ro",
        default => 0,
    );

    method _build_model {
        Imago::Model::KiokuDB->new( dsn => "dbi:SQLite:db/kiokudb.sqlite", extra_args => { create => 1 } ) }

    has data => (
        isa => Dir,
        is  => "ro",
        default => sub { "resc/data" }, # FIXME B::B abs path
        coerce => 1,
    );

    method run {
        my $model = $self->model;

        my @insert;

        warn "Loading";
        my $objects = LoadFile( $self->data->file("objects.yml") );

        push @insert, @{ delete $objects->{pages} };

        my $roles = delete $objects->{roles};

        foreach my $role ( keys %$roles ) {
            push @insert, "role:$role" => $roles->{$role};
        }

        my $users = delete $objects->{users};

        foreach my $user ( keys %$users ) {
            my $user_object = $users->{$user};
            push @insert, "user:$user" => $user_object;
            push @insert, $user_object->identities; # make identities root objects
        }

        warn "Loaded";

        $model->txn_do( scope => 1, body => sub {
            $model->directory->backend->clear if $self->clear;
            $model->insert( @insert, %$objects );
        });

        warn "inserted";
    }
}

# ex: set sw=4 et:

1;

__END__
