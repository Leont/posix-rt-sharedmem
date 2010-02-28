#!perl

use strict;
use warnings;
use POSIX::RT::SharedMem qw/shared_open shared_unlink/;
use Test::More tests => 2;
use Test::Exception;

my $map;
lives_ok { shared_open $map, '/name', '+>', size => 300 } "can open file '/name'";

lives_ok { shared_unlink '/name' } "Can unlink '/name'"
