use MooseX::Declare;

class Imago::View::Response::HTTP with MooseX::Clone {
    use MooseX::MultiMethods;

    use Imago::View::BLOB;
    use Imago::View::Redirection;

    # FIXME partial content negotiation, HEAD vs GET, Last-Modified magic, etc can all go in here? need to lazify blob if so

    use HTML::Entities;

    use MooseX::Types::Buf; # FIXME MX::Types

    has body => (
        isa => "Buf|ArrayRef[Buf]|FileHandle|Object",
        is  => "ro",
        required => 1,
    );

    has status => (
        isa => "Int",
        is  => "ro",
        required => 1,
    );

    has headers => (
        traits => [qw(Array)],
        isa => "ArrayRef[Buf]",
        default => sub { [] },
        handles => {
            headers => "elements",
        },
    );

    multi method new_from_whatever ($class: Imago::View::BLOB $blob ) {
        $class->new(
            status => 200,
            body => [ $blob->contents ],
            headers => [
                $blob->headers,
                "Cache-Control" => "public; max-age=" . (24 * 3600),
                Expires => HTTP::Date::time2str( time + 24 * 3600 )
            ],
        );
    }

    multi method new_from_whatever ($class: Imago::View::Redirection $redirection ) {
        my $uri = $redirection->uri->as_string;

        my $esc = encode_entities($uri);

        $class->new(
            status => $redirection->code,
            headers => [
                "Content-Type" => "text/html; charset=utf8",
                "Location" => $uri,
                "Cache-Control" => "public; max-age=" . (24 * 3600),
                Expires => HTTP::Date::time2str( time + 24 * 3600 )
            ],
            body => <<HTML,
<html>
    <head>
        <title>Redirecting</title>
    </head>
    <body>
        <p>Redirecting to <a href="$esc">$esc</a></p>
    </body>
</html>
HTML
        );
    }

    method add_headers ( @headers ) {
        return $self unless @headers;

        return $self->clone(
            headers => [
                $self->headers,
                @headers,
            ],
        );
    }

    method add_cookies ( @cookies ) {
        $self->add_headers( map { ("Set-Cookie" => $_->as_string) } @cookies );
    }

    method to_psgi {
        return [
            $self->status,
            [ $self->headers ],
            ref($self->body) ? $self->body : [ $self->body ],
        ];
    }

}

# ex: set sw=4 et:

1;

__END__

