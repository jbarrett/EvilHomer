package EvilHomer::RandQuote;

use EvilHomer::Imports 'script';
use DBI;
use IO::All -utf8;

option stash_dir => (
    is => 'ro',
    required => 1,
    format => 's',
    doc => q{Where does the database live?}
);

option filename => (
    is => 'ro',
    format => 's',
    doc => q{Add quotes from this file (one per line)}
);

has dbh => ( is => 'lazy' );
sub _build_dbh( $self ) {
    my $db = catfile( $self->stash_dir, 'randquote.sqlite' );
    my $dsn = "dbi:SQLite:$db";
    my $dbh = DBI->connect_cached( $dsn );
    $dbh->{AutoCommit} = 0;
    $dbh->do('
        CREATE TABLE IF NOT EXISTS randquote (
            randquote TEXT PRIMARY KEY
        )
    ');
    return $dbh;
}

sub quote( $self ) {
    $self->dbh->selectrow_array('
        SELECT randquote
        FROM   randquote
        ORDER BY RANDOM()
        LIMIT 1
    ');
}

sub insert( $self, $quote ) {
    $self->dbh->do('
        INSERT INTO randquote ( randquote )
        VALUES ( ? )
    ', {}, $quote);
}

sub add( $self, $quote ) {
    $self->insert( $quote );
    $self->dbh->commit;
}

sub add_from_file( $self, $filename ) {
    $self->insert( $_ ) for ( grep { $_ } io( $filename )->chomp->slurp );
    $self->dbh->commit;
}

sub run( $self ) {
    if ( $self->filename ) {
        $self->add_from_file( $self->filename );
    }
    else {
        say $self->quote;
    }
}

1;
