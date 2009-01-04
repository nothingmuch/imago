#!/usr/bin/perl

package Imago::Renderer::Result::Page;
use Moose::Role;

use Encode qw(encode);
use XML::LibXML;
use HTML::Selector::XPath;

use Snippet::Element;

use Moose::Util::TypeConstraints;

use namespace::clean -except => 'meta';

with qw(Imago::Renderer::Result);

has context => (
	is => "ro",
	required => 1,
);

has renderer => (
	isa => "Imago::Renderer",
	is  => "ro",
	required => 1,
);

has template_name => (
	isa => "Str",
	is  => "ro",
	default => "page.html",
);

sub template {
	my $self = shift;
	$self->renderer->template( $self->template_name );
}

has user => (
	isa => "Imago::Schema::User",
	is  => "ro",
);

has lang => (
	isa => enum([qw(en he)]),
	is  => "ro",
	required => 1,
);

has rendered => (
	isa => "Snippet::Element",
	is  => "ro",
	lazy_build => 1,
);

requires "body_html";

sub _build_rendered {
	my $self = shift;

	my $lang = $self->lang;

	my $t = $self->template;

	{
		my $c = $self->context;

		my $nav = $c->model("kiokudb")->lookup("nav");

		my @pages = @{ $nav->pages };

		my @links;

		# this is kinda kludgy
		foreach my $page ( @{ $nav->pages } ) {
			my $title = $page->$lang->title;
			my $uri = $c->uri_for("/" . $page->id);
			my $class = $page == $self->page ? 'class="active" ' : "";
			push @links, qq{<a ${class}href="$uri">$title</a>};
		}

		$t->find("#menu")->html(join "", @links);
	}

	my $title = $self->page->$lang->title;

	$t->find("head title")->text($title);

	my $body = $t->find("body");

	if ( $lang eq 'he' ) {
		# FIXME total kludge
		$body->attr( style => "direction: rtl");
	}

	if ( my $user = $self->user and 0 ) {
		my $name = $user->real_name;
		$t->find("#content")->append(qq{<p style="float: right; border: 1px solid black;">logged in user: $name</p>});
	}

	my $c = $body->find("#content");

	$c->append("<h1>$title</h1>");

	$c->append($self->body_html);

	return $t;
}

sub write_to_catalyst {
	my ( $self, $c ) = @_;

	$c->response->content_type( "text/html; charset=utf-8" );
	$c->response->body( encode( utf8 => $self->rendered->as_xml ) );
}

__PACKAGE__

__END__
