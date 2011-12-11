package POSIX::RT::SharedMem;

use strict;
use warnings;

use Exporter 5.57 'import';
use XSLoader;
use Carp qw/croak/;
use Fcntl qw/O_RDONLY O_WRONLY O_RDWR O_CREAT/;
use Const::Fast;

use File::Map 'map_handle';

our @EXPORT_OK = qw/shared_open shared_unlink/;

XSLoader::load(__PACKAGE__, __PACKAGE__->VERSION);

const my $fail_fd       => -1;
const my $default_perms => oct '600';

my %flag_for = (
	'<'  => O_RDONLY,
	'+<' => O_RDWR,
	'>'  => O_WRONLY | O_CREAT,
	'+>' => O_RDWR | O_CREAT,
);

sub shared_open {    ## no critic (Subroutines::RequireArgUnpacking)
	my (undef, $name, $mode, %other) = @_;

	my %options = (
		perms  => $default_perms,
		offset => 0,
		flags  => 0,
		%other,
	);
	croak 'Not enough arguments for shared_open' if @_ < 2;
	$mode = '<' if not defined $mode;
	croak 'No such mode' if not defined $flag_for{$mode};
	croak 'Size must be given in creating mode' if $flag_for{$mode} & O_CREAT and $options{size} == 0;

	my $fh = _shm_open($name, $flag_for{$mode} | $options{flags}, $options{perms});
	$options{after_open}->($fh, \%options) if defined $options{after_open};

	$options{size} = -s $fh if not defined $options{size};
	croak 'Can\'t map empty file' if $options{size} == 0;    # Should never happen
	truncate $fh, $options{size} if $options{size} > -s $fh;

	$options{before_mapping}->($fh, \%options) if defined $options{before_mapping};
	map_handle $_[0], $fh, $mode, $options{offset}, $options{size};

	return $fh if defined wantarray;

	close $fh or croak "Could not close shared filehandle: $!";
	return;
}

1;    # End of POSIX::RT::SharedMem

__END__

#ABSTRACT: Create/open or unlink POSIX shared memory objects in Perl

=head1 SYNOPSIS

 use POSIX::RT::SharedMem qw/shared_open/;

 shared_open my $map, '/some_file', '>+', size => 1024, perms => oct(777);

=func shared_open $map, $name, $mode, ...

Map the shared memory object C<$name> into C<$map>. For portable use, a shared memory object should be identified by a name of the form '/somename'; that is, a string consisting of an initial slash, followed by one or more characters, none of which are slashes.

C<$mode> determines the read/write mode. It works the same as in open and map_file.

Beyond that it can take three named arguments:

=over 4

=item * size

This determines the size of the map. If the map is map has writing permissions and the file is smaller than the given size it will be lengthened. Defaults to the length of the file and fails if it is zero. It is mandatory when using mode C<< > >> or C<< +> >>.

=item * perms

This determines the permissions with which the file is created (if $mode is '+>'). Default is 0600.

=item * offset

This determines the offset in the file that is mapped. Default is 0.

=item * flags

Extra flags that are used when opening the shared memory object (e.g. C<O_EXCL>).

=back

It returns a filehandle that can be used to with L<stat>, L<chmod>, L<chown>. You should not assume you can read or write directly from it.

=func shared_unlink $name

Remove the shared memory object $name from the namespace. Note that while the shared memory object can't be opened anymore after this, it doesn't remove the contents until all processes have closed it.

=head1 SEE ALSO

=over 4

=item * L<File::Map>

=back

=cut
