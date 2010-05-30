use MooseX::Declare;

class Imago::Web::Renderer::Page::Fragment {
    use MooseX::MultiMethods;

    use Imago::Types;

    use Imago::View::Annotation;
    use Imago::View::Fragment;
    use Imago::View::Widget::PageTitle;

    multi method render (Imago::Web::Context $c, Imago::Schema::VersionedItem $item) {
        $self->render($c, $item->item);
    }
    
    multi method render (Imago::Web::Context $c, Imago::Schema::Section $section) {
		$self->add_page_title($c,
			title => $section->title,
			value => $self->render_section($c,
				title => $section->title,
				body => $self->render($c, $section->body),
			),
		);
	}

	method title_widget ($title) {
		Imago::View::Widget::PageTitle->new(
			content => $title,
		);
	}

	method add_page_title (Imago::Web::Context $c, :$title!, :$value!) {
		$self->annotate($c,
			$value,
			exports => [
				$self->title_widget($title),
			],
		);
	}

	method annotate (Imago::Web::Context $c, $value!, @args) {
        return Imago::View::Annotation->new(
            value        => $value,
			@args,
		);
	}

    method render_section (Imago::Web::Context $c, :$title!, :$body! ) {
		return Imago::View::Fragment->new(
			value => {
				template => "section",
				title    => $title,
				body     => $body,
			},
		),
	}

    multi method render (Imago::Web::Context $c, Imago::Schema::Page::Links $section) {
		return $self->add_page_title($c,
			title => $section->title,
			value => $self->render_links($c, $section),
		);
	}

	# FIXME this should more flexible
	# the repitition should be outside of the templates, not inside but that's a little tricky with Zoom ATM
    method render_links (Imago::Web::Context $c, Imago::Schema::Page::Links $section) {
		my $body;

		if ( $section->body->item(0)->isa("Imago::Schema::Link") ) {
			$body = Imago::View::Fragment->new(
				value => {
					template => "link_section",
					links => [ $section->body->items ],
				},
			);
		} else {
			$body = Imago::View::Fragment->new(
				value => {
					template => "links",
					sections => [ map { $self->render_links($c, $_) } $section->body->items ],
				},
			);
		}

		return $self->render_section($c,
			title => $section->title,
			body  => $body,
		);
	}

	multi method render (Imago::Web::Context $c, Imago::Schema::MultiLingualString $s ) {
		return $s;
	}
}

# ex: set sw=4 et:

1;

__END__

