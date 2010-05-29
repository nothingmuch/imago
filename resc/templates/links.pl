my ( $self, $item, %args ) = @_;

filter(".links", repeat_content => [
    map {
        my $section = $_;

        sub {
            # FIXME need Devel::Declare for these keywords to propagate their
            # environment properly as closure data instead of using the dynamic stack
            our $__env;
            local $__env = {
                item          => $item,
                template      => $self,
                mappings      => [],
                template_args => \%args,
            };

            $_->select('.link')->replace( process_for_zoom($section) );
        }
    } @{ param("sections") }
]);

