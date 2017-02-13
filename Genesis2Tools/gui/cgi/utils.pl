# To test, try something like: perl -f <thisfile>
use strict;

# # build_gui_extras tests.
# my ($err, $html) = build_gui_extras("foo");
# if ($err) { print "ERROR: $err\n"; }  # Should print error: cannot find design directory "foo".
# print "\n\n";
# 
# my ($err, $html) = build_gui_extras("/tmp");
# if ($err) { print "ERROR: $err\n"; }  # Should print error: cannot find template "/tmp/gui_extras.template".
# print "\n\n";
# 
# my ($err, $html) = build_gui_extras("/home/steveri/fftgen");
# if ($err) { print "ERROR: $err\n"; }  # No error if bin/gui_extras.template exists and contains valid line.
# else { print $html; }
# print "\n\n";
# exit 0;

sub get_system_dependences() {

  if ($ENV{STANDALONE_GUI}==1) { return; }

  my %SYS;
  my $config = "../CONFIG.TXT";

  my $errmsg = 0;
  open CONFIG, "<$config" or $errmsg = "Error. Cannot open config file \"$config\"";
  if ($errmsg) {
      print embed_alert_script("$errmsg\n");
      die $errmsg;
  }

  while (<CONFIG>) {

    $_ =~ s/#.*//g;                  # Ignore pound-sign comments.

#   if ($_ =~ /\s*(\S+)\s+"([^"]+)/) {  # E.g. 'WELCOME_MSG  "Hey there"  # optional comments  '

    if ($_ =~ /\s*(\S+)\s+(\S+)/) {     # E.g. 'GUI_URL  /cgi-bin/ig  # optional comments  '

      if (0) { print embed_alert_script("sys{$1} = \"$2\"\n"); }
      $SYS{$1} = $2;                 # E.g. $SYS{GUI_URL} = "/cgi-bin/ig"
    }
  }

  # BUG/TODO hack: if GUI_HOME_URL ends in "/", get rid of the "/":
  # This fixes a stewie bug; stewie defines GUI_HOME_URL as "/",
  # which leads to e.g. "$GUI_HOME_URL/images/addbutton.png" expanding
  # as URL "//images/addbutton.png" which causes multiple problems...
  if ($SYS{GUI_HOME_URL} =~ /\/$/) { chop($SYS{GUI_HOME_URL}); }

  close CONFIG;
  return %SYS;
}

sub get_input_parms() {
  my $parms = shift(@_);
  my %INPUT;
  my @fv_pairs = split /\&/ , $parms;
  foreach my $pair (@fv_pairs) {
    if($pair=~m/([^=]+)=(.*)/) {                          # E.g. "(newdesign)=(my_design_name)"
      my $field = $1; my $value = $2;
      $value =~ s/\+/ /g;                                 # Change plus sign to blank space.
      $value =~ s/%([\dA-Fa-f]{2})/pack("C", hex($1))/eg; # Change e.g. "%2F" to "/"
      $INPUT{$field}=$value;                              # E.g. $INPUT{newdesign) = "my_design_name"
    }
  }
  return %INPUT;
}

