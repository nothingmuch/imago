package Imago::Web;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use parent qw/Catalyst/;

use Catalyst qw(
	Static::Simple
	Session
	Session::State::Cookie
    Session::Store::FastMmap
    Authentication
);

our $VERSION = '0.01';

__PACKAGE__->config(
	name => 'Imago::Web',
	'Plugin::Authentication' => {
		default_realm => 'users',
		realms => {
			users => {
				credential => {
					class         => 'Password',
					password_type => 'self_check'
				},
				store => {
					class => '+Imago::Web::Model::Authentication',
				}
			}
		}
	}
);

# Start the application
__PACKAGE__->setup();

__PACKAGE__

__END__
