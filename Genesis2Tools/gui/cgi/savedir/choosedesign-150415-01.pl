#!/usr/bin/perl
use strict;

my $DBG9 = 0;

my $testmode = 0;
my $id = 0;

##############################################################################
# Can call -standalone (different than standalone-for-testing).

my $SDBG = 0;     # Debug standalone mode
my $standalone = ($ARGV[0] eq "-standalone") ? 1 : 0;

if ($standalone) {
    my $mydir = mydir();
    chdir $mydir;
    if ($SDBG) { print "Where am I?  Maybe I'm here:\n$mydir\n\n"; }
}

#######################################################################################
# This file generates a form and sends the resulting user input of new and existing
# design names to "opendesign.pl" as parameters "newdesign" and "file" respectively
# -------------------------------------------------------------------------------------
# "What is your name (e.g. "john", "mary", "shenwen")?     => "&newdesign"
#
# "Which design would you like to browse/modify?           => "&file"
#    100720-1310-ofer.htm
#    100718-2245-kyle.htm
#    ...
# "SUBMIT"
# -------------------------------------------------------------------------------------
# (Note: opendesign.pl will remove spaces and such from "name" leaving only [a-zA-Z0-9]
# (Is that true!??)
#######################################################################################

print "Content-type: text/html; charset=utf-8\n\n";
print
    '<!DOCTYPE HTML PUBLIC '.
    '"-//W3C//DTD HTML 4.01 Transitional//EN" '.
    '"http://www.w3.org/TR/html4/loose.dtd">'.
    "\n";

my $do_result  = do './utils.pl';     #  includes get_system_dependences(), get_input_parms()
if ($testmode) { print embed_alert_script("called include file utils.pl...\n"); }


my %SYS = get_system_dependences(); # E.g. $SYS{GUI_HOME_DIR}
my $PBUTTON = "<img height=10 src='$SYS{GUI_HOME_URL}/images/plusbutton.png' alt='add'>";
my $MBUTTON = "<img height=10 src='$SYS{GUI_HOME_URL}/images/minusbutton.png' alt='sub'>";

my $DBG=0; if ($ENV{QUERY_STRING} =~ /DEBUG=true/) { $DBG = 1; }

my $qs = $ENV{QUERY_STRING};
my %INPUT = get_input_parms($qs);

my $default_design = "NO_DEFAULT"; # No default design!  Any nonsense phrase turns it off.

if ($INPUT{DELETE}) {

    # Delete "$delete" and reopen design "$design".
    my $delete = $INPUT{"DELETE"};
    my $design = $INPUT{"DESIGN"};

    my $pwd=`pwd`; # For debug purposes only!
    if ($DBG9) {
        my $cmd = "ls -l $delete"; # print embed_alert_script("cmd=$cmd");
        my $res = `$cmd`;          # print embed_alert_script("err=$err");
        print embed_alert_script("pwd = $pwd\n% $cmd\n$res");
    }

    # To delete, simply rename w/extension "deleteme"
    my $cmd = "mv $delete $delete.deleteme";
    my $res = `$cmd`;
    if ($DBG) { print embed_alert_script("pwd = $pwd\n% $cmd\n$res"); }

    # Quick check to see if the delete part worked
    if ($DBG9) {
        my $cmd = "ls -l $delete"; my $res = `$cmd`;
        print embed_alert_script("pwd = $pwd\n% $cmd\n$res");
    }

    $default_design = $design;
}

#print embed_alert_script("DEBUG=$DBG");

print "\n<html>\n";
print build_head_inc_style();
print "\n<body>\n";
print_script_block(); print "\n";
print build_title_and_intro();
print_form();
print "\n\n";

print 
    '<!-- HTML compliance -->'                            ."\n".
    '<p>'                                                 ."\n".
    '<a href="http://validator.w3.org/check?uri=referer">'."\n".
    '    <img src="http://www.w3.org/Icons/valid-html401"'."\n".
    '         alt="Valid HTML 4.01 Transitional">'        ."\n".
    '    <!-- height="31" width="88" -->'                 ."\n".
    '</a>'                                                ."\n";

print "\n</body></html>\n";

if ($standalone) { exit 0; }