sub build_new_php() {

    my $LDBG = 0; # Local debug
    my $SDBG = 0; # Debug standalone mode
    my $standalone = $ENV{STANDALONE_GUI};

    if ($LDBG) {
        print "#########################################################<br>\n";
        print "build_new_php()<br>\n";
    }
    if ($SDBG) { print "standalone = $standalone<br>\n";}

    # Given a current design e.g. "../tilegen.js";

    # Open a view on the current design e.g. "../TileGen/design-1400.js"
    # Such that any changes to the design will be written to file 
    # "../TileGen/$newdesign-<timestamp>"; use $php_basename as a basis
    # to build the php file that we will jump to e.g. "genesis/scratch/$php_basename-4475.php

    # Example values:
    #
    #   $curdesign_js    = "../TileGen/default.js"  or  "../TileGen/mydesign-110204-151500.js"
    #   $newdesign    =       "mydesign"       BUT NEVER  "mydesign-110204-152500"
    #   $php_basename =       "mydesign" (opendesign) or "mydesign-110204-152500" (updatedesign)
    #
    #   $modpath      = "top" or "top.DUT.p0"
    #
    #   $tmpfile   =      "mydesign-<pid>" or        "mydesign-110204-152500-<pid>"
    #
    # (Timestamp on tmpfile should never be necessary as long as each user has a unique "mydesign" name).

    my $curdesign_js = shift(@_); # E.g. "../designs/CMP/cmp-baseline.js"
    my $newdesign    = shift(@_); # E.g. "mydesign"
    my $php_basename = shift(@_); # E.g. "mydesign-110204-152500"
    my $modpath      = shift(@_); # E.g. "top" or ? "top.DUT.p0" ?
    my $DBG          = shift(@_);

    if ($LDBG) { print embed_alert_script("LDBG design = $curdesign_js\n"); }

    ########################################################################
    # Bring in optional info from "<design_home>/bin/gui_extras.php"

    $curdesign_js =~ /^(.*\/)[^\/]+$/;  # E.g. "(../designs/CMP/)cmp-baseline.js"
    my $designdir = $1;                 # E.g. "../designs/CMP/"
    if ($LDBG) { print embed_alert_script("LDBG designdir = $designdir\n"); }

#     my $makefile = $designdir."Makefile";
#     if ($LDBG) { print embed_alert_script("LDBG makefile = $makefile\n"); }
#     if (! -f $makefile) {
#         print embed_alert_script("WARNING (utils.pl:build_new_php()) Could not find makefile \"$makefile\"\n");
#     }

    my $sourcedir = `cat $designdir/__SOURCEDIR__`;
    $sourcedir =~ s/^\s*//;     # Eliminate leading spaces
    $sourcedir =~ s/\s*$//;     # Eliminate trailing spaces
    if ($LDBG) { print embed_alert_script("Found source dir \"$sourcedir\""); }
        
#         my $gui_info = `make -f $sourcedir/Makefile gui_info`;
#         print embed_alert_script("Found gui info:\n$gui_info");

#     my $gui_extras = (-f "$sourcedir/bin/gui_extras.php") ?
#         "<?php include \"$sourcedir/bin/gui_extras.php\" ?>" :
#         "NO GUI EXTRAS";

    my ($err, $gui_extras) = build_gui_extras($designdir, $sourcedir, $DBG);
    if ($err) { $gui_extras = "<!-- NO GUI EXTRAS -->"; }
    else {
        open(EXTRAS, ">$designdir/gui_extras.php") or
            print embed_alert_script("ERROR: Could not create/write \"$designdir/gui_extras.php\": $!");
        print EXTRAS $gui_extras;
        close EXTRAS;
        $gui_extras = "<?php include \"$designdir/gui_extras.php\" ?>";
    }

    if ($LDBG) { print embed_alert_script("GUI extras:\n$gui_extras"); }

    ########################################################################
    # Carry on.

    my $newdesfname = $curdesign_js;           # E.g. "../designs/CMP/cmp-baseline.js"

    my $ghd = $ENV{STANDALONE_CGI_DIR};
    $ghd =~ s/cgi[\/]*$//; # "/foo/bar/gui/cgi/" => "/foo/bar/gui/"

    my %SYS = $standalone ?
        (
         "CGI_DIR"      => $ENV{STANDALONE_CGI_DIR},
         "GUI_HOME_DIR" => $ghd,
         "SERVER_URL"   => "file://"        # No way this is ever gonna work...
         )
        :
        get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}

    # Path by which perl file finds the gui.
    my $gui_dir = $SYS{GUI_HOME_DIR}; # E.g. "~steveri/smart_memories/Smart_design/ChipGen/bin/Genesis2Tools/gui";
    my $cgi_url = $SYS{CGI_URL};      # E.g. "/cgi-bin/genesis"
    my $gui_url = $SYS{GUI_HOME_URL}; # E.g. "/genesis"

    # For security purposes, do_anything.pl will only execute scripts from directories
    # that have been pre-registered in "tmp_safedirs"
    #print embed_alert_script("Gonna append \"$sourcedir\" to \"$gui_dir/tmp_safedirs\"");
    $sourcedir =~ s/[\/]+/\//; # Canonicalize dirname by changing e.g. /gen/designs//fftgen" to "/gen/designs/fftgen"
    $sourcedir =~ s/[\/]+$//;  # Canonicalize dirname by changing e.g. /gen/designs/fftgen/" to "/gen/designs/fftgen"
    system("echo $sourcedir >> $gui_dir/tmp_safedirs");  # Write canonicalized dirname to safedir list
    if ($LDBG) { print embed_alert_script("Appended \"$sourcedir\" to \"$gui_dir/tmp_safedirs\""); }

    # Temp file will be "scratch/$design_id-<pid>"
    # $$ is process num e.g. "mydesign-4782" or "mydesign-110212-133302-4028"

    my $tmpfile = "$php_basename-$$";

    if ($standalone) {
        $tmpfile = "$newdesign";
        if ($SDBG) { print "\n\nbnp: STANDALONE using tmpfile = $tmpfile\n\n"; }
    }

