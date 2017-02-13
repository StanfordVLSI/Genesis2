# To test, try something like: perl -f <thisfile>

use strict;

sub get_system_dependences() {

  my %SYS;
  my $config = "../CONFIG.TXT";

  open CONFIG, "<$config" or die "Error. Cannot open config file \"$config\"";
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
    my $curdesign    = shift(@_);
    my $newdesign    = shift(@_);
    my $php_basename = shift(@_); # E.g. "
    my $modpath      = shift(@_); # E.g. ""mydesign"    or          "mydesign-110204-152500"

    my $newdesfname = $curdesign;

    # Temp file will be "scratch/$design_id-<pid>"
    # $$ is process num e.g. "mydesign-4782" or "mydesign-110212-133302-4028"

    my $tmpfile = "$php_basename-$$";

my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}
#print "hoodoo cgi dir is $SYS{CGI_DIR}\n"; exit;  # to test, uncomment this line.

# Path by which perl file finds the gui.
my $gui_dir = $SYS{GUI_HOME_DIR}; # E.g. "~steveri/smart_memories/Smart_design/ChipGen/gui";

    my $cgi_url = $SYS{CGI_URL};  # E.g. "/cgi-bin/genesis"

    my $cmd = 
       " sed 's|include *\"|include \"../|' $gui_dir/0-main-template.php ".
       "|sed 's|../designs/tgt0/tgt0-baseline.js|$newdesfname|g'         ". # Replace default design base.
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

sub embed_alert_script() {

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

1;
