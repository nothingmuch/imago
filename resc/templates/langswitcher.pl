my ( $self, $item, %args ) = @_;

my %langs = map { $_->action->lang => $_ } @{ param("languages") };

delete $langs{ $args{lang} };

# optimized for only a few languages ;-)
filter(".menu", repeat_content => [
    map {
        my $link = $langs{$_};

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
    } sort keys %langs,
]);

# ex: set sw=4 et:
