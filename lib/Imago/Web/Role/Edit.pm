use MooseX::Declare;

class Imago::Web::Role::Edit with Imago::Web::Role {
    use Imago::Types;

    use MooseX::MultiMethods;
    use Carp;

    use HTML::Zoom;

    method sort_order { 5 }

    method nav_items (Imago::Web::Context $c) {
        return HTML::Zoom->from_html("<p>HELLO ADMIN!</p>");
    }

    multi method get_action ( Imago::Web::Context $c, :$method ) {
    }

    multi method invoke ( Imago::Web::Context $c, Imago::Web::Action::Logout $rpx )  {
    }
}

# ex: set sw=4 et:

1;

__END__
