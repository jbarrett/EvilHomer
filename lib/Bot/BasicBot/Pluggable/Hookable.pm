package Bot::BasicBot::Pluggable::Hookable;

use EvilHomer::Imports;
extends qw/ Bot::BasicBot::Pluggable /;
use Clone qw/ clone /;
use File::HomeDir;

use Module::Pluggable
    sub_name    => '_available_hooks',
    search_path => 'Bot::BasicBot::Pluggable::Hookable::Hook';

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

sub available_hooks {
    _available_hooks;
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
