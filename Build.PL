use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'POSIX::RT::SharedMem',
	license             => 'perl',
	dist_author         => 'Leon Timmermans <leont@cpan.org>',
	dist_version_from   => 'lib/POSIX/RT/SharedMem.pm',
	configure_requires  => {
		'Module::Build' => 0,
	},
	build_requires      => {
		'ExtUtils::CBuilder' => 0,
		'Module::Build' => 0,
		'Test::More'    => 0,
		'Test::Exception' => 0,
	},
	requires => {
		perl            => 5.008,
		Readonly        => 1.03,
		Exporter        => 5.57,
	},
	meta_merge => {
		resources       => {
			bugtracker  => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=POSIX::RT::SharedMem',
			repository  => 'http://github.com/Leont/posix-rt-sharedmem/tree',
		},
		keywords        => [ 'mmap', 'memory mapping', 'shared memory' ],
	},
	extra_linker_flags  => '-lrt',
	add_to_cleanup      => [ 'POSIX-RT-SharedMem-*' ],
	create_makefile_pl  => 'small',
	sign                => 1,
);

$builder->create_build_script();
