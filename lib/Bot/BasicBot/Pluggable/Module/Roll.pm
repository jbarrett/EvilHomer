package Bot::BasicBot::Pluggable::Module::Roll;

use EvilHomer::Imports;
extends qw/ Bot::BasicBot::Pluggable::Module /;

use Games::Dice qw/ roll /;

sub told( $self, $message ) {
    my ( $command, $param ) = map { lc } split(/\s+/, $message->{body}, 2);
    return unless $command eq '!roll';
    $param ||= 'd6';
    roll $param;
}

1;
