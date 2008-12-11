#!/usr/bin/perl

package Imago::Web::Model::Authentication::UserWrapper;
use Moose;

use namespace::clean -except => 'meta';

has 'user_object' => (
    reader   => 'get_object',
    isa      => 'Imago::Schema::User',
    required => 1,
    handles  => [qw(id check_password)],
);

has 'auth_realm' => (
    is => 'rw',
);

sub supports {
    return { password => 'self_check' };
}

sub for_session {
    my $self = shift;
    return $self->id;
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
