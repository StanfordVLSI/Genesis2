#!/usr/bin/perl
use strict;

############################################################################
# New alg:
#   1. find the target module (as now)
#   2. foreach parm in target module
#      - do we have an update for this parm?  yes => overwrite, no => ignore
############################################################################

include_file("./utils.pl");                                   #  get_system_dependences()
include_file("./updatedesign.dir/getparms.pl");               #  getparms()
include_file("./updatedesign.dir/build_xml_change_file.pl");  #  build_xml_change_file()
include_file("./updatedesign.dir/emit_parms.pl");             #  emit_parms()
include_file("./updatedesign.dir/defined_parm.pl");           #  defined_parm()
include_file("./updatedesign.dir/xml_utils.pl");              #  find_name_or_key(), skip_xml_block()

my $RPDBG = 0; # Set to 1 for low-level debug

##############################################################################
# Need a header for the output file, so browser knows what's going on.

print "Content-type: text/html\n\n";

##########################################################################################
# Called from Button_SubmitChanges.js with QUERY_STRING e.g.
# setenv QUERY_STRING \
#        "newdesign=clyde"
#	."&curdesign=..%2Fdesigns%2Ftmp.tgt0%2Ftgt0-baseline.js"
#	."&modpath=top&DBG=1"
#	."&ASSERTION=OFF&MODE=VERIF&NUM_MEM_MATS=1&NUM_PROCESSOR=2&QUAD_ID=1&TILE_ID=1"


############################################################################
# Can call standalone, for testing, using the "-test" command-line argument.

my $testmode = ($ARGV[0] eq "-test") ? 1 : 0;
if ($testmode) {

    $ENV{QUERY_STRING} = "newdesign=udtest"                  # ("Updatedesign test")
	."&curdesign=updatedesign.dir%2Ftest%2Ftgt0-baseline.js"
	."&modpath=top.DUT.p0&DBG=1"
	."&USE_SHIM=bar"
	."&SPECIAL_DATA_MEM_OPS.0.name=4bar"
	."&SPECIAL_DATA_MEM_OPS.0.tiecode=0foo"
	."&SPECIAL_DATA_MEM_OPS.2.tiecode=2baz";
}

##############################################################################
# First, unpack the parms $INPUT{curdesign} and $INPUT{modpath} etc.
# First four parms should be "newdesign", "curdesign," "modpath" and "DBG".
# Remaining parms are xml parameters for xml "PARMLIST" e.g.
# $PARMLIST{NUM_MEM_MATS} = 1, etc.

my %PARMLIST;
my %INPUT;

getparms(\%INPUT, \%PARMLIST);


if ($testmode) {
    print "PARMLIST{SPECIAL_DATA_MEM_OPS}{0}{tiecode} = "
	.$PARMLIST{SPECIAL_DATA_MEM_OPS}{0}{tiecode}."\n";

    print "PARMLIST{SPECIAL_DATA_MEM_OPS}{2}{tiecode} = "
	.$PARMLIST{SPECIAL_DATA_MEM_OPS}{2}{tiecode}."\n\n";
}

my $DBG = $INPUT{DBG};

alert("Welcome to updatedesign.pl\n\n".
      "querystring = \"$ENV{QUERY_STRING}\"\n");

##############################################################################
# Need to know what directory the design lives in

my $curdesign = $INPUT{curdesign};  # E.g. "../designs/tgt0/tgt0-baseline.js"
$curdesign =~ s/\.js$/\.xml/;       # E.g. "../designs/tgt0/tgt0-baseline.xml"

$curdesign =~ /(.*)\/([^\/]+)$/;    # E.g. "(../designs/tgt0)/(tgt0-baseline.xml)
my $designdir     = $1;
#my $cur_basename = $2;  # Never used!!  Just need the directory.  Assumes base design "top.vp"

alert("Found design dir \"$designdir\"\n\n".
      "Looking for module \"$INPUT{modpath}\"\n");

if ($testmode) { print "curdesign = $curdesign\n"; }
if ($testmode) { print "directory = $designdir\n"; }
if ($testmode) { print "modpath   = $INPUT{modpath}\n"; }

##############################################################################
# Add timestamp to design name.   E.g. if design name is "my_design"
# and new timestamp is "100903-115500", new id is
# "my_design-100903-115500"

my $newdesign = $INPUT{newdesign};            # E.g. "my_design" or "amplifier17" or "clyde"
if ($newdesign eq "") {
  print "ERROR: new design name is null\n\n"; exit;
}

# Make a unique id based on design name e.g. "clyde" and current time:
# "clyde-100809-131500" means "clyde, Aug 9, 2010 at 1:15pm"
my $timestamp = `date +%y%m%d-%H%M%S`; chomp($timestamp);

my $id = "$newdesign-$timestamp";
alert("newdesign = $id\n");

##############################################################################
# Create change file e.g. "clyde-100809-131500-changes.xml"

my $changefile  = "$id-changes.xml"; # E.g. "clyde-100809-131500-changes.xml"
my $newdesfname = "$id.js";          # E.g. "clyde-100809-131500.js"

# Use parms to generate xml.

my $modpath     = $INPUT{modpath};      # E.g. "top.DUT.cfg"

my $changefile_full_path = "$designdir/SysCfgs/$changefile";

if ($testmode) {
    $changefile_full_path = "updatedesign.dir/test/tmp-udtest-out.xml";
}

# So...this happens everywhere, does it?  Sure, why not.
# See: updatedesign.csh, updatedesigndirs.csh, updatedesign.pl
alert(`cd $designdir; test -e SysCfgs || echo Create missing $designdir/SysCfgs...`);
my $err = `cd $designdir; test -e SysCfgs || mkdir SysCfgs`;

alert("Creating change file \"$changefile_full_path\"\n");
 
build_xml_change_file($curdesign,
		      $changefile_full_path,
		      $modpath,
		      \%PARMLIST
		      );

#alert(`ls $changefile_full_path 1> /tmp/$$ 2> /tmp/$$; cat /tmp/$$`); # Did it work???

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

#my $curdesign   = "..%2Fdesigns%2Ftmp.tgt0%2Ftgt0-baseline.js";
#my $newdesign   = "clyde";
#my $newdesfname = "clyde-100809-131500.js"

my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}

# Path by which perl file finds the gui.
my $gui_dir = $SYS{GUI_HOME_DIR}; # E.g. "~steveri/smart_memories/Smart_design/ChipGen/gui";

# Path (URL) by which the browser finds the gui.
my $gui_url = "$SYS{SERVER_URL}$SYS{GUI_HOME_URL}"; # E.g. "http://www-vlsi.stanford.edu/ig/"

$newdesfname = "$designdir/$newdesfname";  # E.g. "../designs/tgt0/clyde-100809-131500.js"

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
  
 #my ($second, $minute, $hour) = localtime();
 #my $clocktime = "$hour:$minute:$second";
 #$s = "$clocktime\n$s";


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

    if ($do_result != 1) {
	print "Looks like a problem with \"$do_file\"\n";
	print "Suggest you try:\n";
	print "    perl -f $do_file\n";
	exit;
    }
}


####################################################################################################

