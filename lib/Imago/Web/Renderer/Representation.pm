use MooseX::Declare;

role Imago::Web::Renderer::Representation with Imago::Web::Renderer::API {
    use Carp;

    has representation => (
        isa => "Str",
        is  => "ro",
        default => sub { shift->moniker },
    );

    method moniker {
        if ( ref($self) =~ /([^:]+)$/ ) {
            return lc $1;
        } else {
            croak "Can't guess moniker";
        }
    }   
}

# ex: set sw=4 et:

1;

__END__

