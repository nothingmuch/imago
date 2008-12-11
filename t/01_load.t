#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'Imago::Schema::User';
use ok 'Imago::Schema::BLOB';
use ok 'Imago::Schema::Page::Static::Content';
use ok 'Imago::Schema::Page';

use ok 'Imago::Backend::KiokuDB';

use ok 'Imago::Web::Model::KiokuDB';

use ok 'Imago::Web::Controller::Root';

use ok 'Imago::Web';

