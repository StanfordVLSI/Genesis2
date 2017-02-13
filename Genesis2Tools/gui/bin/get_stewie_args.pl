#!/usr/bin/perl
use strict;

my $DBG = 0;

sub usage () {
    my $mydir = mydir();
    print STDERR "\n".
        "Usage: $0 [gui=<dir>] [port=<port>] [-any | -nosearch], where\n\n".
        "  <dir>  => top-level directory of the gui (default: \"$mydir\")\n".
        "  <port> => port for binding (default: 8080)\n".
        "  -any   => if <port> is busy, search for first free port+i (default)\n".
        "  -nosearch => give up if <port> is busy\n\n";
    exit(-1);
}

sub main () {

    my $port=8080;
    my $retry_port = 1;
    my $guidir = "";

    while (my $a = shift(@ARGV)) {
        if ($a =~ /^gui=(.*)/) {
            $guidir = $1;
        }
        elsif ($a =~ /^port=(\d+)$/) {
            $port = $1;
        }
        elsif ($a eq "-any") {}
        elsif ($a eq "-nosearch") { $retry_port = 0; }
        else {
            usage(); exit(-1);
        }
    }
    print "\n";

    # Check whether to use default location...
    if ($guidir eq "") {

        my $scriptdir = mydir();  # E.g. "/home/steveri/gui/cgi/"
        $guidir = "$scriptdir.."; # E.g. "/home/steveri/gui/cgi/.."

        print "You didn't specify a gui on the command line.\n";
        print "I will use guidir =   \"$guidir\".\n\n";

        if ($DBG) {
            # Go to your safe place (i.e. top-level gui directory)
            print "  I think the script lives here:  $scriptdir\n";
            print "  So now I'm going to cd to here: $guidir\n";
        }
    }

    # Need to start from top level of gui directory.
    print "Using gui at location \"$guidir\"\n\n";

    # Maybe this cleans up paths like /foo/bar/baz//../../bazzle/..
    chdir $guidir; $guidir = `pwd`; chomp($guidir);

    # Optional debug message.
    if ($DBG) {
        print "And now I'm here:               $guidir\n\n";
    }

    ########################################################################
    # Find port for binding
    print "Will attempt to bind to port $port.  ";
    if ($retry_port) {
        print "If busy, will search for next available.\n\n";
    }
    else {
        print "If busy, will give up.\n\n";
    }

    ##############################################################################
    # Find first free port, beginning w/$port; give up when reach ($port + 100)
    my $gotport = 0;
    my $maxport = $port + 100;
    while ($port < $maxport) {
        my $portbusy = `netstat -npl  2>&1 | grep :$port`;

        #print "Here's what I found:\n\"$portbusy\"\n\n"; $portbusy="8081\n  ";

        if ($portbusy =~ /^\s*$/) {
            print "Yay   port $port is free\n";
            $gotport = 1;
            last;
        }
        else {
            print "Oh no port $port is busy oh boooooo\n";
            if (! $retry_port) { last; }
        }
        $port++;
    }


    if (! $gotport) {
        if ($retry_port) {
            print STDERR "\nERROR: Could not find free port.  Bye!\n\n";
        }
        else { print STDERR
                   "\nERROR: Sorry, port $port is busy.  Bye!\n\n";
        }
        exit(-1);
    }

#    print "\ngui=\"$guidir\" port=$port\n\n";
    print "\nARGS $guidir $port\n\n";

    exit(0);
}

sub mydir {
    # Return full path of directory where this script lives.
    use Cwd 'abs_path';
    my $fullpath = abs_path($0); # Full pathname of script e.g. "/foo/bar/opendesign.pl"

    use File::Basename 'fileparse';
    my ($filename, $dir, $suffix) = fileparse($fullpath);
    return $dir;
}
  
main();
