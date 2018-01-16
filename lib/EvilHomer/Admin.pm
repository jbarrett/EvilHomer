package EvilHomer::Admin;

use Mojo::Base 'Mojolicious', -signatures;

has 'bot';

sub startup( $self ) {
    $self->_init_plugins;
    $self->_init_routes;
}

sub _init_plugins( $self ) {
    $self->plugin( xslate_renderer => {} );
    $self->renderer->default_handler('tx')
}

sub _init_routes( $self ) {
    my $r = $self->routes;
    $r->get('/' => sub( $c ) {
        $c->render( template => 'admin/index', bot => $self->bot );
    } );
}

1;
