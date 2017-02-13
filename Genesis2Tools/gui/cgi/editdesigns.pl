#!/usr/bin/perl
use strict;

my $DBG9=0;

#print "Content-type: text/html\n\n";
print "Content-type: text/html; charset=utf-8\n\n";
print
    '<!DOCTYPE HTML PUBLIC '.
    '"-//W3C//DTD HTML 4.01 Transitional//EN" '.
    '"http://www.w3.org/TR/html4/loose.dtd">'.
    "\n";

print "<head>\n";
print_title();

# "utils.pl" includes get_system_dependences(), get_input_parms()
my $do_result  = do './utils.pl';     

if ($DBG9) { print embed_alert_script("hello hello testing the communication system..."); }

my $DLfile = get_design_list_filename();

#            add_design("dnam","ddir"); exit;

process_parms(); # Here's where we add/delete/change things if necessary

my $DBG=0; if ($ENV{QUERY_STRING} =~ /DEBUG=true/) { $DBG = 1; }

if ($DBG9) { print embed_alert_script("DEBUG=$DBG"); }
if ($DBG9) { $DBG = 1; }

print_javascript_block(); print "\n";
print_style_block(); print "\n";
print "<\/head>\n";

my $go_back = "<p><a href=choosedesign.pl><b>Click here to return to 'choose your design'.</b></a>\n\n";

print add_new_design();       print $go_back;
print_edit_existing_design(); print $go_back;
print_recycle_bin();          print $go_back;

print 
    '<!-- HTML compliance -->'                            ."\n".
    '<p>'                                                 ."\n".
    '<a href="http://validator.w3.org/check?uri=referer">'."\n".
    '    <img src="http://www.w3.org/Icons/valid-html401"'."\n".
    '         alt="Valid HTML 4.01 Transitional">'        ."\n".
    '    <!-- height="31" width="88" -->'                 ."\n".
    '</a>'                                                ."\n";

print "\n</body></html>\n";

exit;

#########################################################################
sub print_javascript_block {
    my @script =
        (
         '<script type="text/javascript"><!--',

         '  function deletedesign(f,s) {',

#        "    alert(f);",
#        "    alert('delete design '+document.forms[f]['dnam'].value);",

         '    var dnam = document.forms[f]["dnam"].value;',
         '    var reallydo = confirm("Really delete design \"" + dnam + "\"?");',
         '    if (! reallydo) {',
         '        alert("Delete canceled.");',
         '        return;',
         '    }',

         "    document.forms[f]['ddir'].value = s;",  # s = "DELETE_ME" or "FOREVER_DELETE"
         "    document.forms[f].submit();",  # s = "DELETE_ME" or "FOREVER_DELETE"
         '  }',

         '//--></script>',
         '',
         );
    print join("\n",@script);
}

sub print_style_block {
    my @style_block =
        (
         '<style type="text/css">',
         '  table.designtable { ',
         '      border: solid white; border-width:0px 0px 0px 80px;',
         '      background-color:#e7d19a',
         '  }',
         '  table.designtable th { text-align:left }',
         '',
         '  .name_in { width:140px; }',
         '  .loc_in  { width:400px; }',
         '  .name_in_hdr { width:140px; font-size:large; color:black; background-color:#e7d19a; border-width:1px; border: solid #e7d19a }',
         '  .loc_in_hdr  { width:400px; font-size:large; color:black; background-color:#e7d19a; border-width:1px; border: solid #e7d19a }',
         '',
         '  .submitbutton { padding-left:80px; width:140px; }',
         '',
         '  /* input buttons inside table cells */',
         '  td input { font-family:courier-new; }',
         '',
         '  button {width:100%; text-align:left}',
         '</style>',
         ''
         );
    print join("\n",@style_block);
}

sub print_title {
    print
        ''                                                                    ."\n".
        '  <title>Genesis Design Database</title>'                            ."\n".
        '  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">'."\n\n";
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
      '  <input type=hidden name=cmd value=add>',
      "</form>",
      "",
      "",
    );
    return join("\n", @text);
}

