#!/usr/bin/perl

##############################################################################
# Build a tarball for download.  Put it in the scratch directory.  Delete after download.
#
# Called from Misc.Download in ig/Misc.js with QUERY_STRING e.g.
# setenv QUERY_STRING "curdesign=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js

##############################################################################
# System-dependent variables: 1) Where the gui lives in the server's file system and
# 2) The URL path for the gui.

my $GUI_HOME_DIR = "~steveri/smart_memories/Smart_design/ChipGen/gui";
my $GUI_HOME_URL = "/ig";                         # URL path used to access the gui.
my $BUILDTARBALL = "/cgi-bin/ig/buildtarball.pl"; # URL path used to access this script.

my $scratch_dir = "$GUI_HOME_DIR/scratch"; # Two ways to say the same thing.
my $scratch_url = "$GUI_HOME_URL/scratch";

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
# Biggest problem might be "tmp.php" collisions.

##############################################################################
# If cleanup flag is set, delete the tar file and exit.

if ($cleanup) {
  my $cmd = "rm $scratch_dir/$basename.tar";
  my $cmd_result = `$cmd 2>&1 `;
  alert("$cmd_result\n\n");
  exit;
}

##############################################################################
# Create a tar file

my $cmd = "cd $designdir; tar cf $basename.tar $basename.xml *.vp";

alert("Ready to execute \"$cmd\"");

my $cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout
alert("$cmd_result\n\n");


##############################################################################
# Now have to move the tar file to a place where cgi script can access it.
# E.g. $scratch_dir = ~steveri/smart_memories/Smart_design/ChipGen/gui/scratch (see above).

# Check that scratch dir exists (should also check if writable?)
# NOTE: If the scratch dir doesn't exist, you must create it (with mkdir).

my $check = `cd $designdir; test -d $scratch_dir && echo -n 1 || echo -n 0`;
alert("check=.$check.\n\n");

if ($check != 1) {
    print "OOOPS Cannot find scratch directory $scratch_dir\n";
    print "OOOPS Badness see builtarball.pl source code for help (sorry!)\n\n";
    exit;
}

$cmd = "mv $designdir/$basename.tar $scratch_dir";
$cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout
alert("$cmd_result\n\n");

##############################################################################
# Now we want to give the user an opportunity to
# 1) download the resulting file and then
# 2) delete/cleanup the directory

print "Click here to download the tar file:\n";
print "<a href=\"$scratch_url/$basename.tar\">$basename.tar</a><br />\n";

my $cleancmd = $BUILDTARBALL . "?" . $ENV{QUERY_STRING} . "&cleanup=1";

print "\n\nClick here to clean up (delete the tar file):\n";
print "<a href=\"$cleancmd\">Delete $basename.tar</a><br />\n\n";

print "Use your browser's \"back\" button to return to the chip generator.\n\n\n";

##############################################################################
# Unpack the parm $INPUT{curdesign}  (and any others that may get added later).

sub getparms {
  my $pairnum = 0;
  my @parmlist;

  my $parms = $ENV{QUERY_STRING};
  my @fv_pairs = split /\&/ , $parms;
  foreach $pair (@fv_pairs) {
      if($pair=~m/([^=]+)=(.*)/) {
  	$field = $1; $value = $2;
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

  $s = shift(@_);     # E.g. "FOO! We are now at line 12\n"

  if ($testmode) { print "$s\n"; return; }

  while (chomp($s)) {}       # Remove trailing <cr> characters
  if ($s eq "") { return; }  # If nothing left, skip it.

  $s =~ s/\n/\\n/g;  # Strip off trailing <cr> characters.
  $s =~ s/\'/\"/g;   # Single quotes can mess you up, man.

  print '<script type="text/javascript"><!--'."\n";
  print "alert(\'$s\');\n";
  print '//--></script>'."\n\n";
}

