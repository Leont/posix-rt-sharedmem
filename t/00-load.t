#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'POSIX::RT::SharedMem' );
}

diag( "Testing POSIX::RT::SharedMem $POSIX::RT::SharedMem::VERSION, Perl $], $^X" );
