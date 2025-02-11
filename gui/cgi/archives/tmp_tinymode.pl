#!/usr/bin/env perl
use strict;

my $DBG = 1;
my $testmode = 0;

include_file("./utils.pl");     #  alert(), get_system_dependences()
include_file("./updatedesign.dir/getparms.pl");               #  getparms()

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

#alert("Welcome to updatedesign.pl\n\n"."querystring = \"$ENV{QUERY_STRING}\"\n\n");

my $query_string = $ENV{QUERY_STRING};
$query_string =~ s/&/&<br>/g;

print
    "Welcome to updatedesign.pl<br><br>\n"."querystring=<br>\n$query_string<br><br>\n".
    "Usually these parms get passed to \"updatedesign.pl\"<br>\n".
    "<br>\n";

# First runthrough:
#  newdesign=cmpdemo&
#  curdesign=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js&

# Second runthrough:
#   newdesign=cmpdemo&
#   curdesign=..%2Fdesigns%2Ftgt0%2Fcmpdemo-120209-104602.js&

##############################################################################
# Unpack the parms $INPUT{curdesign} and $INPUT{modpath} etc.
# First four parms should be "newdesign", "curdesign," "modpath" and "DBG".
# Remaining parms are xml parameters that will be unpacked later by
# build_xml_changes_file.pl

my %INPUT;
getparms(\%INPUT);

my $DBG = $INPUT{DBG}; # Honor request for debugging.


##############################################################################
# Look for tiny-xml file.  Should have same name as curdesign except with a
# "tiny_" prefix.


my $curdesign = $INPUT{curdesign};  # E.g. "../designs/tgt0/tgt0-baseline.js"
$curdesign =~ s/\.js$/\.xml/;       # E.g. "../designs/tgt0/tgt0-baseline.xml"

$curdesign =~ /(.*)\/([^\/]+)$/;    # E.g. "(../designs/tgt0)/(tgt0-baseline.xml)
my $designdir    = $1;
my $cur_basename = $2;

my $tinyxml = $designdir."/tiny_".$cur_basename;

print
    "<tt>".
    "curdesign currently is... <b>$curdesign</b>.<br>\n".
    "Want to find tinyxml file <b>$tinyxml</b>.<br>\n".
    "<br></tt>\n";

if (-e $tinyxml) {
    print "Whoa!  Found it!<br><br>\n\n";

}
else {
    print "Dang.  No such luck.<br><br>\n\n";
}


print
    "Okay...now what?<br>\n".
    "<br>\n".
    "Now call updatedesign.pl with<br>\n".
    "<b>$tinyxml</b> as curdesign and<br>\n".
    "<b>$curdesign</b> as xmlref...right?<br>\n".
    "<br>\n";

my $br = "\n";

print 
    '<script type="text/javascript"><!--'.$br.
    '  function foo_alert() {'.$br.
    '    alert("foo hey look i am foo_alert");'.$br.
    '    alert("i want to call...what...updatedesign.pl");'.$br.

    '    alert("with parms...what...'.  $query_string  .'");'.$br.




    '  }'.$br.
    '</script>'.$br.
    $br;


print
    "press button to continue<br>\n".
#    "<button onclick='alert(\"foo\")'>hi i am a button</button><br>\n".
    "<button onclick='foo_alert()'>hi i am a button</button><br>\n".
    "<br>\n";





# Next:
# Find candidate tiny-xml files
#    original input file
#    most-recently-generated "tiny" file

##########################################################################################

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
