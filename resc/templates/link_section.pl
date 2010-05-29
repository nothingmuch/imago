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

            $_->select('a')->add_attribute( href => $link->uri->as_string )
				->select("a")->replace_content( process_for_zoom($link->title || $link->uri->as_string) )
				->select("span")->replace( $link->description
					? do {
						# FIXME there has got to be a better way than this, like [ \":&nbsp;&nbsp;", $link->description ]
							my $desc = process_for_zoom($link->description);
							$desc = $desc->() if ref $desc eq 'CODE';
							HTML::Zoom->from_html(
								"<span>:&nbsp;&nbsp;" .
								(blessed $desc ? $desc->to_html : HTML::Entities::encode_entities($desc) )
								. "</span>"
							);
						}
					: HTML::Zoom->from_html("")
				);
        }
    } @{ param("links") }
]);


