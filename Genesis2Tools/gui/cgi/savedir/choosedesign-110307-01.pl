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

print "  <p>Now, choose an existing design to modify in order to create your new design.\n\n";

print '  <p><b>What existing design would you like to start from?</b><br /><br />'."\n\n";

# # Make a list of existing designs in the design directory.  ("newline" will be replaced by "<br>")
# my $designs  = `ls -1 ../designs/tgt0/tgt0-baseline.js`                               . "newline\n";
#    $designs .= `ls -1 ../designs/tgt0/*.js | grep -v 'designs/tgt0/tgt0-baseline.js'` . "newline\n";
#    $designs .= `ls -1 ../designs/*.js`                                                . "newline\n";
#    $designs .= `ls -1 ../designs/*/*.js | grep -v 'designs/tgt0/'`;

# Make a list of existing designs in the design directory.  ("newline" will be replaced by "<br>")
my $designs  =
    `ls -1 ../designs/tgt0/tgt0-baseline.xml`                                . "newline\n" .
    `ls -1 ../designs/tgt0/*.xml | grep -v 'designs/tgt0/tgt0-baseline.xml'` . "newline\n" .
    `ls -1 ../designs/*/*.xml | egrep -v 'designs/tgt0/|tgt0.broken|tmp.tgt0'`;

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

