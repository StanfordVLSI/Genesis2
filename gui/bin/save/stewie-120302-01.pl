#!/usr/bin/env perl

# Useful shortcuts:
#  alias stfind="ps x | egrep '[/]stew' | awk '{print \$1}'"
#  alias stkill='kill `stfind`'


# Next: build config files for standalone etc.

# http://search.cpan.org/~jasonmay/HTTP-Server-Simple/lib/HTTP/Server/Simple.pm
# http://search.cpan.org/~jasonmay/HTTP-Server-Simple-0.45_02/lib/HTTP/Server/Simple/CGI.pm
# http://perldoc.perl.org/CGI.html

my $DBG = 0;

sub main () {

    my $port=8080;
    my $retry_port = 1;
    my $guidir = "";


    # To call this program:
    #  $0 gui=<dir> port=<port> - Start server for gui at <dir> using port <port>
    #                           - <dir> defaults to wherever $0 lives;
    #                           - <port> defaults to "next available (after 8080)"

    while (my $a = shift(@ARGV)) {
        if ($a =~ /^gui=(.*)/) {
            $guidir = $1;
        }
        elsif ($a =~ /^port=(\d+)$/) {
            $port = $1;
            $retry_port = 0;
        }
        else {
            print "\n";
            print "Did not understand arg \"$a\"\n\n";
            print "Usage: $0 gui=<dir> port=<port>\n";
            print "Example: $0 gui=/home/steveri/gui port=8080\n\n";
            exit;
        }
    }
    print "\n";

    # Check whether to use default location...
    if ($guidir eq "") {
        print "You didn't specify a gui on the command line.\n";
        print "I will use the default gui.\n";

        my $scriptdir = mydir();  # E.g. "/home/steveri/gui/cgi/"
        $guidir = "$scriptdir.."; # E.g. "/home/steveri/gui/cgi/.."

        if ($DBG) {
            # Go to your safe place (i.e. top-level gui directory)
            print "  I think the script lives here:  $scriptdir\n";
            print "  So now I'm going to cd to here: $guidir\n";
        }

    }

    # Need to start from top level of gui directory.
    print "Using gui at location \"$guidir\"\n\n";
    chdir $guidir;

    # Optional debug message.
    if ($DBG) {
        $guidir = `pwd`; chomp($guidir);
        print "And now I'm here:               $guidir\n\n";
    }

    ########################################################################
    # Find port for binding (this should be a subroutine BUG/TODO)
    print "Will attempt to bind to port $port\n";
    if ($retry_port) {
        print "If busy, will search for next available.\n\n";
    }
    else {
        print "If busy, will give up.\n\n";
    }

#    print "\nWill check to see if port $port is available\n\n";

    my $timeout = 100;
    my $stop = 0;
    do {
        ########################################################################
        # Yeah "lsof" may not be highly portable.
        # BUG/TODO? might be better to use something like "netstat -npl | grep $port"
        my $portbusy = `lsof -i :$port`; # Yeah this might not be completely portable...!

        #print "Here's what I found:\n\"$portbusy\"\n\n"; $portbusy="8081\n  ";

        if ($portbusy =~ /^\s*$/) {
            print "Yay port $port is free\n\n";
            $stop = 1;
        }
        else {
            print "Oh no port $port is busy oh boooooo\n";
            if ($retry_port) { $port++; }
            else             { print "Giving up.  Bye!\n\n"; exit; }
        }

    } until ( (($timeout--) <= 0) || $stop );
    #
    # End of port-find subroutine
    ########################################################################

    ########################################################################
    # start the server on port 8080
    # my $pid = MyWebServer->new(8080)->background();

    my $pid = MyWebServer->new($port)->background();
    print "To stop server:\n",
    "  kill $pid\n\n";

    # Go ahead and launch firefox why not already.
    my $ff_errfile = "/tmp/stewie-ff.$$.log";
    print "I will attempt to launch firefox for you because you're so lazy.\n";
    print "If there are problems, look for errors in \"$ff_errfile\"\n\n";

#    # Causes error msgs to console when you select e.g. "file" in firefox
#    my $ff_err = `firefox http://localhost:$port/`;
#    exit(0);

#    # This works but it never returns from the "system" call.
#    my $pid = system("firefox");
#    print "pid = $pid\n\n";
#    exit(0);

#    # This works but still sends errors to console when you select e.g. "file" in firefox
#    my $pid = system("firefox &");
#    print "pid = $pid\n\n";
#    exit(0);

    # I guess system() returns an error code, because it's always zero.
    my $err = system("firefox http://localhost:$port/ > $ff_errfile 2>&1 &");
    # if ($err != 0) { something wrong? }
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
    package MyWebServer;
    
    use HTTP::Server::Simple::CGI;
    use base qw(HTTP::Server::Simple::CGI);
    
    # BUG/TODO check and make sure webserver was started from top-level dir

    #my $htmlfile = "index.htm";
    #my $sf1 = 's|base href=.*|base href=\"http://neva-2:8080/\">|';
    #my $sf2 = 's|src=.*alt=.tree.|src=\"images/stanford_seal.gif\" alt=\"tree\"|';
    #print `cat $htmlfile | sed "$sf1" | sed "$sf2"`;
    #exit(0);

    sub handle_request {
        my $self = shift;
        my $cgi  = shift;
        
        my $path = $cgi->path_info();
        
        my $index = "/index.htm";

        if (($path eq "/index.htm")
            | ($path eq "/genesis") | ($path eq "/genesis/")
            | ($path eq "/")       | ($path eq "")
            )
        { $path = $index; }

        if (! -e ".$path") {
#        if (1) {
            print "HTTP/1.0 200 OK\r\n";
            print
                $cgi->header,
                $cgi->start_html('File not found'),
                $cgi->h1("Could not find file \".$path\""),
                print("path $path<br>"),
                print("param $param<br>"),
                print("uparam $uparam<br>"),
                print("qs $qs<br>");
            return(-1);
        }

        if ($path =~ /\.php$/) { # E.g. "/scratch/cmpdemo-5270.php"
            my $php_file = $path;

            `echo > /tmp/stewie_msgs.txt`;
            `echo -n 'we is here raht now: ' >> /tmp/stewie_msgs.txt`;
            `pwd >> /tmp/stewie_msgs.txt`;
            `echo "we's gonna execute '/usr/bin/php .$php_file'" >> /tmp/stewie_msgs.txt`;

            print "HTTP/1.0 200 OK\r\n";
            print `cd cgi; /usr/bin/php ..$php_file`;  # Execute the perl file
            return(0);
        }

        if ($path =~ /\/?cgi\/(.*)/) { # E.g. "cgi/opendesign.pl"
            my $exe = $1;
            print "HTTP/1.0 200 OK\r\n";
            print `cd cgi; $exe`;  # Execute the perl file
            return(0);
        }


        if ($path =~ /.htm[l]?$/) {
            print "HTTP/1.0 200 OK\r\n";
        }
        print `cat .$path`;
        return(0);


#     my $handler = $dispatch{$path};
# 
#     if (ref($handler) eq "CODE") {
#         print "HTTP/1.0 200 OK\r\n";
#         $handler->($cgi);
#         
#     } else {
#         print "HTTP/1.0 404 Not found\r\n";
#         my $path = $cgi->path_info();
#         my $param = $cgi->param();
#         my $uparam = $cgi->url_param();
#         my $qs = $ENV{QUERY_STRING};
#
#
#         print
#             $cgi->header,
#             $cgi->start_html('Not founddd'),
#             $cgi->h1('Not founddd'),
#             $cgi->h2("path $path"),
#             $cgi->h2("param $param"),
#             $cgi->h2("uparam $uparam"),
#             $cgi->h2("qs $qs"),
#
#
#             $cgi->h2("handler ".ref($handler)),
##             print "query = ".$cgi->query."<br>",
#             "hoop-de-doo",
#             $cgi->end_html;
#     }
    }
    
    sub resp_hello {
        my $cgi  = shift;   # CGI.pm object
        return if !ref $cgi;
        
        my $who = $cgi->param('name');
        
        print $cgi->header,
        $cgi->start_html("Hello"),
        $cgi->h1("Hello $who!"),
        $cgi->end_html;
    }
    
} 

main();
