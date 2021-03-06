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

    $r->post('/update_loaded_modules' => sub( $c ) {
        $self->bot->update_loaded_set( $c->req->body_params->names );
        $c->redirect_to('/');
    } );

    $r->post('/say' => sub( $c ) {
        $self->bot->say(
            channel => $c->req->body_params->param('channel'),
            body => $c->req->body_params->param('body')
        );
        $c->redirect_to('/');
    } );
}

1;
