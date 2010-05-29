use MooseX::Declare;

role Imago::Web::Role {
    use Carp;

    method name {
        my ( $name ) = ( ref($self) =~ /([^:]+)$/ );
        return lc $name;
    }

    requires qw(get_action invoke);
}


# ex: set sw=4 et:

1;

__END__
