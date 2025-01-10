#!/usr/bin/env perl
use strict;

########################################################################
# Called from "index.htm" w/pre-selected QUERY_STRING parms for demos
# e.g. "newdesign=demo&file=../designs/demo/top.xml"

########################################################################
# Also called from "choosedesign.pl" w/user-selected QUERY_STRING parms
# e.g. "newdesign=mydesign&file=../designs/tgt0/tgt0-baseline.xml"

my $parms = $ENV{QUERY_STRING};

##############################################################################
# Can call -standalone (different than standalone-for-testing).

my $standalone = ($ARGV[0] eq "-standalone") ? 1 : 0;
my $SDBG = 0;                                       # Debug standalone mode

my $cgi_dir = $standalone ? mydir() : ".";

if ($SDBG) { print "Where am I?  Maybe I'm here:\n$cgi_dir\n\n"; }

##############################################################################
# For testing, can use the "-test" command-line argument.
my $testmode = 0; if ($ARGV[0] eq "-test") { shift (@ARGV); $testmode = 1; }
if ($testmode) {
    print "Warning: standalone test mode\n";
    # Should work either with or without "modpath" parm (?)
    $parms = "newdesign=mydesign&file=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.xml";
    $parms = $parms."&modpath=top.DUT.p0";
}

##############################################################################
if (! $standalone) { print "Content-type: text/html\n\n"; }

my $error_header = $standalone ? "" :                 # Print in case of error
    "<head><title>ChipGen Error</title></head><h1>ChipGen Error</h1>\n\n";

##############################################################################
#  utils.pl includes get_system_dependences(), get_input_parms()
if ($testmode) { print "\nCalling include file utils.pl ... "; }
my $do_result  = do "$cgi_dir/utils.pl";     

if ($do_result != 1) {
    if ($testmode || $standalone) {
        print "Result is \"$do_result\" (should be \"1\").\n\n";
        print "To debug, suggest you try:<br />\n";
        print "     perl -f utils.pl\n\n";
        exit;
    }
    print $error_header;
    print "<p>Looks like a problem with \"utils.pl\"<br />\n";
    print "Suggest you try:<br />\n";
    print "<p><tt><b>&nbsp;&nbsp;&nbsp;&nbsp;perl -f utils.pl<b><tt><br />\n";
    exit;
}

#################################################################################
my $ghd = $cgi_dir; $ghd =~ s/cgi[\/]*$//; # "/foo/bar/gui/cgi/" => "/foo/bar/gui/"
my %SYS = $standalone ?
    (
     "CGI_DIR"      => $cgi_dir,
     "GUI_HOME_DIR" => $ghd
     )
    : 
    get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}

# print "od: cgi dir is      '$SYS{CGI_DIR}'\n";
# print "od: gui home dir is '$SYS{GUI_HOME_DIR}'\n\n"; exit;

##############################################################################
# Unpack the parms: $INPUT{file} and $INPUT{newdesign}

my %INPUT = $standalone ?
    (
     file      => $ARGV[1],
     newdesign => $ARGV[2]  # bigdummy
     )
    : 
    get_input_parms($parms);                    # from "do 'utils.pl'

# print "\n\nhoodoo newdesign is \"$INPUT{newdesign}\"\n"; exit;

my $dbg_msg = "<p><i>Found newdesign \"$INPUT{newdesign}\"<br />Found filename \"$INPUT{file}\"</i><br /><br />\n\n";

# Forgot newdesign name?
if ($INPUT{newdesign} eq "") {
    print $error_header;
    print "<p>Oops, you forgot to choose a new design name\n";
    print "and/or you forgot to enter a valid e-mail address.<br />\n";
    print "Please use your browser's BACK button to go back and try again.\n";
    print $dbg_msg;
    exit;
}
# Invalid newdesign name?
# Okay, we'll allow percent, dash, underbar and plus.  Okay?

