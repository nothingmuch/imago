use MooseX::Declare;

class Imago::View::Annotation extends Imago::View::Element {
    has '+value' => ( isa => "Object" );
}

# ex: set sw=4 et:

1;

__END__

