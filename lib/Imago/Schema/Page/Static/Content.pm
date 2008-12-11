#!/usr/bin/perl

package Imago::Schema::Page::Static::Content;
use Moose;

use Imago::Schema::BLOB;

use Moose::Util::TypeConstraints;

use namespace::clean -except => 'meta';

coerce( __PACKAGE__,
	from HashRef => via { __PACKAGE__->new(%$_) },
);

with qw(Imago::Role::DigestID);

sub digest_parts {
	my $self = shift;
	return ( $self->title, $self->content );
}

has title => (
	isa => "Str",
	is => "ro",	
	required => 1,
);

has content => (
	isa => "Imago::Schema::BLOB",
	is  => "ro",
	required => 1,
	coerce => 1,
);

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
