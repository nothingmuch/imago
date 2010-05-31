my ( $self, $item, %args ) = @_;

filter("ul", repeat_content => [
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

            my $zoom = $_;

            if ( my $uri = $link->uri ) {
                $zoom = $zoom->select('a')->add_attribute( href => "$uri");
                $zoom = $zoom->select("a")->replace_content( $link->title ? process_for_zoom($link->title) : "$uri" );
            } elsif ( $link->title ) {
                $zoom = $zoom->select("a")->replace( process_for_zoom($link->title) );
            } else {
                die "No URI or title";
                # WTF, fix that data
            }

            if ( $link->description ) {
                my $desc = process_for_zoom($link->description);
                $desc = $desc->() if ref $desc eq 'CODE';
                $zoom = $zoom->select("span")->replace(
                    HTML::Zoom->from_html(
                        "<span>: " .
                        (blessed $desc ? $desc->to_html : HTML::Entities::encode_entities($desc) )
                        . "</span>"
                    ),
                );
            } else {
                $zoom = $zoom->select("span")->replace(HTML::Zoom->from_html(""));
            }

            return $zoom;
        }
    } @{ param("links") }
]);

# ex: set sw=4 et:
