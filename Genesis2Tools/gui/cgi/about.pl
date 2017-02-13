#!/usr/bin/perl
use strict;

# File w/version information
my $verfile = "../configs/install/version_number.txt";

# Version number e.g. "10685"
my $verno = `cat $verfile`;
chomp($verno);

# Version date e.g. "Thu Jul 5 11:17:05 2012"
use File::stat;
use Time::localtime;
my $verdate = ctime(stat($verfile)->mtime);

# HTML
print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">';
print "\n";
print "\n";

print "<head><title>GUI version $verno</title></head>\n\n";
print "\n";
print "\n";

#print "<center>\n";
print "<h1>GUI version $verno</h1>\n";
print "<i>Dated $verdate</i>\n";
#print "</center>\n";