#    print embed_alert_script("newdesign = $newdesign\n");

    # Preserve or exclude special instructions from 0-main-template.php
    # $newdesign == "cmpdemo" => preserve special cmpdemo instructions
    # ELSE: no special instructions

    my $nodemo  = "|grep -v cmpdemo"; # Exclude special cmpdemo instructions.
    my $cmpdemo = "|cat";             # Keep cmpdemo instrs

    # if ($newdesign eq "cmpdemo") { print embed_alert_script("found cmp demo\n"); }

    my $demo_filter = $nodemo;                                # Default: no special demo instructions
    if ($newdesign eq "cmpdemo") { $demo_filter = $cmpdemo; } # Demo: keep special instructions
	
    $newdesfname =~ /(.*)(\.js)/; # E.g. "(mydesign-1104-052500)(.js)
    my $xmlfile  = "$1.xml";      # E.g. "mydesign-1104-052500.xml"

    # This is how we pass info to javascripts for download info (ha!)
    my $cv_link =
        "$SYS{SERVER_URL}$SYS{CGI_URL}/opendesign.pl".
        "?newdesign=tmp\\&amp;file=$xmlfile\\&amp;modpath=$modpath";

    # Problem: if $gui_dir/scratch does not exist, bsd_glob fails without
    # expanding e.g. "~/foo" => "/home/steveri/foo" as originally desired.

#    # bsd_glob() turns e.g. "~steveri" into "/home/steveri"
#    use File::Glob ':glob';
#    my $globbed_scratchdir = $standalone?
#        "." :
#        #bsd_glob("$gui_dir/scratch", GLOB_TILDE | GLOB_ERR);
#        bsd_glob("$gui_dir/scratch", GLOB_TILDE); # GLOB_ERR prevents "missing directory" check below.
#

    # BUG/TODO only works if 'dirname' command is present and in path etc.
    # Old dependence: File::Glob; new dependence: dirname
    my $globbed_scratchdir = $standalone ? "." :
        `dirname $gui_dir/scratch/foo`;  # Strips off "foo", expands any tildes in remainder.
    chomp($globbed_scratchdir);          # Strips off trailing "\n" if one exists.

