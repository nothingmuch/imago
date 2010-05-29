use MooseX::Declare;

use utf8;

class Imago::View::Template::Factory {
    use Carp;
    use Encode qw(decode_utf8);

    use MooseX::Types::Path::Class qw(Dir File);

    use Imago::View::Template;
    use Imago::View::Template::Factory::CacheEntry;

    use Parse::Perl qw(parse_perl);

    use Imago::Util qw(timed);

    use HTML::Zoom;


    my $eval_env = do {
        package Imago::View::Template::Body;

        use strict;
        use warnings;
        use utf8;

        use Scalar::Util qw(blessed);
        use Carp;
        use Moose::Autobox; # mixin additional roles?

        use Try::Tiny;

        # Markapl for HTML generation

        #Moose::Autobox->mixin_additional_role(SCALAR => 'Imago::Autobox::Scalar');

        sub arg ($) { (our $__env)->{template_args}{$_[0]} }

        sub context { arg("context") }

        sub param {
            my $item = (our $__env)->{item};

            if ( blessed($item) and $item->can("param") ) {
                $item->param(@_);
            } else {
                croak(overload::StrVal($item) . " does not have a 'param' method");
            }
        }

        sub process ($;@) {
            my ( $item, @args ) = @_;
            our $__env;
            confess unless $__env->{template};
            $__env->{template}->process(
                (ref $item ? $item : param($item) ),
                %{ $__env->{template_args} }, @args
            );
        }

        sub process_for_zoom ($;@) {
            my ( $item, @args ) = @_;
            our $__env;
            confess unless $__env->{template};
            $__env->{template}->process_for_zoom(
                (ref $item ? $item : param($item) ),
                %{ $__env->{template_args} }, @args
            );
        }

        sub loc ($) { Carp::cluck("loc fail") unless arg("lang"); return $_[0]->localize( arg("lang") ) }; # FIXME

        sub raw_html ($) {
            HTML::Zoom->from_html($_[0]);
        }

        sub filter ($@) {
            my ( $target, $transformation, @args ) = @_;

            push @{ (our $__env)->{mappings} }, [ $target, sub { shift->$transformation(@args) } ];
        }

        sub replace_content ($$) { our $__env; filter( $_[0], replace_content => $__env->{template}->process_for_zoom($_[1], %{ $__env->{template_args} }) ) }
        sub replace ($$)         { our $__env; filter( $_[0], replace =>         $__env->{template}->process_for_zoom($_[1], %{ $__env->{template_args} }) ) }
        sub add_attribute ($$$)  { filter( $_[0], add_attribute   => @_[1,2] ) }

        Parse::Perl::current_environment();
    };

    has cache => (
        isa => "HashRef",
        is  => "ro",
        default => sub { return {} },
    );

    has dir => (
        isa => Dir,
        is  => "ro",
        coerce => 1,
    );

    method template_path (Str $name) {
        $self->dir->file($name);
    }

    method compile_auto_body {
        return sub {
            my ( $self, $item, @args ) = @_;

            my @mappings;

            if ( blessed($item) and $item->can("params") ) {
                foreach my $name ( $item->param ) {
                    my $value = $item->param($name);

                    if ( ref $value eq 'ARRAY' ) {
                        warn "TODO ARRAY values not yet implemented";
                        # map over @$value, process each item, and repeat with the result
                        #push @mappings, [ ".${name}", sub { shift->repeat_content() } ];
                    } else {
                        my $processed = $self->process_for_zoom($value);
                        push @mappings, [ "#${name}", sub { shift->replace_content($processed) } ];
                    }
                }
            }

            return \@mappings;
        }
    }

    method compile_pl (File $pl_file) {
        my $body = parse_perl(
            $eval_env,
            join("\n",
                "#line 1 '$pl_file'",
                decode_utf8($pl_file->slurp),
            ),
        );

        return sub {
            my ( $self, $item, %args ) = @_;

            my @mappings;

            {
                package Imago::View::Template::Body;

                our $__env;

                local $__env = {
                    item          => $item,
                    template      => $self,
                    mappings      => \@mappings,
                    template_args => \%args,
                };

                local $_ = $item;

                $self->$body($item, %args);
            }

            return @mappings;
        };
    }

    method template (Str $name) {
        timed {

        my $cache = $self->cache->{$name} ||= Imago::View::Template::Factory::CacheEntry->new(
            factory => $self,
            name => $name,
            ( map { ("${_}_file" => $self->template_path("${name}.$_")) } qw(html pl) ),
        );

        return $cache->template;

        } "get template $name";
    }

    method compile_template (:$html_file!, :$pl_file!, :$name) {
        $self->new_template(
            zoom => HTML::Zoom->from_html(decode_utf8($html_file->slurp)),
            body => ( -e $pl_file ? $self->compile_pl($pl_file) : $self->compile_auto_body ),
            (defined $name ? ( name => $name ) : () ),
        );
    }

    method new_template (@args) {
        return Imago::View::Template->new(
            factory => $self,
            @args,
        );
    }

    # FIXME multi method?
    method process ( $item, %args ) {
        if ( blessed($item) and $item->isa("Imago::View::Annotation") ) {
            # these are just structural annotations, skip them in rendering
            # the annotations are picked up before rendering
            return $self->process( $item->value, %args );
        }

        my $template_name;

        if ( exists $args{template} ) {
            $template_name = delete $args{template};
        } elsif ( blessed($item) and $item->can("param") ) {
            $template_name = $item->param("template");
        }

        if ( defined $template_name ) {
            my $template = ref $template_name
                ? $template_name
                : $self->template($template_name);

            return $template->create_mapping( $item, %args );
        } elsif ( blessed $item ) {
            if ( $item->can("to_zoom") ) {
                return $item;
            } elsif ( $item->isa("Imago::View::Template") ) {
                return $item->create_mapping( undef, %args );
            } elsif ( $item->isa("Imago::View::Annotation") ) {
                # these are just structural annotations, skip them in rendering
                # if they aren't matched with a template
                $self->process( $item->value, %args );
            } elsif ( $item->can("render") ) {
                return $item->render( factory => $self, %args);
            } elsif ( $item->can("localize") ) {
                return $item->localize($args{lang});
            }
        }

        return $item;
    }

    method process_for_zoom ( $value, @args ) { 
        return $value unless ref $value;

        my $processed = $self->process($value, @args);
        $self->prepare_zoom_arg($processed, @args);
    }

    method prepare_zoom_arg ( $value, @args ) {
        if ( blessed($value) and $value->can("to_zoom") ) {
            # lazify if possible
            return sub { $value->to_zoom(@args) };
        }

        return $value;
    }
}

# ex: set sw=4 et:

1;

__END__
