package Bot::BasicBot::Pluggable::Module::Fortune;

use EvilHomer::Imports;
extends qw/ Bot::BasicBot::Pluggable::Module /;

use POE::Future;
use IPC::Run qw/ run /;

has max_length => (
    is => 'ro',
    default => sub { 290 }
);

sub fortune( $self ) {
    my ( $in, $out, $err );
    run [ qw/ fortune -a -n /, $self->max_length ], \$in, \$out, \$err;
    $out =~ s/^\s+//;
    $out =~ s/\s+$//;
    $out =~ s/\s+/ /gr;
}

sub get_guff( $self ) {
    POE::Future->wrap(
        $self->fortune
    );
}

sub told( $self, $message ) {
    my ( $command, $param ) = split(/\s+/, $message->{body}, 2);

    return unless ($command eq '!fortune');

    $self->fortune;
}

1;
