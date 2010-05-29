my ( $self, $item, %args ) = @_;

replace_content "#content" => process("contents");

replace_content "nav" => process("nav");

add_attribute( '#content', dir => "rtl" ) if arg("lang") eq "he";

# IE monkeypatching
filter "head" => sub {
    my $selector = shift;

    $selector->append_content([
        {
            type => "TEXT",
            raw  => qq{
                <!--[if IE 6]>
                <link rel="stylesheet" href="/static/stylesheets/iefix.css" type="text/css" />
                <![endif]-->
                <!--[if lt IE 7.]>
                <script defer type="text/javascript" src="/static/js/pngfix.js"></script>
                <![endif]-->
            },
        },
    ]);
};

if ( $item->dependencies->includes("rpx.js") ) {
    my $c = $args{context};

    filter "head" => sub {
        my $selector = shift;

        # based on the following snippet from RPX:
        
            #<script type="text/javascript">
            #  var rpxJsHost = (("https:" == document.location.protocol) ? "https://" : "http://static.");
            #  document.write(unescape("%3Cscript src='" + rpxJsHost +
            #"rpxnow.com/js/lib/rpx.js' type='text/javascript'%3E%3C/script%3E"));
            #</script>
            #<script type="text/javascript">
            #  RPXNOW.overlay = true;
            #  RPXNOW.language_preference = 'en';
            #</script>

        my $rpxjs_uri = ( $c->plack_request->secure ? "https://" : "http://static." ) . "rpxnow.com/js/lib/rpx.js";

        $selector->append_content([
            #HTML::Zoom->from_html(qq{ # FIXME why doesn't this work?
            {
                type => "TEXT",
                raw => qq{
                    <!-- rpx.js dependency -->
                    <script src="$rpxjs_uri" type="text/javascript"></script>
                    <script type="text/javascript">
                        RPXNOW.overlay = true;
                        RPXNOW.language_preference = '${\ $c->lang }';
                    </script>
                },
            },
        ])
    }
}

my @title = grep { Scalar::Util::blessed($_) and $_->isa("Imago::View::Widget::PageTitle") } $item->exports->members;

die "Can't have more than one title" if @title > 1;

if ( my $title = $title[0] ) {
    replace("#page_title", process_for_zoom($title));
}

#filter "head" => sub {
#   my $selector = shift;
#
#   my @stylesheets = qw(foo.css bar.css); # FIXME this list needs to come from BB
#
#   # inject stylesheets, scripts, etc
#   if ( @stylesheets ) {
#       # FIXME
#       # this is disgusting but I can't get from_html("<link...>")->repeat to work right,
#       # nor can i get append_content to take anything but an array
#       $selector->append_content([ map { +{
#                   type => "TEXT",
#                   raw => qq{<link rel="stylesheet" type="text/css" href="$_" />\n},
#               } } @stylesheets ]);
#   }
#};

# ex: set sw=4 et:
