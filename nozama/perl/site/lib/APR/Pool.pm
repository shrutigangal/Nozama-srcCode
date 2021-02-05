# 
# /*
#  * *********** WARNING **************
#  * This file generated by ModPerl::WrapXS/0.01
#  * Any changes made here will be lost
#  * ***********************************
#  * 01: lib/ModPerl/Code.pm:709
#  * 02: \xampp\perl\bin\.cpanplus\5.10.1\build\mod_perl-2.0.4\blib\lib/ModPerl/WrapXS.pm:626
#  * 03: \xampp\perl\bin\.cpanplus\5.10.1\build\mod_perl-2.0.4\blib\lib/ModPerl/WrapXS.pm:1175
#  * 04: \xampp\perl\bin\.cpanplus\5.10.1\build\mod_perl-2.0.4\Makefile.PL:423
#  * 05: \xampp\perl\bin\.cpanplus\5.10.1\build\mod_perl-2.0.4\Makefile.PL:325
#  * 06: \xampp\perl\bin\.cpanplus\5.10.1\build\mod_perl-2.0.4\Makefile.PL:56
#  * 07: \xampp\perl\bin\cpanp-run-perl.bat:21
#  */
# 


package APR::Pool;

use strict;
use warnings FATAL => 'all';


use APR ();
use APR::XSLoader ();
our $VERSION = '0.009000';
APR::XSLoader::load __PACKAGE__;



1;
__END__

=head1 NAME

APR::Pool - Perl API for APR pools




=head1 Synopsis

  use APR::Pool ();
  
  my $sp = $r->pool->new;
  my $sp2 = APR::Pool->new;
  
  # $sp3 is a subpool of $sp,
  # which in turn is a subpool of $r->pool
  $sp3 = $sp->new;
  print '$r->pool is an ancestor of $sp3'
      if $r->pool->is_ancestor($sp3);
  # but sp2 is not a sub-pool of $r->pool
  print '$r->pool is not an ancestor of $sp2'
      unless $r->pool->is_ancestor($sp2);
  
  # $sp4 and $sp are the same pool (though you can't
  # compare the handle as variables)
  my $sp4 = $sp3->parent_get;
  

  # register a dummy cleanup function
  # that just prints the passed args
  $sp->cleanup_register(sub { print @{ $_[0] || [] } }, [1..3]);
  
  # tag the pool
  $sp->tag("My very best pool");
  
  # clear the pool
  $sp->clear();
  
  # destroy sub pool
  $sp2->destroy;


=head1 Description

C<APR::Pool> provides an access to APR pools, which are used for an
easy memory management.

Different pools have different life scopes and therefore one doesn't
need to free allocated memory explicitly, but instead it's done when
the pool's life is getting to an end. For example a request pool is
created at the beginning of a request and destroyed at the end of it,
and all the memory allocated during the request processing using the
request pool is freed at once at the end of the request.

Most of the time you will just pass various pool objects to the
methods that require them. And you must understand the scoping of the
pools, since if you pass a long lived server pool to a method that
needs the memory only for a short scoped request, you are going to
leak memory. A request pool should be used in such a case. And vice
versa, if you need to allocate some memory for a scope longer than a
single request, then a request pool is inappropriate, since when the
request will be over, the memory will be freed and bad things may
happen.

If you need to create a new pool, you can always do that via the
C<L<new()|/C_new_>> method.


=head1 API

C<APR::Pool> provides the following functions and/or methods:





=head2 C<cleanup_register>

Register cleanup callback to run

  $pool->cleanup_register($callback);
  $pool->cleanup_register($callback, $arg);

=over 4

=item obj: C<$pool> ( C<L<APR::Pool object|docs::2.0::api::APR::Pool>> )

The pool object to register the cleanup callback for

=item arg1: C<$callback> ( CODE ref or sub name )

a cleanup callback CODE reference or just a name of the subroutine
(fully qualified unless defined in the current package).

=item opt arg2: C<$arg> ( SCALAR )

If this optional argument is passed, the C<$callback> function will
receive it as the first and only argument when executed.

To pass more than one argument, use an ARRAY or a HASH reference

=item ret: no return value

=item excpt:

if the registered callback fails, it happens when the pool is
destroyed. The destruction is performed by Apache and it ignores any
failures. Even if it didn't ignore the failures, most of the time the
pool is destroyed when a request or connection handlers are long gone.
However the error B<is> logged to F<error_log>, so if you monitor that
file you will spot if there are any problems with it.

=item since: 2.0.00

=back

If there is more than one callback registered (when
C<cleanup_register> is called more than once on the same pool object),
the last registered callback will be executed first (LIFO).

Examples:

No arguments, using anon sub as a cleanup callback:

  $r->pool->cleanup_register(sub { warn "running cleanup" });

One or more arguments using a cleanup code reference:

  $r->pool->cleanup_register(\&cleanup, $r);
  $r->pool->cleanup_register(\&cleanup, [$r, $foo]);
  sub cleanup {
      my @args = (@_ && ref $_[0] eq ARRAY) ? @{ +shift } : shift;
      my $r = shift @args;
      warn "cleaning up";
  }

No arguments, using a function name as a cleanup callback:

  $r->pool->cleanup_register('foo');












