use MooseX::Declare;

role Imago::Schema::Role::UserID with KiokuDB::Role::ID {
    use Imago::Types;

    requires "id";

    method kiokudb_object_id {
        $self->qualify_id($self->id);
    }

    method qualify_id ($class: Str $id) {
        join ":", qw(userid), $class->namespace, $id;
    }

    method namespace ($class_or_self:) {
        my $class = ref $class_or_self || $class_or_self;

        if ( $class =~ /([^:]+)$/ ) {
            return $1;
        } else {
            die "couldn't guess namespace";
        }
    }

    has user => (
        isa => "Imago::Schema::User",
        is  => "ro",
        weak_ref => 1,
        required => 1,
    );
}

# ex: set sw=4 et:

1;

__END__
