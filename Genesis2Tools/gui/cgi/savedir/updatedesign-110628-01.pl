#!/usr/bin/perl
use strict;

########################################################################
#Possible new alg:
#  1. find the target module (as now)
#  2. foreach parm in target module
#     - do we have an update for this parm?  yes => overwrite, no => ignore
########################################################################

include_file("./utils.pl");                                   #  get_system_dependences()
include_file("./updatedesign.dir/getparms.pl");               #  getparms()
include_file("./updatedesign.dir/build_xml_change_file.pl");  #  build_xml_change_file()

#include_file("./updatedesign_build_xcf.pl"); #  build_xml_change_file()
#include_file("./updatedesign_build_xpl.pl"); #  build_xml_parm_list()

my $RPDBG = 0; # Set to 1 for low-level debug

##############################################################################
# Need a header for the output file, so browser knows what's going on.

print "Content-type: text/html\n\n";

print("Welcome to updatedesign.pl\n\n");

##########################################################################################
# Called from Button_SubmitChanges.js with QUERY_STRING e.g.
# setenv QUERY_STRING \
#        "newdesign=clyde"
#	."&curdesign=..%2Fdesigns%2Ftmp.tgt0%2Ftgt0-baseline.js"
#	."&modpath=top&DBG=1"
#	."&ASSERTION=OFF&MODE=VERIF&NUM_MEM_MATS=1&NUM_PROCESSOR=2&QUAD_ID=1&TILE_ID=1"


############################################################################
# Can call standalone, for testing, using the "-test" command-line argument.

my $testmode = 0; if ($ARGV[0] eq "-test") { $testmode = 1; }
if ($testmode) {

    $ENV{QUERY_STRING} = "newdesign=udtest"                  # ("Updatedesign test")
	."&curdesign=updatedesign.dir%2Ftest%2Ftgt0-baseline.js"
	."&modpath=top.DUT.p0&DBG=1"
	."&USE_SHIM=bar"
	."&SPECIAL_DATA_MEM_OPS.2.tiecode=foo";
}

##############################################################################
# First, unpack the parms $INPUT{curdesign} and $INPUT{modpath} etc.
# First four parms should be "newdesign", "curdesign," "modpath" and "DBG".
# Remaining parms are xml parameters for xml "PARMLIST" e.g.
# $PARMLIST{NUM_MEM_MATS} = 1, etc.

my %PARMLIST;
my %INPUT;

getparms(\%INPUT, \%PARMLIST);

my $DBG = $INPUT{DBG};

#alert("$ENV{QUERY_STRING}\n\n");


# ##############################################################################
# # Unpack encoded filename (I guess this was never used...???)
# 
# use URI::Escape;
# my $curdesign = $INPUT{curdesign};            # E.g. "..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js"
# $curdesign = uri_unescape($curdesign); # E.g. "../designs/tgt0/tgt0-baseline.js"

##############################################################################
# Need to know what directory the design lives in

my $curdesign = $INPUT{curdesign};  # E.g. "../designs/tgt0/tgt0-baseline.js"
$curdesign =~ s/\.js$/\.xml/;       # E.g. "../designs/tgt0/tgt0-baseline.xml"

$curdesign =~ /(.*)\/([^\/]+)$/;    # E.g. "(../designs/tgt0)/(tgt0-baseline.xml)
my $designdir     = $1;
#my $cur_basename = $2;  # Never used!!  Just need the directory.  Assumes base design "top.vp"

my $alert_msg  = "Found design dir \"$designdir\"\n\n";
   $alert_msg .= "Looking for module \"$INPUT{modpath}\"\n";
alert($alert_msg);

if ($testmode) { print "curdesign = $curdesign\n"; }
if ($testmode) { print "directory = $designdir\n"; }
if ($testmode) { print "modpath   = $INPUT{modpath}\n"; }

##############################################################################
# Add timestamp to design name.   E.g. if design name is "my_design"
# and new timestamp is "100903,1155", new id is
# "my_design-100903-1155"

my $newdesign = $INPUT{newdesign};            # E.g. "my_design" or "amplifier17" or "clyde"
if ($newdesign eq "") {
  print "ERROR: new design name is null\n\n";
  exit;
}

# Make a unique id based on design name e.g. "clyde" and current time:
# "clyde-100809.1315" means "clyde, Aug 9, 2010 at 1:15pm"
my $timestamp = `date +%y%m%d-%H%M%S`; chomp($timestamp);

my $id = "$newdesign-$timestamp";
alert("newdesign = $id\n");

