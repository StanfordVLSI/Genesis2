#!/usr/bin/perl
use strict;

########################################################################
# Called from "index.htm" w/pre-selected QUERY_STRING parms for demos
# e.g. "newdesign=demo&file=../designs/demo/top.xml"

########################################################################
# Also called from "choosedesign.pl" w/user-selected QUERY_STRING parms
# e.g. "newdesign=mydesign&file=../designs/tgt0/tgt0-baseline.xml"

my $parms = $ENV{QUERY_STRING};

##############################################################################
# Can call standalone, for testing, using the "-test" command-line argument.
my $testmode = 0; if ($ARGV[0] eq "-test") { shift (@ARGV); $testmode = 1; }
if ($testmode) {
    print "Warning: standalone test mode\n";
    $parms = "newdesign=mydesign&file=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.xml";
}

if ($testmode) { print "calling include file utils.pl...\n"; }
my $do_result  = do   './utils.pl';     #  includes get_system_dependences(), get_input_parms()
#my $do_result = eval `cat ./utils.pl`; #  includes get_system_dependences(), get_input_parms()

if ($testmode) {
    print "...result is .$do_result.\n\n";
    print "If there are errors (e.g. result != 1) try:\n";
    print "     perl -f utils.pl\n\n";
    if ($do_result != 1) {exit;}
}

print "Content-type: text/html\n\n";
my $error_header = "<head><title>ChipGen Error</title></head><h1>ChipGen Error</h1>\n\n";

if ($do_result != 1) {
    print $error_header;
    print "<p>Looks like a problem with \"utils.pl\"<br />\n";
    print "Suggest you try:<br />\n";
    print "<p><tt><b>&nbsp;&nbsp;&nbsp;&nbsp;perl -f utils.pl<b><tt><br />\n";
    exit;
}



#################################################################################
my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}
#print "hoodoo cgi dir is $SYS{CGI_DIR}\n"; exit;  # to test, uncomment this line.

##############################################################################
# Unpack the parms: $INPUT{newdesign} and $INPUT{file}

my %INPUT = get_input_parms($parms);                    # from "do 'utils.pl'
#print "hoodoo newdesign is $INPUT{newdesign}\n"; exit; # to test, uncomment this line

my $dbg_msg = "<p><i>Found newdesign \"$INPUT{newdesign}\"<br />Found filename \"$INPUT{file}\"</i><br /><br />\n\n";

# Forgot newdesign name?
if ($INPUT{newdesign} eq "") {
    print $error_header;
    print "<p>Oops, you forgot to choose a new design name.<br />\n";
    print "Please use your browser's BACK button to go back and try again.\n";
    print $dbg_msg;
    exit;
}
# Invalid newdesign name?
elsif (! ($INPUT{newdesign} =~ /^[-a-zA-Z0-9_]+$/)) {
    print $error_header;
    print "<p>illegal name \"$INPUT{newdesign}\"<br />\n";
    print "must have letters and numbers ONLY, no spaces (e.g. \"john\" or \"mary17\")<br />\n";
    print "use BACK button on browser to try again.<br />\n";
    print $dbg_msg;
    exit;
}
# Forgot to choose an input design?
elsif ($INPUT{file} eq "") {
    print $error_header;
    print "<p>Oops, you forgot to choose an existing base design.<br />\n";
    print "Please use your browser's BACK button to go back and try again.\n";
    print $dbg_msg;
    exit;
}

my $newdesign = $INPUT{newdesign};  # E.g. "my_design_name"

# Build a javascript file that corresponds to the indicated xml file.

my $curdesign_xml = $INPUT{file};       # E.g. "../designs/tgt0/tgt0-baseline.xml"

if (! ($curdesign_xml =~ /(.*)(.xml)$/)) {
    my $alert = "Incorrect filename extension for \"$curdesign_xml\"; should be \".xml\"\n\n";
    print $error_header;
    print "<p>$alert\n";
    exit;    
}

# Path by which perl file finds the gui.
my $gui_dir = $SYS{GUI_HOME_DIR}; # E.g. "~steveri/smart_memories/Smart_design/ChipGen/gui";

my $curdesign_js = $1.".js"; # Root filename from split in above if-statement

my $cmd = "$gui_dir/xml-decoder/xml2js.csh $curdesign_xml > $curdesign_js";

my $DBG=0; if ($DBG) {
# if ($testmode) {print $cmd} else 

    print embed_alert_script($cmd);

    #print '<script type="text/javascript"><!--'."\n";
    #print "alert(\'$cmd\');\n";
    #print '//--></script>'."\n\n";
}

system($cmd);

#my $curdesign = $INPUT{file};       # E.g. "../designs/tgt0/tgt0-baseline.js"
my $curdesign = $curdesign_js;       # E.g. "../designs/tgt0/tgt0-baseline.js"

my $alert1 = "Input filename = \"$INPUT{file}\"";
my $alert2 = "Output filename = \"$curdesign\"";

$DBG+=0; if ($DBG) {
    print embed_alert_script($alert1);
    print embed_alert_script($alert2);

#    print '<script type="text/javascript"><!--'."\n";
#    print "alert(\'$alert1\');\n";
#    print "alert(\'$alert2\');\n";
#    print '//--></script>'."\n\n";
}

##############################################################################
# Build and jump to the indicated design.

# BUG/TODO should do a transfer to "updatedesign" here instead of going on as below...
# ...but that will create an added "make gen" delay that we don't really
# want for demos...maybe demos should call existing .php files directly somehow?

# Create a new design based on the javascript pointed to by $curdesign;
# give it a new name $newdesign; build and jump to new php file $php_basename-<pid>.php

my $php_basename = $newdesign;

my $tmpfile =         # E.g. "scratch/mydesign-4472"
  build_new_php(      # Loaded from "utils.pl"
    $curdesign,       # E.g. "../designs/tgt0/tgt0-baseline.js"
    $newdesign,       # E.g. "mydesign"
    $php_basename,    # E.g. "mydesign"
    "top"             # Always start at the top (module).
);

# Path (URL) by which the browser finds the gui.
my $gui_url = "$SYS{SERVER_URL}$SYS{GUI_HOME_URL}"; # E.g. "http://www-vlsi.stanford.edu/ig/"

#print "<!--\n";
print "<meta HTTP-EQUIV=\"REFRESH\" content=\"0; url=$gui_url/$tmpfile.php\">\n";
#print "-->\n";

#print embed_alert_script("transferring to $gui_url/$tmpfile.php");
#print "<a href=\"$gui_url/$tmpfile.php\">Click here to go to $gui_url/$tmpfile.php</a>\n";