#####################################################################################################
sub print_script_block {
    my @script_block =
        (
         '<script type="text/javascript"><!--',

         'var most_recently_active_popuptable;',
         'function ToggleTable(id) {',
         '    var e = document.getElementById("designs_" + id);',
         '    var b = document.getElementById("button_"  + id);',
         '    if (e.style.display == "") { e.style.display = "none"; b.innerHTML = "+ " + id; }',
         '    else                       { e.style.display = "";     b.innerHTML = "- " + id; }',
         '}',

         'function togglepopup(i) { ',

         '  var t0 = most_recently_active_popuptable;',    # The one that's currently active.
         '  var t1 = document.getElementById("table"+i);', # The one we just clicked.

         # If another popup currently active (t0), make sure it's off.
         '  if (t0) { if (t0 != t1) { t0.style.display="none"; }}',

         # Toggle the popup that was just clicked (t1).
         '  if (t1.style.display == "inline") { t1.style.display="none";   }',
         '  else                              { t1.style.display="inline";   }',

         '  most_recently_active_popuptable = t1;',
         '}',

         'function visit_it(filename) {',
         '  // "newdesign" has already been set by user; we need to fill in "file"',
#       #'  alert("i think newdesign= " + document.forms[0]["newdesign"].value);',
         '  document.forms[0]["file"].value = filename;',
         '  document.forms[0].submit();',
         '}',

         'function delete_it(design,filename) {',
         #'alert("ima gonna delete " + filename); alert("and reopen design " + design);',
         '  var checked = document.getElementById("dbg_chkbox").checked;',
         '  var update = "choosedesign.pl?DELETE="+filename+"&DESIGN="+design;',
         '  if (checked) { update += "&DEBUG=true"; }',
         #'alert(update);',
         '  window.location = update;',
         '}',

         'function killtable(t) { document.getElementById(t).style.display="none"; }',
                       
         '//--></script>',
	'',
    );
    print join("\n",@script_block);
}

sub build_head_inc_style {
    my @head = (
      "<head>",
      "  <title>Interactive Chip Generator powered by Genesis</title>",
      '  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">',
      '',
      '  <style type="text/css">',
      '     button {width:100%; text-align:left}',
      '   ',
      '     .popupbutton:hover  { background-color:#e7d19a; }',
      '   ',
      '     .popuptable {',
      '        display:none; position:absolute; z-index:1; width:100%; ',
      '        border:1px solid white; border-width: 0px 40px 0px 0px; ',
      '        background-color:#e5eecc; font-size:small;',
      '     }',
      '  </style>',
      "</head>",
      "",
    );
    return join("\n", @head);
}


sub build_title_and_intro {

    my @intro =
     (
      "<h2>Welcome to the Interactive Chip Generator!</h2>",
      "",
     #"<table style='width:520'><tr><td>",
      "<table><tr><td>",
      "The Interactive Chip Generator (ICG) allows you to take an existing design base",
      "and quickly modify it to produce a new design, customized for your specific needs.",
      "",
      "<p>First, choose a base name for your design.  This can be any combination of",
      "letters, numbers and hyphens, e.g. \"mydesign\" or \"smartmem-bob\".",
      "The Interactive Chip Generator will append a timestamp to the base",
      "name to create a unique version each time you save your design,",
      "e.g. \"mydesign-100815-134333\" would be the version of \"mydesign\"",
      "written on August 15, 2010 at 33 seconds after 1:43pm.",
      "</td></tr></table>",
      "",
      "<br>\n",
      "",
    );
    return join("\n", @intro);
}


sub print_form {

    my %SYS = get_system_dependences();                # E.g. $SYS{GUI_HOME_DIR}
    my $opendesign = "$SYS{CGI_URL}/opendesign.pl";    # E.g. "/cgi-bin/genesis/opendesign.pl"
    if ($testmode) { print embed_alert_script("opendesign = $opendesign\n"); }
    if ($testmode) {
	print "<form method=\"get\" action=\"$SYS{CGI_URL}/foo.htm\">\n\n";
    }
    else {
	print "<form method=\"get\" action=\"$opendesign\">\n\n";
	print "  <input type=hidden name=file>\n\n",     # Placeholder to be filled in by script.
    }

    print_base_name_request();
    print_choose_existing_design();

    print "\n\n</table>\n";
    print "<div style='text-align:right'>".
          "<input type='checkbox' name='DBG' id=dbg_chkbox value=1>(debug)</div>";
    print "</form>\n";

    my $designdir = `cd ../designs; pwd`; chomp($designdir);
    print
        "<small><i>(Designs live here: $designdir)<br></i></small>".
        "<a href=editdesigns.pl>".
        "<b>Click here to edit the design database (add, subtract and edit designs).</b></a>";
}

sub print_base_name_request {

    my @instructions = (
      "<table><tr><td>",
      "  <b>Base name for your new design</b> (e.g. \"john\" or \"mary17\" or \"memtile7\"): ",
      "  <input type=\"text\" name=\"newdesign\" value=\"mydesign\"><br>",
      "",
      "  <p>",
      "  <b>Now, choose an existing design as a base for your new design.</b><br>",
      "  What existing design would you like to start from?<br>",
      "",
      "</td></tr></table>",
      "",
    );

    print join("\n", @instructions);
}

