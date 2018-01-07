package Bot::BasicBot::Pluggable::Module::MegaHAL;

use EvilHomer;
extends Bot::BasicBot::Pluggable::Module;

# Should definitely be a POE::Component::AI::MegaHAL or something instead
use IA::MegaHAL;

has stash_dir => ( is => 'lazy' );
sub _build_stash_dir( $self ) {
    catdir( $self->bot->stash_dir, 'megahal' );
    mkdir $d unless -d $d;
    return $d;
}

has megahal => ( is => 'lazy' );
sub _build_megahal( $self ) {
    IA::MegaHAL->new(
        Path => $self->stash_dir,
        AutoSave => 1,
    );
}

sub told( $self, $message ) {
    my $nick = $self->bot->nick;
    my $body = $message->{body};

    return unless ( $body =~ s/^$nick: ?// );
    return $self->megahal->do_reply( $body );
}

1;