elsif (! ($INPUT{newdesign} =~ /^[a-zA-Z0-9._%+-@]+$/)) {
    print $error_header;
    print "<p>illegal name \"$INPUT{newdesign}\"<br />\n";
    print "must have letters and numbers ONLY, no spaces (e.g. \"john\" or \"mary17\")<br />\n";
    print "use BACK button on browser to try again.<br />\n";
    print $dbg_msg;
    exit;
    # (Some say this would be more precise: ^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$
    # (...but I don't really care if they put in a valid e-mail address maybe.)
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
my $curdesign_js = $1.".js"; # Root filename from split in above if-statement

# Path by which perl file finds the gui.
my $gui_dir = $SYS{GUI_HOME_DIR}; # E.g. "~steveri/smart_memories/Smart_design/ChipGen/bin/Genesis2Tools/gui";

my $DBG = $INPUT{DBG} ? 1 : 0;

#################################################################################
# Stats for the sweet
my $summary = "'$newdesign' '$curdesign_xml'"; # Part of mail subject hdr
my $msg1 = "opendesign.pl:";                   # msg[123] are lines in msg body
my $msg2 = "  new design '$newdesign'";
my $msg3 = "  is being built from base design '$curdesign_xml'";

my $mailer = "$SYS{GUI_HOME_DIR}/bin/gui_mail.csh";
my $cmd_result = `$mailer "$summary" "$msg1" "$msg2" "$msg3"`;

#chomp($cmd_result);
#print embed_alert_script("mail attempt says: '$cmd_result'");

#################################################################################
# If xml file is empty, or if xml file is named "empty.xml",
# then build a .js from scratch via updatedesign.csh(NONE)
my $nlines = `cat $curdesign_xml | wc -l`; chop $nlines; $nlines += 0;
if (($nlines < 5) || ($curdesign_xml =~ /\/empty.xml/)){

    # BUG/TODO: For now, deal_with_empty_file() is in utils.pl
    # However, should probably be moved to this file instead,
    # Since this is the only place it's ever called from...
    deal_with_empty_file($curdesign_xml, $DBG);
}

# Otherwise use xml2js to build the .js file directly.
else {
    my $cmd = "$gui_dir/xml-decoder/xml2js.csh $curdesign_xml > $curdesign_js";

    if ($DBG) {
        if ($standalone) {print "\n\n$cmd\n\n"}
        else             {print embed_alert_script($cmd);}
    }
    system($cmd);
}


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

my $modpath = $INPUT{modpath}; if ($modpath eq "") { $modpath = "top"; }

if ($testmode || $SDBG ) { print "modpath = \"$modpath\"\n"; }

# I'm pretty sure these are already set; but just in case...
$ENV{STANDALONE_GUI}     = $standalone;
$ENV{STANDALONE_CGI_DIR} = $SYS{CGI_DIR};

if ($SDBG) { print "calling utils.pl:build_new_php()...\n"; }
if ($DBG) { print embed_alert_script("calling utils.pl:build_new_php()..."); }

my $tmpfile =         # E.g. "scratch/mydesign-4472"
  build_new_php(      # Loaded from "utils.pl"
    $curdesign,       # E.g. "../designs/tgt0/tgt0-baseline.js"
    $newdesign,       # E.g. "mydesign"
    $php_basename,    # E.g. "mydesign"
    $modpath,         # E.g. "top" or "top.DUT.p0"
    $DBG
);

if ($DBG) { print embed_alert_script("utils.pl:built php file $tmpfile..."); }

if ($standalone) {
    if ($SDBG) {print "tmpfile = $tmpfile\n\n";}
    exit;
}

# Path (URL) by which the browser finds the gui.
my $gui_url = "$SYS{SERVER_URL}$SYS{GUI_HOME_URL}"; # E.g. "http://www-vlsi.stanford.edu/ig/"

if ($DBG) { print embed_alert_script("utils.pl:now off to \"$gui_url\" land..."); }

#print "<!--\n";
print "<meta HTTP-EQUIV=\"REFRESH\" content=\"0; url=$gui_url/$tmpfile.php\">\n";
#print "-->\n";

#print embed_alert_script("transferring to $gui_url/$tmpfile.php");
#print "<a href=\"$gui_url/$tmpfile.php\">Click here to go to $gui_url/$tmpfile.php</a>\n";

#BUG/TODO I don't think this is ever used; probably uses the one in utils.pl instead!!
sub mydir {
    use Cwd 'abs_path';
    my $fullpath = abs_path($0); # Full pathname of script e.g. "/foo/bar/opendesign.pl"

    use File::Basename 'fileparse';
    my ($filename, $dir, $suffix) = fileparse($fullpath);
    return $dir;
}
