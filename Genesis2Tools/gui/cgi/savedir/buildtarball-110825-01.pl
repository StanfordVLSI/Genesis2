#!/usr/bin/perl
use strict;

##############################################################################
# Build a tarball for download.  Put it in the scratch directory.  Delete after download.
#
# Called from Misc.Download in ig/Misc.js with QUERY_STRING e.g.
# setenv QUERY_STRING "curdesign=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js

do './utils.pl'; #  includes get_system_dependences(), get_input_parms()

##############################################################################
# System-dependent variables:
#   1) Where the gui lives in the server's file system and
#   2) The URL path for the gui.

my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}
#print "hoodoo cgi dir is $SYS{CGI_DIR}\n"; exit;  # to test, uncomment this line.

my $BUILDTARBALL = "$SYS{CGI_URL}/buildtarball.pl"; # URL path used to access this script.

my $scratch_dir = "$SYS{GUI_HOME_DIR}/scratch"; # E.g. ~steveri/gui/scratch
my $scratch_url = "$SYS{GUI_HOME_URL}/scratch"; # E.g. /ig/scratch


my $design_url = "$SYS{GUI_HOME_URL}"; # E.g. "/genesis_dev_sr"

##############################################################################
# Need a header for the output file, so browser knows what's going on.

print "Content-type: text/html\n\n";

##############################################################################
# Can call standalone, for testing, using the "-test" command-line argument.
my $testmode = 0; if ($ARGV[0] eq "-test") { shift (@ARGV); $testmode = 1; }
if ($testmode) {
    $ENV{QUERY_STRING} = "curdesign=..%2Fdesigns%2Ftmp.tgt0%2Ftgt0-baseline.js".
	                 "&DBG=1";
    print "$ENV{QUERY_STRING}\n";
}

##############################################################################
# First, unpack the parms e.g. $INPUT{curdesign} 

my %INPUT;
my @parmlist = getparms();

my $DBG = $INPUT{DBG};

my $cleanup = $INPUT{cleanup};
if ($ARGV[0] eq "-cleanup") { $cleanup = 1; } # For testing from command line.

##############################################################################
# Need to know what directory the design lives in

my $curdesign = $INPUT{curdesign};    # E.g. "../designs/tgt0/tgt0-baseline.js"
#$curdesign =~ s/\.js$/\.xml/;        # E.g. "../designs/tgt0/tgt0-baseline.xml"

$curdesign =~ /(.*)\/([^\/]+).js$/;   # E.g. "(../designs/tgt0)/(tgt0-baseline).js
my $designdir = $1;
my $basename  = $2;

if ($DBG) {
    alert("\ncurdesign = $curdesign");
    alert(  "directory = $designdir");
    alert(  "base name = $basename\n");
    alert(  "cleanup   = $cleanup\n");
}

# What if two students are trying to modify same design at same time???

##############################################################################
# If cleanup flag is set, delete the tar file and exit.

if ($cleanup) {
  my $cmd = "rm $scratch_dir/$basename.tar";
  my $cmd_result = `$cmd 2>&1 `;
  alert("$cmd_result\n\n");
  print "Thank you!  Now use your browser's \"back\" button (twice) to return to the chip generator.";

  exit;
}

##############################################################################
# Create a tar file: No!  New regime.  Tar file should already exist.
# my $cmd = "cd $designdir; tar cf $basename.tar $basename.xml *.v";



##############################################################################
# Copy the existing tar file to a place where cgi script can access it.
# E.g. $scratch_dir = ~steveri/smart_memories/Smart_design/ChipGen/gui/scratch (see above).

# Check that scratch dir exists (should also check if writable?)
# NOTE: If the scratch dir doesn't exist, you must create it (with mkdir).

my $check = `cd $designdir; test -d $scratch_dir && echo -n 1 || echo -n 0`;
alert("check=.$check.\n\n");

if ($check != 1) {
    print "OOOPS Cannot find scratch directory $scratch_dir<br /n>\n";
    print "OOOPS Badness see builtarball.pl source code for help (sorry!)\n\n";
    exit;
}

# Check that tarball exists.
my $check = `test -f $designdir/$basename.tar && echo -n 1 || echo -n 0`;

if ($check != 1) {
    print "OOOPS Cannot find tar file \"$designdir/$basename.tar\"<br /n>\n";
    print "OOOPS Try rebuilding it by pushing your design's \"Submit changes\" button.\n\n";
    exit;
}

#my $cmd = "cp $designdir/$basename.tar $scratch_dir";
#my $cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout
#alert("$cmd_result\n\n");

##############################################################################
# How about a header?

print "<head>\n";
print "  <title>Genesis Download Page.</title>\n";
print "</head>\n\n";

##############################################################################
# Now we want to give the user an opportunity to
# 1) download the resulting file and then
# 2) delete/cleanup the directory

#print "<a href=\"$scratch_url/$basename.tar\">$basename.tar</a>\n";

print "design_url = \"$design_url\"\n\n<p>\n";
print "<a href=\"$design_url/designs/$designdir/$basename.tar\">\n";
print "  $basename.tar\n";
print "</a>\n";
print " <= Click to download a tar file foo including xml file\n";
print "and all generated *.v files.\n\n";

my $cleancmd = $BUILDTARBALL . "?" . $ENV{QUERY_STRING} . "&cleanup=1";

print "<p /><a href=\"$cleancmd\">Delete $basename.tar</a>\n";
print " <= Then PLEASE click here to clean up (delete the tar file).\n";

print "<p />Use your browser's \"back\" button to return to the chip generator.\n\n\n";

##############################################################################
# List all the .v files maybe.

print "Use the links below to download individual files if desired:\n";
print "<p />";

#my $cmd = "ls $designdir/$basename.tar $scratch_dir";
#my $cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout
#alert("$cmd_result\n\n");





##############################################################################
# Unpack the parm $INPUT{curdesign}  (and any others that may get added later).

sub getparms {
  my $pairnum = 0;
  my @parmlist;

  my $parms = $ENV{QUERY_STRING};
  my @fv_pairs = split /\&/ , $parms;
  foreach my $pair (@fv_pairs) {
      if($pair=~m/([^=]+)=(.*)/) {
  	my $field = $1; my $value = $2;
  	$value =~ s/\+/ /g;
  	$value =~ s/%([\dA-Fa-f]{2})/pack("C", hex($1))/eg;
	$INPUT{$field}=$value;

	$pairnum++;
	if ($pairnum > 4) {
	  push(@parmlist, "<$field>$value</$field>");
	}
      }
  }
  return @parmlist;
}

sub alert {
  if ($DBG == 0) { return; }

  my $s = shift(@_);     # E.g. "FOO! We are now at line 12\n"

  if ($testmode) { print "$s\n"; return; }

  while (chomp($s)) {}       # Remove trailing <cr> characters
  if ($s eq "") { return; }  # If nothing left, skip it.

  $s =~ s/\n/\\n/g;  # Strip off trailing <cr> characters.
  $s =~ s/\'/\"/g;   # Single quotes can mess you up, man.

  print '<script type="text/javascript"><!--'."\n";
  print "alert(\'$s\');\n";
  print '//--></script>'."\n\n";
}
