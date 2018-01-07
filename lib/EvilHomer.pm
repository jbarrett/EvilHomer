package EvilHomer;

use EvilHomer::Imports 'script';

option server => (
    is => 'ro',
    format => 's',
    required => 1,
);

option channel => (
    is => 'ro',
    format => 's@',
    required => 1,
);

option hook => (
    is => 'ro',
    format => 's@',
    default => sub { [] }
);

option module => (
    is => 'ro',
    format => 's@',
    default => sub { [] }
);

option nick => (
    is => 'ro',
    format => 's',
    default => sub { q{EvilHomer} }
);

has default_modules => (
    is => 'ro',
    default => sub { [ qw/
        Bash
        Fortune
        GuffSpouter
        EightBall
        Skaal
        Karma
        Title
    / ] }
);

has default_hooks => (
    is => 'ro',
    default => sub { [ qw/
        Output
    / ] }
);

has bot => ( is => 'lazy' );
sub _build_bot( $self ) {
    my @hooks = ( @{ $self->hook }, @{ $self->default_hooks } );
    my @modules = ( @{ $self->default_modules }, @{ $self->module } );
    require Bot::BasicBot::Pluggable::Hookable;
    my $bot = Bot::BasicBot::Pluggable::Hookable->new (
        channels => $self->channel,
        server   => $self->server,
        nick     => $self->nick,
        enabled_hooks => \@hooks,
    );
    $bot->load( $_ ) for @modules;
    return $bot;
}

sub run( $self ) {
    $self->bot->run;
}

1;