sub print_edit_existing_design {

    print "<h2>Edit existing design directories</h2>\n\n";
    print_designtable_header();

    my @design_list = get_design_list();

    # Based on what we find in the design list, make
    # a list of designs and their source directories.

    my $FORMNUM = 0;  # Should this be in a BEGIN block??
    foreach my $line (@design_list) {            # E.g. "demo /home/steveri/genesis_designs/demo"
        if ($line =~ /^\s*([^\#]\S+)\s+(\S+)/) {
            print_designdir_data($1, $2);
        }
    }
    return;
    
    sub print_designdir_data {
        my $dnam = shift @_;
        my $ddir = shift @_;

        my $fname = "form".$FORMNUM++; # "form0", "form1", "form2", ...
        $fname = "\"$fname\""; # Put it in double quotes, why not.
            
        #print "$line<br />\n";
        #print "-$1-$2<br />\n";
            
        #$designs{$1} = $2; # E.g. $designs{"demo"} = "/home/steveri/genesis_designs/demo" 

        print
            "<form method='get' action='editdesigns.pl' name=$fname>\n".
            "  <table class=designtable>\n".
            "    <tr>\n".
            "      <td><input type=text name=dnam class=name_in value='$dnam' readonly=readonly></td>\n".
            "      <td><input type=text name=ddir class=loc_in  value='$ddir'></td>\n".
            "      <td><input type=button value='Delete' onclick='deletedesign($fname,\"DELETE_ME\")'></td>\n".
            "      <td><input type=submit value='Submit changes'></td>\n".
            "      <td><input type=hidden name=cmd value='change'></td>\n".
            "    </tr>\n".
            "  </table>\n".
            "</form>\n".
            "";
    }
}

sub print_designtable_header {
    print
        "<table class=designtable>".
        "  <tr>".
        "    <td><input type=text disabled=disabled class=name_in_hdr value='Design name' ></td>\n".
        "    <td><input type=text disabled=disabled class=loc_in_hdr  value='Design location'></td>\n".
        "    <td><input type=button value='Delete' style='visibility:hidden'></td>\n".
        "    <td><input type=submit value='Submit changes' style='visibility:hidden'></td>\n".
        "</tr>\n".
        "</table>\n".
        "";
}
sub print_recycle_bin {
#    my @header = 
#        (
#         "<h2>Recycle bin</h2>",
#         "<table class=designtable>",
#         "  <tr><th>Design name</th><th>Design location</th></tr>",
#         );
#
#    print join("\n", @header);

    print "<h2>Recycle bin</h2>\n\n";
    print_designtable_header();

    my @design_list = get_design_list();

    my $FORMNUM = 1000;
    foreach my $line (@design_list) {            # E.g. "demo /home/steveri/genesis_designs/demo"
        if ($line =~ /^(\#[^\#]\S+)\s+(\/\S+)\s*[\#]*/) {
            print_recyclebin_data($1, $2);
        }
    }
#    print "</table>\n\n";
    return;
    
    sub print_recyclebin_data {
        my $dnam = shift @_;
        my $ddir = shift @_;

        my $fname = "form".$FORMNUM++; # "form1000", "form1001", "form1002", ...
        $fname = "\"$fname\""; # Put it in double quotes, why not.
            
        #print "$line<br />\n";
        #print "-$1-$2<br />\n";
            
        # $designs{$1} = $2; # E.g. $designs{"demo"} = "/home/steveri/genesis_designs/demo" 
            
#        print "  <tr>\n";
#        print "  <tr><form method='get' action='editdesigns.pl' name=$fname>\n";
#        print "    <td><input name=dnam type=text class=name_in value='$dnam' readonly=readonly></td>\n";
#        print "    <td><input name=ddir type=text class=loc_in  value='$ddir' readonly=readonly></td>\n";
#        print "    <td><input type=button value='Permanent Delete' onclick=deletedesign($fname,'FOREVER_DELETE')></td>\n";
#        print "    <td><input type=hidden name=cmd value=change></td>\n";
#        print "  </form></tr>\n";
#        print "  </tr>\n";

        print
            "<form method='get' action='editdesigns.pl' name=$fname>\n".
            "  <table class=designtable>\n".
            "    <tr>\n".
            "      <td><input type=text name=dnam class=name_in value='$dnam' readonly=readonly></td>\n".
            "      <td><input type=text name=ddir class=loc_in  value='$ddir' readonly=readonly></td>\n".
            "      <td><input type=button value='Delete' onclick='deletedesign($fname,\"FOREVER_DELETE\")'></td>\n".
            "      <td><input type=submit value='Submit changes'></td>\n".
            "      <td><input type=hidden name=cmd value='change'></td>\n".
            "    </tr>\n".
            "  </table>\n".
            "</form>\n".
            "";


    }
}


###################################################################################################
# Should this be in utils??
sub get_design_list {

    # Return contents of design list; assumes
    # design-list filename in global "$DLfile"
    my $DL = $DLfile;

    open(DL,"<$DLfile") or print embed_alert_script($!);
    my @DL_contents = <DL>;
    close DL;
    return @DL_contents;
}


###################################################################################################
# Should this be in utils??
sub get_design_list_filename {

    # E.g. "DESIGN_LIST     ~steveri/gui/configs/design_list_stanford.txt"

    use File::Glob ':glob';  # To turn e.g. "~steveri" into "/home/steveri"

    open CONFIG, "<../CONFIG.TXT" or print_help_and_die(); # Maybe in wrong directory?
    foreach my $line (<CONFIG>) {
        if ($line =~ /^DESIGN_LIST\s+(\S+)/) {
            my $DL = bsd_glob($1, GLOB_TILDE | GLOB_ERR); # Turns e.g. "~steveri" into "/home/steveri"

            if (($DL eq "") || (! -e $DL)) {
                print embed_alert_script("Could not find design file \"$1\";\n".
                                         "aka \"$DL\";\n".
                                         "will try to create a new empty one;\n".
                                         "hope that's okay!"
                                         );
                $DL = $1;
                open(DL,">$DL") or print embed_alert_script($!);
                close DL;
            }
            #if (1) { print "Found design list \"$DL\"<br /><br />"; }
            if ($DBG9) { print embed_alert_script("Found design list \"$DL\""); }
            close CONFIG;
            return $DL;
        }
    }
}

# TODO see ~/gui/designs.aux/updatedesigndirs.pl
# Here's where we add and delete and change things if necessary
sub process_parms() {

    my $parms = $ENV{QUERY_STRING};

####print embed_alert_script($parms);

    # Parms may include e.g.:
    #   ddir="/home/steveri/my_chipgen"
    #   dnam="steveri_chipgen"
    #   cmd="change" or "add"

    my %INPUT = get_input_parms($parms);                    # from "do 'utils.pl'

    #my $parmlist;
    #foreach my $parm (sort keys(%INPUT)) {
    #    $parmlist = $parmlist."\nfound parm \"$parm\" = \"$INPUT{$parm}\"";
    #}
    #print embed_alert_script($parmlist);

    my $cmd = $INPUT{"cmd"};

    if ($DBG9) { print embed_alert_script("cmd= ".$cmd); }

    if ($cmd) {
        if (! -w $DLfile) {
            print embed_alert_script(
               "OOPS looks like design-list file\n    \"$DLfile\"\nnot writable.\n".
                "I'm guessing you're running the dev version of the gui from a ".
                "perforce-controlled directory.\nIf you want this to work, ".
                "you'll have to tweak the permissions and try again.".
                "");
            print embed_alert_script(
                "Try this:\n".
                "    % cd gui/configs\n".
                "    % chgrp www-data design_list_stanford.txt\n".
                "    % chmod g+w design_list_stanford.txt\n".
                "\n".
                "And for good measure, maybe fix the directory too:\n".
                "    % cd gui/configs; chgrp www-data .; chmod g+w .".
                "");
            die "Permission problems in editdesigns.pl";
        }

        # If cmd is nonzero, that means we have to add or change something before proceeding.
        my ($dnam,$ddir) = ($INPUT{"dnam"}, $INPUT{"ddir"});
        if ($cmd eq "add") { 
            add_design($dnam,$ddir);
        }
        elsif ($cmd eq "change") {
            change_design($dnam,$ddir);
        }
        else {
            print embed_alert_script("Oops unknown command");
        }
    }
}

sub change_design {
    my $dnam = shift @_;
    my $ddir = shift @_;

#    print embed_alert_script("Gotta change $dnam to point to $ddir");

    make_backup_file($DLfile);

    # Find design $dnam in design file and change it.
    my @dlist = get_design_list();


    for (my $i=0; $i <= $#dlist; $i++) {
        my $line = $dlist[$i];

        if ($ddir eq "FOREVER_DELETE") {
            if ($line =~ /^([\#]\S+)\s+(\S+)/) {
                if ("$1" eq "$dnam") {         # Triple protection!

                    # This effectively deletes the (already-deleted)
                    # design from the recyle bin()...right?

                    $dlist[$i] = "#".$dlist[$i]; # GASP!  Double pound sign!!

                    # Silly boy...nothing's ever gone for good.

                    next; 
                }
            }
        }

        elsif ($line =~ /^\s*([^\#]\S+)\s+(\S+)/) {
            if ("$1" eq "$dnam") {
                $dlist[$i] = "#".$dlist[$i]; # Comment out existing design $dnam
                if ($ddir ne "DELETE_ME") {   # Add new design entry for $dnam
                    $dlist[$i] .= sprintf("%-30s %s\n", $dnam, $ddir);
                }
            }
        }
    }
    open(DL, ">$DLfile") || check_dl_permissions($DLfile);

    for (my $i=0; $i <= $#dlist; $i++) {
        print DL $dlist[$i];
    }
    close DL;
}

sub check_dl_permissions {
    my $DLfile = shift @_;
    print embed_alert_script("Problem opening design list\n\n$DLfile\n\n...check permissions maybe?");
    die("Cannot open $DLfile for writing");
}
sub add_design {
    my $dnam = shift @_;
    my $ddir = shift @_;

    if ($DBG9) { print embed_alert_script("adding \"$dnam\" to  dir \"$ddir\""); }

#    print embed_alert_script("Gotta add design $dnam => $ddir");

    # Check to make sure that design $dnam does not already exist in design file.
    my @dlist = get_design_list();
    foreach my $line (@dlist) {            # E.g. "demo /home/steveri/genesis_designs/demo"
        if ($line =~ /^\s*([^\#]\S+)\s+(\S+)/) {
            if ("$1" eq "$dnam") {
                print embed_alert_script("First delete existing design $dnam = \"$2\"");
                return;
            }
        }
    }
    make_backup_file($DLfile);

    my $newdesign = sprintf("%-30s %s\n", $dnam, $ddir);
    if ($DBG9) { print embed_alert_script("Ready with new design \"$newdesign\""); }

    open(DL,">>$DLfile") or print embed_alert_script($!);
    print DL $newdesign;
    if ($DBG9) { print embed_alert_script("Wrote newdesign file $DLfile"); }
    close DL;
}

# Make a copy of the indicated file, in case something bad happens.
# E.g. if $f = "/home/steveri/mydoc", copy it to "/home/steveri/mydoc.backup<i>"
# Where ($i) is the first integer such that backup file doesn't already exist.
sub make_backup_file {
    my $f = shift @_;

    use File::Copy;

#    print embed_alert_script("Okay first backup design file $DLfile");
#    print embed_alert_script("Making a backup copy of $f");

# Tries to copy e.g. "/home/steveri/gui/configs/design_list.txt"
# to "/home/steveri/gui/configs/design_list.txt.0"
#
# Now how's that gonna work?  Permission problems!!


    #my $backup = "/var/www/homepage/genesis/configs/design_list.backup.";
    # Wow!  What was I thinking!??
    my $backup = "$f.";
    my $i = 0;
    while (-e "$backup$i") { $i++; }

    if ($DBG9) { print embed_alert_script("Backup: copy \"$f\" to \"$backup$i\""); }

    my $copy_failed = 0; copy($f, "$backup$i") or $copy_failed = 1;

    if ($copy_failed) {
        print embed_alert_script("ERROR: Cannot copy \"$f\" to \"$backup$i\"");
        die "File cannot be copied.";
    }

#    print embed_alert_script("ls returned: $ls".`ls -l $backup$i`);
}







































