#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Dancer2;
#use inventory;
use default;

#inventory->to_app;
default->to_app;
start;
