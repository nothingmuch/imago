use MooseX::Declare;

class Imago::View::BLOB::Thunk extends Imago::View::BLOB {
    use MooseX::Types::Buf;

    has thunk => (
        isa => "CodeRef",
        is  => "ro",
        required => 1,
    );

    # has "+contents"
    has contents => (
        isa => "Buf", # FIXME MX::Types
        is  => "ro",
        lazy_build => 1,
    );
    
    method _build_contents {
        $self->thunk->();
    }
}

# ex: set sw=4 et:

1;

__END__