sub print_choose_existing_design {

    print '<table style="border:solid white; border-left-width:100">'."\n";

    my $do_result  = do './getdesigns.pl';     #  contains subroutine "getdesigns()"

    my $designs = getdesigns($DBG);
    foreach my $k (sort keys(%$designs)) {
	
	print "  <!-- Button for design \"$k\" -->\n\n";

	print "  <tr><td><button type=button id=\"button_$k\" onclick=\"ToggleTable('$k');\">\n";
	print "    + $k\n";
	print "  </button></td></tr>\n";

	# Hide all but "default" list of config files.
	my $display = ($k eq $default_design) ? '' : ' style="display:none"';

	print "  <tr id=\"designs_$k\"$display><td>\n";

        # @list is list of all designs currently in the "GUI/designs/$key" directory
        # E.g. if $k = "tgt0" it might be all files "~/gui/designs/tgt0/*.xml"
	my @list = split(" ", $designs->{$k});

        # Order the list such that "small_" and "tiny_" designs are at the end.

        my (@small, @tiny, @other);
	foreach my $design (@list) {
            if ($design =~ /^tiny_/)     { push(@tiny, $design); }
            elsif ($design =~ /^small_/) { push(@small, $design); }
            else                         { push(@other, $design); }
        }
        @list = (@other, @small, @tiny);


        my $source_dir = `cat ../designs/$k/__SOURCEDIR__`;  # E.g. "/home/steveri/designs/mydesign\n"
        chomp $source_dir;                                   # Off with its...tail...!
#      #print embed_alert_script("source dir for $k is $source_dir");

        if ($DBG9) { print STDERR "Current key is \"$k\""; }

        # Trying something new: "DEFAULT"
        my $design = "empty.xml";
        my $deletable = (-e "$source_dir/$design") ? 0 : 1;
        print "\n";
        print "    <div  style='position:relative; padding:0px 20px'>\n";
        print "      <button type=button id=button$id onclick='visit_it(\"../designs/$k/empty.xml\")'>\n";
        print "        <rm><b>GENERATE DEFAULT DESIGN</b></rm>\n";
        print "      </button>\n";
        print "    </div>\n";
        print "\n";
        $id++;

	foreach my $design (@list) {
	    my $fullpath = "../designs/$k/$design";

            ########################################################################
            # BUG/TODOT
            # Okay I don't know shat this was supposed to be for.  Debugging I guess.
            # Note that it will give errors if a design file $design= foo.xml exists in
            # e.g. genesis/designs/tgt0 but not in genesis/examples/tgt0,
            if (0) {
                my $ls = "ls -l $source_dir/$design";    if ($DBG9) { print embed_alert_script($ls); }
                my $ls_out = `$ls`;                      if ($DBG9) { print embed_alert_script($ls_out); }
            }
            ########################################################################

            my $deletable = (-e "$source_dir/$design") ? 0 : 1;

	    # Skip "old", "save" directories.
	    if ($fullpath =~ /designs.old/) { next; }
	    if ($fullpath =~ /designs.save/) { next; }

            print "\n";
	    print "    <div  style='position:relative; padding:0px 20px'>\n";
            print "      <button type=button id=button$id onclick='togglepopup($id)'>\n";
            print "        <tt>$design</tt>\n";
            print "      </button>\n";
            print "      <br>\n";
            print_buttons("      ",$id,$k,$fullpath,$deletable);
	    print "    </div>\n";
            print "\n";
            $id++;
	}
        print "  </td></tr>\n\n";
    }
}

sub print_buttons {
    my $indent    = shift @_;
    my $id        = shift @_;
    my $chipgen   = shift @_;
    my $fullpath  = shift @_;
    my $deletable = shift @_;

#    if ($deletable) { print embed_alert_script("$fullpath is deletable"); }
#    else            { print embed_alert_script("$fullpath is not deletable"); }

    print $indent."<table class=popuptable id=table$id>\n";
    print $indent."  <tr><td onclick='visit_it(\"$fullpath\")' ".
        "class=popupbutton>$PBUTTON Visit this design</td></tr>\n";

    if ($deletable) {
        print $indent."  <tr><td onclick='delete_it(\"$chipgen\",\"$fullpath\")' ".
            "class=popupbutton>$MBUTTON Delete this design</td></tr>\n";
    }

    print $indent."  <tr><td onclick=\"killtable('table$id')\" ".
        "class=popupbutton style=color:red><center><b>Cancel</b></center></td></tr>\n";
    print $indent."</table>\n";
}

############################################################################
# NOTES: Web resources for CGI scripts:  Google "cgi script example"
#   http://www.perlfect.com/articles/url_decoding.shtml
#   http://www.it.bton.ac.uk/~mas/mas/courses/html/html3.html
#   http://www.jmarshall.com/easy/cgi/
#   http://www.comptechdoc.org/independent/web/cgi/cgimanual/cgiexample.html
############################################################################

sub mydir {
    use Cwd 'abs_path';
    my $fullpath = abs_path($0); # Full pathname of script e.g. "/foo/bar/opendesign.pl"

    use File::Basename 'fileparse';
    my ($filename, $dir, $suffix) = fileparse($fullpath);
    return $dir;
}
