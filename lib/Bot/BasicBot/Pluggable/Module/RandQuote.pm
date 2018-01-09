package Bot::BasicBot::Pluggable::Module::RandQuote;

use EvilHomer::Imports;
extends 'Bot::BasicBot::Pluggable::Module';

use POE::Future;
use EvilHomer::RandQuote;

has stash_dir => ( is => 'lazy' );
sub _build_stash_dir( $self ) {
    my $d = catdir( $self->bot->stash_dir, 'randquote' );
    mkdir $d unless -d $d;
    return $d;
}

has randquote => ( is => 'lazy' );
sub _build_randquote( $self ) {
    EvilHomer::RandQuote->new(
        stash_dir => $self->stash_dir,
    );
}

sub get_guff( $self ) {
    POE::Future->wrap(
        $self->randquote->quote
    );
}

sub told( $self, $message ) {
    my ( $command, $param ) = split(/\s+/, $message->{body}, 2);

    if ( lc( $command ) eq '!randquote' ) {
        if ( $param ) {
            $self->randquote->add( $param );
            return 'Randquote added.';
        }
        else {
            return $self->randquote->quote;
        }
    }

}

1;
