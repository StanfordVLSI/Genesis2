#!/usr/bin/perl
use strict;
do './utils.pl'; #  includes get_system_dependences(), get_input_parms()
my $LDBG = 0;

# print system("echo foo");
# print system("egrep '^abc\$' /tmp/foo");

########################################################################################
# Execute any given script file (WITHIN STRICT LIMITS!!!)
# Yeah this is a Real Good Idea (tm).
#
# Usage:   do_anything.pl?<designdir>?<executable>
# Example: do_anything.pl?/home/steveri/fftgen?bin/do_test.csh
#
# Security:
#    1. <designdir> must exist and be registered in $SYS{GUI_HOME_URL}/tmp_safedirs
#    2. Cannot have string "/../" in the path

# Header for printing valid output to browser.
print "Content-type: text/html; charset=utf-8\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'."\n\n";

my $parms = $ENV{QUERY_STRING};                           # E.g. "../designs/FFTGenerator&/home/steveri/fftgen&bin/do_test.csh"
my ($designdir,$sourcedir,$script) = split /\&/ , $parms; # E.g. ("../designs/FFTGenerator", "/home/steveri/fftgen", "bin/do_test.csh")

# Canonicalize the dirname; remove double-slash, trailing slash
$sourcedir =~ s/[\/]+/\//;   # E.g. /gen/designs//fftgen" => "/gen/designs/fftgen"
$sourcedir =~ s/[\/]+$//;    # E.g. /gen/designs/fftgen/" => "/gen/designs/fftgen"

# Security: design dir must be registered in "tmp_safedirs"
my %SYS     = get_system_dependences();  # E.g. $SYS{GUI_HOME_DIR}
my $gui_dir = $SYS{GUI_HOME_DIR};        # E.g. "/nobackup/steveri/stewie_kiwi"
my $err = system("egrep '^$sourcedir\$' $gui_dir/tmp_safedirs > /dev/null");

if ($err) {
    print "ERROR (do_anything.pl): dir \"$sourcedir\" not safe\n";
    exit -1;
}
else {
    # Security: script path cannot have ".." in it anywhere.
    $script = "$sourcedir/$script";
    if ($script =~ /[.][.]/) {
        print "ERROR (do_anything.pl): dir \"$sourcedir\" not safe because of dots\n";
        exit -1;
    }
    else {
        # Everything checks out; go ahead and execute the script.
        if ($LDBG) { print "<br>Safe to execute \"$script\"<br><br>\n\n"; }
        if ($LDBG) { print "\n<br>\nExecuting script \"$script\"<br><br>\n\n"; }
        my $result = `cd $designdir; $script`;
        if ($LDBG) { print "\n\nResult was:<br>\n"; }
        print $result;
    }
}
