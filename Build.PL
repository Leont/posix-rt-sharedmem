use strict;
use warnings;
use Devel::CheckLib;
use Module::Build;

my @extra_linker_flags = map { "-l$_" } grep { check_lib(lib => $_) } qw/rt/;

my $builder = Module::Build->new(
  module_name         => 'POSIX::RT::SharedMem',
  ##{ $plugin->get_prereqs ##}
  ##{ $plugin->get_default('share_dir') ##}
  extra_linker_flags  => \@extra_linker_flags,
);

$builder->create_build_script();
