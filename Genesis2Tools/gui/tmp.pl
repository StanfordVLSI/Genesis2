#!/usr/bin/perl

my $err = system("egrep foo /tmp/foo > /dev/null");
print "\n\nerr=\n$err\n\n";
