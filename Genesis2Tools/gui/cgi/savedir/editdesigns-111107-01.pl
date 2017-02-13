#!/usr/bin/perl
use strict;

my $testmode = 0;

my $id = 0;

print "Content-type: text/html\n\n";

my $do_result  = do './utils.pl';     #  includes get_system_dependences(), get_input_parms()
if ($testmode) { print embed_alert_script("called include file utils.pl...\n"); }

my $parms = $ENV{QUERY_STRING};
#print embed_alert_script($parms);

# Parms may include e.g.:
#   ddir=/home/steveri/my_chipgen
#   dnam=steveri_chipgen
#   cmd=change (or "add")

my %INPUT = get_input_parms($parms);                    # from "do 'utils.pl'

#my $parmlist;
#foreach my $parm (sort keys(%INPUT)) {
#    $parmlist = $parmlist."\nfound parm \"$parm\" = \"$INPUT{$parm}\"";
#}
#print embed_alert_script($parmlist);


my $cmd = $INPUT{"cmd"};
#if (! $INPUT{"cmd"}) {
if (! $cmd) {
    print embed_alert_script("I don't gotta do NUTTIN");
}
else {
    my $ddir = $INPUT{"ddir"};
    my $dnam = $INPUT{"dnam"};
    if ($cmd eq "add") { 
        print embed_alert_script("Gotta add design $dnam => $ddir");
    }
    elsif ($cmd eq "change") {
        print embed_alert_script("Gotta change $dnam to $ddir");
    }
    else {
        print embed_alert_script("Oops unknown command");
    }
}

my %SYS = get_system_dependences(); # E.g. $SYS{GUI_HOME_DIR}
my $PBUTTON = "<img height=10 src=$SYS{GUI_HOME_URL}/images/plusbutton.png />";
my $MBUTTON = "<img height=10 src=$SYS{GUI_HOME_URL}/images/minusbutton.png />";

my $DBG=0; if ($ENV{QUERY_STRING} =~ /DEBUG=true/) { $DBG = 1; }
#print embed_alert_script("DEBUG=$DBG");

print_javascript(); print "\n";
print_style_block(); print "\n";

print_title();
print add_new_design();
print_edit_existing_design();
print_clean_up();
print_form();

#####################################################################################################
sub print_javascript {
    my @toggletable =
        (
         '<script type="text/javascript"><!--',
         'var currently_active_popuptable;',
         'function ToggleTable(id) {',
         '    var e = document.getElementById("designs_" + id);',
         '    var b = document.getElementById("button_"  + id);',
         '    if (e.style.display == "") { e.style.display = "none"; b.innerHTML = "+ " + id; }',
         '    else                       { e.style.display = "";     b.innerHTML = "- " + id; }',
         '}',

         ########################################################################
         # BUG/TODO do_nothing is not currently used...!
         'function do_nothing(i) { alert("i am " + i + "; i do almost nothing");',
         '                         var t = currently_active_popuptable;',
         '                         if (t) { t.style.display="none"; }',
         '                         t = document.getElementById("table"+i); t.style.display="inline"; ',
         '                         currently_active_popuptable = t;',
         '}',
         ########################################################################

         'function killtable(t) { document.getElementById(t).style.display="none"; }',
         'function deletedesign(f) {',
#        "    alert(f);",
#        "    alert('delete design '+document.forms[f]['dnam'].value);",
         "    document.forms[f]['ddir'].value = 'DELETE_ME';",
         '}',
         '//--></script>',
         '',
         );
    print join("\n",@toggletable);
}

sub print_style_block {
    my @style_block =
        (
         '<style type="text/css">',
         '  table.designtable { ',
         '      border: solid white; border-width:0px 0px 0px 80px; background-color:#e7d19a',
         '  }',
         '  table.designtable th { text-align:left }',
         '  table.designtable input.name_in { width:140px; }',
         '  table.designtable input.loc_in  { width:400px; }',
         '',
         '  .submitbutton { padding-left:80px; width:140px; }',
         '',
         '  /* input buttons inside table cells */',
         '  td input { font-family:courier-new; }',
         '  button {width:100%; text-align:left}',
         '  .popupbutton:hover  { background-color:#e7d19a; }',
         '  .popuptable {',
         '      display:none; position:absolute;top:10px;right:10px;',
         '      border:1px solid #c3c3c3;background-color:#e5eecc;z-index:1; font-size:small;',
         '  }',
         '</style>',
         ''
         );
    print join("\n",@style_block);
}

