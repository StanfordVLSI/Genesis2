#!/usr/bin/perl
use strict;

print "Content-type: text/html\n\n";

# "utils.pl" includes get_system_dependences(), get_input_parms()
my $do_result  = do './utils.pl';     

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
    close DL;

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
        print "    <td><input type=text class=name_in name=dnam value=$dnam></td>\n";
        print "    <td><input type=text class=loc_in  name=ddir\n";
        print "         value=$ddir></td>\n";
        print "    <td><input type=button value=Delete onclick=deletedesign($fname)></td>\n";
        print "    <td><input type=submit value=Submit changes></td>\n";
        print "    <input type=hidden name=cmd value=change />\n";
        print "  </form></tr>\n";
    }
}


sub print_recycle_bin {
    my @text = 
        (
         "<h2>Recycle bin</h2>",
         );

    print join("\n", @text);
}


###################################################################################################
# Should this be in utils??
sub get_design_list {

    # E.g. "DESIGN_LIST     ~steveri/gui/configs/design_list_stanford.txt"

    use File::Glob ':glob';  # To turn e.g. "~steveri" into "/home/steveri"

    open CONFIG, "<../CONFIG.TXT" or print_help_and_die(); # Maybe in wrong directory?
    foreach my $line (<CONFIG>) {
        if ($line =~ /^DESIGN_LIST\s+(\S+)/) {
            my $DL = bsd_glob($1, GLOB_TILDE | GLOB_ERR); # Turns e.g. "~steveri" into "/home/steveri"
            close CONFIG;

            # Return contents of design list.
            #if (1) { print "Found design list \"$DL\"<br /><br />"; }
            open DL, "<$DL" or die "Could not find design list \"$DL\"";
            my @DL_contents = <DL>;
            close DL;
            return @DL_contents
        }
    }
    #my $homedir = bsd_glob('~steveri', GLOB_TILDE | GLOB_ERR);
    #print "$homedir\n\n";
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
            print embed_alert_script("Gotta change $dnam to point to $ddir");
        }
        else {
            print embed_alert_script("Oops unknown command");
        }
    }
}