=head2 C<clear>

Clear all memory in the pool and run all the registered cleanups. This
also destroys all sub-pools.

  $pool->clear();

=over 4

=item obj: C<$pool> ( C<L<APR::Pool object|docs::2.0::api::APR::Pool>> )

The pool to clear

=item ret: no return value

=item since: 2.0.00

=back

This method differs from C<L<destroy()|/C_destroy_>> in that it is not
freeing the previously allocated, but allows the pool to re-use it for
the future memory allocations.











=head2 C<DESTROY>

C<DESTROY> is an alias to C<L<destroy|/C_destroy_>>. It's there so
that custom C<APR::Pool> objects will get properly cleaned up, when
the pool object goes out of scope. If you ever want to destroy an
C<APR::Pool> object before it goes out of scope, use
C<L<destroy|/C_destroy_>>.


=over 4

=item since: 2.0.00

=back













=head2 C<destroy>

Destroy the pool.

  $pool->destroy();

=over 4

=item obj: C<$pool> ( C<L<APR::Pool object|docs::2.0::api::APR::Pool>> )

The pool to destroy

=item ret: no return value

=item since: 2.0.00

=back

This method takes a similar action to C<L<clear()|/C_clear_>> and then
frees all the memory.











=head2 C<is_ancestor>

Determine if pool a is an ancestor of pool b

  $ret = $pool_a->is_ancestor($pool_b);

=over 4

=item obj: C<$pool_a> ( C<L<APR::Pool object|docs::2.0::api::APR::Pool>> )

The pool to search

=item arg1: C<$pool_b> ( C<L<APR::Pool object|docs::2.0::api::APR::Pool>> )

The pool to search for

=item ret: C<$ret> ( integer )

True if C<$pool_a> is an ancestor of C<$pool_b>.

=item since: 2.0.00

=back

For example create a sub-pool of a given pool and check that the pool
is an ancestor of that sub-pool:

  use APR::Pool ();
  my $pp = $r->pool;
  my $sp = $pp->new();
  $pp->is_ancestor($sp) or die "Don't mess with genes!";









=head2 C<new>

Create a new sub-pool

  my $pool_child = $pool_parent->new;
  my $pool_child = APR::Pool->new;

=over 4

=item obj: C<$pool_parent> ( C<L<APR::Pool object|docs::2.0::api::APR::Pool>> )

The parent pool.

If you don't have a parent pool to create the sub-pool from, you can
use this object method as a class method, in which case the sub-pool
will be created from the global pool:

  my $pool_child = APR::Pool->new;

=item ret: C<$pool_child> ( C<L<APR::Pool object|docs::2.0::api::APR::Pool>> )

The child sub-pool

=item since: 2.0.00

=back









=head2 C<parent_get>

Get the parent pool

  $parent_pool = $child_pool->parent_get();

=over 4

=item obj: C<$child_pool> ( C<L<APR::Pool object|docs::2.0::api::APR::Pool>> )

the child pool

=item ret: C<$parent_pool> ( C<L<APR::Pool object|docs::2.0::api::APR::Pool>> )

the parent pool. C<undef> if there is no parent pool (which is the
case for the top-most global pool).

=item since: 2.0.00

=back

Example: Calculate how big is the pool's ancestry:

  use APR::Pool ();
  sub ancestry_count {
      my $child = shift;
      my $gen = 0;
      while (my $parent = $child->parent_get) {
          $gen++;
          $child = $parent;
      }
      return $gen;
  }



=head2 C<tag>

Tag a pool (give it a name)

  $pool->tag($tag);

=over 4

=item obj: C<$pool> ( C<L<APR::Pool object|docs::2.0::api::APR::Pool>> )

The pool to tag

=item arg1: C<$tag> ( string )

The tag (some unique string)

=item ret: no return value

=item since: 2.0.00

=back

Each pool can be tagged with a unique label. This can prove useful
when doing low level apr_pool C tracing (when apr is compiled with
C<-DAPR_POOL_DEBUG>). It allows you to grep(1) for the tag you have
set, to single out the traces relevant to you.

Though there is no way to get read the tag value, since APR doesn't
provide such an accessor method.





=head1 Unsupported API

C<APR::Pool> also provides auto-generated Perl interface for a few
other methods which aren't tested at the moment and therefore their
API is a subject to change. These methods will be finalized later as a
need arises. If you want to rely on any of the following methods
please contact the L<the mod_perl development mailing
list|maillist::dev> so we can help each other take the steps necessary
to shift the method to an officially supported API.








=head2 C<cleanup_for_exec>

META: Autogenerated - needs to be reviewed/completed

Preparing for exec() --- close files, etc., but *don't* flush I/O
buffers, *don't* wait for subprocesses, and *don't* free any memory.
Run all of the child_cleanups, so that any unnecessary files are
closed because we are about to exec a new program

=over

=item ret: no return value

=item since: subject to change

=back







=head1 See Also

L<mod_perl 2.0 documentation|docs::2.0::index>.




=head1 Copyright

mod_perl 2.0 and its core modules are copyrighted under
The Apache Software License, Version 2.0.




=head1 Authors

L<The mod_perl development team and numerous
contributors|about::contributors::people>.

=cut
