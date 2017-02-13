#!/usr/bin/perl
use strict;

##############################################################################
# Build a tarball for download.
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

my $design_url = "$SYS{GUI_HOME_URL}/designs"; # E.g. "/genesis_dev_sr/designs"

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
  my $cmd = "rm $designdir/$basename.tar";
  my $cmd_result = `$cmd 2>&1 `;
  alert("$cmd_result\n\n");

  print "Thank you!  Now use your browser's \"back\" button (twice) to return to the chip generator.";
  exit;
}

##############################################################################
# Create a tar file: No!  New regime.  Tar file should already exist.
# It gets created every time we do a "make"...right?
# my $cmd = "cd $designdir; tar cf $basename.tar $basename.xml *.v";

##############################################################################
# Check that tarball exists.
my $check = `test -f $designdir/$basename.tar && echo -n 1 || echo -n 0`;

if ($check != 1) {
    print "OOOPS Cannot find tar file \"$designdir/$basename.tar\"<br /n>\n";
    print "OOOPS Try rebuilding it by pushing your design's \"Submit changes\" button.\n\n";
    exit;
}

##############################################################################
# How about a header?

print "<head>\n";
print "  <title>Genesis Download Page.</title>\n";
print "</head>\n\n";

##############################################################################
# Now we want to give the user an opportunity to
# 1) download the resulting file and then
# 2) delete/cleanup the directory

#print "<a href=\"$design_url/$designdir/$basename.tar\">\n";
#print "  Download $basename.tar</a>\n";
#print "<= Click to download a tar file including xml file\n";
#print "and all generated *.v files.\n\n";

print "\n\n<b>$basename.tar</b>\n";
print "<ul>\n";

#print "  <li><a href=\"$design_url/$designdir/$basename.tar\">Download</a>\n";
#print "      &lt;= Click to download tar file including xml file\n";
#print "      and all generated *.v files.\n\n";
#print "  </li>\n";

print "  <li><a href=\"$design_url/$designdir/$basename.tar\">Download</a>\n";
print "      &lt;= Click to download tar file including xml file\n";
print "      and all generated *.v files.\n\n";
print "  </li>\n";

#print "<a href=\"$design_url/$designdir/$basename.tar\">\n";
#print "  Download $basename.tar</a>\n";
#print "<= Click to download a tar file including xml file\n";
#print "and all generated *.v files.\n\n";

my $cleancmd = $BUILDTARBALL . "?" . $ENV{QUERY_STRING} . "&cleanup=1";


print "  <li><a href=\"$cleancmd\">Delete</a>\n";
print "      &lt;= Then PLEASE click here to clean up (delete the tar file).\n";
print "  </li>\n";

print "</ul>\n";





#print "<p /><a href=\"$cleancmd\">Delete $basename.tar</a>\n";
#print "<= Then PLEASE click here to clean up (delete the tar file).\n";

print "\n\n<p>\n";
print "Use the links below to access individual files if desired.\n";

print "\n\n<p>\n";
print "Use your browser's \"back\" button to return to the chip generator.\n";

##############################################################################
# List xml file and all the .v files as separate links.
# First, the xml file:

print "\n\n<p>\n";
print "<ul>\n";
my $cmd = "ls $designdir/$basename.xml";
my $cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout
alert("$cmd_result\n\n");
my $xml_file = $cmd_result;

#$xml_file =~ /..\/designs\/(.*)/; # E.g. "../designs/(mydesign-timestamp.xml)

$xml_file =~ /(.*)\/([^\/]+.xml)$/;   # E.g. "(../designs/tgt0)/(tgt0-baseline.xml)

#print "\n\n<p>\n";
print "  <li><a href=$design_url/$xml_file>$2</a>\n";
print "</ul>\n";

########################################################################
# Now, the *.v files:

print "\n\n<p>\n";
print "<ul>\n";
my $cmd = "ls $designdir/*.v";
my $cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout
alert("$cmd_result\n\n");

foreach my $vfile (split("\n", $cmd_result)) {
#    $vfile =~ /..\/designs\/(.*)/; # E.g. "../designs/(p0.v)
    $vfile =~ /(.*)\/([^\/]+.v)$/;   # E.g. "(../designs/tgt0)/(p0.v)
    print "  <li><a href=$design_url/$vfile>$2</a>\n";
}

#my $xml_file = $cmd_result;
#
#$xml_file =~ /..\/designs\/(.*)/; # E.g. "../designs/(mydesign-timestamp.xml)
#
##print "\n\n<p>\n";
#print "  <li><a href=$design_url/$xml_file>$1</a>\n";
print "</ul>\n";
#
#
##my $cmd = "ls $designdir/$basename.tar $designdir/*.v";
#
#
##print $cmd_result;



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
