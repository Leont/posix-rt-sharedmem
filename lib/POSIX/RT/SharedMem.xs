/*
 * This software is copyright (c) 2010 by Leon Timmermans <leont@cpan.org>.
 *
 * This is free software; you can redistribute it and/or modify it under
 * the same terms as perl itself.
 *
 */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <sys/mman.h>
#include <sys/stat.h>        /* For mode constants */
#include <fcntl.h>           /* For O_* constants */
#include <string.h>

static void get_sys_error(char* buffer, size_t buffer_size) {
#ifdef _GNU_SOURCE
	const char* message = strerror_r(errno, buffer, buffer_size);
	if (message != buffer) {
		memcpy(buffer, message, buffer_size -1);
		buffer[buffer_size] = '\0';
	}
#else
	strerror_r(errno, buffer, buffer_size);
#endif
}

MODULE = POSIX::RT::SharedMem				PACKAGE = POSIX::RT::SharedMem

PROTOTYPES: DISABLED

int _shm_open(name, flags, mode)
	const char* name;
	int flags;
	int mode;
	CODE:
		RETVAL = shm_open(name, flags, mode);
		if (RETVAL == -1) {
			char buffer[128];
			get_sys_error(buffer, sizeof buffer);
			Perl_croak(aTHX_ "Can't open shared memory '%s': %s", name, buffer);
		}
	OUTPUT:
		RETVAL

void shared_unlink(name);
	const char* name;
	CODE:
		if (shm_unlink(name) == -1) {
			char buffer[128];
			get_sys_error(buffer, sizeof buffer);
			Perl_croak(aTHX_ "Can't unlink shared memory '%s': %s", name, buffer);
		}
