#!/usr/bin/env perl

# Useful shortcuts:
#  alias stfind="ps x | egrep '[/]stew' | awk '{print \$1}'"
#  alias stkill='kill `stfind`'


# Next: build config files for standalone etc.

# http://search.cpan.org/~jasonmay/HTTP-Server-Simple/lib/HTTP/Server/Simple.pm
# http://search.cpan.org/~jasonmay/HTTP-Server-Simple-0.45_02/lib/HTTP/Server/Simple/CGI.pm
# http://perldoc.perl.org/CGI.html

sub main () {
    my $port=8080;

    # Go to your safe place (i.e. top-level gui directory)
    print "I think the script lives here: ".mydir()."\n\n";
    print "So now I'm going to cd to here: ".mydir()."..\n\n";
    chdir mydir()."..";
    chdir mydir()."../cgi";
    print "And now I'm here:               ".`pwd`."..\n\n";

    # start the server on port 8080
    # my $pid = MyWebServer->new(8080)->background();
    my $pid = MyWebServer->new($port)->background();
    print "To stop server:\n",
    "  kill $pid\n\n";

    # Go ahead and launch firefox why not already.
    print "here goes firefox..???\n\n";
    my $ff_err = `firefox http://localhost:$port/`;
#    system(1, "firefox http://localhost:$port/");
#    my $pid = system("firefox");
#    print "pid = $pid\n\n";

    exit(0); # Don't delete; never exits without the "exit" (because of firefox?)
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
        
        my $index = "/configs/index_guisada2.htm";

        if ($path eq "/index.htm") { $path = $index; }
        if ($path eq "/") { $path = $index; }
        if ($path eq "") { $path = $index; }

        if (! -e ".$path") {
#        if (1) {
            print "HTTP/1.0 200 OK\r\n";
            print
                $cgi->header,
                $cgi->start_html('File not found'),
                $cgi->h1("Could not find file \".$path\""),
                $cgi->h2("path $path"),
                $cgi->h2("param $param"),
                $cgi->h2("uparam $uparam"),
                $cgi->h2("qs $qs");
            return(-1);
        }

        if ($path =~ /.pl?$/) {
            print "HTTP/1.0 200 OK\r\n";
#            print "found a perl file.  can i please execute the perl file??\n";
#            return(0);

            print `.$path`;  # Execute the perl file
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
