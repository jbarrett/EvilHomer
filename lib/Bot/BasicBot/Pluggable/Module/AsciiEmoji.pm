package Bot::BasicBot::Pluggable::Module::AsciiEmoji;

use EvilHomer::Imports;
extends qw/ Bot::BasicBot::Pluggable::Module /;

use Acme::AsciiEmoji;
use Encode qw/ decode /;

sub told( $self, $message ) {
    my ( $command, $param ) = map { lc } split(/\s+/, $message->{body}, 2);
    return unless $command eq '!e';
    $param ||= 'shrug';
    $param =~ s/\s+/_/g;
    $param =~ s/[^a-z_]//g;
    my $call = Acme::AsciiEmoji->can( $param );
    return decode( 'UTF-8', ( $call ) ? $call->() : Acme::AsciiEmoji->shrug );
}

1;
