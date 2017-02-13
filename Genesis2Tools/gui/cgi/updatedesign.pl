#!/usr/bin/perl
use strict;

############################################################################
# New alg:
#   1. find the target module (as now)
#   2. foreach parm in target module
#      - do we have an update for this parm?  yes => overwrite, no => ignore
############################################################################

my %CLONE_LIST;
my %DELETE_LIST;

my $testtype = "";;

my $standalone = $ENV{GUI_STANDALONE};

my $incdir = $standalone ? mydir() : ".";
include_file("$incdir/utils.pl");                                   #  get_system_dependences(), mydir()
include_file("$incdir/updatedesign.dir/getparms.pl");               #  getparms()
include_file("$incdir/updatedesign.dir/build_xml_change_file.pl");  #  build_xml_change_file()

# include_file("./updatedesign.dir/build_xml_change_file2.pl"); #  build_xml_change_file2()
# include_file("./updatedesign.dir/emit_parms.pl");             #  emit_parms() used by build_xml_change_file()
# include_file("./updatedesign.dir/emit_parms2.pl");            #  emit_parms() used by build_xml_change_file()
# include_file("./updatedesign.dir/defined_parm.pl");           #  defined_parm()
# include_file("./updatedesign.dir/xml_utils.pl");              #  find_name_or_key(), skip_xml_block()
# include_file("./updatedesign.dir/rewrite_parmstring.pl");     #  rewrite_parmstring, used by getparms()

my $DBG9 = 0; # Set to 1 for low-level debug
my $SDBG = 0; # debug standalone mode

##############################################################################
# Need a header for the output file, so browser knows what's going on.

if (! $standalone) {
    print "Content-type: text/html\n\n";
    print "<title>Genesis GUI \"Submit Changes\" Debug/Info page</title>\n\n";
}

##########################################################################################
# Called from Button_SubmitChanges.js with QUERY_STRING e.g.
# setenv QUERY_STRING \
#        "newdesign=clyde"
#	."&curdesign=..%2Fdesigns%2Ftmp.cmp%2Fcmp-baseline.js"
#	."&modpath=top&DBG=1"
#	."&ASSERTION=OFF&MODE=VERIF&NUM_MEM_MATS=1&NUM_PROCESSOR=2&QUAD_ID=1&TILE_ID=1"

ud_alert("Welcome to updatedesign.pl\n\n"."querystring = \"$ENV{QUERY_STRING}\"\n\n");

############################################################################
# Can call standalone, for testing, using the "-test" command-line argument.

my $testmode = ($ARGV[0] eq "-test") ? 1 : 0;

##############################################################################
# This is how we would propagate vars to another module:
# set_testtype_for_emit_parms($testtype);

####################################################################################
# Set parms for testing, if desired.

if ($testmode) {
    $ENV{QUERY_STRING} = $ARGV[1];

    #print "now qstring = $ENV{QUERY_STRING}\n\n";

#    if ($testtype eq "new") {
#        $ENV{QUERY_STRING} .="&SPECIAL_DATA_MEM_OPS.0=%.deleteme";
#    }
#
#    $ENV{QUERY_STRING} = "newdesign=udtest"                  # ("Updatedesign test")
#	."&curdesign=updatedesign.dir%2Ftest%2Fcmp-baseline.js"
#	."&modpath=top.DUT.p0&DBG=1"
#	."&USE_SHIM=bar"
#	."&SPECIAL_DATA_MEM_OPS.0.name=4bar"
#	."&SPECIAL_DATA_MEM_OPS.0.tiecode=0foo"
#	."&SPECIAL_DATA_MEM_OPS.2.tiecode=2baz"
#	."&SPECIAL_DATA_MEM_OPS.0=%.cloneme";
}

##############################################################################
# First, unpack the parms $INPUT{curdesign} and $INPUT{modpath} etc.
# First four parms should be "newdesign", "curdesign," "modpath" and "DBG".
# Remaining parms are xml parameters that will be unpacked later by
# build_xml_changes_file.pl

my %INPUT;
getparms(\%INPUT);

my $DBG = $INPUT{DBG}; # Honor request for debugging.

tinymode();            # Check for tiny-xml version of design.