#        '  .filebutton { padding: 0px 10px; border: 1px solid black; }',
#        '  a { text-decoration: none; width:100% }',
#        '  a:hover { background-color:#e7d19a; }',
#        '  .cancelbutton       { background-color:#ff8888; }',
#        '  .cancelbutton:hover { background-color:#ff2222; }',
#        '  .abutton { padding: 0px 10px; border: 1px solid black; }',
#        '  .popuptable[showme=true] { background-color:blue; }',
#        '  .popuptable[mydisplay=false] { display:none; }',
        #'  table.designtable tr { background-color:#e7d19a }',


sub print_title {
    print "<head><title>Genesis Design Database</title></head>\n\n";
}

sub add_new_design {
    my @text = 
     (
      "<h2>Add new design directory</h2>",
      "<form method='get' action='editdesigns.pl'>",
      "  <table class=designtable>",
      "    <tr>    <th>Design name</th>    <th>Design location</th>    </tr>",
      "    <tr>",
      "      <td><input type=text class=name_in name=dnam></td>", # select w/"table.designtable td"
      "      <td><input type=text class=loc_in name=ddir></td>",
      "    </tr>",
      "  </table>",
      '  <span class=submitbutton><input type="submit" value="Submit"></span>',
      '  <input type=hidden name=cmd value=add />',
      "</form>",
#      "<br />\n",
      "",
      "",
    );
    return join("\n", @text);
}

sub print_edit_existing_design {
    my @header = 
        (
         "<h2>Edit existing design directories</h2>",
         "<small>",
         "<table class=designtable>",
         "  <tr><th>Design name</th><th>Design location</th></tr>",
         );

    ##############################################################################################
    my @trailer =
        (
         "</table>",
         "",
         "<span class=submitbutton>",
         '    <input type="submit" value="Submit">',
         "</span>",
#         "</form>",
         "</small>\n",
         "",
         );

    print join("\n", @header);

    my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}

    # TODO see ~/gui/designs.aux/updatedesigndirs.pl

    my $DL = get_design_list_filename(); # E.g. "/home/steveri/gui/configs/design_list_stanford.txt"
    open DL, "<$DL" or die "Could not find design list \"$DL\"";
    #if (1) { print "Found design list \"$DL\"<br /><br />"; }

    # Based on what we find in the design list, make
    # a list of designs and their source directories.

    ##############################################################################################
    my $FORMNUM=0;
    foreach my $line (<DL>) {
        # E.g. "demo /home/steveri/genesis_designs/demo"

        if ($line =~ /^\s*([^\#]\S+)\s+(\S+)/) {
            my $fname = "form".$FORMNUM++; # "form0", "form1", "form2", ...
            $fname = "\"$fname\""; # Put it in double quotes, why not.
            
            #print "$line<br />\n";
            #print "-$1-$2<br />\n";
            
            #$designs{$1} = $2; # E.g. $designs{"demo"} = "/home/steveri/genesis_designs/demo" 
            
            print "  <tr>\n";
            print "    <form method='get' action='editdesigns.pl' name=$fname>\n";
            print "    <td><input type=text class=name_in name=dnam value=$1></td>\n";
            print "    <td><input type=text class=loc_in  name=ddir value=$2></td>\n";
            print "    <td><input type=button value=Delete onclick=deletedesign($fname)></td>\n";
            print "    <td><input type=submit value=Submit changes></td>\n";
            print "    <input type=hidden name=cmd value=change />";
            print "    </form>\n";
            print "  </tr>\n";
        }
    }
    ##############################################################################################
    print join("\n", @trailer);
    return;

    ##############################################################################################
    # What's going on *here*?
    my $do_result  = do './getdesigns.pl';     #  contains subroutine "getdesigns()"

    my $DBG=0;
    my $designs = getdesigns($DBG);

    foreach my $k (sort keys(%$designs)) {
        print "k=$k<br />\n";
        print "designs=".$designs->{$k}."<br /><br />\n";
    }
}


###################################################################################################
sub print_clean_up {
  my @text = 
        (
         "<h2>Delete/cleanup individual designs <i>(not currently used!?)</i></h2>",
         );
  print join("\n", @text);
}
  
###################################################################################################
sub print_form {

    my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}
    my $opendesign = "$SYS{CGI_URL}/opendesign.pl";    # E.g. "/cgi-bin/genesis/opendesign.pl"
    if ($testmode) { print embed_alert_script("opendesign = $opendesign\n"); }
    if ($testmode) {
	print "<form method=\"get\" action=\"$SYS{CGI_URL}/foo.htm\">\n\n";
    }
    else {
	print "<form method=\"get\" action=\"$opendesign\">\n\n";
    }

    print_choose_existing_design();
    my @submitbutton = (
			'  <tr><td>',
			'    <br /><input type="submit" value="Submit"><br />',
			'  </td></tr>',
			);
    print join("\n",@submitbutton);
    print "\n\n</table>\n";
    print "<div style='text-align:right'><input type='checkbox' name='DBG' value=1>(debug)</input></div>";
    print "</form>\n";
    print "<a href=editdesigns.pl><b>Click here to edit the design database (add, subtract and edit designs).</b></a>",

}

