use MooseX::Declare;

class Imago::View::Redirection with Imago::View::Result {
    use MooseX::Types::URI qw(Uri);
    use Moose::Util::TypeConstraints qw(enum);

    use Imago::Types;

    has code => (
        isa => enum([301, 302, 307]), # FIXME 303 too?
        is  => "ro",
        default => 302,
    );

    has uri => (
        isa => Uri,
        is  => "ro",
        required => 1,
        coerce => 1,
    );

    method new_from_action ($class: Imago::Web::Context $c, Imago::Web::Action $action ) {
        $class->new(
            uri => $c->uri_for($action),
        );
    }
}

# ex: set sw=4 et:

1;

__END__

