package Bot::BasicBot::Pluggable::Hookable;

use Moo;
extends qw/ Bot::BasicBot::Pluggable /;
use Clone qw/ clone /;

use Module::Pluggable
    sub_name    => '_available_hooks',
    search_path => 'Bot::BasicBot::Pluggable::Hookable::Hook';

has enabled_hooks => (
    is => 'ro',
    default => sub { [] }
);

sub available_hooks {
    _available_hooks;
}

sub FOREIGNBUILDARGS {
    my ( $class, %args ) = @_;
    my $args_clone = clone( \%args );
    delete $args_clone->{enabled_hooks};
    return %{ $args_clone };
}

sub BUILD {
    my ( $self ) = @_;
    with grep {
        my $available = $_;
        grep {
            $available =~ /::$_$/
        } @{ $self->enabled_hooks }
    } _available_hooks();
}

1;
