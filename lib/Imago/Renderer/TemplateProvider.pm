#!/usr/bin/perl

package Imago::Renderer::TemplateProvider;
use Moose;

use Carp qw(croak);

use MooseX::Types::Moose qw(ArrayRef HashRef Bool);
use MooseX::Types::Path::Class qw(Dir);

use Snippet::Element;

use namespace::clean -except => 'meta';

has preparse => (
	isa => Bool,
	is  => "ro",
	default => 1,
);

has include_path => (
	isa => ArrayRef[Dir],
	is  => "ro",
	required => 1,
);

has _parsed => (
	isa => HashRef,
	is  => "ro",
	default => sub { +{} },
);

sub template {
	my ( $self, $path ) = @_;

	my $template = $self->_parsed->{$path} ||= $self->_load_template($path) || croak "No such template: $path";

	return $template->clone;
}

sub _load_template {
	my ( $self, $path ) = @_;

	foreach my $dir ( @{ $self->include_path } ) {
		my $full = $dir->file($path);

		if ( -e $full ) {
			return Snippet::Element->new( body => $full );
		}
	}

	return;
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
