use MooseX::Declare;

class Imago::Schema::MultiLingualString with MooseX::Clone with Imago::Schema::Role::Localizable is dirty {
    use I18N::LangTags qw(implicate_supers);
    use Encode qw(decode_utf8);
    use utf8;

    use MooseX::Types::UniStr;

    clean; # because of overloading

    use overload q{""} => "as_string";

    sub BUILDARGS {
        my ( $self, @args ) = @_;

        my $args = $self->SUPER::BUILDARGS(@args);

        $args = { strings => $args } unless exists $args->{string};

        for ( values %{ $args->{strings} } ) {
            $_ = decode_utf8($_) unless utf8::is_utf8($_);
        }

        return $args;
    }

    has strings => (
        traits => [qw(Hash)],
        isa => "HashRef[UniStr]",
        reader => "_strings",
        required => 1,
        handles => {
            languages => "keys",
            get       => "get",
            strings   => "elements",
        },
    );

    method digest_parts {
        $self->_strings;
    }

    method get_best (@options) {
        foreach my $lang ( @options ) {
            if ( length( my $str = $self->get($lang) ) ) {
                return $str;
            }
        }

        return;
    }

    method as_string {
        $self->get_best( "en", $self->languages );
    }

    method localize (@langs) {
        @langs = @{ $langs[0] } if @langs == 1 and ref $langs[0] eq 'ARRAY';

        $self->get_best( implicate_supers( map { ref $_ ? $_->language_tag : $_ } @langs ), $self->languages );
    }

    method add (%strings) {
        for ( values %strings ) {
            $_ = decode_utf8($_) unless utf8::is_utf8($_);
        }

        $self->clone(
            strings => {
                $self->strings,
                %strings,
            },
        );
    }

    method remove (@keys) {
        my %strings = $self->strings;

        delete @strings{@keys};

        $self->clone( strings => \%strings );
    }

    method TO_JSON {
        return { $self->strings };
    }
}

# ex: set sw=4 et:

1;

__END__
