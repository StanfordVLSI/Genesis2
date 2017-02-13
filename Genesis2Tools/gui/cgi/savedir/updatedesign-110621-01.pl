#!/usr/bin/perl

do './utils.pl'; #  includes get_system_dependences(), get_input_parms()

# Test rig for "build_xml_change_file" subroutine

my $RPDBG = 0;
# build_xml_change_file_testrig(); exit;

###############################################################
# Called from ig/Button_SubmitChanges.js with QUERY_STRING e.g.
# setenv QUERY_STRING "newdesign=clyde&curdesign=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js\
#  &modpath=top&ASSERTION=ON&MODE=VERIF&NUM_MEM_MATS=1&NUM_PROCESSOR=1&QUAD_ID=0&TILE_ID=0"

###############################################################
# Can call standalone, for testing, using the "-test" command-line argument.
my $testmode = 0; if ($ARGV[0] eq "-test") { $testmode = 1; }
if ($testmode) {
    $ENV{QUERY_STRING} = "newdesign=clyde"
#	."&curdesign=..%2Fdesigns%2Ftmp.tgt0%2Ftgt0-baseline.js"
	."&curdesign=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js"
	."&modpath=top&DBG=1"
	."&ASSERTION=OFF&MODE=VERIF&NUM_MEM_MATS=1&NUM_PROCESSOR=2&QUAD_ID=1&TILE_ID=1"
	."&SPECIAL_DATA_MEM_OPS.2.tiecode=foo";
    print "$ENV{QUERY_STRING}\n";
}

##############################################################################
# First, unpack the parms $INPUT{curdesign} and $INPUT{modpath} etc.
# First four parms should be "newdesign", "curdesign," "modpath" and "DBG".
# Remaining parms are xml parameters for xml "parmlist".
# "getparms" formats them e.g. "<NUM_MEM_MATS>1</NUM_MEM_MATS>" etc.

my @parmlist = getparms();

##############################################################################
# Need a header for the output file, so browser knows what's going on.

print "Content-type: text/html\n\n";

# ##############################################################################
# # Unpack encoded filename (I guess this was never used...???)
# 
# use URI::Escape;
# my $curdesign = $INPUT{curdesign};            # E.g. "..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js"
# $curdesign = uri_unescape($curdesign); # E.g. "../designs/tgt0/tgt0-baseline.js"

##############################################################################
# Need to know what directory the design lives in

my $curdesign = $INPUT{curdesign};  # E.g. "../designs/tgt0/tgt0-baseline.js"
$curdesign =~ s/\.js$/\.xml/;       # E.g. "../designs/tgt0/tgt0-baseline.xml"

$curdesign =~ /(.*)\/([^\/]+)$/;    # E.g. "(../designs/tgt0)/(tgt0-baseline.xml)
my $designdir     = $1;
#my $cur_basename  = $2;  # Never used!!  Just need the directory.  Assumes base design "top.vp"

my $DBG = $INPUT{DBG};

my $alert_msg  = "Found design dir \"$designdir\"\n\n";
   $alert_msg .= "Looking for module \"$INPUT{modpath}\"\n";
alert($alert_msg);

if ($testmode) { print "curdesign = $curdesign\n"; }
if ($testmode) { print "directory = $designdir\n"; }
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

alert("Creating change file \"$designdir/SysCfgs/$changefile\"\n");

build_xml_change_file($curdesign,
		      "$designdir/SysCfgs/$changefile",
		      $modpath, @parmlist
		      );


# Did it work???
#$alert_msg = `ls $designdir/SysCfgs/$changefile 1> /tmp/$$ 2> /tmp/$$; cat /tmp/$$`;
#alert($alert_msg);


##############################################################################
# Call "Genesis2" based on "curdesign" path etc.
# Genesis2.pl -gen -top top -depend depend.list -product genesis_vlog.vf \
#             -hierarchy hierarchy_out.xml -debug 0 -xml SysCfgs/config.xml
#
# But we don't call Genesis2 directly: "updatedesign.csh" does all the work.

if ($testmode) { exit; } # Time to bug out.

updatedesign($designdir,
	     "SysCfgs/$changefile",
	     $newdesfname,
	     $DBG);

##############################################################################
# Build and transfer to a new php file.  To the user, it will seem as if
# nothing has changed on his or her screen.

#my $curdesign = "CURDESIGN";
#my $newdesign = "CLYDE";
#my $newdesfname = "$designdir/$timestamp";


my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}
#print "hoodoo cgi dir is $SYS{CGI_DIR}\n"; exit;  # to test, uncomment this line.

