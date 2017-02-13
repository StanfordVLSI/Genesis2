package File::Tee;

our $VERSION = '0.07';

use strict;
use warnings;
no warnings 'uninitialized';

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(tee);

use Carp;

use Symbol qw(qualify_to_ref);
use POSIX qw(_exit);
use Fcntl qw(:flock);

sub tee (*;@) {
    @_ >= 2 or croak 'Usage: tee($fh, $target, ...)';

    my $fh = qualify_to_ref(shift, caller);

    my $last_mode;

    my @target;
    while (@_) {
        my $arg = shift @_;
        my %target;
        my %opts = ( ref $arg eq 'HASH' ? %$arg :
                     ref $arg eq 'CODE' ? ( process => $arg ) :
                                          ( open => $arg ) );

        $target{ignore_errors} = delete $opts{ignore_errors};
        $target{prefix} = delete $opts{prefix};
        $target{end} = delete $opts{end};
        $target{begin} = delete $opts{begin};
        $target{preprocess} = delete $opts{preprocess};
        $target{process} = delete $opts{process};
        unless (defined $target{process}) {
            $target{mode} = delete $opts{mode};
            $target{open} = delete $opts{open};
            $target{reopen} = delete $opts{reopen};
            $target{autoflush} = delete $opts{autoflush};
            $target{lock} = delete $opts{lock};
        }

        %opts and croak "bad options '".join("', '", keys %opts)."'";

        unless (defined $target{process}) {
            if (defined $target{reopen}) {
                croak "both 'open' and 'reopen' options used for the same target"
                    if defined $target{open};
                $target{open} = $target{reopen};
                $target{reopen} = 1;
            }
            elsif (!defined $target{open}) {
                croak "missing mandatory argument 'open'";
            }

            $target{autoflush} = 1 unless defined $target{autoflush};

            $target{open} = [$target{open}]
                unless ref $target{open} eq 'ARRAY';
            unless (defined $target{mode}) {
                if (ref $target{open}[0]) {
                    if (ref $target{open}[0] eq 'CODE') {
                        $target{mode} = 'CODE';
                    }
                    else {
                        $target{mode} = (defined $last_mode ? $last_mode : '>>&');
                    }
                }
                else {
                    my ($mode, $fn) = shift(@{$target{open}}) =~ /^(\+?[<>]{1,2}(?:&=?)?|\|-?|)\s*(.*)$/;

                    $mode = (defined $last_mode ? $last_mode : '>>') unless length $mode;
                    $mode = '|-' if $mode eq '|';

                    unshift @{$target{open}}, $fn
                        if length $fn;

                    $target{mode} = $mode;
                }
            }

            $target{mode} =~ /^(?:>{1,2}&?|\|-|CODE)$/ or croak "invalid mode '$target{mode}'";

            # file name is next argument or slurp everything when mode is '|-'
            unless (@{$target{open}} > 0) {
                if (ref $arg ne 'HASH' and @_) {
                    if ($target{mode} eq '|-') {
                        @{$target{open}} = splice @_;
                    }
                    else {
                        my $last_mode = $target{mode};
                        @{$target{open}} = shift;
                    }
                }
                else {
                    croak "missing target file name";
                }
            }

            $target{open}[0] = qualify_to_ref($target{open}[0], caller)
                if $target{mode} =~ tr/&//;

            unless ($target{mode} eq '|-')  {
                open my $teefh, $target{mode}, @{$target{open}}
                    or return undef;

                if ($target{reopen}) {
                    $target{mode} =~ s/>+/>>/;
                    close $teefh
                        or return undef;
                }
                else {
                    $target{teefh} = $teefh;
                    if ($target{autoflush}) {
                        my $oldsel = select $teefh;
                        $| = 1;
                        select $oldsel;
                    }
                }
            }
        }

        push @target, \%target;
    }

    my $fileno = eval { fileno($fh) };

    defined $fileno
        or croak "only real file handles can be tee'ed";

    unless (defined $fileno) {
        return undef;
    }

    # flush any data buffered in $fh
    my $oldsel = select($fh);
    my @oldstate = ($|, $%, $=, $-, $~, $^, $.);
    $| = 1;
    select $oldsel;

    open my $out, ">&$fileno" or return undef;

    $oldsel = select $out;
    $| = $oldstate[0];
    select $oldsel;

    my $pid = open $fh, '|-';
    unless ($pid) {
        defined $pid
            or return undef;

	$SIG{INT} = 'IGNORE';
        undef @ARGV;
        eval { $0 = "perl [File::Tee]" };

        my $error = 0;

        my $oldsel = select STDERR;
        $| = 1;

        for my $target (@target) {
            my $begin = $target->{begin};
            &$begin if $begin;
        }
        my $buffer = '';
        my $eof;
        while(!$error and !$eof) {
            my $read = sysread STDIN, $buffer, 16*1024, length $buffer;
            if ($read) {
                print $out substr $buffer, -$read;
            }
            else {
                $eof = 1;
            }
            while (!$error and length $buffer) {
                my $line;
                my $eol = index $buffer, $/;
                if ($eol >= 0) {
                    $line = substr $buffer, 0, $eol + length $/, '';
                }
                elsif ($eof) {
                    $line = $buffer;
                    $buffer = '';
                }
                else {
                    last;
                }

                for my $target (@target) {
                    my $cp = $line;
                    $cp = join('', $target->{preprocess}($cp)) if $target->{preprocess};
                    $cp = $target->{prefix} . $cp if length $target->{prefix};
                    my $process = $target->{process};
                    if ($process) {
                        my $ok;
                        $ok = &$process for ($cp);
                        $error = 1 unless ($ok or $target->{ignore_errors});
                    }
                    else {
                        my $teefh = $target->{teefh};
                        unless ($teefh) {
                            undef $teefh;
                            if (open $teefh, $target->{mode}, @{$target->{open}}) {
                                unless ($target->{reopen}) {
                                    $target->{teefh} = $teefh;
                                    if ($target->{autoflush}) {
                                        my $oldsel = select $teefh;
                                        $| = 1;
                                        select $oldsel;
                                    }
                                }
                            }
                            else {
                                $error = 1 unless $target->{ignore_errors};
                                next;
                            }
                        }
                        flock($teefh, LOCK_EX) if $target->{lock};
                        print $teefh $cp;
                        flock($teefh, LOCK_UN) if $target->{lock};

                        if ($target->{reopen}) {
                            unless (close $teefh) {
                                $error = 1 unless $target->{ignore_errors};
                            }
                            delete $target->{teefh};
                        }
                    }
                }
            }
        }

        for my $target (@target) {

            my $end = $target->{end};
            &$end if $end;

            my $teefh = $target->{teefh};
            if ($teefh) {
                unless (close $teefh) {
                    $error = 1 unless $target->{ignore_errors};
                }
            }
        }

        close $out or $error = 1;

        _exit($error);
    }
    # close $teefh;

    $oldsel = select($fh);
    no warnings 'once';
    ($|, $%, $=, $-, $~, $^, $.) = @oldstate;
    select($oldsel);

    return $pid;
}

