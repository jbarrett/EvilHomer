package EvilHomer::Imports;

use strict;
use warnings;
use v5.26.1;
use feature 'signatures';
no warnings qw/ experimental::smartmatch experimental::signatures /;

use Import::Into;
use Carp;

sub import ( $module, $type = 'class' ) {
    my ( $caller, $filename ) = caller;

    my $i = sub ( $use, @params ) {
        eval "require $use";
        $use->import::into( $caller, @params );
    };

    $i->( $_ ) for ( qw/
        strict warnings utf8 autodie
        Carp File::Spec::Functions
    / );

    for ($type) {
        when ('role')   { $i->('Moo::Role') }
        when ('script') { $i->('Moo'); $i->('MooX::Options') }
        default         { $i->('Moo'); }
    }

    feature->import::into( $caller, qw/ :5.26.1 signatures state say / );

    warnings->unimport::out_of(
        $caller,
        qw/ experimental::smartmatch experimental::signatures /
    );
}

1;
