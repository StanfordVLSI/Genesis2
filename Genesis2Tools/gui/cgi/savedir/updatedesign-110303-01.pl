#!/usr/bin/perl

# Called from ig/Button_SubmitChanges.js with QUERY_STRING e.g.
# setenv QUERY_STRING "newdesign=clyde&curdesign=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js\
#  &modpath=top&ASSERTION=ON&MODE=VERIF&NUM_MEM_MATS=1&NUM_PROCESSOR=1&QUAD_ID=0&TILE_ID=0"

# Can call standalone, for testing, using the "-test" command-line argument.
my $testmode = 0; if ($ARGV[0] eq "-test") { $testmode = 1; }
if ($testmode) {
    $ENV{QUERY_STRING} = "newdesign=clyde&curdesign=..%2Fdesigns%2Ftgt0-local%2Ftgt0-baseline.js"
	."&modpath=top&DBG=1&ASSERTION=ON&MODE=VERIF&NUM_MEM_MATS=1&NUM_PROCESSOR=1&QUAD_ID=0&TILE_ID=0";
    print "$ENV{QUERY_STRING}\n";
}

##############################################################################
# First, unpack the parms $INPUT{curdesign} and $INPUT{modpath} etc.
# First four parms should be "newdesign", "curdesign," "modpath" and "DBG".
# Remaining parms are xml parameters for xml "parmlist".

my @parmlist = getparms();

##############################################################################
# Need a header for the output file, so browser knows what's going on.

print "Content-type: text/html\n\n";

# ##############################################################################
# # Unpack encoded filename (I guess this was never used...???)
# 
# use URI::Escape;
# my $prevdesign_fullpath = $INPUT{curdesign};               # E.g. "..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js"
# $prevdesign_fullpath = uri_unescape($prevdesign_fullpath); # E.g. "../designs/tgt0/tgt0-baseline.js"

##############################################################################
# Need to know what directory the design lives in

my $prevdesign_fullpath = $INPUT{curdesign};  # E.g. "../designs/tgt0/tgt0-baseline.js"
$prevdesign_fullpath =~ /(.*)\/([^\/]+)$/;    # E.g. "(../designs/tgt0)/(tgt0-baseline.js)
my $designdir = $1;
my $prevdesign_basename = $2;  # Never used!!  Just need the directory.  Assumes base design "top.vp"

my $DBG = $INPUT{DBG};

my $alert_msg  = "Found design \"$prevdesign_basename\" in dir \"$designdir\"\n";
   $alert_msg .= "modpath \"$INPUT{modpath}\"\n";
alert($alert_msg);

if ($testmode) { print "curdesign = $prevdesign_fullpath\n"; }
if ($testmode) { print "directory = $designdir\n"; }
if ($testmode) { print "base name = $prevdesign_basename\n"; }
if ($testmode) { print "modpath   = $INPUT{modpath}\n"; }

##############################################################################
# Add timestamp to design name.   E.g. if design name is "my_design"
# and new timestamp is "100903,1155", new id is
# "my_design-100903-1155"

my $newdesign = $INPUT{newdesign};            # E.g. "my_design" or "amplifier17" or "clyde"
if ($newdesign eq "") {
  print "ERROR: new design name is null\n\n";
  exit;
}

# Make a unique id based on design name e.g. "clyde" and current time:
# "clyde-100809.1315" means "clyde, Aug 9, 2010 at 1:15pm"
my $timestamp = `date +%y%m%d-%H%M%S`; chomp($timestamp);

my $id = "$newdesign-$timestamp";
alert("newdesign = $id\n");

##############################################################################
# Create change file e.g. "clyde-100809,1315-changes.xml"

my $changefile = "$id-changes.xml";  # E.g. "clyde-100809,1315-changes.xml"
my $newdesfname = "$id.js";          # E.g. "clyde-100809,1315.js"

# Use parms to generate xml.

my $modpath     = $INPUT{modpath};      # E.g. "top.DUT.cfg"
my $xml_changes = build_xml_change_file($modpath, @parmlist);

# Write xml-formatted design changes "$xml_changes" to the new xml change file
alert($xml_changes);
alert("Creating change file \"$designdir/SysCfgs/$changefile\"\n");

open CHANGES_FILE, ">$designdir/SysCfgs/$changefile";
print CHANGES_FILE $xml_changes;
close (CHANGES_FILE);

# Did it work???
#$alert_msg = `ls $designdir/SysCfgs/$changefile 1> /tmp/$$ 2> /tmp/$$; cat /tmp/$$`;
#alert($alert_msg);


##############################################################################
# Now call "Genesis2" based on "curdesign" path etc.
# Genesis2.pl -gen -top top -depend depend.list -product genesis_vlog.vf \
#             -hierarchy hierarchy_out.xml -debug 0 -xml SysCfgs/config.xml
#
# But we don't call Genesis2 directly: "updatedesign.csh" does all the work.

# Test of ability to capture and return a msg from stderr
#$alert_msg = `ls fugee 1> /tmp/$$ 2> /tmp/$$; cat /tmp/$$`;
#alert($alert_msg);

my $gencmd = "../designs/updatedesign.csh\n"
  . "   -dir $designdir\n"
  . "   -ch SysCfgs/$changefile\n"
  . "   -out $newdesfname\n"
  . "   1> /tmp/tmp$$ 2> /tmp/tmp$$;\n"
  . "   cat /tmp/tmp$$\n\n";

alert("ready to call: $gencmd");

$gencmd =~ s/\n//g;

alert("calling $gencmd\n");

$alert_msg = `$gencmd`; alert($alert_msg);

if (($alert_msg =~ /Usage/) || ($alert_msg =~ /ERR/)) {
  print "Genesis2 driver returned the following error:\n";
  print "$alert_msg\n";
  exit;
}

##############################################################################
# Build and transfer to a new tmp.php file.  To the user, it will seem as if
# nothing has changed on his or her screen.

#my $prevdesign_fullpath = "CURDESIGN";
#my $newdesign = "CLYDE";
#my $newdesfname = "$designdir/$timestamp";

alert("tmp.php should reflect new design file $newdesfname\n");

my $gui = "~steveri/smart_memories/Smart_design/ChipGen/gui";

$newdesfname = "$designdir/$newdesfname";
my $cmd = 
       " sed 's|include *\"|include \"../|' $gui/0-main-template.php ".
       "|sed 's|../designs/tgt0/tgt0-baseline.js|$newdesfname|g'     ". # Replace default design base.
       "|sed 's|CURRENT_DESIGN_FILENAME_HERE|$newdesfname|g'         ".
       "|sed 's|NEW_DESIGN_BASENAME_HERE|$newdesign|g'               ".
       "|sed 's|CURRENT_BOOKMARK_HERE|$modpath|g'                    ". # Begin at top level.
       " > $gui/scratch/tmp.php                                      ";

if ($testmode) { print "$cmd\n\n"; exit; }

alert("Building new tmp.php...");
system($cmd);

alert("...and off we go!!!");

print '<meta HTTP-EQUIV="REFRESH" content="0; url=http://www-vlsi.stanford.edu/ig/scratch/tmp.php">\n';

##############################################################################
# Issue debug messages in pop-up windows if DBG is turned on.

sub alert {
  if ($DBG == 0) { return; }

  $s = shift(@_);     # E.g. "FOO! We are now at line 12\n"

  if ($testmode) { print "$s\n"; return; }

  while (chomp($s)) {}       # Remove trailing <cr> characters
  if ($s eq "") { return; }  # If nothing left, skip it.

  $s =~ s/\n/\\n/g;   # Strip off trailing <cr> characters.

  print '<script type="text/javascript"><!--'."\n";
  print "alert(\'$s\');\n";
  print '//--></script>'."\n\n";
}

##############################################################################
# Unpack the parms $INPUT{curdesign} and $INPUT{modpath} etc.
# First four parms should be "newdesign", "curdesign," "modpath" and "DBG".
# Remaining parms are xml parameters for xml "parmlist".

sub getparms {
  my $pairnum = 0;
  my @parmlist;

  my $parms = $ENV{QUERY_STRING};
  my @fv_pairs = split /\&/ , $parms;
  foreach $pair (@fv_pairs) {
      if($pair=~m/([^=]+)=(.*)/) {
  	$field = $1; $value = $2;
  	$value =~ s/\+/ /g;
  	$value =~ s/%([\dA-Fa-f]{2})/pack("C", hex($1))/eg;
	$INPUT{$field}=$value;

	$pairnum++;
	if ($pairnum > 4) {
	  push(@parmlist, "<$field>$value</$field>");
	}
      }
  }
  return @parmlist;
}

##############################################################################
# Use parms to generate xml.
#
# Given something like: "modpath=top.DUT&NUM_MEM_MATS=1&NUM_PROCESSOR=1"
# Generate something like:
# <top>                                            (head)
#     <SubInstances>                               (head)
#        <DUT>                                     (head)
#            <Parameters>                          (head)
#                <NUM_MEM_MATS>1</NUM_MEM_MATS>
#                <NUM_PROCESSOR>1</NUM_PROCESSOR>
#                ...
#            </Parameters>                         (tail)
#        </DUT>                                    (tail)
#     </SubInstances>                              (tail)
# </top>                                           (tail)

# Unpack modpath e.g. "top.DUT.cfg"

sub build_xml_change_file {
  my $modpath = shift(@_);                        # E.g. "top.DUT.cfg"
  my @parmlist = @_;

  my @path_array = split(/[.]/, $modpath);        # E.g. {"top", "DUT", "cfg"}
  my $top = shift(@path_array);                   # E.g. "top"

  my $head = "<$top>\n";                          # E.g. "<top>\n"
  my $tail = "</$top>\n";                         # E.g. "</top>\n"
  my $indent = "   ";

  # Every path element except last one must have a "SubInstances" field.
  foreach my $p (@path_array) {
    $head = "$head$indent<SubInstances>\n";       # E.g. "<top>\n    <SubInstances>\n"
    $tail = "$indent</SubInstances>\n$tail";      # E.g. "    </SubInstances>\n></top>\n"
    $indent = "$indent    ";

    $head = "$head$indent<$p>\n";                 # E.g. "<top>\n    <SubInstances>\n        <DUT>\n"
    $tail = "$indent</$p>\n$tail";                # E.g. "        </DUT>\n    </SubInstances>\n></top>\n"
    $indent = "$indent    ";
  }

  # Last tail element must have a "Paramaeters" subfield.
  $head = "$head$indent<Parameters>\n";
  $tail = "$indent</Parameters>\n$tail";
  $indent = "$indent    ";

  # Add parms and values in between $head and $tail to form final "xml changes" text.
  # parmlist = e.g. {  "<NUM_MEM_MATS>1</NUM_MEM_MATS>"  ,  "<NUM_PROCESSOR>1</NUM_PROCESSOR>"  }

  my $xml_changes = $head;
  foreach my $p (@parmlist) { $xml_changes .= "$indent$p\n"; }
  $xml_changes .= $tail;

  return $xml_changes;
}


