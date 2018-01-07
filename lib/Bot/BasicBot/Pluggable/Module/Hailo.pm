package Bot::BasicBot::Pluggable::Module::Hailo;

use EvilHomer::Imports;
extends 'Bot::BasicBot::Pluggable::Module';

use Hailo;

has stash_dir => ( is => 'lazy' );
sub _build_stash_dir( $self ) {
    my $d = catdir( $self->bot->stash_dir, 'hailo' );
    mkdir $d unless -d $d;
    return $d;
}

has hailo => ( is => 'lazy' );
sub _build_hailo( $self ) {
    Hailo->new(
        brain => catfile ( $self->stash_dir, 'brain' ),
        save_on_exit => 1,
    );
}

sub get_guff( $self ) {
    POE::Future->wrap(
        $self->hailo->reply
    );
}

sub tick( $self ) { $self->hailo->save };

sub told( $self, $message ) {
    my $nick = lc( $self->bot->nick );
    my $body = $message->{body};

    if ( lc( $message->{address} ) eq $nick ) {
        $body =~ s/^$nick[[:alpha:]]+//;
        return $self->hailo->learn_reply( $body );
    }
    elsif ( $body !~ /^!/ && $message->{channel} =~ /^#/ ) {
        $self->hailo->learn( $body );
    }

    return;
}

1;
