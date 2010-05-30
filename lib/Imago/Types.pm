package Imago::Types;

use utf8;

use strict;
use warnings;

use Encode qw(decode_utf8);

use Moose::Util::TypeConstraints;
use MooseX::Types::UniStr;
use MooseX::Types::Buf;

use namespace::clean;

class_type "Imago::Model::KiokuDB";
class_type "Imago::Schema::Alias";
class_type "Imago::Schema::Text";
class_type "Imago::Schema::Document";
class_type "Imago::Schema::HTML";
class_type "Imago::Schema::Link";
class_type "Imago::Schema::Listing";
class_type "Imago::Schema::MultiLingualString";
class_type "Imago::Schema::Page::Links";
class_type "Imago::Schema::Section";
class_type "Imago::Schema::String";
class_type "Imago::Schema::User";
class_type "Imago::Schema::User::ID::RPX";
class_type "Imago::Schema::User::Settings";
class_type "Imago::Schema::VersionedItem";
class_type "Imago::Schema::VersionedItem::Version";
class_type "Imago::Script::InitDB";
class_type "Imago::View::Annotation";
class_type "Imago::View::BLOB";
class_type "Imago::View::BLOB::Thunk";
class_type "Imago::View::Element";
class_type "Imago::View::Fragment";
class_type "Imago::View::Mapping";
class_type "Imago::View::Redirection";
class_type "Imago::View::Response::HTTP";
class_type "Imago::View::Template";
class_type "Imago::View::Template::Factory";
class_type "Imago::View::Widget::Link";
class_type "Imago::View::Widget::PageTitle";
class_type "Imago::Web";
class_type "Imago::Web::Action::Logout";
class_type "Imago::Web::Action::Page";
class_type "Imago::Web::Action::RPXLogin";
class_type "Imago::Web::Action::SetLang";
class_type "Imago::Web::AuthToken::User";
class_type "Imago::Web::AuthToken::UserID";
class_type "Imago::Web::Context";
class_type "Imago::Web::Renderer";
class_type "Imago::Web::Renderer::HTML";
class_type "Imago::Web::Renderer::HTTP";
class_type "Imago::Web::Renderer::JSON";
class_type "Imago::Web::Renderer::Page::Fragment";
class_type "Imago::Web::Renderer::Page::Full";
class_type "Imago::Web::Renderer::RSS";
class_type "Imago::Web::Renderer::Template";
class_type "Imago::Web::Role::Browse";
class_type "Imago::Web::Role::Edit";
class_type "Imago::Web::Role::Login";
class_type "Imago::Web::Role::Logout";

role_type "Imago::Schema::Role::Localizable";
role_type "Imago::Schema::Role::UserID";
role_type "Imago::View::Result";
role_type "Imago::Web::Action";
role_type "Imago::Web::Renderer::API";
role_type "Imago::Web::Renderer::Representation";
role_type "Imago::Web::Role";

subtype "Imago::Schema::TextOrHTML", as "Imago::Schema::String|Imago::Schema::HTML", where { 1 };

coerce "Imago::Schema::TextOrHTML", from "Str", via {
    my $str = utf8::is_utf8($_) ? $_ : decode_utf8($_);

    my $lang = ( /\p{Hebrew}/ ? "he" : "en" );

    my $class = ( $str =~ /\<\w+.*?\>/s ? "Imago::Schema::HTML" : "Imago::Schema::String" );

    Class::MOP::load_class($class);
    $class->new( $lang => $str );
};

coerce "Imago::Schema::TextOrHTML", from "HashRef", via {
    my %hash = %$_;

    my $class = "Imago::Schema::String";

    for ( values %hash ) {
        $_ = utf8::is_utf8($_) ? $_ : decode_utf8($_);
        $class = "Imago::Schema::HTML" if /\<\w+.*?\>/s;
    }

    Class::MOP::load_class($class);
    $class->new($_);
};

coerce "Imago::Schema::String", from "HashRef", via {
    require Imago::Schema::String;
    Imago::Schema::String->new($_);
};

coerce "Imago::Schema::String", from "Str", via {
    require Imago::Schema::String;

    my $str = utf8::is_utf8($_) ? $_ : decode_utf8($_);

    my $lang = ( /\p{Hebrew}/ ? "he" : "en" );
    Imago::Schema::String->new( $lang => $str );
};

coerce "Imago::Schema::Text", from "HashRef", via {
    require Imago::Schema::Text;
    Imago::Schema::Text->new($_);
};

coerce "Imago::Schema::HTML", from "HashRef", via {
    require Imago::Schema::HTML;
    Imago::Schema::HTML->new($_);
};

coerce "Imago::Schema::Listing", from "ArrayRef", via {
    require Imago::Schema::Listing;
    Imago::Schema::Listing->new( items => $_ );
};

# ex: set sw=4 et:

__PACKAGE__

__END__