###################################################################################################
sub print_choose_existing_design {

    print '<table style="border:solid white; border-left-width:100">'."\n";

    my $do_result  = do './getdesigns.pl';     #  contains subroutine "getdesigns()"

    # Select a default design e.g. "tgt0/tgt0-baseline.xml"

    my ($default_design,$default_config) = ("tgt0", "tgt0-baseline.xml");
    my ($default_design,$default_config) = ("fooby", "barby"); # No default design!

    my $designs = getdesigns($DBG);
    foreach my $k (sort keys(%$designs)) {
	
	print "  <!-- Button for design \"$k\" -->\n\n";

	print "  <tr><td><button type=button id=\"button_$k\" onclick=\"ToggleTable('$k');\">\n";
	print "    + $k\n";
	print "  </button></td></tr>\n";

	# Hide all but "default" list of config files.
	my $display = ($k eq $default_design) ? '' : ' style="display:none"';

	print "  <tr id=\"designs_$k\"$display><td>\n";

	my @list = split(" ", $designs->{$k});
	foreach my $design (@list) {
	    my $fullpath = "../designs/$k/$design";

	    # Skip "old", "save" directories.
	    if ($fullpath =~ /designs.old/) { next; }
	    if ($fullpath =~ /designs.save/) { next; }

	    my $selected = "";
	    if ($design eq $default_config) { $selected = ' checked="checked"'; }

#	    print "    <input  style='position:absolute' type='radio' name='file' value='$fullpath'$selected "."/><tt>$design</tt><br />\n";

	    print "    <div  style='position:relative; padding:0px 20px'>";
            print "<button type=button id=button$id onclick='do_nothing($id)'><tt>$design</tt></button>\n";
            print_buttons($id);
	    print "    </div>\n";

            $id++;

#            print "    <table class=popuptable id=table$id><tr><td>foo</td></tr></table></div>\n";
#            print "    <div onclick='alert(\"$fullpath\")'><tt>$design</tt></div>\n";

	}
        print "  </td></tr>\n\n";
    }

    # BUG/TODO something wacky here?
}

###################################################################################################
sub print_buttons {
    my $id = shift @_;
    print "    <table class=popuptable id=table$id>\n";
    print "      <tr><td onclick=alert('visitin') class=popupbutton>$PBUTTON Visit this design</td></tr>\n";
    print "      <tr><td onclick=alert('deletin') class=popupbutton>$MBUTTON Delete this design</td></tr>\n";
#    print "      <tr><td onclick=alert('deletin')>$MBUTTON Delete this design</td></tr>\n";
#    print "      <tr><td>Delete this design</td></tr>\n";
    print "      <tr><td onclick=killtable('table$id') class=popupbutton style=color:red><center><b>Cancel</b></center></td></tr>\n";
#    print "      <tr><td><button type=button height=10 style=color:#ff0000><tt>Cancel</tt><b></button></b></td></tr>\n";
    print "    </table>\n";
}

###################################################################################################
sub print_buttons_div {
    my $id = shift @_;
    print "    <div class=popuptable id=table$id>\n";
    print "      <button type=button onclick=alert('visitin')><small>Visit this design</small></button>\n";
#    print "      <tr><td>Delete this design</td></tr>\n";
#    print "      <tr><td>Cancel</td></tr>\n";
    print "    </div>\n";
}

############################################################################
# NOTES:
#
# Web resources for CGI scripts:  Google "cgi script example"
#   http://www.perlfect.com/articles/url_decoding.shtml
#   http://www.it.bton.ac.uk/~mas/mas/courses/html/html3.html
#   http://www.jmarshall.com/easy/cgi/
#   http://www.comptechdoc.org/independent/web/cgi/cgimanual/cgiexample.html
############################################################################


###################################################################################################
# Should this be in utils??
sub get_design_list_filename {

    # E.g. "DESIGN_LIST     ~steveri/gui/configs/design_list_stanford.txt"

    use File::Glob ':glob';  # To turn e.g. "~steveri" into "/home/steveri"

    open CONFIG, "<../CONFIG.TXT" or print_help_and_die(); # Maybe in wrong directory?
    foreach my $line (<CONFIG>) {
        if ($line =~ /^DESIGN_LIST\s+(\S+)/) {
            my $DL = bsd_glob($1, GLOB_TILDE | GLOB_ERR); # Turns e.g. "~steveri" into "/home/steveri"
            close CONFIG;
            return $DL;
        }
    }
    #my $homedir = bsd_glob('~steveri', GLOB_TILDE | GLOB_ERR);
    #print "$homedir\n\n";
}

