#!/usr/bin/perl

package Imago::Renderer::Result::Page::Static;
use Moose;

use Encode qw(encode);
use Text::MultiMarkdown qw(markdown);

use namespace::clean -except => 'meta';

with qw(Imago::Renderer::Result::Page);

has page => (
	does => "Imago::Schema::Role::Page::Static",
	is  => "ro",
);

sub body_html {
	my $self = shift;

	my $lang = $self->lang;

	markdown( $self->page->$lang->content->body );
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
