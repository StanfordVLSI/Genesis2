#!/usr/bin/perl
use strict;

my $DBG = 0;

sub usage() {
    my $mydir = mydir();
    print "\n".
        "Usage: $0 gui=<dir> port=<port>, where\n\n".
        "  <dir>  => top-level directory of the gui (default=\"$mydir\")\n".
        "  <port> => port for binding (default: 8080)\n\n";

    exit(-1);
}

sub main () {

    my $port=8080;

    # Default gui dir = one level up from where this perl script lives.

    my $guidir = mydir();     # E.g. "/home/steveri/gui/bin"
    $guidir = "$guidir/..";   # E.g. "/home/steveri/gui/bin/.."

    #  $0 gui=<dir> port=<port> - Start server for gui at <dir> using port <port>

    while (my $a = shift(@ARGV)) {
        if ($a =~ /^gui=(.*)/) {           # E.g. 'gui="/tmp/stewie"'
            $guidir = $1;
        }
        elsif ($a =~ /^port=(\d+)$/) {     # E.g. 'port=8080'
            $port = $1;
        }
        else {
            usage();
        }
    }

    # Need to start from top level of gui directory.
    print "\nUsing gui at location \"$guidir\"\n\n";
    chdir $guidir or die "Can't cd to \"$guidir\": $!\n";

    # Optional debug message.
    if ($DBG) {
        $guidir = `pwd`; chomp($guidir);
        print "And now I'm here:               $guidir\n\n";
    }

    print "Will attempt to bind to port $port\n";

    ########################################################################
    # start the server on indicated port
    my $pid = MyWebServer->new($port)->background();  # E.g. $port = "8080"
    print "To stop server:\n  kill $pid\n\n";

    ########################################################################
    # Go ahead and launch firefox why not already.
    my $ff_errfile = "/tmp/stewie-ff.$$.log";
    print "I will attempt to launch firefox for you because you're so lazy.\n";
    print "If there are problems, look for errors in \"$ff_errfile\"\n";

   #!! "localhost" does not seem to work for kiwi...!
   #my $err = system("firefox http://localhost:$port/ > $ff_errfile 2>&1 &");

    # I guess system() returns an error code, because it's always zero.
    my $err = system("firefox http://`hostname`:$port/ > $ff_errfile 2>&1 &");
    # if ($err != 0) { something wrong? }

    # Wait 2 sec for server to print its little message (see print_banner(), below)
    sleep(2);
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
  
{
    # mydir() returns e.g. "/home/steveri/gui/bin"
    # Want path to local HTTP libraries, just in case.
    # "use lib" adds e.g. "/home/steveri/gui/bin/../configs/install/perlfiles" to @inc...right?

    my $mydir = mydir();
    use lib "$mydir/../configs/install/perlfiles";    

    package MyWebServer;
    
    use HTTP::Server::Simple::CGI;
    use base qw(HTTP::Server::Simple::CGI);
    
    sub print_banner {
        my $self = shift;

#        print( ref($self) # i.e. "MyWebServer"
#               . ": You can connect to your server at "
#               . "http://localhost:"
#               . $self->port
#               . "/\n" );

        my $port = $self->port;
        my $hostname = `hostname -f`; chomp($hostname);
        print("\nYou can connect to your server at http://$hostname:$port/\n\n" );
    }

    sub handle_request {
        my $self = shift;
        my $cgi  = shift;
        
        my $path = $cgi->path_info();  # E.g. path = "/index.htm"

        #my $dbgfile = "/tmp/stewie-dbg.$$.log";
        #my $err = system("echo I see a request for path $path >> $dbgfile");

        # Multiple ways to get to top level file "index.htm" include:
        #   http://foo:8080            http://foo:8080/
        #   http://foo:8080/genesis    http://foo:8080/genesis/
        #   http://foo.8080/index.htm
        
        my $index = "/index.htm";

        if (($path eq "/index.htm")
            | ($path eq "/genesis") | ($path eq "/genesis/")
            | ($path eq "/")       | ($path eq "")
            )
        { $path = $index; }

        # Nonexistent file
        if (! -e ".$path") {
            print "HTTP/1.0 200 OK\r\n";
            print
                $cgi->header,
                $cgi->start_html('File not found'),
                $cgi->h1("Could not find file \".$path\""),
                print("path $path<br>"),
            return(-1);
        }

        # PHP files
        if ($path =~ /\.php$/) { # E.g. "/scratch/cmpdemo-5270.php"
            my $php_file = $path;

            # Send debug info to a readable /tmp file
            # `echo                             > /tmp/stewie_msgs$$.txt`;
            # `echo -n 'we is here raht now: ' >> /tmp/stewie_msgs$$.txt`;
            # `pwd                             >> /tmp/stewie_msgs$$.txt`;
            # `echo "we's gonna execute '/usr/bin/php .$php_file'" >> /tmp/stewie_msgs$$.txt`;
            
            print "HTTP/1.0 200 OK\r\n";
           #print `cd cgi; /usr/bin/php    ..$php_file`;  # Execute the php file
            print `cd cgi;   ../bin/php.pl ..$php_file`;  # Execute the php file
            return(0);
        }

        # Perl files
        if ($path =~ /\/?cgi\/(.*)/) { # E.g. "cgi/opendesign.pl"
            my $exe = $1;

            # `echo found exe=$exe > /tmp/stewie_msgs$$.txt`;

            print "HTTP/1.0 200 OK\r\n";
            print `cd cgi; ./$exe`;  # Execute the perl file
            return(0);
        }

        # HTM and HTML extensions
        if ($path =~ /.htm[l]?$/) {
            print "HTTP/1.0 200 OK\r\n";
        }
        print `cat .$path`;
        return(0);
    }
} 

main();

##############################################################################
# Ref:
# http://search.cpan.org/~jasonmay/HTTP-Server-Simple/lib/HTTP/Server/Simple.pm
# http://search.cpan.org/~jasonmay/HTTP-Server-Simple-0.45_02/lib/HTTP/Server/Simple/CGI.pm
# http://perldoc.perl.org/CGI.html



# Trash heap:

# Useful shortcuts:
#  alias stfind="ps x | egrep '[/]stew' | awk '{print \$1}'"
#  alias stkill='kill `stfind`'

    #my $htmlfile = "index.htm";
    #my $sf1 = 's|base href=.*|base href=\"http://neva-2:8080/\">|';
    #my $sf2 = 's|src=.*alt=.tree.|src=\"images/stanford_seal.gif\" alt=\"tree\"|';
    #print `cat $htmlfile | sed "$sf1" | sed "$sf2"`;
    #exit(0);

#         my $param = $cgi->param();
#         my $uparam = $cgi->url_param();
#         my $qs = $ENV{QUERY_STRING};
#
#         print
#             $cgi->header,
#             $cgi->start_html('Not founddd'),
#             $cgi->h1('Not founddd'),
#             $cgi->h2("path $path"),
#             $cgi->h2("param $param"),
#             $cgi->h2("uparam $uparam"),
#             $cgi->h2("qs $qs"),
#             $cgi->h2("handler ".ref($handler)),
##             print "query = ".$cgi->query."<br>",
#             "hoop-de-doo",
#             $cgi->end_html;
#     }

#    sub resp_hello {
#        my $cgi  = shift;   # CGI.pm object
#        return if !ref $cgi;
#        
#        my $who = $cgi->param('name');
#        
#        print $cgi->header,
#        $cgi->start_html("Hello"),
#        $cgi->h1("Hello $who!"),
#        $cgi->end_html;
#    }
