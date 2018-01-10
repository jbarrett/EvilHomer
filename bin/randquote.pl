#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use EvilHomer::RandQuote;

EvilHomer::RandQuote->new_with_options->run;

1;

