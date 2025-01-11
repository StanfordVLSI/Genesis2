#!/usr/bin/perl

# This file generates a form:
#
# "What is your name (e.g. "john", "mary", "shenwen")?
#
# "Which design would you like to browse/modify?
#    100720-1310-ofer.htm
#    100718-2245-kyle.htm
#    ...
# "SUBMIT"
#
# Remove all spaces and such from "name" leaving only [a-zA-Z0-9]
# (opendesign.pl is responsible for this.)

print "Content-type: text/html\n\n";
#print "Content-type: text/plain\n\n";

print "<head><title>Interactive Chip Generator powered by Genesis</title></head>\n\n";

print "<h2>Welcome to the Interactive Chip Generator!</h2>\n\n";

# print "The name you enter below will be used to identify your design when you save it.<br /><br />\n\n";

print "<table style='width:600'><tr><td>\n";
print "Choose a name for your design.  The name can be any combination of\n";
print "letters, numbers and hyphens, e.g. \"mydesign\" or \"smartmem-clyde\".\n";
print "The Interactive Chip Generator will append a timestamp to the base\n";
print "name to create a unique version each time you modify your design,\n";
print "e.g. \"mydesign-100815-134333\" would be the version of \"mydesign\"\n";
print "written on August 15, 2010 at 33 seconds after 1:43pm.\n";
print "</td></tr></table>\n\n";

print "<br />\n\n";

print '<form method="get" action="/cgi-bin/ig/opendesign.pl">'."\n";
print '  <b>Design name</b> (e.g. "john" or "mary17" or "memtile7"): <input type="text" name="newdesign" value="clyde"><br />'."\n";
print "  <p>\n";
print '  <b>What design would you like to browse/modify?</b><br /><br />'."\n";
print '';

my $designs = `ls -1 ../designs/tgt0/tgt0-baseline.js`;
$designs   .= "newline\n";
$designs   .= `ls -1 ../designs/tgt0/*.js | grep -v 'designs/tgt0/tgt0-baseline.js'`;
$designs   .= "newline\n";
$designs   .= `ls -1 ../designs/*.js`;
$designs   .= "newline\n";
$designs   .= `ls -1 ../designs/*/*.js | grep -v 'designs/tgt0/'`;

my @designs = split /\n/, $designs;
foreach my $design (@designs) {
    if ($design eq "newline") { print "  <br />\n"; next; }
    if ($design =~ /designs.old/) { next; }
    if ($design =~ /designs.save/) { next; }

    my $selected = "";
    if ($design eq "../designs/tgt0/tgt0-baseline.js") { $selected = "checked"; }
    print  "  <input type='radio' name='file' value='$design' $selected /><tt>$design</tt><br />\n";
}

print
    '  <p><input type="submit" value="Submit"><br />' ."\n".
    '</form>' ."\n".
    '';

########################################################################
# NOTES
#
# Web resources for CGI scripts:  Google "cgi script example"
#   http://www.perlfect.com/articles/url_decoding.shtml
#   http://www.it.bton.ac.uk/~mas/mas/courses/html/html3.html
#   http://www.jmarshall.com/easy/cgi/
#   http://www.comptechdoc.org/independent/web/cgi/cgimanual/cgiexample.html
########################################################################