1;
__END__

=head1 NAME

File::Tee - replicate data sent to a Perl stream

=head1 SYNOPSIS

  use File::Tee qw(tee);

  # simple usage:
  tee(STDOUT, '>', 'stdout.txt');

  print "hello world\n";
  system "ls";

  # advanced usage:
  my $pid = tee STDERR, { prefix => "err[$$]: ", reopen => 'my.log'};

  print STDERR "foo\n";
  system("cat /bad/path");


=head1 DESCRIPTION

This module is able to replicate data written to a Perl stream into
another streams. It is the Perl equivalent of the shell utility
L<tee(1)>.

It is implemeted around C<fork>, creating a new process for every
tee'ed stream. That way, there are no problems handling the output
generated by external programs run with L<system|perlfunc/system>
or by XS modules that don't go through L<perlio>.

=head2 API

The following function can be imported from this module:

=over 4

=item tee $fh, $target, ...

redirects a copy of the data written to C<$fh> to one or several files
or streams.

C<$target, ...> is a list of target streams specifications that can
be:

=over 4

=item * file names with optional mode specifications:

  tee STDOUT, '>> /tmp/out', '>> /tmp/out2';
  tee STDOUT, '>>', '/tmp/out', '/tmp/out2';

If the mode specification is a separate argument, it will affect all
the file names following and not just the nearest one.

