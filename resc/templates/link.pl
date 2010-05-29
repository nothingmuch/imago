add_attribute "a", href => $_->uri;
replace_content "a", loc($_->title);
replace_content "a", param("link")->title;
