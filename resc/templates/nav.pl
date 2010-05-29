my ( $self, $item, %args ) = @_;

filter(".menu", repeat_content => [
    map {
        my $link = $_;

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

            $_->select('a')->replace( process_for_zoom($link) );
        }
    } @{ param("menu") }
]);

replace_content "#langswitcher", process("langswitcher");

# ex: set sw=4 et:
