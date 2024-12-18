#!/usr/bin/env perl

print "SEE welcome.pl instead\n\n";
exit;

# cgi-bin/ig/index.pl generates a form:
#
# "What is your name (e.g. "john", "mary", "shenwen")?
#
# "Alter an existing design:
#    100720-1310-ofer.htm
#    100718-2245-kyle.htm
#    ...
# "Or start a new design:
#    default.htm
# "SUBMIT"
#
# Remove all spaces and such from "name" leaving only [a-zA-Z0-9]
# The form copies the indicated design e.g. "default.htm"
# to the new design name "100722-1100-steveri.htm" and transfers control.
# An "alert" box pops up that says something like
# "your design will be saved as 100722-1100-steveri.htm---make a note of it!





# Web resources for CGI scripts:  Google "cgi script example"
#   http://www.perlfect.com/articles/url_decoding.shtml
#   http://www.it.bton.ac.uk/~mas/mas/courses/html/html3.html
#   http://www.jmarshall.com/easy/cgi/
#   http://www.comptechdoc.org/independent/web/cgi/cgimanual/cgiexample.html

my $my_input = $ENV{QUERY_STRING};

my @fv_pairs = split /\&/ , $my_input;

foreach $pair (@fv_pairs) {
    if($pair=~m/([^=]+)=(.*)/) {
	$field = $1;
	$value = $2;
	$value =~ s/\+/ /g;
	$value =~ s/%([\dA-Fa-f]{2})/pack("C", hex($1))/eg;
	$INPUT{$field}=$value;
    }
}

#print "Content-type: text/html\n\n";
print "Content-type: text/plain\n\n";

print "Hey there tooby.<br /><br />\n";

print "oop<br /><br />\n$ENV{QUERY_STRING}<br /><br />\ndoop";

print "Your name is $INPUT{name} and your email is $INPUT{email}";

print "\n\n";