#    print embed_alert_script("guidir = $gui_dir\n".
#                             "looked for \"$gui_dir/scratch\"\n".
#                             "found \"$globbed_scratchdir\"");

    if (! -e "$globbed_scratchdir") {

        my $msg =
            "Oops scratch directory \"$globbed_scratchdir\" did not exist.\n".
            "I tried to create it.  Please check to make sure it's there (and writable)!";

        print embed_alert_script($msg);

        my $err=0;
        mkdir "$globbed_scratchdir" or $err=1;
        if ($err) {
            print embed_alert_script("ERROR: mkdir failed in utils:build_php: ".$!);
            exit -1;
        }

    }

    if ($SDBG) {print "Is gui home dir == \"$gui_dir\" (still)?\n\n"; }

    my $inc_dir = $standalone ? $gui_dir : "..";

    if ($standalone) {
        $gui_url = "STANDALONE";
        $cgi_url = "STANDALONE";
    }

    my $cmd =
       "cat $gui_dir/0-main-template.php                     ".

       # Change all 'include "foo"' to 'include "../foo"'
       "|sed 's|include *\"|include \"$inc_dir/|'            ".

       # Change 'include "../curdesign_js"' back to 'include "curdesign_js"' (!??)
      #"|sed 's|$inc_dir/designs/tgt0/tgt0-baseline.js|$curdesign_js|g'     ". # Replace default design base.
       "|sed 's|$inc_dir/CURDESIGN_HERE|$curdesign_js|g'     ". # Replace default design base.

       $demo_filter.
       "|sed 's|CURRENT_DESIGN_FILENAME_HERE|$newdesfname|g' ". # E.g. "../designs/CMP/cmp-baseline.js"
       "|sed 's|NEW_DESIGN_BASENAME_HERE|$newdesign|g'       ".
       "|sed 's|CURRENT_BOOKMARK_HERE|$modpath|g'            ". # Begin at indicated module.
       "|sed 's|CURVIEW_LINK_HERE|$cv_link|g'                ". # Info for downloads
       "|sed 's|HOME_URL_HERE|$gui_url|g'                    ". # System dependent.
       "|sed 's|CGI_URL_HERE|$cgi_url|g'                     ". # System dependent.
       "|sed 's|^.*OPTIONAL GUI_EXTRAS.PHP.*\$|$gui_extras|g'     ". 
       " > $globbed_scratchdir/$tmpfile.php                  ";

    if ($LDBG) {
        my $printable_cmd = $cmd; $printable_cmd =~ s/   */ \n/g; 
        print embed_alert_script("$printable_cmd");
    }
    if ($SDBG) {
        my $printable_cmd = $cmd; $printable_cmd =~ s/   */ \n/g; 
        print "\n\n$printable_cmd\n\n";
        print "...and I am here: ".`pwd`."\n\n";
    }

    system($cmd);

    if ($SDBG || $LDBG) { print "Built new $tmpfile.php...\n\n"; }

    # BUG/TODO?
    # This is a GOOD way to pass information to the guisada script.
    if ($standalone) {
        print "\nGUI_STANDALONE_PHP $tmpfile.php\n";
        return("$tmpfile");
    }
    return("scratch/$tmpfile");
}

##############################################################################
# Issue debug message in a pop-up "alert" window

sub embed_alert_script {

  my $s = shift(@_);         # E.g. "FOO! We're now at line 12\n"

  my ($second, $minute, $hour) = localtime();
  my $clocktime = "$hour:$minute:$second";
  $s = "$clocktime $s";

  while (chomp($s)) {}       # Remove trailing <cr> characters
  if ($s eq "") { return ""; }  # If nothing left, skip it.

  $s =~ s/\n/\\n/g;   # Strip off trailing <cr> characters.
  $s =~ s/\'/\"/g;    # Single quotes can mess you up, man.

  my $script = 
   '<script type="text/javascript"><!--'."\n".
   "alert(\'$s\');\n".
   '//--></script>'."\n\n";

  return $script;
}  

