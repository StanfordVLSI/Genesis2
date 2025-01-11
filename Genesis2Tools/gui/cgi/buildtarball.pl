#!/usr/bin/perl
use strict;

########################################################################################
# Build a tarball for download.
#
# Called from Misc.Download in ig/Misc.js with QUERY_STRING e.g.
# setenv QUERY_STRING "curdesign=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js

do './utils.pl'; #  includes get_system_dependences(), get_input_parms()

########################################################################################
# System-dependent variables

my %SYS          = get_system_dependences();        # E.g. $SYS{GUI_HOME_DIR}
my $BUILDTARBALL = "$SYS{CGI_URL}/buildtarball.pl"; # URL path to this script.
my $design_url   = "$SYS{GUI_HOME_URL}/designs";    # Eg "/genesis_dev_sr/designs"

########################################################################################
# Need a header for the output file, so browser knows what's going on.

print "Content-type: text/html; charset=utf-8\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'."\n\n";

######################################################################################
# Can call standalone, for testing, using the "-test" command-line argument.
my $testmode = 0; if ($ARGV[0] eq "-test") { shift (@ARGV); $testmode = 1; }
if ($testmode) {
    $ENV{QUERY_STRING} = "curdesign=..%2Fdesigns%2Ftmp.tgt0%2Ftgt0-baseline.js&DBG=1";
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

########################################################################################
# Notify the mothership!  Someone actually used the download function.
my $summary = "TARFILE BUILD! for $basename";  # Part of mail subject hdr
#my $msg1 = "buildtarball.pl:";                # msg[123] are lines in msg body
#my $msg2 = "  curdesign = $curdesign";
#my $msg3 = "  directory = $designdir";
#my $msg4 = "  base name = $basename";

my $mailer = "$SYS{GUI_HOME_DIR}/bin/gui_mail.csh";
#print embed_alert_script("mailer: $mailer");

#my $cmd_result = `$mailer "$summary" "$msg1" "$msg2" "$msg3" "$msg4"`;
my $cmd_result = `$mailer "$summary"`;

#chomp($cmd_result);
#print embed_alert_script("mail attempt says: '$cmd_result'");

##############################################################################
# BUG/TODO: need a lock?
# What if two students are trying to modify the same design at the same time???

##############################################################################
# If cleanup flag is set, delete the tar file and exit.

if ($cleanup) {
  my $cmd = "rm $designdir/$basename.tar";
  my $cmd_result = `$cmd 2>&1 `;
  if ($DBG) { alert("$cmd_result\n\n"); }

  print "Thank you!  Now use your browser's \"back\" button (twice) ".
        "to return to the chip generator.";
  exit;
}

##############################################################################
# Tar file should have been created by most recent "make"...right?
# Otherwise, would have to do:
# my $cmd = "cd $designdir; tar cf $basename.tar $basename.xml *.v";

##############################################################################
# Check that tarball exists.
my $check = `test -f $designdir/$basename.tar && echo -n 1 || echo -n 0`;

if ($check != 1) {
    print "OOOPS Cannot find tar file \"$designdir/$basename.tar\"<br /n>\n";
    print "OOOPS Try rebuilding it with your design's \"Submit changes\" button.\n\n";
    exit;
}

##############################################################################
# How about a header?

print "<head>\n";
print "  <title>Genesis Download Page.</title>\n";
print '  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">';
print "</head>\n";

##############################################################################
# Now we want to give the user an opportunity to
# 1) download the resulting file and then
# 2) delete/cleanup the directory

print "\n";
print "<a href=\"$design_url/$designdir/$basename.tar\">\n";
print "  <b>Tar file: $basename.tar</b>\n";
print "</a>\n";

print "\n";
print "<ul>\n";

print "  <li><a href=\"$design_url/$designdir/$basename.tar\">\n";
print "      Click here to download tar file including xml file\n";
print "      and all generated *.v files.\n";
print "  </a></li>\n";

my $safe_env = $ENV{QUERY_STRING};
$safe_env =~ s/\&/\&amp;/g;

#my $cleancmd = $BUILDTARBALL . "?" . $ENV{QUERY_STRING} . "&cleanup=1";
 my $cleancmd = $BUILDTARBALL . "?" .  $safe_env         . "&amp;cleanup=1";

print "\n";
print "  <li><a href=\"$cleancmd\">\n";
print "      Then PLEASE click here to clean up (delete the tar file).\n";
print "  </a></li>\n";

print "</ul>\n";

print "\n";
print "<p>";
print "Use your browser's \"back\" button to return to the chip generator,\n";
print "and/or use the links below to access individual files.\n";

##############################################################################
# List xml file and all the .v files as separate links.
# First, the xml file:

print "\n<p><b>XML parm file(s)*:</b>  ";

# List base, tiny and small designs IN ORDER
my $cmd = "(".
    "ls $designdir/$basename.xml;".
    "ls $designdir/small_$basename.xml;".
    "ls $designdir/tiny_$basename.xml;".
    ")";
my $cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout
if ($DBG) { alert("$cmd_result\n\n"); }

print "<br>\n<ul>\n";

foreach my $xml_file (split("\n", $cmd_result)) {
    $xml_file =~ /(.*)\/([^\/]+.xml)$/;   # E.g. "(../designs/tgt0)/(tgt0-baseline.xml)
    my $fname = $2;

    my $size = `wc -l $xml_file`;
    if (! ($size =~ /^([0-9]+) /)) { $size = "??"; } else { $size = $1; }
    print "  <li><a href=$design_url/$xml_file>$fname</a> ($size lines)\n";
}
print "</ul>\n";

explain_designs();

########################################################################
# Changes file $designdir/SysCgs/*$basename*.xml

print "\n<p><b>XML changes file:</b>\n";
print "<ul>\n";

my $cmd = "ls $designdir/SysCfgs/$basename-changes.xml";
my $cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout

my $changes_file = $cmd_result;

if ($changes_file =~ /(.*)\/(SysCfgs\/[^\/]+.xml)$/) {  # E.g. "(../designs/tgt0)/(SysCfgs/tgt0-baseline-changes.xml)
    my $fname = $2;
    if ($DBG) { alert("changes_file = ($1)($2)\n\n"); }

    my $chsize = `wc -l $changes_file`;
    if (! ($chsize =~ /^([0-9]+) /)) { $chsize = "??"; } else { $chsize = $1; }
    print "  <li><a href=$design_url/$changes_file>$fname</a> ($chsize lines)\n";
}
elsif ("$basename" eq "empty") {
    print "  <li><i>No changes file: \"empty\" design was generated from scratch.</i>\n";
}
else {
    print "  <li>ERROR: Couldn't find it!  See 'buildtarball.pl', search for this msg.\n";
    print "  <li>More info: tried to find cf = '$changes_file'\n";
    print "  <li>Also: cmd result was '$cmd_result'\n";
    print "  <li>Also: cmd looked for '$designdir/SysCfgs/$basename-changes.xml'\n";
    print "  <li>Also: designdir = '$designdir'\n";
    print "  <li>Also: basename = '$basename'\n";
}
print "</ul>\n";

##############################################################################
# List the Makefile(s)

print "\n<p><b>Makefile(s):</b>  ";

my $cmd = "ls $designdir/*akefile*";
my $cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout
if ($DBG) { alert("$cmd_result\n\n"); }

print "<br>\n<ul>\n";

foreach my $makefile (split("\n", $cmd_result)) {
    $makefile =~ /(.*)\/([^\/]+)$/;   # E.g. "(../designs/tgt0)/(makefile)
    my $fname = $2;
    print "  <li><a href=$design_url/$makefile>$fname</a>\n";
}
print "</ul>\n";

########################################################################
# Now, the *.v (and/or *.sv) files:

print "\n<p><b>Individual verilog files:</b>\n";
print "<ul>\n";

# Has to work for *.v and *.sv at least...
my $cmd = "ls $designdir/*.*v";
my $cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout
if ($DBG) { alert("$cmd_result\n\n"); }

foreach my $vfile (split("\n", $cmd_result)) {
    $vfile =~ /(.*)\/([^\/]+.*v)$/;   # E.g. "(../designs/tgt0)/(p0.v)
    print "  <li><a href=$design_url/$vfile>$2</a>\n";
}

# genesis_{verif,synth}/*.{v,sv}
$cmd = "ls $designdir/genesis_*/*.*v";
$cmd_result = `$cmd 2>&1 `;  # "2>&1" thingy captures stderr along with stdout
if ($DBG) { alert("$cmd_result\n\n"); }

foreach my $vfile (split("\n", $cmd_result)) {
    $vfile =~ /(.*)\/(genesis[^\/]+\/[^\/]+.*v)$/;   # E.g. "(../designs/tgt0)/(genesis_synth/p0.v)
    print "  <li><a href=$design_url/$vfile>$2</a>\n";
}

print "</ul>\n";

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

#sub alert {
#  if ($DBG == 0) { return; }
#
#  my $s = shift(@_);     # E.g. "FOO! We are now at line 12\n"
#
#  if ($testmode) { print "$s\n"; return; }
#
#  while (chomp($s)) {}       # Remove trailing <cr> characters
#  if ($s eq "") { return; }  # If nothing left, skip it.
#
#  $s =~ s/\n/\\n/g;  # Strip off trailing <cr> characters.
#  $s =~ s/\'/\"/g;   # Single quotes can mess you up, man.
#
#  print '<script type="text/javascript"><!--'."\n";
#  print "alert(\'$s\');\n";
#  print '//--></script>'."\n\n";
#}

sub explain_designs {
    print "<small><i>\n";
    print "*Base design is full XML representation of the entire design hierarchy including all ";
    print "base (template) module names, unique (generated) module names, instance ";
    print "names, mutable and immutable parameters and more; ";
    
    print "<b>small_</b> design is XML representation of the design ";
    print "hierarchy including only instance names and mutable parameters.  ";
    
    print "<b>tiny_</b> design is XML representation of the design ";
    print "hierarchy including only instance names and mutable parameters which ";
    print "are not at their default value.";
    print "</i></small>\n";
}