##############################################################################
# Need to know what directory the design lives in

my $curdesign = $INPUT{curdesign};  # E.g. "../designs/CMP/cmp-baseline.js"
$curdesign =~ s/\.js$/\.xml/;       # E.g. "../designs/CMP/cmp-baseline.xml"

$curdesign =~ /(.*)\/([^\/]+)$/;    # E.g. "(../designs/cmp)/(cmp-baseline.xml)
my $designdir     = $1;
#my $cur_basename = $2;  # Never used!!  Just need the directory.  Assumes base design "top.vp"

ud_alert("Found design dir \"$designdir\"\n\n".
      "Looking for module \"$INPUT{modpath}\"\n");

if ($testmode || $SDBG) { print "curdesign = $curdesign\n"; }
if ($testmode || $SDBG) { print "designdir = $designdir\n"; }
if ($testmode || $SDBG) { print "modpath   = $INPUT{modpath}\n"; }

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
ud_alert("newdesign = $id");

##############################################################################
# Create change file e.g. "clyde-100809-131500-changes.xml"

my $changefile  = "$id-changes.xml"; # E.g. "clyde-100809-131500-changes.xml"
my $newdesfname = "$id.js";          # E.g. "clyde-100809-131500.js"

# Use parms to generate xml.

my $modpath     = $INPUT{modpath};      # E.g. "top.DUT.cfg"

my $changefile_full_path = "$designdir/SysCfgs/$changefile";

if ($DBG9) { print "changefile_full_path = $changefile_full_path\n\n"; }

if ($testmode) {
    $changefile_full_path = "updatedesign.dir/test/tmp-udtest-out.xml";
   #$changefile_full_path = "tmp$testtype.xml";
}

# So...this happens everywhere, does it?  Sure, why not.
# See: updatedesign.csh, updatedesigndirs.pl, updatedesign.pl
#ud_alert(`cd $designdir; test -e SysCfgs || echo Create missing $designdir/SysCfgs...`);

my $err = `cd $designdir; test -e SysCfgs || echo Create missing $designdir/SysCfgs ...`;
if ($err) { ud_alert($err); }

my $err = `cd $designdir; test -e SysCfgs || mkdir SysCfgs`;
if ($err) { ud_alert($err); }

ud_alert("Calling build_xml_change_file() to create \"$changefile_full_path\"");

my $xmlref_fname = $INPUT{xmlref}; # Should still work if $INPUT{xmlref} no existe.
#if ($xmlref_fname) {
#    print("\n\nI see xml ref filename \"$xmlref_fname\"\n");
#    print("This means that \"$curdesign\" is a tiny xml file, right?\n\n");
#}

build_xml_change_file($curdesign, $changefile_full_path, $xmlref_fname);

ud_alert("built xml change file \"$changefile_full_path\"");

#ud_alert(`ls $changefile_full_path 1> /tmp/$$ 2> /tmp/$$; cat /tmp/$$`); # Did it work???

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

#my $curdesign   = "..%2Fdesigns%2Ftmp.cmp%2Fcmp-baseline.js";
#my $newdesign   = "clyde";
#my $newdesfname = "clyde-100809-131500.js"

my $cgi_dir = mydir();
my $gui_dir = $cgi_dir; $gui_dir =~ s/cgi[\/]*$//; # "/foo/bar/gui/cgi/" => "/foo/bar/gui/"

#my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}
my %SYS = $standalone ?
    (
     "CGI_DIR"      => $cgi_dir,
     "GUI_HOME_DIR" => $gui_dir
     )
    : 
    get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}

# Path by which perl file finds the gui.
my $gui_dir = $SYS{GUI_HOME_DIR}; # E.g. "~steveri/smart_memories/Smart_design/ChipGen/bin/Genesis2Tools/gui";

$newdesfname = "$designdir/$newdesfname";  # E.g. "../designs/cmp/clyde-100809-131500.js"

my $php_basename = $id;

# Create a new design based on the javascript pointed to by $curdesign;
# give it a new name $newdesign; place gui for design in $php_basename-<pid>.php

# I'm pretty sure these are already set; but just in case...
$ENV{STANDALONE_GUI} = $standalone;
$ENV{STANDALONE_CGI_DIR} = $SYS{CGI_DIR};

