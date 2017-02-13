#!/usr/bin/perl

#BUG/TODO global replace "testmode" => "DBG"

# This file generates a form and sends the resulting user input of new and existing
# design names to "opendesign.pl" as parameters "newdesign" and "file" respectively
# ---------------------------------------------------------------------------------
# "What is your name (e.g. "john", "mary", "shenwen")?     => "&newdesign"
#
# "Which design would you like to browse/modify?           => "&file"
#    100720-1310-ofer.htm
#    100718-2245-kyle.htm
#    ...
# "SUBMIT"
# ---------------------------------------------------------------------------------
# (Note: opendesign.pl will remove spaces and such from "name" leaving only [a-zA-Z0-9]

print "Content-type: text/html\n\n";

my $do_result  = do   './utils.pl';     #  includes get_system_dependences(), get_input_parms()

my $testmode = 1;
if ($testmode) { print embed_alert_script("called include file utils.pl...\n"); }

print build_title_and_intro();

print_form();

#sub build_toggletable {
#<script type="text/javascript"> 
#function ToggleTable(button_name, table_name) {
#    print '    var e = document.getElementById(table_name);';
#    print '    if (e.style.display == "") { e.style.display = "none"; }';
#    print '    else                       { e.style.display = "";     }';
#
#// also want to change button innerHTML text from "+ design" to "- design"
#
#//--></script>
#}

sub build_title_and_intro {

return ""
     . "<head><title>Interactive Chip Generator powered by Genesis</title></head>\n\n"

     . "<h2>Welcome to the Interactive Chip Generator!</h2>\n\n"

     . "<table style='width:520'><tr><td>\n"
     . "The Interactive Chip Generator (ICG) allows you to take an existing design base\n"
     . "and quickly modify it to produce a new design, customized for your specific needs.\n\n"

     . "<p>First, choose a base name for your design.  This can be any combination of\n"
     . "letters, numbers and hyphens, e.g. \"mydesign\" or \"smartmem-bob\".\n"
     . "The Interactive Chip Generator will append a timestamp to the base\n"
     . "name to create a unique version each time you save your design,\n"
     . "e.g. \"mydesign-100815-134333\" would be the version of \"mydesign\"\n"
     . "written on August 15, 2010 at 33 seconds after 1:43pm.\n"
     . "</td></tr></table>\n\n"

     . "<br />\n\n"
     ;
}


sub print_form {

    my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}
    my $opendesign = "$SYS{CGI_URL}/opendesign.pl"; # E.g. "/cgi-bin/genesis/opendesign.pl"
    if ($testmode) { print embed_alert_script("opendesign = $opendesign\n"); }

    #print "<form method=\"get\" action=\"$opendesign\">\n";
    print "<form method=\"get\" action=\"$SYS{CGI_URL}/foo.htm\">\n";

    print_base_name_request();

    print_choose_existing_design();

    print '  <p><input type="submit" value="Submit"><br />' ."\n".
	  '</form>' ."\n";

}

sub print_base_name_request {

    print '  <b>Base name for your new design</b> (e.g. "john" or "mary17" or "memtile7"): ';
    print '  <input type="text" name="newdesign" value="mydesign"><br />'."\n\n";
}

sub print_choose_existing_design {

    print "  <p>Now, choose an existing design as a base for your new design.\n\n";

    print '  <p><b>What existing design would you like to start from?</b><br /><br />'."\n\n";

    my $do_result  = do   './getdesigns.pl';     #  contains subroutine "getdesigns()"

    # Make a list of existing designs in the design directory.  ("newline" will be replaced by "<br>")
    # "tgt0-baseline" is the paradigmatic example.
    my $designs  = `ls -1 ../designs/tgt0/tgt0-baseline.xml` . "newline\n";

    my $designdirs = `ls -1d ../designs/* | 
                  egrep -v 'tgt0.broken|tmp.tgt0|designs.old|designs.save'`;
    my @designdirs = split /\n/, $designdirs;
    foreach my $designdir (@designdirs) {
	my $xml_exists =
	    `test -d $designdir && ls -1 $designdir/*.xml | egrep -v 'igns.tgt0.tgt0.baseline.xml'` or next;
	$designs .= $xml_exists . "newline\n"; # Gap (newline) after each design dir group.
    }


    my $designss = getdesigns();

    foreach my $k (sort keys(%$designss)) {
#	print "designdir = $k\n";
#	print "designs:\n" . $designss->{$k};

	my @list = split(" ", $designss->{$k});

	foreach my $design (@list) {

	    print "BAR ../designs/$k/$design\n";
	}

	print "\n";
    }

    foreach my $design (split /\n/, $designs) {
	print "FOO $design\n";
    }
    exit;




    # For prettiness, replace "newline" lines with "<br>".  Ignore designs in "old" or "save" dirs.
    # Select "baseline" design as the default.
    my @designs = split /\n/, $designs;
    foreach my $design (@designs) {

	if ($design eq "newline") { print "  <br />\n"; next; }
	if ($design =~ /designs.old/) { next; }
	if ($design =~ /designs.save/) { next; }

	my $selected = "";
	if ($design eq "../designs/tgt0/tgt0-baseline.xml") { $selected = "checked"; }
	print  "  <input type='radio' name='file' value='$design' $selected /><tt>$design</tt><br />\n";
    }





}


############################################################################
# NOTES:
#
# Web resources for CGI scripts:  Google "cgi script example"
#   http://www.perlfect.com/articles/url_decoding.shtml
#   http://www.it.bton.ac.uk/~mas/mas/courses/html/html3.html
#   http://www.jmarshall.com/easy/cgi/
#   http://www.comptechdoc.org/independent/web/cgi/cgimanual/cgiexample.html
############################################################################


