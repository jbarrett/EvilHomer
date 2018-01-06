package Bot::BasicBot::Pluggable::Module::EightBall;

use EvilHomer::Imports;
extends qw/ Bot::BasicBot::Pluggable::Module /;

use POE::Future;
use List::Util qw/ shuffle /;

has answers => (
    is => 'ro',
    default => sub {
        [
            q{As I see it, yes},
            q{Ask again later},
            q{Better not tell you now},
            q{Cannot predict now},
            q{Concentrate and ask again},
            q{Don't count on it},
            q{It is certain},
            q{It is decidedly so},
            q{Most likely},
            q{My reply is no},
            q{My sources say no},
            q{Outlook good},
            q{Outlook not so good},
            q{Reply hazy, try again},
            q{Signs point to yes},
            q{Very doubtful},
            q{Without a doubt},
            q{Yes - definitely},
            q{Yes},
            q{You may rely on it},
        ]
    }
);

sub answer( $self ) {
    ( shuffle @{ $self->answers } )[0];
}

sub get_guff( $self ) {
    POE::Future->wrap(
        $self->answer
    );
}

sub told( $self, $message ) {
    my ( $command, $param ) = split(/\s+/, $message->{body}, 2);

    return unless ($command eq '!8ball');

    $self->answer;
}

1;
