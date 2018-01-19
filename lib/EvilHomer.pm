package EvilHomer;

use EvilHomer::Imports 'script';
use Plack::Builder;
use Mojo::Server::PSGI;
use EvilHomer::Admin;

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
        Hailo
        RandQuote
        Giphy
        GuffSpouter
        AsciiEmoji
        EightBall
        Skaal
        Karma
        Title
    / ] }
);

has default_hooks => (
    is => 'ro',
    default => sub { [ qw/
        HTTPServer
    / ] }
);

option http_username => (
    is => 'ro',
    format => 's',
    default => sub { $ENV{EVILHOMER_HTTP_USERNAME} },
);

option http_password => (
    is => 'ro',
    format => 's',
    default => sub { $ENV{EVILHOMER_HTTP_PASSWORD} }
);

has app => ( is => 'lazy' );
sub _build_app( $self ) {
    my $admin_server = Mojo::Server::PSGI->new;
    $admin_server->build_app( 'EvilHomer::Admin', bot => $self->bot );

    my $basic_auth_cb = sub( $username, $password, $env ) {
        $username eq $self->http_username && $password eq $self->http_password;
    };

    my $guff_app = sub {
        [
            200, [ "Content-Type" => "text/plain" ],
            [ $self->bot->module('guffspouter')->return_guff ],
        ]
    };

    my $app = builder {
        enable "Auth::Basic", authenticator => $basic_auth_cb;
        mount '/' => $guff_app;
        mount '/admin' => $admin_server->to_psgi_app;
    };

    return $app;
}

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
    $self->bot->init_http( { app => $self->app } );
    $self->bot->run;
}

1;
