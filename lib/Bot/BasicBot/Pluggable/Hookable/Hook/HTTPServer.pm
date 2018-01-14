package Bot::BasicBot::Pluggable::Hookable::Hook::HTTPServer;

use EvilHomer::Imports 'role';

use Net::Async::HTTP::Server::PSGI;
use IO::Async::Loop::POE;
use Scalar::Util qw/ reftype /;

has io_async_loop => ( is => 'lazy' );
sub _build_loop {
    IO::Async::Loop::POE->new;
}

has http_server => ( is => 'rw' );

sub init_http( $self, $args ) {

    die 'Need app!' unless reftype $args->{app} eq 'CODE';
    $args->{port}     //= 8888;
    $args->{ip}       //= '0.0.0.0';
    $args->{socktype} //= 'stream';
    $args->{family}   //= 'inet';

    my $http_server = Net::Async::HTTP::Server::PSGI->new(
       app => $args->{app}
    );

    $self->loop->add( $http_server );

    $http_server->listen(
       addr => {
          family   => $args->{family},
          ip       => $args->{ip},
          socktype => $args->{socktype},
          port     => $args->{port}
       },
       on_listen_error => sub { die 'Unable to start HTTP server' }
    );

    $self->http_server( $http_server );
    return $http_server;
}

1;
