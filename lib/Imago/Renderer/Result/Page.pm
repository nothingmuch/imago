#!/usr/bin/perl

package Imago::Renderer::Result::Page;
use Moose;

use Data::Dumper;
use Encode qw(encode);

use namespace::clean -except => 'meta';

with qw(Imago::Renderer::Result);

has page => (
	isa => "Imago::Schema::Page",
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

sub _build_html {
	my $self = shift;

	no warnings 'uninitialized';

	{
		package Imago::Renderer::Result::HTML::Tags; # T::D exports 'meta', etc, need a new namespace

		use Template::Declare::Tags 'HTML';
		use Text::MultiMarkdown qw(markdown);

		"" . html {
			head {
				title { $self->page->en->title }
			}
			body {
				p { "user: " . $self->user }
				div {
					attr { id => "content" }
					outs_raw markdown( $self->page->en->content->body )
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