sub deal_with_empty_file {
    my $curdesign_xml = shift(@_);
    my $DBG = shift(@_);

    # Warning removed per Ofer request.
    # print embed_alert_script
    #     ("WARNING:Input \"$curdesign_xml\" small/nonexistent, using empty design.\n");

    #BUG/TODO/NEXT: DO THE RIGHT THING
    #  - write the empty-file default as a change file,
    #    use that to do the first "updatedesign" (is this actually better?  why/how?)

    $curdesign_xml  =~ /(.*)\/([^\/]+)$/;    # E.g. "(../designs/tgt0)/(tgt0-baseline.xml)
    my $designdir   = $1;
    my $newdesfname = $2;  # tgt0-baseline.xml
    
    my $changefile   = "NONE";   # "NONE" means build and use "emptyfile" as change file.
    
    if ($DBG) {
        print embed_alert_script
            ("Calling updatedesign to create \"$newdesfname\" =? \"$curdesign_xml\"\n");
    }
    
    # Given the right arguments, updatedesign() should create valid *.xml and *.js files.
    updatedesign(
        $designdir,   # E.g. "../designs/tgt0"
        $changefile,  # E.g. "SysCfgs/foo-changes.xml"
        $newdesfname, # E.g. "clyde-100809,1315.xml"
        $DBG          # 0 or 1
        );
}

