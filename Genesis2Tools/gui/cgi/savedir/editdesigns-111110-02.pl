#!/usr/bin/perl
use strict;

print "Content-type: text/html\n\n";

# "utils.pl" includes get_system_dependences(), get_input_parms()
my $do_result  = do './utils.pl';     

my $DLfile = get_design_list_filename();

#            add_design("dnam","ddir");
#exit;

process_parms(); # Here's where we add/delete/change things if necessary

my $DBG=0; if ($ENV{QUERY_STRING} =~ /DEBUG=true/) { $DBG = 1; }
#print embed_alert_script("DEBUG=$DBG");

print_javascript_block(); print "\n";
print_style_block(); print "\n";

print_title();
print add_new_design();
print_edit_existing_design();
print_recycle_bin();
return;

#########################################################################
sub print_javascript_block {
    my @script =
        (
         '<script type="text/javascript"><!--',
         '  function deletedesign(f) {',
#        "    alert(f);",
#        "    alert('delete design '+document.forms[f]['dnam'].value);",
         "    document.forms[f]['ddir'].value = 'DELETE_ME';",
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
         '  table.designtable input.name_in { width:140px; }',
         '  table.designtable input.loc_in  { width:400px; }',
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
      "",
      "",
    );
    return join("\n", @text);
}

sub print_edit_existing_design {
    my @header = 
        (
         "<h2>Edit existing design directories</h2>",
         "<table class=designtable>",
         "  <tr><th>Design name</th><th>Design location</th></tr>",
         );
    print join("\n", @header);

    my @design_list = get_design_list();

    # Based on what we find in the design list, make
    # a list of designs and their source directories.

    foreach my $line (@design_list) {            # E.g. "demo /home/steveri/genesis_designs/demo"
        if ($line =~ /^\s*([^\#]\S+)\s+(\S+)/) {
            print_designdir_data($1, $2);
        }
    }

    print "</table>\n\n";
    return;
    
    my $FORMNUM = 0;  # Should this be in a BEGIN block??
    sub print_designdir_data {
        my $dnam = shift @_;
        my $ddir = shift @_;

        my $fname = "form".$FORMNUM++; # "form0", "form1", "form2", ...
        $fname = "\"$fname\""; # Put it in double quotes, why not.
            
        #print "$line<br />\n";
        #print "-$1-$2<br />\n";
            
        #$designs{$1} = $2; # E.g. $designs{"demo"} = "/home/steveri/genesis_designs/demo" 
            
        print "  <tr><form method='get' action='editdesigns.pl' name=$fname>\n";
        print "    <td><input name=dnam type=text class=name_in value=$dnam readonly=readonly></td>\n";
        print "    <td><input name=ddir type=text class=loc_in  value=$ddir></td>\n";
        print "    <td><input type=button value=Delete onclick=deletedesign($fname)></td>\n";
        print "    <td><input type=submit value=Submit changes></td>\n";
        print "    <input type=hidden name=cmd value=change />\n";
        print "  </form></tr>\n";
    }
}


sub print_recycle_bin {
    my @header = 
        (
         "<h2>Recycle bin</h2>",
         "<table class=designtable>",
         "  <tr><th>Design name</th><th>Design location</th></tr>",
         );

    print join("\n", @header);

    my @design_list = get_design_list();

    foreach my $line (@design_list) {            # E.g. "demo /home/steveri/genesis_designs/demo"
        if ($line =~ /^(\#\S+)\s+(\S+)/) {
            print_recyclebin_data($1, $2);
        }
    }

    print "</table>\n\n";
    return;
    
#    my $FORMNUM = 0;  # Should this be in a BEGIN block??
    sub print_recyclebin_data {
        my $dnam = shift @_;
        my $ddir = shift @_;

#        my $fname = "form".$FORMNUM++; # "form0", "form1", "form2", ...
#        $fname = "\"$fname\""; # Put it in double quotes, why not.
            
        #print "$line<br />\n";
        #print "-$1-$2<br />\n";
            
        #$designs{$1} = $2; # E.g. $designs{"demo"} = "/home/steveri/genesis_designs/demo" 
            
        print "  <tr>\n";
#        print "  <tr><form method='get' action='editdesigns.pl' name=$fname>\n";
        print "    <td><input name=dnam type=text class=name_in value=$dnam readonly=readonly></td>\n";
        print "    <td><input name=ddir type=text class=loc_in  value=$ddir readonly=readonly></td>\n";
#        print "    <td><input type=button value=Delete onclick=deletedesign($fname)></td>\n";
#        print "    <td><input type=submit value=Submit changes></td>\n";
#        print "    <input type=hidden name=cmd value=change />\n";
#        print "  </form></tr>\n";
        print "  </tr>\n";
    }

}


###################################################################################################
# Should this be in utils??
sub get_design_list {

    # Return contents of design list; assumes
    # design-list filename in global "$DLfile"
    my $DL = $DLfile;

    open DL, "<$DL" or die "Could not find design list \"$DL\"";
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
            #if (1) { print "Found design list \"$DL\"<br /><br />"; }
            close CONFIG;
            return $DL;
        }
    }
}

# TODO see ~/gui/designs.aux/updatedesigndirs.pl
# Here's where we add and delete and change things if necessary
sub process_parms() {
    my $parms = $ENV{QUERY_STRING};
    #print embed_alert_script($parms);

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
    if ($cmd) {
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
        if ($line =~ /^\s*([^\#]\S+)\s+(\S+)/) {
            if ("$1" eq "$dnam") {
                $dlist[$i] = "#".$dlist[$i]; # Comment out existing design $dnam
                if ($ddir ne "DELETE_ME") {   # Add new design entry for $dnam
                    $dlist[$i] .= sprintf("%-30s %s\n", $dnam, $ddir);
                }
            }
        }
    }
    open(DL, ">$DLfile") || die("Cannot open $DLfile for writing");
    for (my $i=0; $i <= $#dlist; $i++) {
        print DL $dlist[$i];
    }
    close DL;
}

sub add_design {
    my $dnam = shift @_;
    my $ddir = shift @_;

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
#    print embed_alert_script("Ready with new design \"$newdesign\"");

    open(DL,">>$DLfile") || die("Cannot Open File");
    print DL $newdesign;
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

    my $backup = "/var/www/homepage/genesis/configs/design_list.backup.";
    my $i = 0;
    while (-e "$backup$i") { $i++; }

    copy($f, "$backup$i") or die "File cannot be copied.";

#    print embed_alert_script("ls returned: $ls".`ls -l $backup$i`);
}
