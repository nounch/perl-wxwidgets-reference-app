#!/usr/bin/perl

package Main;

use 5.010;
use strict;
use warnings;

use base qw(Wx::App);

use MainFrame;


sub OnInit {
    my $self = shift;

    Wx::InitAllImageHandlers();

    my $frame = MainFrame->new();
    $frame->Show(1);

    return 1;
}

Main->new->MainLoop;

