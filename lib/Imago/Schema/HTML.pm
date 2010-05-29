use MooseX::Declare;

class Imago::Schema::HTML extends Imago::Schema::Text {
	use utf8;
	use Encode qw(encode_utf8);
	use HTML::Zoom;

    has '+type' => (
		default => "text/html",
    );

	method to_zoom (%args) {
		my $str = $self->localize($args{lang});

		#my $type = $self->type;

		#if ( utf8::is_utf8 ) {
		#	$type .= "; charset=utf-8" unless $type =~ /charset/;
		#	$str = encode_utf8($str);
		#}

		HTML::Zoom->from_html($str);
	}
}

# ex: set sw=4 et:

1;

__END__

