package Imago::Web::Controller::Root;

use strict;
use warnings;

use parent 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

	if ( my $page = $c->model("kiokudb")->index ) {
		$self->page($c, $page);
	} else {
		$self->not_found($c);
	}
}

sub default :Path {
    my ( $self, $c ) = @_;

	my $path = $c->req->path;

	if ( my $page = $c->model("kiokudb")->page($path) ) {
		$self->page($c, $page);
	} else {
		$self->not_found($c);
	}
}

sub page {
	my ( $self, $c, $page ) = @_;

	$c->view("Renderer")->process( $c, $page );
}

sub not_found {
	my ( $self, $c ) = @_;

	$c->response->body( 'Page not found' );
	$c->response->status(404);
}

__PACKAGE__

__END__

