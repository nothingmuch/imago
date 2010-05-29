package Imago::Util;

use strict;
use warnings;

use Carp;
use Guard;
use Time::HiRes qw(time);

use namespace::clean;

use Sub::Exporter -setup => {
	exports => [qw(timed)],
};

my @stack;

sub timed (&;$) {
	my ( $sub, $desc ) = @_;

	my ($start, $end);

	$desc ||= Carp::shortmess();
	chomp $desc;

	my @sub_times;
	push @stack, \@sub_times;

	scope_guard {
		$end = time;

		my @msg = ( sprintf("%.5f %s", $end - $start, $desc), map { "  $_" } @sub_times );

		pop @stack;

		if ( @stack ) {
			push @{ $stack[-1] }, @msg;
		} else {
			warn join("\n", @msg) . "\n";
		}
	};

	$start = time;

	$sub->();
}

# ex: set sw=4 et:

1;

__END__

