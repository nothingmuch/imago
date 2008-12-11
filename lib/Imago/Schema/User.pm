#!/usr/bin/perl

package Imago::Schema::User;
use Moose;

use MooseX::AttributeHelpers;
use MooseX::Types::Authen::Passphrase qw(Passphrase);

use namespace::clean -except => 'meta';

sub kiokudb_object_id { "user:" . shift->id }

has id => (
    isa => "Str",
    is  => "ro",
);

has password => (
    isa      => Passphrase,
    is       => 'rw',
    coerce   => 1,
	required => 1,
    #handles => { check_password => "match" },
);


sub check_password {
    my $self = shift;
    $self->password->match(@_);
}

has real_name => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
);

has priviliges => (
	metaclass => "Collection::Hash",
	isa => "HashRef",
	is  => "ro",
	default => sub { +{} },
	provides  => {
		exists => "has_priv",
		keys   => "privs",
		get    => "priv_attrs",
		set    => "add_priv",
		delete => "remove_priv",
	},
);

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
