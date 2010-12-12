package POSIX::RT::SharedMem;

use strict;
use warnings;

use Exporter 5.57 'import';
use XSLoader;
use Carp qw/croak/;
use Fcntl qw/O_RDONLY O_WRONLY O_RDWR O_CREAT/;
use Const::Fast;

use File::Map 'map_handle';

our $VERSION = '0.05';

our @EXPORT_OK = qw/shared_open shared_unlink/;

XSLoader::load('POSIX::RT::SharedMem', $VERSION);

const my $fail_fd       => -1;
const my $default_perms => oct '700';

my %flag_for = (
	'<'  => O_RDONLY,
	'+<' => O_RDWR,
	'>'  => O_WRONLY,
	'+>' => O_RDWR | O_CREAT,
);

sub shared_open {    ## no critic (Subroutines::RequireArgUnpacking)
	my (undef, $name, $mode, %other) = @_;

	my %options = (
		perms  => $default_perms,
		offset => 0,
		%other,
	);
	croak 'Not enough arguments for shared_open' if @_ < 2;
	$mode = '<' if not defined $mode;
	croak 'No such mode' if not defined $flag_for{$mode};
	croak 'Size must be given in creating mode' if $mode eq '+>' and $options{size} == 0;

	my $fd = _shm_open($name, $flag_for{$mode}, $options{perms});
	croak "Can't open shared memory object $name: $!" if $fd == $fail_fd;
	open my $fh, "$mode&", $fd or croak "Can't fdopen($fd): $!";
	$options{after_open}->($fh, \%options) if defined $options{after_open};

	$options{size} = -s $fh if not defined $options{size};
	croak 'can\'t map empty file' if $options{size} == 0;    # Should never happen
	truncate $fh, $options{size} if $options{size} > -s $fh;

	$options{before_mapping}->($fh, \%options) if defined $options{before_mapping};
	map_handle $_[0], $fh, $mode, $options{offset}, $options{size};

	return $fh if defined wantarray;

	close $fh or croak "Could not close shared filehandle: $!";
	return;
}

1;    # End of POSIX::RT::SharedMem

__END__

=head1 NAME

POSIX::RT::SharedMem - Create/open or unlink POSIX shared memory objects in Perl

=head1 VERSION

Version 0.05

=head1 SYNOPSIS

 use POSIX::RT::SharedMem qw/shared_open/;

 shared_open my $map, '/some_file', '>+', size => 1024, perms => oct(777);

=head1 FUNCTIONS

=head2 shared_open $map, $name, $mode, ...

Map the shared memory object C<$name> into C<$map>. For portable use, a shared memory object should be identified by a name of the form '/somename'; that is, a string consisting of an initial slash, followed by one or more characters, none of which are slashes.

C<$mode> determines the read/write mode. It works the same as in open and map_file.

Beyond that it can take two named arguments:

=over 4

=item * size

This determines the size of the map. If the map is map has writing permissions and the file is smaller than the given size it will be lengthened. Defaults to the length of the file and fails if it is zero.

=item * perms

This determines the permissions with which the file is created (if $mode is '+>'). Default is 0700.

=item * offset

This determines the offset in the file that is mapped. Default is 0.

=back

=head2 shared_unlink $name

Remove the shared memory object $name from the namespace. Note that while the shared memory object can't be opened anymore after this, it doesn't remove the contents until all processes have closed it.

=head1 AUTHOR

Leon Timmermans, C<< <leont at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-posix-rt-sharedmem at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=POSIX-RT-SharedMem>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc POSIX::RT::SharedMem

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=POSIX-RT-SharedMem>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/POSIX-RT-SharedMem>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/POSIX-RT-SharedMem>

=item * Search CPAN

L<http://search.cpan.org/dist/POSIX-RT-SharedMem>

=back

=head1 SEE ALSO

=over 4

=item * L<File::Map>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2010 Leon Timmermans, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
