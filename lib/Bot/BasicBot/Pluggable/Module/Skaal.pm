package Bot::BasicBot::Pluggable::Module::Skaal;

use EvilHomer::Imports;
extends qw/ Bot::BasicBot::Pluggable::Module /;

sub help { q{Cheers for the *BEERS*!} }

sub told( $self, $message ) {
    return sprintf( "%s: Skål!", $message->{who} )
        if $message->{body} =~ /^\*[[:upper:]]+\*$/;
}

1;
