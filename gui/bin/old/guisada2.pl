#!/usr/bin/env perl

# Next: build config files for standalone etc.

# http://search.cpan.org/~jasonmay/HTTP-Server-Simple/lib/HTTP/Server/Simple.pm
# http://search.cpan.org/~jasonmay/HTTP-Server-Simple-0.45_02/lib/HTTP/Server/Simple/CGI.pm
# http://perldoc.perl.org/CGI.html

my $port=8080;

{
    package MyWebServer;
 
    use HTTP::Server::Simple::CGI;
    use base qw(HTTP::Server::Simple::CGI);
 
#    sub mydir {
#        use Cwd 'abs_path';
#        my $fullpath = abs_path($0); # Full pathname of script e.g. "/foo/bar/opendesign.pl"
#        
#        use File::Basename 'fileparse';
#        my ($filename, $dir, $suffix) = fileparse($fullpath);
#        return $dir;
#    }

# BUG/TODO check and make sure webserver was started from top-level dir

#my $htmlfile = "index.htm";
#my $sf1 = 's|base href=.*|base href=\"http://neva-2:8080/\">|';
#my $sf2 = 's|src=.*alt=.tree.|src=\"images/stanford_seal.gif\" alt=\"tree\"|';
#print `cat $htmlfile | sed "$sf1" | sed "$sf2"`;
#exit(0);

sub handle_request {
    my $self = shift;
    my $cgi  = shift;
    
    # Just for funsies, let's try and make sure we're in a known place.
    #    chdir mydir()."/..";
    
    my $path = $cgi->path_info();
    
    my $index = "/configs/index_guisada2.htm";

    if ($path eq "/index.htm") { $path = $index; }
    if ($path eq "/") { $path = $index; }
    if ($path eq "") { $path = $index; }

    if (! -e ".$path") {
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

#     if ($path =~ /^\/genesis\/(.*)/) {
#    if ($path eq $index) {
#        my $sf1 = 's|base href=.*|base href=\"http://neva-2:8080/cgi/\">|';
#        my $sf2 = 's|src=.*alt=.tree.|src=\"images/stanford_seal.gif\" alt=\"tree\"|';
#
#        print "HTTP/1.0 200 OK\r\n";
#        print `cat .$index | sed "$sf1" | sed "$sf2"`;
#    }
    if ($path =~ /htm[l]?$/) {
        print "HTTP/1.0 200 OK\r\n";
    }
#    else {
        print `cat .$path`;
#    }


#    if (-e "$path") {
#        print "woo hoo $path<br>\n";
#        my $htmlfile = $path;
#        print `ls -l $htmlfile`;
#
#my $sf1 = 's|base href=.*|base href=\"http://neva-2:8080/\">|';
#my $sf2 = 's|src=.*alt=.tree.|src=\"images/stanford_seal.gif\" alt=\"tree\"|';
#
#print `cat $htmlfile | sed "$sf1" | sed "$sf2"`;
#
#}

         return(0);
#     }
#     return(0);





     my $handler = $dispatch{$path};
 
     if (ref($handler) eq "CODE") {
         print "HTTP/1.0 200 OK\r\n";
         $handler->($cgi);
         
     } else {
         print "HTTP/1.0 404 Not found\r\n";
         my $path = $cgi->path_info();
         my $param = $cgi->param();
         my $uparam = $cgi->url_param();
         my $qs = $ENV{QUERY_STRING};


         print
             $cgi->header,
             $cgi->start_html('Not founddd'),
             $cgi->h1('Not founddd'),
             $cgi->h2("path $path"),
             $cgi->h2("param $param"),
             $cgi->h2("uparam $uparam"),
             $cgi->h2("qs $qs"),


             $cgi->h2("handler ".ref($handler)),
#             print "query = ".$cgi->query."<br>",
             "hoop-de-doo",
             $cgi->end_html;
     }
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
 
 # start the server on port 8080
# my $pid = MyWebServer->new(8080)->background();
my $pid = MyWebServer->new($port)->background();
print "To stop server:\n",
    "  kill $pid\n\n";
