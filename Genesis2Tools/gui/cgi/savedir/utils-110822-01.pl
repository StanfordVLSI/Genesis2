# To test, try something like: perl -f <thisfile>

use strict;

sub get_system_dependences() {

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

      #print "sys{$1} = \"$2\"\n";
      $SYS{$1} = $2;                 # E.g. $SYS{GUI_URL} = "/cgi-bin/ig"
    }
  }
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

# Example values:
#
#   $curdesign    = "../tgt0/default.js"  or  "../tgt0/mydesign-110204-151500.js"
#   $newdesign    =         "mydesign" BUT NEVER      "mydesign-110204-152500"
#   $php_basename =         "mydesign"    or          "mydesign-110204-152500"
#
#   $modpath      = "top" or "top.DUT.p0"
#
#   $tmpfile   =      "mydesign-<pid>" or        "mydesign-110204-152500-<pid>"
#
# (Timestamp on tmpfile should never be necessary as long as each user has a unique "mydesign" name).

sub build_new_php() {
    my $curdesign    = shift(@_); # E.g. "../designs/tgt0/tgt0-baseline.js"
    my $newdesign    = shift(@_); # E.g. "mydesign"
    my $php_basename = shift(@_); # E.g. "mydesign"
    my $modpath      = shift(@_); # E.g. "top" or ? "top.DUT.p0" ?

#    print embed_alert_script("design = $curdesign\n");

    my $nlines = `cat $curdesign | wc -l`;
    chop $nlines;
    $nlines += 0;

#    print embed_alert_script("design file size = $nlines lines\n");

    # If nlines <= 5 use a default/empty javascript file

    my $newdesfname = $curdesign;

    if ($nlines < 5) {
	print embed_alert_script("Too small, using empty design.\n");


	#BUG/TODO/NEXT
	#DO THE RIGHT THING:
	#  - write the empty-file default as a change file,
	#    use that to do the first "updatedesign"

#    my $curdesign    = shift(@_); # E.g. "../designs/tgt0/tgt0-baseline.js"

	$curdesign =~ /(.*)\/([^\/]+)$/;    # E.g. "(../designs/tgt0)/(tgt0-baseline.js)
	my $designdir    = $1;
	my $newdesfname  = $2;  # tgt0-baseline.xml
	my $changefile   = "../empty_design.xml";  # Relative to design dir
	my $DBG = 1;

	print embed_alert_script("Calling updatedesign to create \"$newdesfname\" =? \"$curdesign\"\n");

	# Given the right arguments, updatedesign() should create valid *.xml and *.js files.
	updatedesign(
		     $designdir,   # E.g. "../designs/tgt0"
		     $changefile,  # E.g. "SysCfgs/foo-changes.xml"
		     $newdesfname, # E.g. "clyde-100809,1315.js"
		     $DBG          # 0 or 1
		     );

#	print embed_alert_script("Using blank/empty design template.\n");
#	$curdesign = "../designs/empty_design.js";
    }

    # Temp file will be "scratch/$design_id-<pid>"
    # $$ is process num e.g. "mydesign-4782" or "mydesign-110212-133302-4028"

    my $tmpfile = "$php_basename-$$";

    my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}
    #print "hoodoo cgi dir is $SYS{CGI_DIR}\n"; exit;  # to test, uncomment this line.

    # Path by which perl file finds the gui.
    my $gui_dir = $SYS{GUI_HOME_DIR}; # E.g. "~steveri/smart_memories/Smart_design/ChipGen/gui";

    my $cgi_url = $SYS{CGI_URL};  # E.g. "/cgi-bin/genesis"

#    print embed_alert_script("newdesign = $newdesign\n");

    my $nodemo  = "|grep -v cmpdemo |grep -v socdemo";
    my $socdemo = "|grep -v cmpdemo";
    my $cmpdemo = "|grep -v socdemo";

#    if ($newdesign eq "cmpdemo") { print embed_alert_script("found cmp demo\n"); }
#    if ($newdesign eq "socdemo") { print embed_alert_script("found soc demo\n"); }

    my $demo_filter = $nodemo;
    if ($newdesign eq "cmpdemo") { $demo_filter = $cmpdemo; }
    if ($newdesign eq "socdemo") { $demo_filter = $socdemo; }
	


    my $cmd = 
       " sed 's|include *\"|include \"../|' $gui_dir/0-main-template.php ".
       $demo_filter.
       "|sed 's|../designs/tgt0/tgt0-baseline.js|$curdesign|g'           ". # Replace default design base.
       "|sed 's|CURRENT_DESIGN_FILENAME_HERE|$newdesfname|g'             ".
       "|sed 's|NEW_DESIGN_BASENAME_HERE|$newdesign|g'                   ".
       "|sed 's|CURRENT_BOOKMARK_HERE|$modpath|g'                        ". # Begin at indicated module.
       "|sed 's|CGI_URL_HERE|$cgi_url|g'                                 ". # System dependent.
       " > $gui_dir/scratch/$tmpfile.php                                 ";

    #print "$cmd\n\n";
    #exit;

# if ($testmode) { print "$cmd\n\n"; exit; }

# alert("Building new $tmpfile.php...");


    system($cmd);

    return("scratch/$tmpfile");
}

##############################################################################
# Issue debug message in a pop-up "alert" window

sub embed_alert_script {

  my $s = shift(@_);         # E.g. "FOO! We're now at line 12\n"

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

sub updatedesign {
  
    ##############################################################################
    # Call "Genesis2" based on "curdesign" path etc.
    # Genesis2.pl -gen -top top -depend depend.list -product genesis_vlog.vf \
    #             -hierarchy hierarchy_out.xml -debug 0 -xml SysCfgs/config.xml
    #
    # But we don't call Genesis2 directly: "updatedesign.csh" does all the work.

    my $designdir   = shift(@_); # E.g. "../designs/tgt0"
    my $changefile  = shift(@_); # E.g. "SysCfgs/foo-changes.xml"
    my $newdesfname = shift(@_); # E.g. "clyde-100809,1315.js"
    my $DBG         = shift(@_); # 0 or 1

    # Test of ability to capture and return a msg from stderr
    #$alert_msg = `ls fugee 1> /tmp/$$ 2> /tmp/$$; cat /tmp/$$`;
    #alert($alert_msg);

    my $gencmd = "../designs/updatedesign.csh\n"
      . "   -dir $designdir\n"
    #  . "   -ch SysCfgs/$changefile\n"
      . "   -ch $changefile\n"
      . "   -out $newdesfname\n"
      . "   1> /tmp/tmp$$.1 2> /tmp/tmp$$.2;\n"
      . "   cat /tmp/tmp$$.[12]\n\n";

    if ($DBG) { print embed_alert_script("ready to call: $gencmd"); }

    $gencmd =~ s/\n//g;

#   if (! $DBG) { $gencmd = "$gencmd | grep -v WARNING"; } # This works
    if (! $DBG) { $gencmd = "$gencmd | grep '^Genesis'"; } # Maybe this works better?

#    print embed_alert_script("calling $gencmd\n");

    my $alert_msg = `$gencmd`; 

    # ALWAYS show result of command, regardless of DBG value (is this the best way to do this?) BUG/TODO?

    if ($DBG) { print embed_alert_script($alert_msg); }

    if (($alert_msg =~ /Usage/) || ($alert_msg =~ /ERR/)) {
      print "Genesis2 driver returned the following error:\n";
      print "$alert_msg\n";
      exit;
    }

}

1;
