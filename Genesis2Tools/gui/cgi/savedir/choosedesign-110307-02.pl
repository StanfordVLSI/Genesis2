#!/usr/bin/perl

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
#print "Content-type: text/plain\n\n";

print "<head><title>Interactive Chip Generator powered by Genesis</title></head>\n\n";

print "<h2>Welcome to the Interactive Chip Generator!</h2>\n\n";

print "<table style='width:520'><tr><td>\n";
print "The Interactive Chip Generator (ICG) allows you to take an existing design base\n";
print "and quickly modify it to produce a new design, customized for your specific needs.\n\n";

print "<p>First, choose a base name for your design.  This can be any combination of\n";
print "letters, numbers and hyphens, e.g. \"mydesign\" or \"smartmem-bob\".\n";
print "The Interactive Chip Generator will append a timestamp to the base\n";
print "name to create a unique version each time you save your design,\n";
print "e.g. \"mydesign-100815-134333\" would be the version of \"mydesign\"\n";
print "written on August 15, 2010 at 33 seconds after 1:43pm.\n";
print "</td></tr></table>\n\n";

print "<br />\n\n";

print '<form method="get" action="/cgi-bin/ig/opendesign.pl">'."\n";
print '  <b>Base name for your new design</b> (e.g. "john" or "mary17" or "memtile7"): ';
print '  <input type="text" name="newdesign" value="mydesign"><br />'."\n\n";

print "  <p>Now, choose an existing design as a base for your new design.\n\n";

print '  <p><b>What existing design would you like to start from?</b><br /><br />'."\n\n";

# Make a list of existing designs in the design directory.  ("newline" will be replaced by "<br>")
# "tgt0-baseline" is the paradigmatic example.
my $designs  = `ls -1 ../designs/tgt0/tgt0-baseline.xml` . "newline\n";

my $designdirs = `ls -1d ../designs/* | egrep -v 'designs/tgt0|tgt0.broken|tmp.tgt0|designs.old|designs.save'`;
my @designdirs = split /\n/, $designdirs;
# my $count = 0;
foreach my $designdir (@designdirs) {
    my $xml_exists = `ls -1 $designdir/*.xml` or next;
# print "FOO\n$xml_exists\nBOO\n\n";

#    if ($xml_exists) {
# 	$count++;
#         $designs .= "$count\n";
#         $designs .= "$count $designdir\n";
       #$designs .= `ls -1 $designdir/*.xml` . "newline\n"; # Gap (newline) after each design dir group.
	$designs .= $xml_exists . "newline\n"; # Gap (newline) after each design dir group.

# 	$designs .= $xml_exists . "$count newline\n"; # Gap (newline) after each design dir group.
# 	if ($count == 4) { goto FOO; }
#    }
}

# FOO:
#     print $designs;


# For prettiness, replace "newline" lines with "<br>".  Ignore designs in "old" or "save" dirs.
# Select "baseline" design as the default.
my @designs = split /\n/, $designs;
foreach my $design (@designs) {

#     print "\nHOO $design\n\n";

#     if ($design eq "newline") { print "  noob<br />\n"; next; }
    if ($design eq "newline") { print "  <br />\n"; next; }
    if ($design =~ /designs.old/) { next; }
    if ($design =~ /designs.save/) { next; }

    my $selected = "";
    if ($design eq "../designs/tgt0/tgt0-baseline.xml") { $selected = "checked"; }
    print  "  <input type='radio' name='file' value='$design' $selected /><tt>$design</tt><br />\n";
}

# exit;

print '  <p><input type="submit" value="Submit"><br />' ."\n".
      '</form>' ."\n";

############################################################################
# NOTES:
#
# Web resources for CGI scripts:  Google "cgi script example"
#   http://www.perlfect.com/articles/url_decoding.shtml
#   http://www.it.bton.ac.uk/~mas/mas/courses/html/html3.html
#   http://www.jmarshall.com/easy/cgi/
#   http://www.comptechdoc.org/independent/web/cgi/cgimanual/cgiexample.html
############################################################################

