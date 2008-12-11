package Imago::Web;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use parent qw/Catalyst/;

use Catalyst qw(
	Static::Simple
);

our $VERSION = '0.01';

__PACKAGE__->config( name => 'Imago::Web' );

# Start the application
__PACKAGE__->setup();

__PACKAGE__

__END__