my $tmpfile =         # E.g. "scratch/mydesign-110204-133000-4472" (130pm on 2/4/2011)
  build_new_php(      # Loaded from "utils.pl"
    $newdesfname,     # E.g. "../designs/cmp/mydesign-110204-133000.js" (just now created at 130pm)
    $newdesign,       # E.g. "mydesign"
    $php_basename,    # E.g. "mydesign-110204-133000"
    $modpath          # E.g. "top.DUT.p0"
);

ud_alert("$tmpfile.php should reflect new design file $newdesfname\n");

ud_alert("...and off we go!!!");

if ($standalone) { exit(0); }  # All done (if standalone)

# Path (URL) by which browser finds the gui, eg "http://www-vlsi.stanford.edu/ig/"
my $gui_url = "$SYS{SERVER_URL}$SYS{GUI_HOME_URL}";

# Jump to next php file.
print "<meta HTTP-EQUIV=\"REFRESH\" content=\"0; url=$gui_url/$tmpfile.php\">\n";

##############################################################################
# Issue debug messages in pop-up windows if DBG is turned on. E.g.
#
#  <script type="text/javascript"><!--
#     ud_alert('how d"ye do');
#   //--></script>

sub ud_alert {                # "ud_alert" so as not to collide w/util.pl's new "alert"
  if ($DBG == 0) { return; }

  my $s = shift(@_);     # E.g. "FOO! We are now at line 12\n"
  
  # Useful for placing timestamps on messages as they occur.
  # my ($second, $minute, $hour) = localtime();
  # my $clocktime = "$hour:$minute:$second";
  # $s = "$clocktime\n$s";

  if ($testmode || $standalone) { print "$s\n"; return; }   # Print to console and quit.

  print "<small>\n$s<br><br>\n</small>\n\n"; # Print to html behind alert box.

  my $script = embed_alert_script($s);       # From utils.pl
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

sub tinymode {
    my $query_string = $ENV{QUERY_STRING};
    $query_string =~ s/&/&<br>\n/g;

    # $DBG=1;

    ud_alert
        "Welcome to sub tinymode(), querystring=<br>\n<br>\n".
        "$query_string<br>\n<br>\n".
        "If we detect no tiny-xml, these parms will pass through unmodified.<br>\n".
        "<br>\n";

    ##############################################################################
    # Look for tiny-xml file.
    # It should have same name as curdesign except with a "tiny_" prefix.

    # Ugh, what an awful hack.  BUG/TODO just pass in the file with the .xml extension!!
    my $curdesign = $INPUT{curdesign};  # E.g. "../designs/CMP/cmp-baseline.js"
    $curdesign =~ s/\.js$/\.xml/;       # E.g. "../designs/CMP/cmp-baseline.xml"

    $curdesign =~ /(.*)\/([^\/]+)$/;    # E.g. "(../designs/CMP)/(cmp-baseline.xml)
    my $designdir    = $1;
    my $cur_basename = $2;

    my $tinyxml = $designdir."/tiny_".$cur_basename;

    ud_alert
        "curdesign currently is: $curdesign<br>\n".
        "looking for tinyxml file $tinyxml<br>\n";


    if (-e $tinyxml) {
        ud_alert "Found tiny-xml file.  Now must change parms to reflect<br>\n".
            "<b>$tinyxml</b> as curdesign and<br>\n".
            "<b>$curdesign</b> as xmlref; i.e. set<br>\n".
            "  \$INPUT{curdesign}= $tinyxml and<br>\n".
            "  \$INPUT{xmlref}   = $curdesign<br>\n<br>\n";

        $INPUT{curdesign} = $tinyxml;
        $INPUT{xmlref}    = $curdesign;
    }
    else {
        ud_alert
            "Found no tiny-xml file;<br>\n".
            "will produce fully-elaborated change file as usual.<br>";
    }
}

sub mydir {
    use Cwd 'abs_path';
    my $fullpath = abs_path($0); # Full pathname of script e.g. "/foo/bar/opendesign.pl"

    use File::Basename 'fileparse';
    my ($filename, $dir, $suffix) = fileparse($fullpath);
    return $dir;
}


####################################################################################################
