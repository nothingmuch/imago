#!/usr/bin/perl

use utf8;

package Imago::Script::Load;
use Moose;

use Imago::Backend::KiokuDB;
use Authen::Passphrase;
use Path::Class;
use MooseX::YAML qw(LoadFile);

use MooseX::Types::Path::Class qw(Dir File);

use namespace::clean -except => 'meta';

with qw(MooseX::Getopt);

has backend => (
	isa => "Imago::Backend::KiokuDB",
	is  => "ro",
	lazy_build => 1,
);

sub _build_backend { Imago::Backend::KiokuDB->new( extra_args => { create => 1 } ) }

has data => (
	isa => Dir,
	is  => "ro",
	default => sub { file(__FILE__)->parent->parent->subdir("data") },
);

has yaml_files => (
	isa => "ArrayRef[Path::Class::File]",
	is  => "ro",
	required => 1,
	lazy_build => 1,
);

sub _build_yaml_files {
	my $self = shift;

	my @files;

	$self->data->recurse( callback => sub {
		my $file = shift;

		if ( -f $file && $file->basename =~ /\.yml$/ ) {
			push @files, $file;
		}
	} );

	return [ sort @files ];
}

sub run {
	my $self = shift;

	my $backend = $self->backend;

	my @objects;

	warn "loading\n";

	foreach my $file ( @{ $self->yaml_files } ) {
		my @data = LoadFile($file);

		if ( @data == 1 ) {
			unless ( blessed $data[0] ) {
				if ( ref $data[0] eq 'ARRAY' ) {
					@data = @{ $data[0] };
				} else {
					@data = %{ $data[0] }; # with IDs
				}
			}
		}

		push @objects, @data;
	}

	warn "inserting " . scalar(@objects) . " objects\n";

	$backend->txn_do(sub {
		my $scope = $backend->new_scope;

		$backend->insert(@objects);
	});
}

__PACKAGE__->new_with_options->run;

__END__