# Path by which perl file finds the gui.
my $gui_dir = $SYS{GUI_HOME_DIR}; # E.g. "~steveri/smart_memories/Smart_design/ChipGen/gui";

# Path (URL) by which the browser finds the gui.
my $gui_url = "$SYS{SERVER_URL}$SYS{GUI_HOME_URL}"; # E.g. "http://www-vlsi.stanford.edu/ig/"

$newdesfname = "$designdir/$newdesfname";

my $php_basename = $id;

# Create a new design based on the javascript pointed to by $curdesign;
# give it a new name $newdesign; place gui for design in $php_basename-<pid>.php

my $tmpfile =         # E.g. "scratch/mydesign-110204-133000-4472" (130pm on 2/4/2011)
  build_new_php(      # Loaded from "utils.pl"
    $newdesfname,     # E.g. "../designs/tgt0/mydesign-110204-133000.js" (just now created at 130pm)
    $newdesign,       # E.g. "mydesign"
    $php_basename,    # E.g. "mydesign-110204-133000"
    $modpath          # E.g. "top.DUT.p0"
);

alert("$tmpfile.php should reflect new design file $newdesfname\n");

alert("...and off we go!!!");

print "<meta HTTP-EQUIV=\"REFRESH\" content=\"0; url=$gui_url/$tmpfile.php\">\n";

##############################################################################
# Issue debug messages in pop-up windows if DBG is turned on. E.g.
#
#  <script type="text/javascript"><!--
#     alert('how d"ye do');
#   //--></script>

