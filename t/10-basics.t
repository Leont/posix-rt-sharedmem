#!perl

use strict;
use warnings;
use POSIX::RT::SharedMem qw/shared_open shared_unlink/;
use Test::More tests => 9;
use Test::Exception;

my $random = int rand 1024;
my $name = "/test-posix-rt-$$-$random";

my $map;

eval { shared_unlink $name }; # pre-delete

lives_ok { shared_open $map, $name, '+>', size => 300 } "can open file '$name'";

{
	local $SIG{SEGV} = sub { die "Got SEGFAULT\n" };
	lives_ok { substr $map, 100, 6, "foobar" } 'Can write to map';
	ok($map =~ /foobar/, 'Can read written data from map');
}

my ($reader, $fh);
lives_ok { $fh = shared_open $reader, $name } 'Can open it readonly';

cmp_ok -s $fh, '>=', 300, 'File is (at least) 300 bytes';
ok -o $fh, 'File is owned by current user';
SKIP: {
	skip 'chmod is broken on ', 1 if $^O eq 'freebsd' or $^O eq 'darwin';
	ok chmod(0644, $fh), 'Can chmod handle';
}

lives_ok { shared_unlink $name } "Can unlink '$name'";

dies_ok { shared_open my $failer, $name } 'Can\'t open it anymore';

