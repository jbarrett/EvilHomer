package Bot::BasicBot::Pluggable::Hookable;

use EvilHomer::Imports;
extends qw/ Bot::BasicBot::Pluggable /;
use Clone qw/ clone /;
use Symbol qw/ delete_package /;
use File::HomeDir;
use IO::Async::Loop::POE;

use Module::Pluggable
    sub_name    => '_available_hooks',
    search_path => 'Bot::BasicBot::Pluggable::Hookable::Hook';

has io_async_loop => ( is => 'lazy' );
sub _build_io_async_loop {
    IO::Async::Loop::POE->new;
}

has enabled_hooks => (
    is => 'ro',
    default => sub { [] }
);

has stash_dir => (
    is => 'ro',
    default => sub {
        my $d = catdir( File::HomeDir->my_home, '.evilhomer' );
        mkdir $d unless -d $d;
        return $d;
    }
);

after unload => sub( $self, $module ) {
    delete_package "Bot::BasicBot::Pluggable::Module::$module";
};

sub available_hooks {
    _available_hooks;
}

sub available_modules_ref( $self ) {
    [ $self->available_modules ]
}

sub channels_ref( $self ) {
    [
        map { s/\s.*//r }
        $self->channels
    ]
}

sub update_loaded_set( $self, $modules ) {
    my @available = $self->available_modules;

    for my $module ( @available ) {
        warn "unload $module";
        $self->unload( $module )
            if !( grep { lc($module) eq lc($_) } @{ $modules } )
            && $self->module( $module );
        warn "unload $module complete";
    }

    for my $module ( @{ $modules } ) {
        $self->load( $module ) unless $self->module( $module );
    }
}

sub FOREIGNBUILDARGS( $class, %args ) {
    my $args_clone = clone( \%args );
    delete $args_clone->{$_}
        for ( qw/ enabled_hooks stash_dir / );
    return %{ $args_clone };
}

sub BUILD( $self, $args ) {
    require Moo::Role;
    my @roles = grep {
        my $available = $_;
        grep {
            $available =~ /::$_$/
        } @{ $self->enabled_hooks }
    } _available_hooks();
    Moo::Role->apply_roles_to_object( $self, @roles ) if @roles;
}

1;
