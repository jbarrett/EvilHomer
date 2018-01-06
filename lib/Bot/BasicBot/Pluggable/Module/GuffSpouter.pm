package Bot::BasicBot::Pluggable::Module::GuffSpouter;

use EvilHomer::Imports;
extends qw/ Bot::BasicBot::Pluggable::Module /;

use POE::Future;
use Future::Utils qw/ repeat /;
use List::Util qw/ shuffle /;

has targets => ( is => 'lazy' );
sub _build_targets( $self ) {
    [ $self->bot->channels ];
}

has guff_modules => ( is => 'lazy' );
sub _build_guff_modules( $self ) {
    [
        map  { $self->bot->module( $_ ) }
        grep {
            $self->bot->module( $_ )->can('get_guff')
        } $self->bot->modules
    ];
}

has delay => (
    is => 'ro',
    default => sub { 5 * 60 }
);

# Futures store. Could use module store, but I froze a code ref once and it
# stunk out my kitchen.
my $f;

sub help { 'Spouts guff from a selection of modules when the channel is idle' }

sub _random_guff_module( $self ) {
    ( shuffle @{ $self->guff_modules } )[0];
}

sub _f( $self, $channel ) {
    repeat {
        POE::Future->new_delay( $self->delay )
        ->on_done(
            sub {
                $self->_random_guff_module->get_guff
                ->on_done(
                    sub( $guff ) {
                        $self->tell( $channel, $guff )
                    }
                )
            }
        );
    } while => sub { 1 };
}

sub init( $self ) {
    $f = {
        map { $_ => $self->_f( $_ ) }
        map { lc }
        @{ $self->targets }
    };
}

sub told( $self, $message ) {

    my $channel = lc( $message->{channel} );
    return unless grep { $channel eq lc( $_ ) } @{ $self->targets };

    $f->{ $channel }->cancel;
    $f->{ $channel } = $self->_f( $channel );

    return;
}

1;
