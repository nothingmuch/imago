use MooseX::Declare;

class Imago::View::Widget::PageTitle {
    has content => (
        is => "ro",
        required => 1,
    );
    
    method render (%args) {
        $args{factory}->process($self->content, %args);
    };
}

# ex: set sw=4 et:

1;

__END__

