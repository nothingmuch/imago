#!/usr/bin/perl

package Imago::Web::Model::KiokuDB;
use Moose;

use Imago::Backend::KiokuDB;

use namespace::clean -except => 'meta';

BEGIN { extends qw(Moose::Object Catalyst::Model) }

has backend => (
    isa => "Imago::Backend::KiokuDB",
    is  => "ro",
    lazy_build => 1,
);

sub _build_backend { Imago::Backend::KiokuDB->new }

sub COMPONENT {
    my ($self, $app, $args) = @_;
    $self->new(%$args);
}

sub ACCEPT_CONTEXT {
    my ($self, $c, @args) = @_;
    my $b = $self->backend;
    $c->stash->{__kioku_scope} ||= $b->new_scope;
    return $b;
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__

