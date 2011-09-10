use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'POSIX::RT::SharedMem',
	##{ $plugin->get_prereqs ##}
	##{ $plugin->get_default('share_dir') ##}
);

if ($^O eq 'solaris' or $^O eq 'linux') {
	$builder->extra_linker_flags('-lrt');
}

$builder->create_build_script();
