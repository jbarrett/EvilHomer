package Bot::BasicBot::Pluggable::Hookable::Hook::NeedVoice;

use EvilHomer::Imports 'role';

around say => sub( $orig, $self, %args ) {
    if ( $args{channel} =~ /^#/ &&
         $self->pocoirc->has_channel_voice( $args{channel}, $self->nick ) ) {

         $orig->( $self, %args );
     }
};

1;

