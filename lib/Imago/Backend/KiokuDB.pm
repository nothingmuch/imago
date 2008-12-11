#!/usr/bin/perl

package Imago::Backend::KiokuDB;
use Moose;

use KiokuDB;
use KiokuDB::TypeMap;
use KiokuDB::TypeMap::Entry::Passthrough;
use KiokuDB::TypeMap::Entry::Callback;
use KiokuDB::TypeMap::Entry::Set;

use KiokuDB::Set::Transient;

use Search::GIN::Extract::Callback;
use Search::GIN::Query::Manual;

use Imago::Schema::BLOB;
use Imago::Schema::Page;
use Imago::Schema::User;
use Imago::Schema::Page::Login;

use namespace::clean -except => 'meta';

has dsn => (
    isa => "Str",
    is  => "ro",
    default => "bdb-gin:dir=root/db", # TODO
);

has extra_args => (
    isa => "HashRef",
    is  => "ro",
    default => sub { +{} },
    auto_deref => 1,
);

has extractor => (
    does => "Search::GIN::Extract",
    is   => "ro",
    lazy_build => 1,
);

sub _build_extractor {
    my $self = shift;

    Search::GIN::Extract::Callback->new(
        extract => sub {
            my ( $obj, $gin, %args ) = @_;

            if ( $obj->does("Aetna::CMS::Schema::Role::Tag::Approve" ) ) {
                return {
                    page    => [ map { $_->digest } $obj->approved_pages->members ],
                    section => [ map { $_->digest } $obj->approved_sections->members ],
                };
            }

            return;
        },
    );
}

has directory => (
    isa => "KiokuDB",
    is  => "ro",
    lazy_build => 1,
    handles => [qw(new_scope store insert update lookup delete txn_do search)],
);

sub _build_directory {
    my $self = shift;

    KiokuDB->connect(
        $self->dsn,
        extract => $self->extractor,
        $self->extra_args,
    )
}

sub index {
	shift->page("index");
}

sub page {
	my ( $self, $page ) = @_;

	$self->lookup("page:$page");
}

sub user {
	my ( $self, $user ) = @_;

	$self->lookup("user:$user");
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
