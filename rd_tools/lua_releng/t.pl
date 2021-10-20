#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
while (print ">> ") {
    chomp($_ = <>);
    /^q$/ && last;
    say "=> ", (eval $_) // "undef";
}