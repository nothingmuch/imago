#!/usr/bin/perl

package Imago::Renderer::Result::Page::Static;
use Moose;

use Encode qw(encode);

use Moose::Util::TypeConstraints;

use namespace::clean -except => 'meta';

with qw(Imago::Renderer::Result);

has page => (
	does => "Imago::Schema::Role::Page::Static",
	is  => "ro",
);

has html => (
	isa => "Str",
	is  => "ro",
	lazy_build => 1,
);

has user => (
	isa => "Imago::Schema::User",
	is  => "ro",
);

has lang => (
	isa => enum([qw(en he)]),
	is  => "ro",
	required => 1,
);

sub _build_html {
	my $self = shift;

	my $lang = $self->lang;

	{
		package Imago::Renderer::Result::Page::Static::Tags; # T::D exports 'meta', etc, need a new namespace

		use strict;
		use warnings;

		use Template::Declare::Tags 'HTML';
		use Text::MultiMarkdown qw(markdown);

		"" . html {
			head {
				title { $self->page->$lang->title }
			}
			body {
				if ( $lang eq 'he' ) {
					# FIXME total kludge
					attr { style => "direction: rtl" };
				}
				if ( my $user = $self->user ) {
					p { attr { style => "float: right; border: 1px solid black;" } "logged in user: " . $user->real_name }
				}
				div {
					attr { id => "content" }
					outs_raw markdown( $self->page->$lang->content->body )
				}
			}
		};
	}
}

sub write_to_catalyst {
	my ( $self, $c ) = @_;

	my $body = $self->html;

	$c->response->content_type( "text/html; charset=utf-8" );
	$c->response->body( encode( utf8 => $self->html ) );
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
