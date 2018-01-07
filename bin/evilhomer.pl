#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use EvilHomer;

EvilHomer->new_with_options->run;

1;