sub updatedesign {
  
    ##############################################################################
    # Call "Genesis2" based on "curdesign_js" path etc.
    # Genesis2.pl -gen -top top -depend depend.list -product genesis_vlog.vf \
    #             -hierarchy hierarchy_out.xml -debug 0 -xml SysCfgs/config.xml
    #
    # But we don't call Genesis2 directly: "updatedesign.csh" does all the work.

    my $designdir   = shift(@_); # E.g. "../designs/tgt0"
    my $changefile  = shift(@_); # E.g. "SysCfgs/foo-changes.xml"
    my $newdesfname = shift(@_); # E.g. "clyde-100809,1315.js" or "clyde-100809,1315.xml"
    my $DBG         = shift(@_); # 0 or 1

    # Test of ability to capture and return a msg from stderr
    #$alert_msg = `ls fugee 1> /tmp/$$ 2> /tmp/$$; cat /tmp/$$`;
    #alert($alert_msg);

    my $LDBG = 0; # Local debug
    my $SDBG = 0; # standalone debug (temp)
    my $standalone = $ENV{STANDALONE_GUI};
    if ($SDBG) { print "standalone = $standalone\n\n"; }

    ################################################################################################
    # Read the OFER cookie; set an environment variable if it's ON
    # use CGI; my $query = new CGI;
    # my $ofermode = $query->cookie('OFER_MODE');  # (Returns "" if cookie doesn't exist.)
    # $ENV{'OFER_MODE'} = ($ofermode eq "ON")? "ON" : "OFF";

    my $cgi_dir = $standalone ? mydir() : ".";
    my $updatedesign_shell = "$cgi_dir/../designs.aux/updatedesign.csh";
    if ($standalone) { $ENV{GUI_CGI_DIR} = mydir(); }

    #my $gencmd = "../designs.aux/updatedesign.csh\n"
    my $gencmd = "$updatedesign_shell\n"
      . "   -dir $designdir\n"
      . "   -ch $changefile\n"    # "NONE" means build and use "emptyfile" as change.
      . "   -out $newdesfname\n"
      . "   1> /tmp/tmp$$.1 2> /tmp/tmp$$.2;\n"
      . "   cat /tmp/tmp$$.[12]\n\n";

    if ($DBG) { alert("ready to call: $gencmd"); }

    if ($standalone) { print "Please be patient, this can take awhile...\n"; }

    $gencmd =~ s/\n//g;

#   if (! $DBG) { $gencmd = "$gencmd | grep -v WARNING"; }      # This works
#   if (! $DBG) { $gencmd = "$gencmd | grep '^Genesis'"; }      # Maybe this works better?
#   if (! $DBG) { $gencmd = "$gencmd | egrep '^Genesis|ERR'"; } # Better still.

#    print embed_alert_script("calling $gencmd\n");

    my $alert_msg = `$gencmd`; 

    if ($DBG) { alert("DEBUG:\n:".$alert_msg); }

    if (($alert_msg =~ /(Usage|ERR)/)) {

        # Build a truncated form of the output showing only error msg and environs.
        my $trunc_alert_msg = $alert_msg;

        # Eliminate stupid escape characters!!
        $trunc_alert_msg =~ s/..1;31;40m//g;
        $trunc_alert_msg =~ s/.\[0m//g;

        # Want at most 1024 chars after the error.
        if ($trunc_alert_msg =~ /(Usage|ERR)(.{1024})/s) {
            $trunc_alert_msg = $1.$2;
        }
        elsif ($trunc_alert_msg =~ /(Usage|ERR)(.*)/s) {
            $trunc_alert_msg = $1.$2;
        }

        # Keep it small: no sense going on past the exit...!
        if ($trunc_alert_msg =~ /(.*Exiting.*due to fatal error[^\n]*)/s) {
            $trunc_alert_msg = $1;
        }

        # Print the error message
        alert("Genesis2 driver returned the following error(s):\n".$trunc_alert_msg);

        # For completeness, print everything.
        alert(
            "\n\n".
            "==============================================================================\n".
            "Complete/raw output looks like this:\n\n".$alert_msg);

#         print "<pre>\n$alert_msg\n<\pre>\n";
        exit;
    }
}

sub updatedesigndirs { # e.g. "updatedesigndirs($DBG)
  
    ##############################################################################
    # Call "updatedesigndirs.pl" to update design dirs, xml links, etc.
    #   updatedesigndirs.pl -doit       (if DBG==0)
    #   updatedesigndirs.pl -doit -test (if DBG==1)

    my $DBG         = shift(@_); # 0 or 1

    my $test = $DBG ? " -test" : "";

    my $udd = "../designs.aux/updatedesigndirs.pl -doit$test\n"
      . "   1> /tmp/tmp$$.1 2> /tmp/tmp$$.2;\n"
      . "   cat /tmp/tmp$$.[12]\n\n";

    my ($second, $minute, $hour) = localtime();
    my $clocktime = "$hour:$minute:$second";
    if ($DBG) { print embed_alert_script("$clocktime ready to call: $udd"); }

    $udd =~ s/\n//g;

#   if (! $DBG) { $gencmd = "$gencmd | grep '^Genesis'"; } # Maybe this works better?

    my $alert_msg = `$udd`; 

    if ($DBG) { print embed_alert_script($alert_msg); }

    if (($alert_msg =~ /Usage/) || ($alert_msg =~ /ERR/)) {
      print "updatedesigndirs.pl returned the following error:\n";
      print "$alert_msg\n";
      exit;
    }
}

sub mydir {
    use Cwd 'abs_path';
    my $fullpath = abs_path($0); # Full pathname of script e.g. "/foo/bar/opendesign.pl"

    use File::Basename 'fileparse';
    my ($filename, $dir, $suffix) = fileparse($fullpath);
    return $dir;
}
  
sub alert {
    #if ($DBG == 0) { return; }

    my $s = shift(@_);     # E.g. "FOO! We are now at line 12\n"
    
    # Useful for placing timestamps on messages as they occur.
    # my ($second, $minute, $hour) = localtime();
    # my $clocktime = "$hour:$minute:$second";
    # $s = "$clocktime\n$s";

    if ($ENV{STANDALONE_GUI}) { print "$s\n"; return; }   # Print to console and quit.

    print "<small><pre>\n$s<br><br>\n</pre></small>\n\n"; # Print to html behind alert box.

    my $script = embed_alert_script($s);       # From utils.pl
    print $script;
}

sub build_gui_extras {
    # Given full path of a design directory, build a gui_extras.php file
    # for inclusion in 0-main-template.php
    # Assumes existence of a template file $designdir/bin/gui_extras.template
    # Returns error code 0 on success, non-nil error string on failure.
    my $designdir = shift @_; # E.g. "/home/steveri/fftgen"
    my $sourcedir = shift @_; # E.g. "../designs/FFTGenerator"
    my $DBG       = shift @_;

    if (! -d $designdir) { return "Could not find design directory \"$designdir\"."; }
    if (! -d $sourcedir) { return "Could not find source directory \"$sourcedir\"."; }

    my $template = "$sourcedir/bin/gui_extras.template";
    if (! -f $template) { return "Could not find template \"$template\""; }
    if ($DBG) { print embed_alert_script("Found gui_extras template \"$template\"."); }
    
    open(TEMPLATE, "<$template") or return "Could not open template \"$template\": $!";
    my @template_contents = <TEMPLATE>;
    close(TEMPLATE);

#     my @scripts; my @button_labels;
#     foreach my $line (@template_contents) {
#         if ($line =~ /^\s*([^#\s]+)\s+(["'].*["'])\s*$/) {
#             push(@scripts, $1); push(@button_labels, $2);
#         }
#     }
#     if (@scripts == 0) { return "Found no valid script info in template \"$template\""; }

    #print embed_alert_script("template file \"$template\"");

    my $gui_extras = "<!-- GUI extras =========================================================-->\n";

    my $found_info = 0;
    my @scripts; my @button_labels;
    while (@template_contents) {
        my $line = shift @template_contents;

        # VERBATIM info gets added, uh, verbatim.
        #print embed_alert_script("Looking at \"$line\"");
        if ($line =~ /^\s*\#\s*BEGIN\s*VERBATIM/) {
            #print embed_alert_script("Found begin");
            my $line = shift @template_contents;
            #print embed_alert_script("Looking at \"$line\"");
            $found_info = 1;
            while ((@template_contents) && ! ($line =~ /^\s*\#\s*END\s*VERBATIM/)) {
                $gui_extras = $gui_extras.$line;
                #print embed_alert_script("now gui_extras=\n$gui_extras");
                $line = shift @template_contents;
                #print embed_alert_script("Got line \"$line\"");
            }
        }

        # Look for coded button/script info
        if ($line =~ /^\s*([^#\s]+)\s+(["'].*["'])\s*$/) {
            push(@scripts, $1); push(@button_labels, $2);
            $found_info = 1;
        }
    }

    if ($found_info == 0) { return "Found no valid script info in template \"$template\""; }

    # Build one table for each button.
    my $class = "top_stack_button";
    for (my $i = 0; $i < @scripts; $i++) {
        my $script = $scripts[$i];
        my $label  = $button_labels[$i];
        $gui_extras .= "<table class=$class><tr><td>\n"; $class = "mid_stack_button";
        $gui_extras .= "  <input\n";
        $gui_extras .= "        type=\"button\" id=\"downloadbutton\"\n";
       #$gui_extras .= "    onclick=\"window.location=CGI_URL+'/do_anything.pl?/home/ser/fgen&bin/tmp_hello_gui.csh'\"\n";
        $gui_extras .= "    onclick=\"window.location=CGI_URL+'/do_anything.pl?".
                       "${designdir}&${sourcedir}&${script}'\"\n";
       #$gui_extras .= "    value='What the heck does this button do?'\n";
        $gui_extras .= "    value=$label\n";
        $gui_extras .= "  >\n";
        $gui_extras .= "</td></tr></table>\n\n";
    }
    $gui_extras .= "<br>\n";
    return (0, $gui_extras);

    # To test:
    # my ($err, $html) = build_gui_extras("foo");
    # if ($err) { print "ERROR: $err\n"; }  # Should print error: cannot find design directory "foo".
    #
    # my ($err, $html) = build_gui_extras("/tmp");
    # if ($err) { print "ERROR: $err\n"; }  # Should print error: cannot find template "/tmp/gui_extras.template".
    #
    # my ($err, $html) = build_gui_extras("/home/steveri/fftgen");
    # if ($err) { print "ERROR: $err\n"; }  # No error if bin/gui_extras.template exists and contains valid line.
    # else { print $html; }
}
1;
