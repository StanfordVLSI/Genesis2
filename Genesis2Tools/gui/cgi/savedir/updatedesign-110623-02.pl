#!/usr/bin/perl
use strict;
#my %INPUT;

#Possible new alg:
#  1. find the target module (as now)
#  2. foreach parm in target module
#     - do we have an update for this parm?  yes => overwrite, no => ignore

my $do_result;

#my $do_result  = do './utils.pl';     #  includes get_system_dependences()
#check_do_error('utils.pl', $do_result);

include_file("./utils.pl");     #  includes get_system_dependences()


#$do_result = do './updatedesign_getparms.pl'; #  for getparms()
#check_do_error('updatedesign_getparms.pl', $do_result);

include_file("./updatedesign_getparms.pl"); #  for getparms()

#if ($do_result != 1) {
#    print $error_header;
#    print "<p>Looks like a problem with \"utils.pl\"<br />\n";
#    print "Suggest you try:<br />\n";
#    print "<p><tt><b>&nbsp;&nbsp;&nbsp;&nbsp;perl -f utils.pl<b><tt><br />\n";
#    exit;
#}
#


my $RPDBG = 0; # Set to 1 for low-level debug

# Test rig for "build_xml_change_file" subroutine
#build_xml_change_file_testrig(); exit; # BUG/TODO test is old regime and it breaks.

##########################################################################################
# Called from ig/Button_SubmitChanges.js with QUERY_STRING e.g.
# setenv QUERY_STRING "newdesign=clyde&curdesign=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js\
#  &modpath=top&ASSERTION=ON&MODE=VERIF&NUM_MEM_MATS=1&NUM_PROCESSOR=1&QUAD_ID=0&TILE_ID=0"

############################################################################
# Can call standalone, for testing, using the "-test" command-line argument.
my $testmode = 0; if ($ARGV[0] eq "-test") { $testmode = 1; }
if ($testmode) {
    $ENV{QUERY_STRING} = "newdesign=clyde"
#	."&curdesign=..%2Fdesigns%2Ftmp.tgt0%2Ftgt0-baseline.js"
	."&curdesign=..%2Fdesigns%2Ftgt0%2Ftgt0-baseline.js"
	."&modpath=top&DBG=1"
	."&p1=v1&SPECIAL_DATA_MEM_OPS.2.tiecode=foo";
#	."&ASSERTION=OFF&MODE=VERIF&NUM_MEM_MATS=1&NUM_PROCESSOR=2&QUAD_ID=1&TILE_ID=1"
    print "$ENV{QUERY_STRING}\n\n";
}

##############################################################################
# First, unpack the parms $INPUT{curdesign} and $INPUT{modpath} etc.
# First four parms should be "newdesign", "curdesign," "modpath" and "DBG".
# Remaining parms are xml parameters for xml "PARMLIST" e.g.
# $PARMLIST{NUM_MEM_MATS} = 1, etc.

my %PARMLIST;
my %INPUT;
#getparms(\%INPUT, \%PARMLIST, $DBG);
getparms(\%INPUT, \%PARMLIST);

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
#my $cur_basename = $2;  # Never used!!  Just need the directory.  Assumes base design "top.vp"

my $DBG = $INPUT{DBG};

my $alert_msg  = "Welcome to updatedesign.pl\n\n";
   $alert_msg .= "Found design dir \"$designdir\"\n\n";
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
		      $modpath
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