If mode C<|-> is used as a separate argument, the rest of the
arguments are slurped as arguments for the pipe command:

   tee STDERR, '|-', 'grep', '-i', 'error';
   tee STDERR, '| grep -i error'; # equivalent

Valid modes are C<E<gt>>, C<E<gt>E<gt>>, C<E<gt>&>, C<E<gt>E<gt>&>
and C<|->. The default mode is C<E<gt>E<gt>>.

File handles can also be used as targets:

   open my $target1, '>>', '/foo/bar';
   ...
   tee STDOUT, $target1, $target2, ...;

Finally, code references can also be used as targets. The callback
will be invoked for every line written to the tee'ed stream with the
data in C<$_>. It has to return a true value on success or false if
some error happens. Also, note that the callback will be called from a
different process.

=item * hash references describing the targets

For instance:

  tee STDOUT, { mode => '>>', open => '/tmp/foo', lock => 1};

will copy the data sent to STDOUT to C</tmp/foo>.

The attributes that can be included inside the hash are:

=over 4

=item open => $file_name

=item reopen => $file_name

sets the target file or stream. It can contain a mode
specification and also be an array. For instance:

  tee STDOUT, { open => '>> /tmp/out' };
  tee STDOUT, { reopen => ['>>', '/tmp/out2'] };
  tee STDOUT, { open => '| grep foo > /tmp/out' };

If C<reopen> is used, the file or stream is reopen for every write
operation. The mode will be forced to append after the first
write.

=item mode => $mode

Alternative way to specify the mode to open the target file or stream

=item lock => $bool

When true, an exclusive lock is obtained on the target file before
writing to it.

=item prefix => $txt

Some text to be prepended to every line sent to the target file.

For instance:

  tee STDOUT, { prefix => 'OUT: ', lock => 1, mode => '>>', open => '/tmp/out.txt' };
  tee STDERR, { prefix => 'ERR: ', lock => 1, mode => '>>', open => '/tmp/out.txt' };

=item preprocess => sub { ... }

A callback function that can modify the data before it gets sent to
the target file.

For instance:

  sub hexdump {
    my $data = shift;
    my @out;
    while ($data =~ /(.{1,32})/smg) {
        my $line=$1;
        my @c= (( map { sprintf "%02x",$_ } unpack('C*', $line)),
                (("  ") x 32))[0..31];
        $line=~s/(.)/ my $c=$1; unpack("c",$c)>=32 ? $c : '.' /egms;
        push @out, join(" ", @c, '|', $line), "\n";
    }
    join('', @out);
  }

  tee BINFH, { preprocess => \&hexdump, open => '/tmp/hexout'};

=item autoflush => $bool

Sets autoflush mode for the target streams. Default is on.

=item ignore_errors => $bool

By default, when writting to the targets, any error will close the
tee'ed handle. This option allows to change that behaviour.

=item process => sub { ... }

the callback will be called for every line read (see using code
references as targets discussion above). This option can not be used
at the same time as most other options (open, reopen, lock, autoflush,
etc.).

=item begin => sub { ... }

=item end => sub { ... }

Those functions are called on the forked process before the first
write and when closing the handle respectively.

For instance:

  my @capture;
  tee STDERR, { process => sub { push @capture, $_ },
                end => sub { send_mail 'foo@bar.com', 'stderr capture', "@capture" } };


=back

=back

The funcion returns the PID for the newly created process.

Inside the C<tee> pipe process created, data is readed honouring the
input record separator C<$/>.

You could also want to set the tee'ed stream in autoflush mode:

  open $fh, ...;

  my $oldsel = select $fh;
  $| = 1;
  select $fh;

  tee $fh, "> /tmp/log";

=back

=head1 BUGS

Does not work on Windows (patches welcome).

Send bug reports by email or via L<the CPAN RT web|https://rt.cpan.org>.

=head1 SEE ALSO

L<IO::Capture>

L<IO::Tee> is a similar module implemented around tied file
handles. L<Tee> allows to launch external processes capturing their
output to some files. L<IO::CaptureOutput> allows to capture the
output generated from a child process or a subroutine.


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008, 2010, 2011 by Salvador FandiE<ntilde>o
(sfandino@yahoo.com)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut


