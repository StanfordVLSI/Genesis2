#!/usr/bin/env perl
# gvp2.pl - lightweight Genesis2-style preprocessor.
# Reuses Genesis2::Manager's parser; keeps gvp.pl's flat single-eval execution
# model and all gvp.pl built-ins (parameter, mname, pp, emit, generate,
# generate_base, instantiate, synonym, pinclude).

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../PerlLibs";
use lib "$FindBin::Bin/../PerlLibs/ExtrasForOldPerlDistributions";

use FileHandle;
use File::Basename;
use Getopt::Long;
use Cwd qw(cwd);

use Genesis2::Manager;
use Genesis2::UniqueModule;

# -- CLI ---------------------------------------------------------------------

my $prog    = basename($0);
my $comment = "//";
my $rawperl = 0;
my $mname_cli;
my $help      = 0;
my @libdirs   = ("./");
my @incdirs   = ("./");
my %defparams = ();

my %opts = (
    "help"       => \$help,
    "libdirs=s"  => \@libdirs,
    "incdirs=s"  => \@incdirs,
    "defparam=s" => \%defparams,
    "pdebug"     => \$rawperl,
    "rawperl"    => \$rawperl,
    "mname=s"    => \$mname_cli,
    "comment=s"  => \$comment,
);

usage() and exit(1) if !GetOptions(%opts);
usage() and exit(0) if $help;

@libdirs = split(/,/, join(',', @libdirs));
@incdirs = split(/,/, join(',', @incdirs));

sub usage {
    print <<"_EOH_";
usage: $prog [--h] [--libdirs d] [--incdirs d] [--defparam p=v] file(s)
    --h              : This message
    --rawperl|pdebug : Output tidied raw perl for debugging instead of running it
    --mname  name    : Set top module name
    --libdirs d1,d2  : Add dirs to the perl \@INC path
    --incdirs d1,d2  : Add dirs to the include search path
    --defparam p=v   : Set parameter 'p' to value 'v'
    --comment str    : Set the comment start of output language to "str"
                       (default "//"; perl-escape becomes "str;")

_EOH_
}

# -- Inline subclass of Genesis2::Manager ------------------------------------

package GvpManager;

use parent -norequire, 'Genesis2::Manager';
use File::Basename;
use Cwd qw(cwd);

sub new {
    my ($class, %args) = @_;
    my $cmt  = defined $args{comment} ? $args{comment} : '//';
    my $self = bless {

        # state read by Genesis2::Manager::parse_file / include
        PrlEsc          => $cmt . ';',
        PRLESC          => quotemeta($cmt . ';'),
        IncludesPath    => $args{incdirs} || ['./'],
        SourcesPath     => $args{libdirs} || ['./'],
        ModuleHead      => [],
        ModuleBody      => [],
        ModuleTail      => [],
        LineComment     => $cmt,
        Debug           => 0,
        DependHistogram => {},
        DependHandle    => undef,
        CallDir         => cwd(),
        InfileSuffixes  => [".vp", ".svp", ".vph", ".cp", ".tclp"],
    }, $class;
    return $self;
}

# Replace Manager's heavyweight error (Term::ANSIColor + confess) with a
# simple stderr message + exit, matching gvp.pl's UX.
sub error {
    my ($self, $msg) = @_;
    my $loc = '';
    $loc = " at $Genesis2::Manager::infile line $Genesis2::Manager::inline"
      if $Genesis2::Manager::infile && $Genesis2::Manager::inline;
    print STDERR "ERROR$loc: $msg";
    print STDERR "\n" unless $msg =~ /\n\z/;
    exit 1;
}

package main;

# -- Driver ------------------------------------------------------------------

my $mgr = GvpManager->new(
    comment => $comment,
    incdirs => [@incdirs],
    libdirs => [@libdirs, '.'],
);

# Build the eval'd Perl program: preamble + parsed body.
my $ExecPerl = "";

# basic compile pragmas + extra @INC dirs from --libdirs
$ExecPerl .= "use strict;\nno strict 'refs';\nuse warnings;\n";
$ExecPerl .= "no warnings 'redefine';\n";
foreach my $d (@libdirs) {
    $ExecPerl .= "use lib \"$d\";\n";
}

# parameters from --defparam
$ExecPerl .= "my %parameters = (\n";
foreach my $p (keys %defparams) {
    $ExecPerl .= "\t$p\t=>\t$defparams{$p},\n";
}
$ExecPerl .= "\t);\n\n";

$ExecPerl .= "my \$comment = \"$comment\";\n\n";

# point Genesis2::UniqueModule::myself at STDOUT so the parser-generated
# `print { $Genesis2::UniqueModule::myself->{OutfileHandle} } '...'` lines
# stream to STDOUT, matching gvp.pl's behavior.
$ExecPerl .=
"\$Genesis2::UniqueModule::myself = { OutfileHandle => \\*STDOUT, LineComment => \"$comment\" };\n\n";

# gvp.pl built-ins (verbatim from gvpy/gvp.pl), plus pinclude.
$ExecPerl .= q{

# stash incdirs for pinclude
my @__gvp_incdirs = ();
sub __set_incdirs { @__gvp_incdirs = @_ }

sub parameter {
    my %argh = @_;
    my $name = "NAME";

    if (exists $argh{'name'}) { $name = $argh{'name'}; }

    if (exists $parameters{$name}) {
        print "$comment parameter $name => $parameters{$name} (command line)\n";
        return $parameters{$name};
    }
    if (exists $argh{'val'}) {
        print "$comment parameter $name => $argh{'val'} (default value)\n";
        return $argh{'val'};
    } else {
        print "$comment parameter $name => UNDEFINED\n";
        return undef;
    }
}

my $mname = "FIXME";
sub mname { return $mname }

sub pp {
    my $num = shift;
    my $fmt = shift;
    $fmt = "%02d" unless defined $fmt;
    return sprintf $fmt, $num;
}

sub emit { printf @_; }

# $self carries LineComment so the parser-emitted include-prelude print works,
# and is the root for generate()/instantiate() bookkeeping.
my $self = { LineComment => $comment };
bless $self;

sub generate {
    my $arg1 = shift;
    my $tname = ref($arg1) eq ref($main::self) ? $arg1 : shift;
    my $iname = shift;
    my %argh = @_;

    $self->{$tname}->{$iname}->{'tname'} = $tname;
    $self->{$tname}->{$iname}->{'iname'} = $iname;
    %{$self->{$tname}->{$iname}->{'params'}} = %argh;

    return bless $self->{$tname}->{$iname};
}

sub generate_base { generate(@_); }

sub instantiate {
    my $i = shift;

    emit "$i->{'tname'} /*PARAMS: ";
    my %params = %{$i->{'params'}};
    foreach my $k (keys %params) {
        emit "$k=>"; emit $params{$k}; emit " ";
    }
    emit " */ $i->{'iname'}";
}

sub synonym { }

sub pinclude {
    my $fn = shift;
    my $path;
    if (-f $fn) {
        $path = $fn;
    } else {
        for my $d (@__gvp_incdirs) {
            if (-f "$d/$fn") { $path = "$d/$fn"; last; }
        }
    }
    die "pinclude: cannot find $fn in '" . join(':', @__gvp_incdirs) . "'\n"
        unless defined $path;
    my $code = do { local (@ARGV, $/) = ($path); <> };
    my $r = eval $code;
    die $@ if $@;
    return $r;
}
};

# tell pinclude where to look
{
    my $list = join(',', map { "\"$_\"" } @incdirs);
    $ExecPerl .= "\n__set_incdirs($list);\n\n";
}

# parse each input file via Genesis2::Manager::parse_file.
# Mode 'main' (anything not /src|inc/) skips both the SUPER::to_verilog
# branch and the include-prelude branch — we just get the # line directives.
foreach my $f (@ARGV) {
    my $name =
      defined $mname_cli
      ? $mname_cli
      : (basename($f, ".vp", ".gvp", ".svp"));
    $ExecPerl .= "\$mname = \"$name\";\n";
    $mgr->parse_file($f, $mgr->{SourcesPath}, 'main');
}

# pinclude shim: Manager's parser only fast-paths `include(...)` (it adds the
# `$self->` prefix and a hidden semicolon at parse time). `pinclude(...)` falls
# through to the verbatim-push branch missing a trailing `;`. Patch those lines.
for my $stmt (@{$mgr->{ModuleBody}}) {
    $stmt =~ s/^(\s*pinclude\s*\([^\)]*\))(\s*)\n\z/$1;$2\n/;
}

$ExecPerl .= join('', @{$mgr->{ModuleBody}});

# -- Execute -----------------------------------------------------------------

if ($rawperl) {
    my $have_perltidy = 0;
    foreach my $d (split /:/, ($ENV{PATH} // '')) {
        if (-x "$d/perltidy") { $have_perltidy = 1; last; }
    }
    if ($have_perltidy) {
        if (open(my $fh, "|-", "perltidy -l 140 -sbl -ce -i=4 -ci=4")) {
            print $fh $ExecPerl;
            close($fh);
        } else {
            print STDERR "$prog: perltidy invocation failed ($!); emitting raw perl\n";
            print $ExecPerl;
        }
    } else {
        print STDERR "$prog: perltidy not found in PATH; emitting raw perl\n";
        print $ExecPerl;
    }
} else {
    eval $ExecPerl;
    if (defined $@ && $@ ne "") {
        my $err = $@;
        printf STDERR "Error: $err";

        my $base    = basename($ARGV[0] // "unknown");
        my $tmpfile = "/tmp/$base.$$\.pl";
        eval { unlink($tmpfile) };

        if (open my $fh, ">", $tmpfile) {
            print STDERR "\n$prog: dumping generated perl to $tmpfile..\n";
            print $fh $ExecPerl;
            close $fh;
            printf STDERR "$prog: running \"perl -w $tmpfile\" for debug info:\n%s\n", '-' x 80;
            system("perl -w $tmpfile");
            printf STDERR "%s\n", '-' x 80;
        } else {
            print STDERR "$prog: could not write $tmpfile\n";
        }
        exit 1;
    }
}

exit 0;
