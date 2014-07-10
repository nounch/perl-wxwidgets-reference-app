#!/usr/bin/perl

package CustomGrid;

use 5.010;
use strict;
use warnings;

use Wx 0.15 qw[:allclasses];
use Wx qw[:everything];

use base qw(Wx::Grid);


sub new {
    my($self, $parent, $id, $position, $size, $style, $name);
    $parent = undef unless defined $parent;
    $id = undef unless defined $id;
    $position = wxDefaultPosition unless defined $position;
    $size = wxDefaultSize unless defined $size;
    $style = wxWANTS_CHARS unless defined $style;
    $name = undef unless defined $name;
    $self = $self->SUPER::new($parent, $id, $position, $size, $style, $name);
}

1;
