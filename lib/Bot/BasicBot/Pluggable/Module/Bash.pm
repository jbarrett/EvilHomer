package Bot::BasicBot::Pluggable::Module::Bash;

use EvilHomer::Imports;
extends qw/ Bot::BasicBot::Pluggable::Module /;

use POE::Future;
use WWW::BashOrg;

has bash => ( is => 'lazy' );
sub _build_bash {
    # Some day this will be async-y... Nah...
    WWW::BashOrg->new;
}

has max_length => (
    is => 'ro',
    default => sub { 290 }
);

around qw/ random quote / => sub {
    my $orig = shift;
    my $self = shift;
    my $quote = $orig->( $self, @_ );
    return $quote =~ s/[\n\r]/ /gr;
};

sub help { q{Get quotes from bash.org} }

sub random( $self, $site = 'bash' ) {
    $self->bash->random( $site );
}

sub short_random( $self, $site = 'bash' ) {
    my $quote = $self->random( $site );
    while ( length $quote > $self->max_length ) {
        $quote = $self->random( $site );
    }
    return $quote;
}

sub quote( $self, $id, $site = 'bash' ) {
    $self->bash->get_quote( $id, $site ) || "$site quote not found";
}

sub get_guff( $self ) {
    POE::Future->wrap(
        $self->short_random
    );
}

sub told( $self, $message ) {
    my ( $command, $param ) = split(/\s+/, $message->{body}, 2);
    my $site;

    ( $command eq '!bash' ) && ( $site = 'bash' );
    ( $command eq '!qdb' ) && ( $site = 'qdb' );

    return unless $site;

    return ( $param )
        ? $self->quote( $param + 0, $site )
        : $self->short_random( $site );
}

1;