sub alert {
  if ($DBG == 0) { return; }

  my $s = shift(@_);     # E.g. "FOO! We are now at line 12\n"

  if ($testmode) { print "$s\n"; return; }

  my $script = embed_alert_script($s);    # From utils.pl

  print $script;
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

sub build_xml_change_file {

    my $old_fname = @_[0];   # E.g. "designs/tgt0/demo-110225-162146.xml"

    my $new_regime =
	`head -n 5 $old_fname | grep HierarchyTop > /dev/null && echo -n 1 || echo -n 0`;

    if ($new_regime) {
	alert("Found NEW REGIME changefile \"$old_fname\"\n");
	alert("Will attempt to write NEW REGIME changefile\n");

	build_xml_change_file_new(@_);
	return;
    }
    else {
      my $t = $DBG; $DBG=1;
      alert("Found OLD REGIME changefile\n\"$old_fname\";\n");
      alert("ERROR Old regime no longer supported.  Sorry dude!\n");
      exit;
#      $DBG = $t;
    }
}

sub build_xml_change_file_testrig {

    # Test rig.
    my $testparmpath = "top.DUT.p0.rf.PDebugData_reg";

    my @testparms = ("<FLOP_DEFAULT>new_0</FLOP_DEFAULT>",
		     "<FLOP_TYPE>new_REFLOP</FLOP_TYPE>");

    build_xml_change_file(
		 "tgt0/demo-110225-162146.xml",
		 "tmp.out",
		 $testparmpath, @testparms
		 );
}

sub build_xml_change_file_new {

    ########################################################################
    # Given the name of an existing hierarchy file e.g. "designs/tgt0/demo-110225-162146.xml"
    # and a name for a new hier. file to be created;
    # and a path e.g. "top.DUT.p0.rf.PDebugData_reg"
    # and a list of parms e.g. @parmlist = (
    #    "<FLOP_DEFAULT>0</FLOP_DEFAULT>",
    #    "<FLOP_TYPE>REFLOP</FLOP_TYPE>");
    # print new hierarchy file with the new parameters instead of the old ones
    ########################################################################
    # Subroutine parms and globals

    my $old_fname = shift(@_);   # E.g. "designs/tgt0/demo-110225-162146.xml"
    my $new_fname = shift(@_);   # E.g. "designs/tgt0/SysCfgs/demo-110225-162146-changes.xml"

    my $targpath = shift(@_);    # E.g. "top.DUT.p0.rf.PDebugData_reg"
    my @parmlist  =      @_;     # E.g. ("<DEFAULT>0</DEFAULT>","<TYPE>REFLOP</TYPE>")

    alert(join("\n",@parmlist));

    if ($RPDBG) { print "DBG hoob $targpath xxx @parmlist\n\n"; }

    my @path;
    my $curmod;
    my $found_targ_module = 0;

    ########################################
    # Valid states include:
    #     "looking_for_module_name"
    #     "inside_module"
    #     "we_out"

    my $state = "looking_for_next_module";

    ########################################################################
    # Read in the old xml file.

    open EXISTING_HIERARCHY, "<$old_fname" or die "ERROR help help help";  # TODO/BUG "or die..."
    my @lines = <EXISTING_HIERARCHY>;
    close (EXISTING_HIERARCHY);

    ########################################################################
    # Prepare to write out new-changes file based on existing design file.

#    alert("20a preparing to write new changefile \"$new_fname\"\n");


    open CHANGES_FILE, ">$new_fname" or die "could not open $new_fname";

    while (my $line = shift(@lines)) {

	if ($RPDBG) { printf("%d %-23s %s", $found_targ_module, $state, $line); }
	else      { print CHANGES_FILE $line; }

	if ($state eq "we_out") { next; } # WE OUT!

	my $mname = qr/\w+/;                # One or more non-whitespace chars
	my $parms = qr/Parameters/;         # "Parameters"
	my $subin = qr/SubInstances/;       # "SubInstances"
	my $subit = qr/SubInstanceItem/;    # "SubInstanceItem"

#	my $ModuleName =        qr/^(\s*)[<]($mname)[>]\s*$/;
	my $ModuleName =        qr/^(\s*)[<]InstanceName[>]($mname)[<]\/InstanceName[>]\s*$/;


	my $Parameters        = qr/^(\s*)[<]($parms)[>]\s*$/;
	my $SubInstances      = qr/^(\s*)[<]($subin)[>]\s*$/;

#	my $CloseModule =       qr/^(\s*)[<]\/($mname)[>]\s*$/;
	my $CloseModule =       qr/^(\s*)[<]\/SubInstanceItem[>]\s*$/;


	my $CloseParameters   = qr/^(\s*)[<]\/($parms)[>]\s*$/;
	my $CloseSubInstances = qr/^(\s*)[<]\/($subin)[>]\s*$/;

	if ($state eq "looking_for_next_module") {

	    # Trigger on module name e.g. "<InstanceName>top</InstanceName>" or "...DUT...";
	    # or close-subinst tag "</SubInstances>"

	    if ($line =~ /$ModuleName/) {
		$curmod = $2;
		push (@path, $curmod);
		if ($RPDBG) {
		    print "FOO found modulename $curmod\n";
		    print "FOO path now looks like this: @path\n";
		    print "FOOB indent = " . length($1)/4 .
			  " and nelements = " . (scalar(@path)-1) . "\n";
		}

		$state = "inside_module";

		my $tmp = join(".", @path);      # E.g. ("top","DUT") => "top.DUT"
		if ($RPDBG) { print "BOOB $tmp $targpath\n\n"; }
		if ($tmp eq $targpath) {
		    if ($RPDBG) { print "EUREKA I have found it\n\n"; }
		    alert("EUREKA I have found it\n\n");
		    $found_targ_module = 1;
		}
	    }
	    elsif ($line =~ /$CloseSubInstances/) {
		if ($RPDBG) { print "FOO found subinst-close; curmod is $curmod\n"; }
		$state = "inside_module";
	    }
	}

	elsif ($state eq "inside_module") {
	    #2. Look for a) close-module or (b) subinstances or (c) close-subinstances

	    # Next trigger is "SubInstances" or "Parameters" or "close-module" or "close-subinst"
	    if ($line =~ /$SubInstances/) {
		if ($RPDBG) { print "FOO found SubInstances\n\n"; }
		$state = "looking_for_next_module";
	    }
	    elsif (($found_targ_module ==1) && ($line =~ /$Parameters/)) {

#		my $tmp = join(".", @path);      # E.g. ("top","DUT") => "top.DUT"
#		if ($tmp eq $targpath) {

		if ($RPDBG) { print "EUREKA I have found it\n\n"; }
		my $indent = $1;
#		if ($RPDBG) { printf("%d %-23s %s", 1, "new_parms", $line); }

		my $comm = $indent;
		if ($RPDBG) { $comm = "1 newpar $indent"; }

		foreach my $p (@parmlist) {

		    my $newparm = "";

		    $p =~ /[<]([^>]+)[>]([^<]+)[<][^>]+[>]/;  # E.g. "<(NPROCS)>(16)</NPROCS>"
		    my ($name,$val) = ($1,$2); 

 # Parms in the form "SPECIAL_DATA_MEM_OPS.2.tiecode=foo" indicate an array/hash...what to do???
		    # Should be something like...?
		    # <ParameterItem>
		    #  <Name>SPECIAL_DATA_MEM_OPS</Name>
		    #  <ArrayType>
		    #    <ArrayItem></ArrayItem> #(0)
		    #    <ArrayItem></ArrayItem> #(1)
		    #    <ArrayItem>             #(2)
		    #      <HashType>
		    #        <HashItem>
		    #          <Key>name</Key>
		    #          <Val>METALOADfoo</Val>
		    #        </HashItem>
		    #      </HashType>
		    #    </ArrayItem>
		    #  </ArrayType>
		    # </ParameterItem>

		    if ($name =~ /[.]/) {
			alert("\nWhoa!  Found hash/array item \"$name\" ... now what?\n");

			# commha = hash/array (ha) comment (comm)
			my $commha = $comm;

			# First the Parm name.
			$name =~ /^([^.]+)([.].*)/;                # (SPECIAL_DATA_MEM_OPS)(.2.tiecode)
			alert("    $1 $2"); # "SPECIAL_DATA_MEM_OPS" ".2.tiecode"

			$newparm .= "  $commha<ParameterItem>\n";
			$newparm .= "  $commha  <Name>$1</Name>\n";  # "SPECIAL_DATA_MEM_OPS"
			$name = $2;                                # ".2.tiecode"

			my $parmtail = "  $commha</ParameterItem>\n";

			# Now the various components of the path
			while ($name =~ /^[.]([^.]+)(.*)/) {      # .(2)(.tiecode), then .(tiecode)()
			    alert("    $1 $2");                   # "2" ".tiecode", then "tiecode" ""
			    my $index = $1;                       # "2"           , then "tiecode"
			    $name = $2;                           # ".tiecode"    , then ""
			    $commha = "$commha  ";

			    # If it's a number < 100, assume ArrayType
			    if ($index =~ /^[0-9]+$/) {
				$newparm .= "  $commha  <ArrayType>\n";
				$parmtail = "  $commha  </ArrayType>\n$parmtail";
				$commha = "$commha  ";

				# Skip ahead to correct array index starting at zero
				for (my $i=0; $i<$index; $i++) {
				    $newparm .= "  $commha  <ArrayItem></ArrayItem>\n";
				}

				$newparm .= "  $commha  <ArrayItem>\n";
				$parmtail = "  $commha  </ArrayItem>\n$parmtail"; # oh this is awful
				$commha = "$commha  ";
			    }

			    # Otherwise I guess it's a HashType
			    else {
				$newparm .= "  $commha  <HashType>\n";
				$parmtail = "  $commha  </HashType>\n$parmtail";
				$commha = "$commha  ";

				$newparm .= "  $commha  <HashItem>\n";
				$parmtail = "  $commha  </HashItem>\n$parmtail"; # oh this is awful
				$commha = "$commha  ";

				$newparm .= "  $commha  <Key>$index</Key>\n";
			    }
			}
			$newparm .= "  $commha  <Val>$val</Val>\n";
			$newparm .= $parmtail;

			if ($RPDBG) { print              "$newparm\n"; }
			else        { print CHANGES_FILE $newparm; }

			next;
		    }


		    $newparm .= "  $comm<ParameterItem>\n";

		    $newparm .= "  $comm  <Doc></Doc>\n";
		    $newparm .= "  $comm  <Name>$name</Name>\n";
		    $newparm .= "  $comm  <Range></Range>\n";
		    $newparm .= "  $comm  <Val>$val</Val>\n";

		    $newparm .= "  $comm</ParameterItem>\n";


		    if ($RPDBG) { print              "$newparm\n"; }
		    else        { print CHANGES_FILE $newparm; }


		    #if ($RPDBG) { printf("%d %-23s %s\n\n", 1, "newpar", "  $comm$p"); }
		    #else        { print CHANGES_FILE "  $comm$p\n"; }

		}


		# Skip over old parameters

		while (my $line = shift(@lines)) {
		    if ($line =~ /$CloseParameters/) {
			if ($RPDBG) { printf("%d %-23s %s", 1, "new_parms", $line); }
			else      { print CHANGES_FILE $line; }
			#$found_targ_module = 0;       # Not strictly necessary.
			$state = "we_out"; # Write rest of old file w/no further processing.
			last;
		    }
		}
	    }
	    elsif ($line =~ /$CloseModule/) { # Careful!  Close-mod looks like Subinst!
#		if ($2 eq $curmod) {

		    pop(@path);
		    $curmod = $path[$#path];
		    if ($RPDBG) {
			print "FOO found close-module name $1\n";
			print "FOO path now looks like this: @path\n";
			print "FOO and now curmod is $curmod\n";
			print "\n";
		    }
		    $state = "looking_for_next_module";
#		}
#		elsif ($2 eq "SubInstances") {   # Found close-subinst "</SubInstances>"
#		    # never happens!??
#		}
		}
	}
    }
    close (CHANGES_FILE);
    if ($found_targ_module != 1) {
	alert("ERROR! Never found target module \"$targpath\"\n");
    }
}
