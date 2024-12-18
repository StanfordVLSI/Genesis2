#!/usr/bin/env perl
use strict;

my $port=8080;
if ($#ARGV == 0) { $port = $ARGV[0]; }

if (! ($port =~ /^\d+/)) {
    print
        "Usage:   $0 [port] (default port=8080)\n".
        "Example: $0 8081\n\n";
}

# Find first free port, beginning w/$port; give up when reach ($port + 100)

my $maxport = $port + 100;
while ($port < $maxport) {
    my $portbusy = `netstat -npl  2>&1 | grep :$port`;

    #print "Here's what I found:\n\"$portbusy\"\n\n"; $portbusy="8081\n  ";

    if ($portbusy =~ /^\s*$/) {
        print "Yay port $port is free\n\n";
        print "$port\n";
        exit(0);
    }
    else {
        print "Oh no port $port is busy oh boooooo\n";
    }
    $port++;
}
exit(-1);


#print "\n\n$port";
#print "\n\n";

