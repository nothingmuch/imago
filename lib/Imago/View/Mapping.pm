use MooseX::Declare;

class Imago::View::Mapping {
    use HTML::Zoom;

    has zoom => (
        isa => "HTML::Zoom",
        is  => "ro",
        required => 1,
    );

    has mappings => (
        traits => [qw(Array)],
        isa => "ArrayRef",
        required => 1,
        handles => {
            transformations => "elements",
        },
    );

    method to_zoom { $self->output }

    has 'output' => (
        isa => "Object",
        is  => "ro",
        lazy_build => 1,
    );

    method _build_output {
        use Imago::Util qw(timed);

        timed {
        my $zoom = $self->zoom;

        foreach my $mapping ( $self->transformations ) {
            local $_ = $zoom;
            if ( ref $mapping eq 'ARRAY' ) {
                my ( $target, $transform ) = @$mapping;
                $zoom = $zoom->select($target)->$transform;
            } elsif ( ref $mapping eq 'CODE' ) {
                $zoom = $zoom->$mapping;
            }
        }

        return $zoom;
        } "mapping transformations";
    }
}

# ex: set sw=4 et:

1;

__END__
