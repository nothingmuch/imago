use MooseX::Declare;

class Imago::Schema::Page::Links extends Imago::Schema::Section {
	use Imago::Types;

	# FIXME split up into Imago::Schema::Links and Imago::Schema::LinkSections
	# make the Listing type parameterizable
    has '+body' => ( isa => "Imago::Schema::Listing", coerce => 1, );
}

# ex: set sw=4 et:

1;

__END__