##############################################################################
# Create change file e.g. "clyde-100809,1315-changes.xml"

my $changefile = "$id-changes.xml";  # E.g. "clyde-100809,1315-changes.xml"
my $newdesfname = "$id.js";          # E.g. "clyde-100809,1315.js"

# Use parms to generate xml.

my $modpath     = $INPUT{modpath};      # E.g. "top.DUT.cfg"

my $changefile_full_path = "$designdir/SysCfgs/$changefile";

if ($testmode) {
    $changefile_full_path = "updatedesign.dir/test/tmp-udtest-out.xml";
}

alert("Creating change file \"$changefile_full_path\"\n");

build_xml_change_file($curdesign,
#		      "$designdir/SysCfgs/$changefile",
		      "$changefile_full_path",
		      $modpath,
		      \%PARMLIST
#		      ,$testmode
		      );

# Did it work???
#$alert_msg = `ls $changefile_full_path 1> /tmp/$$ 2> /tmp/$$; cat /tmp/$$`;
#alert($alert_msg);


##############################################################################
# Call "Genesis2" based on "curdesign" path etc.
# Genesis2.pl -gen -top top -depend depend.list -product genesis_vlog.vf \
#             -hierarchy hierarchy_out.xml -debug 0 -xml SysCfgs/config.xml
#
# But we don't call Genesis2 directly: "updatedesign.csh" does all the work.

if ($testmode) { exit; } # Time to bug out.

updatedesign($designdir,
	     "SysCfgs/$changefile",
	     $newdesfname,
	     $DBG);

##############################################################################
# Build and transfer to a new php file.  To the user, it will seem as if
# nothing has changed on his or her screen.

#my $curdesign = "CURDESIGN";
#my $newdesign = "CLYDE";
#my $newdesfname = "$designdir/$timestamp";


my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}
#print "hoodoo cgi dir is $SYS{CGI_DIR}\n"; exit;  # to test, uncomment this line.

# Path by which perl file finds the gui.
my $gui_dir = $SYS{GUI_HOME_DIR}; # E.g. "~steveri/smart_memories/Smart_design/ChipGen/gui";

# Path (URL) by which the browser finds the gui.
my $gui_url = "$SYS{SERVER_URL}$SYS{GUI_HOME_URL}"; # E.g. "http://www-vlsi.stanford.edu/ig/"

$newdesfname = "$designdir/$newdesfname";

my $php_basename = $id;

# Create a new design based on the javascript pointed to by $curdesign;
# give it a new name $newdesign; place gui for design in $php_basename-<pid>.php

my $tmpfile =         # E.g. "scratch/mydesign-110204-133000-4472" (130pm on 2/4/2011)
  build_new_php(      # Loaded from "utils.pl"
    $newdesfname,     # E.g. "../designs/tgt0/mydesign-110204-133000.js" (just now created at 130pm)
    $newdesign,       # E.g. "mydesign"
    $php_basename,    # E.g. "mydesign-110204-133000"
    $modpath          # E.g. "top.DUT.p0"
);

alert("$tmpfile.php should reflect new design file $newdesfname\n");

alert("...and off we go!!!");

print "<meta HTTP-EQUIV=\"REFRESH\" content=\"0; url=$gui_url/$tmpfile.php\">\n";

##############################################################################
# Issue debug messages in pop-up windows if DBG is turned on. E.g.
#
#  <script type="text/javascript"><!--
#     alert('how d"ye do');
#   //--></script>

sub alert {
  if ($DBG == 0) { return; }

  my $s = shift(@_);     # E.g. "FOO! We are now at line 12\n"

  if ($testmode) { print "$s\n"; return; }

  my $script = embed_alert_script($s);    # From utils.pl

  print $script;
}

sub include_file {
    my $include_file = shift @_;
    my $do_result = do $include_file;
    check_do_error($include_file, $do_result);
}

sub check_do_error {
    my $do_file = shift @_;
    my $do_result = shift @_;

    my $error_header = "<head><title>ChipGen Error</title></head><h1>ChipGen Error</h1>\n\n";


    if ($do_result != 1) {
#	print $error_header;

	print "Looks like a problem with \"$do_file\"\n";
	print "Suggest you try:\n";
	print "    perl -f $do_file\n";
	exit;

#	print "<p>Looks like a problem with \"$do_file\"<br />\n";
#	print "Suggest you try:<br />\n";
#	print "<p><tt><b>&nbsp;&nbsp;&nbsp;&nbsp;perl -f $do_file<b><tt><br />\n";
#	exit;
    }
}


####################################################################################################

