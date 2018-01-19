package Bot::BasicBot::Pluggable::Module::Giphy;

use EvilHomer::Imports;
extends qw/ Bot::BasicBot::Pluggable::Module /;

use POE::Future;
use URI;
use URI::QueryParam;
use JSON::MaybeXS;
use Net::Async::HTTP;
use Try::Tiny;

has api_key => (
    is => 'rw',
    default => sub { $ENV{GIPHY_API_KEY} }
);

has timeout => (
    is => 'ro',
    default => sub { 1 }
);

has agent => ( is => 'lazy' );
sub _build_agent( $self ) {
    my $agent = Net::Async::HTTP->new;
    $self->bot->io_async_loop->add( $agent );
    return $agent;
}

has giphy => ( is => 'lazy' );
sub _build_giphy( $self ) {
    my $u = URI->new('https://api.giphy.com/');
    $u->query_param( api_key => $self->api_key );
    return $u;
}

has format => (
    is => 'rw',
    default => sub { 'mp4' }
);

has json => ( is => 'lazy' );
sub _build_json {
    JSON::MaybeXS->new;
}

sub url( $self, $search ) {
    my $endpoint;

    if ( $search ) {
        $self->giphy->query_param( s => $search );
        $endpoint = 'translate';
    }
    else {
        $self->giphy->query_param_delete('s');
        $endpoint = 'random'
    }
    $self->giphy->path("v1/gifs/$endpoint");

    return $self->giphy->canonical->as_string;
}

sub image( $self, $data ) {
    my $format = $self->format;

    my $decoded_data = try {
        $self->json->decode( $data )
    } catch {
        warn $_[0];
        return undef;
    };
    return unless $decoded_data;

    my $image = $decoded_data->{data}->{image_original_url};
    return $image =~ s/gif$/$format/r if $image;
    return $decoded_data->{data}->{images}->{original}->{ $format };
}

sub fetch( $self, $search ) {
    my $future = $self->agent->GET( $self->url( $search ), timeout => $self->timeout );
    $future->on_fail( sub { warn $_[0] } );
    $self->image( $future->get->content );
}

sub get_guff( $self ) {
    Future->wrap( $self->fetch( undef ) );
}

sub told( $self, $message ) {
    my ( $command, $param ) = split(/\s+/, $message->{body}, 2);
    return unless $command eq '!gif';
    return $self->fetch( $param );
}

1;