sub build_xml_change_file {

    ########################################################################
    # Given the name of an existing hierarchy file e.g. "designs/tgt0/demo-110225-162146.xml"
    # and a name for a new hier. file to be created;
    # and a path e.g. "top.DUT.p0.rf.PDebugData_reg"
    # print new hierarchy file with the new parameters instead of the old ones
    # Assumes global hash holding parameters e.g.
    # $PARMLIST{FLOP_DEFAULT} = 0, $PARMLIST{FLOP_TYPE} = REFLOP
    # (or %PARMLIST = (FLOP_DEFAULT, 0, FLOP_TYPE, REFLOP))
    ########################################################################

    # Subroutine parms and globals

    my $old_fname = shift(@_);   # E.g. "designs/tgt0/demo-110225-162146.xml"
    my $new_fname = shift(@_);   # E.g. "designs/tgt0/SysCfgs/demo-110225-162146-changes.xml"

    my $targpath = shift(@_);    # E.g. "top.DUT.p0.rf.PDebugData_reg"

    my $new_regime =
	`head -n 5 $old_fname | grep HierarchyTop > /dev/null && echo -n 1 || echo -n 0`;

    if (! $new_regime) {
	$DBG=1;
#	alert("Found OLD REGIME changefile\n\"$old_fname\";\n");
#	alert("ERROR Old regime no longer supported.  Sorry dude!\n");

	alert("ERROR Could not find HierarchyTop tag in \n\"$old_fname\";\n");
	exit;
    }

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
    my $changes = "";           # Keep changes here until ready to write.

    # Convenient regular expressions

#    my $parms = qr/Parameters/;         # "Parameters"
#    my $subin = qr/SubInstances/;       # "SubInstances"
#    my $subit = qr/SubInstanceItem/;    # "SubInstanceItem"

    my $ModuleName        = qr/^(\s*)[<]InstanceName[>](\w+)[<]\/InstanceName[>]\s*$/;

    my $Parameters        = qr/^(\s*)[<](Parameters)[>]\s*$/;
    my $SubInstances      = qr/^(\s*)[<](SubInstances)[>]\s*$/;

    my $CloseParameters   = qr/^(\s*)[<]\/(Parameters)[>]\s*$/;
    my $CloseSubInstances = qr/^(\s*)[<]\/(SubInstances)[>]\s*$/;

    my $CloseModule       = qr/^(\s*)[<]\/SubInstanceItem[>]\s*$/;

    while (my $line = shift(@lines)) {

	if ($state eq "we_out") { last; } # WE OUT!

	if ($RPDBG) { printf("%d %-23s %s", $found_targ_module, $state, $line); }
	else        { $changes .= $line; } # Print lines as we search.

	if ($state eq "looking_for_next_module") {

	    # Trigger on module name e.g. "<InstanceName>top</InstanceName>" or "...DUT...";
	    # or close-subinst tag "</SubInstances>"

	    if ($line =~ /$ModuleName/) { # (indent)<InstanceName>(curmod)</InstanceName>
		$curmod = $2;
		push (@path, $curmod);
		if ($RPDBG) { foundmod_dbg($1, $2, @path); }
		if (pathmatch($targpath, @path)) { $found_targ_module = 1; } # EUREKA
		$state = "inside_module";
	    }
	    elsif ($line =~ /$CloseSubInstances/) {
		# BUG/TODO ???shouldn't we shift tail out of @path here...??
		# Maybe no; only do that for "CloseModule"
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

		if ($RPDBG) { print "EUREKA2 found parms in target module\n\n"; }
		my $indent = $1;

#		if ($RPDBG) { printf("%d %-23s %s", 1, "new_parms", $line); }

		$changes .= build_xml_parm_list($indent);

		# Skip over old parameters

		$state = "we_out";       # Write rest of old file w/no further processing.

	    }
	    elsif ($line =~ /$CloseModule/) { # Careful!  Close-mod looks like Subinst!

		pop(@path);
		$curmod = $path[$#path];
		if ($RPDBG) {
		    print "FOO found close-module name $1\n";
		    print "FOO path now looks like this: @path\n";
		    print "FOO and now curmod is $curmod\n";
		    print "\n";
		}
		$state = "looking_for_next_module";
	    }
	}
    }

    # Last thing we did was to write new parameters; now, skip over old parameters
    while (my $line = shift(@lines)) {
	if ($line =~ /$CloseParameters/) {
	    
	    if ($RPDBG) { printf("%d %-23s %s", 1, "new_parms", $line); }
	    else        { $changes .= $line; }

	    #$found_targ_module = 0;       # Not strictly necessary.
	    $state = "we_out";       # Write rest of old file w/no further processing.
	    last;
	}
    }

    # Write remaining lines unchanged.
    while (my $line = shift(@lines)) {

	if ($RPDBG) { printf("%d %-23s %s", $found_targ_module, $state, $line); }
	else        { $changes .= $line; } # Print lines as we search.
    }

    print CHANGES_FILE $changes;
    close (CHANGES_FILE);
    if ($found_targ_module != 1) {
	alert("ERROR! Never found target module \"$targpath\"\n");
    }
}

sub pathmatch {
    my $targpath = shift @_;
    my @path = @_;

    my $tmp = join(".", @path);      # E.g. ("top","DUT") => "top.DUT"
    if ($tmp eq $targpath) {
	alert("EUREKA1 found target module\n\n");
	return 1;
    }
    else {
	return 0;
    }
}

sub foundmod_dbg {
    my $indent  = shift @_;
    my $curmod = shift @_;
    my @path = @_;

    print "FOO found modulename $curmod\n";
    print "FOO path now looks like this: @path\n";
}    

#sub build_xml_parm_list {
#
#    ##############################################################
#    # Change %PARMLIST into $xmlparms i.e.
#    #
#    #     $PARMLIST{FLOP_DEFAULT} = 0
#    #     $PARMLIST{FLOP_TYPE} = REFLOP
#    #     $PARMLIST{SPECIAL}{0} = foo
#    #
#    # generates $xmlparms =
#    #     "    <ParameterItem>\n".
#    #     "      <Doc></Doc>\n".
#    #     "      <Name>FLOP_DEFAULT</Name>\n".
#    #     "      <Range></Range>\n".
#    #     "      <Val>0</Val>\n".
#    #     "    </ParameterItem>\n".
#    #     "    <ParameterItem>\n".
#    #     "      <Doc></Doc>\n".
#    #     "      <Name>FLOP_TYPE</Name>\n".
#    #     "      <Range></Range>\n".
#    #     "      <Val>REFLOP</Val>\n".
#    #     "    </ParameterItem>\n"
#
#    my $indent   = shift @_;
#    my $xmlparms = "";
#
#    foreach my $key (keys %PARMLIST) {
#	my $name = $key; my $val = $PARMLIST{$key};
#
#	# Parms in the form "SPECIAL_DATA_MEM_OPS.2.tiecode=foo" indicate an array/hash...
#	# what to do???
#
#	$xmlparms .= "  $indent<ParameterItem>\n";
#	$xmlparms .= "  $indent  <Doc></Doc>\n";
#	$xmlparms .= "  $indent  <Name>$name</Name>\n";
#	$xmlparms .= "  $indent  <Range></Range>\n";
#	$xmlparms .= "  $indent  <Val>$val</Val>\n";
#	$xmlparms .= "  $indent</ParameterItem>\n";
#
#	if ($RPDBG) { printf("%d %-23s %s\n", 1, "new_parms", "  $indent$name = $val"); }
#
#        # Should be more like "join $xmlparms, "1 new_parms" etc.
#
#    } # foreach my $key
#
#    alert("PARMS:\n$xmlparms\n");
#
#    return $xmlparms;
#}

####################################################################################################

sub build_xml_parm_list {

    ##############################################################
    # Change %PARMLIST into $xmlparms i.e.
    #
    #     $PARMLIST{FLOP_DEFAULT} = 0
    #     $PARMLIST{FLOP_TYPE} = REFLOP
    #     $PARMLIST{SPECIAL}{0} = foo
    #
    # generates $xmlparms =
    #     "    <ParameterItem>\n".
    #     "      <Doc></Doc>\n".
    #     "      <Name>FLOP_DEFAULT</Name>\n".
    #     "      <Range></Range>\n".
    #     "      <Val>0</Val>\n".
    #     "    </ParameterItem>\n".
    #     "    <ParameterItem>\n".
    #     "      <Doc></Doc>\n".
    #     "      <Name>FLOP_TYPE</Name>\n".
    #     "      <Range></Range>\n".
    #     "      <Val>REFLOP</Val>\n".
    #     "    </ParameterItem>\n"

#    my %parm = %{ shift (@_)};
    my $indent = shift @_;
    my %parm = %PARMLIST;
    my $xmlparms;

#    my $indent = "";
    foreach my $key (sort keys %parm) {
	my $val = $parm{$key};
	my $type = ref($parm{$key});

	if ($type eq "HASH") {
	    if ($RPDBG) { $xmlparms .= "#$key :: $val :: $type\n"; }
	    $xmlparms .= emit_parm_name($indent, $key);
	    $xmlparms .= process_hash("$indent    ", $key, $parm{$key});
	    $xmlparms .= emit_end_parm($indent);
	}
	else {
	    if ($DBG) { $xmlparms .= "\n"; }
	    $xmlparms .= emit_parm_name($indent, $key);
	    $xmlparms .= emit_simple_parm($indent, $val);
	}
    }
    alert("PARMS:\n$xmlparms\n");
    return $xmlparms;
}

sub emit_parm_name {
    my $indent = shift @_;
    my $name   = shift @_;
    my $newparm = "";

    $newparm .= "$indent<ParameterItem>\n";
    $newparm .= "$indent  <Name>$name</Name>\n";

    return $newparm;
}

sub emit_simple_parm {
    my $indent = shift @_;
    my $val    = shift @_;
    my $newparm = "";

    $newparm .= "$indent  <Doc></Doc>\n";
    $newparm .= "$indent  <Range></Range>\n";
    $newparm .= "$indent  <Val>$val</Val>\n";
    $newparm .= "$indent</ParameterItem>\n";

    return $newparm;
}

sub emit_end_parm {
    my $indent = shift @_;
    return "$indent</ParameterItem>\n";
}

####################################################################################################

sub process_hash {
    my $indent   =    shift(@_);
    my $key      =    shift(@_);
    my %hashparm = %{ shift(@_) };
    my @keys     = sort keys %hashparm;

    my $xmltype = ""; # Return string = e.g. "<HashType>...</HashType>"

    ########################################################################
    # Key might be an integer e.g. "0" (indicating array)
    # or a string e.g. "foo" (indicating hash)

    my $type = "Hash"; if ($keys[0] =~ /^[0-9]+/) { $type = "Array"; }

    # Open a new Type of the appropriate kind.

    $xmltype .= $indent."<".$type."Type>\n"; # "<HashType>" or "<ArrayType>"

    my $index    = 0;               # For counting array elements, starting at 0
    foreach my $key (@keys) {

	# Open a new Item for each key.

	if ($type eq "Array") {
	    my @aai = adjust_array_index($indent, $index, $key); # Hack(?) for sparse arrays
	    $index    = $aai[0];
	    $xmltype .= $aai[1].$indent."  <ArrayItem>\n";
	}
	else {
	    $xmltype .= $indent."  <HashItem>\n";
	    $xmltype .= $indent."    <Key>$key</Key>\n";
	}

	# Now print the hashvalue ($val) associated w/the key.
	# If hashvalue is itself a hash, call process_hash recursively, else emit hashvalue

	my $val = $hashparm{$key};
	my $reftype = ref($hashparm{$key});
	if ($RPDBG) { $xmltype .= "# $key :: $val :: $reftype\n"; }

	if ($reftype eq "HASH") {
	    $xmltype .= process_hash("$indent    ", $key, $hashparm{$key});
	}
	else {
	    $xmltype .= $indent."    <Val>$val</Val>\n";
	}

	$xmltype .= $indent."  </".$type."Item>\n"; # Close this item
    }
    $xmltype .= $indent."</".$type."Type>\n";       # Done with items; close the type.
}

sub adjust_array_index {

    # Given current array index $icur and desired index $itarg,
    # if ($itarg < $icur) then ERROR
    # if ($itarg == $icur) do nothing
    # if ($itarg >> $icur) then freak out (probably was a hash)
    # otherwise emit "<ArrayItem></ArrayItem>" pairs until $itarg = $icur

    my $indent = shift @_;
    my $icur   = shift @_;
    my $itarg  = shift @_;

    if ($itarg > 100)   { return ($icur, "ERROR very large array freakout\n"); }
    if ($itarg < $icur) { return ($icur, "ERROR array index out of order\n"); }

    my $rval = "";

    while ($icur < $itarg) {
	if ($RPDBG) { $rval .= "# [$icur]\n"; }
	$rval .= "$indent  <ArrayItem></ArrayItem>\n";
	$icur++;
    }
    if ($RPDBG) { $rval .= "# [$icur]\n"; }
#    $rval .= $indent."  <ArrayItem>\n";
    $icur++;

    return ($icur,$rval);
}

sub include_file {
    my $include_file = shift @_;
    my $do_result = do $include_file;
    check_do_error($include_file, $do_result);
}


sub check_do_error {
    my $do_file = shift @_;
    my $do_result = shift @_;

    my $error_header = "<head><title>ChipGen Error</title></head><h1>ChipGen Error</h1>\n\n";


    if ($do_result != 1) {
#	print $error_header;

	print "Looks like a problem with \"$do_file\"\n";
	print "Suggest you try:\n";
	print "    perl -f $do_file\n";
	exit;

#	print "<p>Looks like a problem with \"$do_file\"<br />\n";
#	print "Suggest you try:<br />\n";
#	print "<p><tt><b>&nbsp;&nbsp;&nbsp;&nbsp;perl -f $do_file<b><tt><br />\n";
#	exit;
    }
}
