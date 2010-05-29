use MooseX::Declare;

class Imago::View::Template::Factory::CacheEntry {
    use MooseX::Types::Path::Class qw(Dir File);

    has name => (
        isa => "Str",
        is  => "ro",
    );

    has [qw(html_file pl_file)] => (
        isa => File,
        is  => "ro",
        required => 1,
    );

    has factory => (
        isa => "Imago::View::Template::Factory",
        is  => "ro",
        required => 1,
        weak_ref => 1,
        handles => [qw(process process_for_zoom)],
    );

    has timestamp => (
        isa => "Int",
        is  => "rw",
        default => 0,
    );

    has cached_template => (
        isa => "Imago::View::Template",
        is  => "ro",
        lazy_build => 1,
    );

    method most_recent_mtime {
        return (sort { $b <=> $a } map { $_->mtime } map { $_->stat } $self->html_file, $self->pl_file)[0];
    }

    method _build_cached_template {
        $self->factory->compile_template(
            html_file => $self->html_file,
            pl_file   => $self->pl_file,
            name      => $self->name,
        );
    }

    method template {
        my $mtime = $self->most_recent_mtime;

        if ( $mtime >= $self->timestamp ) {
            $self->timestamp($mtime);
            $self->clear_cached_template;
        }

        return $self->cached_template;
    }   
}

# ex: set sw=4 et:

1;

__END__

