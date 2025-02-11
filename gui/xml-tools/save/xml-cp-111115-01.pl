#!/usr/bin/env perl
use strict;
use XML::Simple qw(:strict);                      # use XML::Simple;

my $DBG = 0;
#$DBG=1;
my $DBG9  = 0; # DBG9 = xtreme debug

#print $ARGV[0];#print "\n";#exit;

# Icky(?) globals
my (
    $copyfrom_str,
    $copyfrom_ptr,

    $copyto_str,
    $copyto_array,
    $copyto_ix
    );

$copyfrom_str = $ARGV[1];
$copyto_str   = $ARGV[2];


# E.g. "xml_cp.pl samples/regression.xml top.DUT.drh0 top.DUT.drh1"
xml_cp($ARGV[0],$ARGV[1],$ARGV[2]);
exit(0);

sub xml_cp {

    #########################################################################################
    # xml2js($xml_in): Given the name of an existing xml file "$xml_in", list
    # "InstanceName" "BaseModuleName" "UniqueModuleName" "CloneOf"
    # and write it to STDOUT.
    ##########################################################################################

    # Subroutine parms and globals

    my $xml_in    = shift(@_);   # E.g. "samples/regression.xml"

#    my $copy_from_str = shift(@_);   # E.g. "top.DUT.drh0"
#    my $copy_to_str   = shift(@_);   # E.g. "top.DUT.drh1" (must already exist!)

    # See /cad/genesis2/r9519/PerlLibs/Genesis2/Manager.pm for XMLin,XMLout prototypes.

    my $xmldata = XMLin($xml_in, 
                        KeepRoot => 1, # Don't throw away "HierarchyTop"
                        NoAttr => 1,
                        KeyAttr => [],
                        ForceArray => ['ArrayItem', 'HashItem', 'ParameterItem', 'SubInstanceItem']
                        );

    #######################################################################################
    # Coupla error checks

    my $msg = "Root element of the xml_in file \"$xml_in\" must be <HierarchyTop>!";
    if (! defined $xmldata->{HierarchyTop}) { die $msg; }

    my $msg = "Only single root element allowed for the xml_in_file (must be HierarchyTop)";
    if (keys %{$xmldata} > 1) { die $msg; }

    #######################################################################################
    # Use "devtest" to visually verify functionality using "updatedesign.pl -test"
    my $devtest=0; if ($devtest) { devtest($xmldata); }

#    print_header();

    process_instance($xmldata->{HierarchyTop}, "top");

    if (! $copyfrom_ptr) {
        die "ERROR Could not find copyfrom instance $copyfrom_str\n";
    }
    elsif (! $copyto_array) {
        die "ERROR Could not find copyto instance $copyto_str\n";
    }

    debug( "" );
    debug( "found copyfrom instance ".$copyfrom_ptr->{InstanceName} );
    debug( "found copyto instance ".@{$copyto_array}[$copyto_ix]->{InstanceName} );
    debug( "" );

#    print "First, delete copyto instance ".$copyto_ptr->{InstanceName}."\n";
    debug("DEEP COPY from one to the other");
    
#    my $deepcopy = deep_copy($copyfrom_ptr);
    my $deepcopy = deep_copy_and_update_instancepaths($copyfrom_ptr);

    @{$copyto_array}[$copyto_ix] = $deepcopy;

    # Don't forget to update the instance name!!!
    $copyto_str =~ /[.]([^.]+)$/;
    my $in = $1;
    debug("copyto instance name should be $in\n");
    @{$copyto_array}[$copyto_ix]->{InstanceName} = $in;


    # Now time to change pathnames etc.

#    find_and_replace($deepcopy); # 
#

    #######################################################################################
    # Print the changes to the change file.
    print
    XMLout($xmldata,
	   NoAttr => 1, 
	   KeyAttr => [],
#	   RootName => 'HierarchyTop',   # Add root "HierarchyTop"
           KeepRoot => 1,                # Don't throw away "HierarchyTop"
#	   OutputFile => $new_fname
#	   OutputFile => "tmpfoo"
           );
}



sub process_instance {
    my $instance = shift @_; # E.g. $xmldata->{HierarchyTop}
    my $path     = shift @_; # E.g. "top.DUT"

    if ($copyfrom_ptr && $copyto_array) { return; }

#    print "checking $path against $copyfrom_str\n";

#    if ($path eq $copyfrom_str) {
#        print "\nfound copyfrom instance ".$instance->{InstanceName}."\n";
#        $copyfrom_ptr = $instance;
#        return;
#    }
#    elsif ($path eq $copyto_str) {
#        $copyto_ptr = $instance;
#        return;
#    }

##    my $InstanceName     = $instance->{InstanceName};
#    my $BaseModuleName   = $instance->{BaseModuleName};
#    my $UniqueModuleName = $instance->{UniqueModuleName};
#    my $CloneOf          = $instance->{CloneOf};
#
#    if ($CloneOf) {
#        $CloneOf = $instance->{CloneOf}->{InstancePath};
#    }
#    else {
#        $CloneOf = "";
#    }        
#
#    printf($lsformat,
#           $path,
##           $InstanceName,
#           $BaseModuleName,
#           $UniqueModuleName,
#           $CloneOf);

    my $subinstances = $instance->{SubInstances}->{SubInstanceItem};
    if ($subinstances) {
        my $ix = 0;
        foreach my $si (@{$subinstances}) {
            my $in = $si->{InstanceName};
            my $si_path = "$path.$in";

#            print "checking $si_path against $copyfrom_str and $copyto_str\n";

            if ($si_path eq $copyfrom_str) {
                debug("1. found copyfrom instance ".$si->{InstanceName} );
                $copyfrom_ptr = $si;
            }
            elsif ($si_path eq $copyto_str) {
                debug("2. found copyto instance ".$si->{InstanceName} );
                $copyto_array = $subinstances;
                $copyto_ix    = $ix;
                debug("3. found copyto instance ".@{$copyto_array}[$copyto_ix]->{InstanceName});
            }
            else {
                process_instance($si, "$path.$in");
            }
            if ($copyfrom_ptr && $copyto_array) { return; }
            $ix++;
        }
    }

}

## E.g. print_value("cgtop.", $xml->{"HierarchyTop"}, "UniqueModuleName") =>
## cgtop.UniqueModuleName = "modname";
#sub print_value {
#    my $path     = shift @_;
#    my $instance = shift @_;
#    my $tag      = shift @_;
#
##    $tag = default_hack($tag);  # Ugh.
#
#    print "$path$tag = \"$instance->{$tag}\";\n";
#}
#
#sub create_object {
#    my $obname = shift @_;
#
#    # BUG/TODO whatta hack!  "default" is a keyword for some javascript implementations;
#    # therefore e.g. "cgtop.Parameters.REG.default" => "cgtop.Parameters.REG.defaultHACK" =>
#
#    if ($obname =~ /default$/) { $obname .= "HACK"; }
#    print "$obname = new Object();\n";                 # Extends existing data structure "cgtop"
#}
#
#sub set_value {
#    my $obname = shift @_;
#    my $val    = shift @_;
#
#    # BUG/TODO whatta hack!  "default" is a keyword for some javascript implementations;
#    # therefore e.g. "cgtop.Parameters.REG.default" => "cgtop.Parameters.REG.defaultHACK" =>
#
#    if ($obname =~ /default$/) { $obname .= "HACK"; }
#
#    if (ref($val) eq "HASH") { $val = ""; }  # E.g. "<Val></Val>" results in HASH value for "Val"
#
#    print "$obname = \"$val\";\n";                 # Extends existing data structure "cgtop"
#}
#
#sub process_parameters {
#    my $parms = shift @_;  # E.g. array $xmldata->{HierarchyTop}->{Parameters}->{ParameterItem}
#    my $path = shift @_;  # E.g. "cgtop.SubInstances.wallace_3
#    
#    if ($DBG) { print "# processing parms using path $path\n#\n"; }
#
#    foreach my $obj ("Parameters","Comments","Range") {
#        print "$path$obj = new Object();\n";
#    }
#
#    foreach my $parm (@{$parms}) {
#        my $n = $parm->{Name};
##        $n = default_hack($n); # Ugh.
#
#        my $c = $parm->{Doc};
#
#        if (! $c) { $c = "no comment"; }
#        
#        # <Doc></Doc> results in $c of type "HASH" !??
#        elsif (ref($c) eq "HASH") { $c = "no comment"; }
#
#        #print $path."Comments.$n = \"$c\";\n";
#        set_value($path."Comments.$n", $c);
#
#        # ParameterItem can be a array ("ArrayType"), hash ("HashType"), or simple
#
#        if ($parm->{ArrayType}) {
#
##            print "\nI guess it's an array\n\n";
#            # if (! $ai) { print "    oops no array items\n"; } else {
##            print $path."Parameters.$n = new Object();\n";
#
#            my $ai = $parm->{ArrayType}->{ArrayItem};
#            process_array_items($ai, $path."Parameters.$n");
#
#        }
#        elsif ($parm->{HashType}) {
#            debug("#\n#I guess it's a hashy\n#\n");
#
#            my $hi = $parm->{HashType}->{HashItem};
#            process_hash_items($hi, $path."Parameters.$n");
#
#        }
#        elsif ($parm->{InstancePath}) {
#            debug("#\n#oh no they is a instancepath for the parameter\n#\n");
#            #print $path."Parameters.$n = new Object();\n";
#            create_object($path."Parameters.$n");
#            #print $path."Parameters.$n.InstancePath = \"$parm->{InstancePath}\";\n";
#            set_value($path."Parameters.$n.InstancePath", $parm->{InstancePath});
#        }
#
#        else {
#            debug("#\n#I guess it's simple\n#\n");
#
#            #print $path."Parameters.$n = \"$parm->{Val}\";\n";
#            set_value($path."Parameters.$n", $parm->{Val});
#
#            if ($parm->{Range}) {
#                debug("#oh it has a range.\n");
#                process_ranges($parm->{Range}, $path."Range.$n");
#            }
#        }
#
#    }
#}
#
##          <Range>
##            <List>1</List>
##            <List>2</List>
##            <List>3</List>
##            <List>4</List>
##...
##            <List>16</List>
##            <List>32</List>
##            <List>64</List>
##          </Range>
##
## => cgtop.SubInstances.wallace_3.ImmutableRange.N = "1 2 3 4 5 6 7 8 9 16 32 64";
#
#
##          <Range>
##            <Max>410</Max>
##            <Step>2</Step>
##          </Range>
##
## => cgtop.SubInstances.wallace_3.Range.ParMaxStep = ",410,2";
#
#sub process_ranges {
#    my $ranges = shift @_;
#    my $path   = shift @_;
#
#    debug("#oh it has a range. is it lists?  mn/max/step???\n");
#
#    if ($ranges->{List}) {
#        #print "oh looks like a list maybe\n";
#        my @list;
#        foreach my $i (@{$ranges->{List}}) {
#            #print " i see $i\n";
#
#            if (ref($i) ne "HASH") { # It happened!!!
#                push( @list, $i);
#            }
#        }
#        my $liststring = join(" ", @list);
#        print "$path = \"$liststring\";\n";
#    }
#    else {
#        #print "oh no maybe it's a min/max/step\n";
#
#        my $min = $ranges->{Min};
#        my $max = $ranges->{Max};
#        my $step = $ranges->{Step};
#
#        my $rangestring = "$min,$max,$step";
#        if ($rangestring eq ",,") { return; } # For historical reasons.
#        #print "$path = \"$rangestring\";\n";
#        set_value($path, $rangestring);
#    }
#}
#
#sub process_array_items {
#    my $array_items = shift @_;
#    my $path        = shift @_;
#
#    print "$path = new Object();\n"; # $i++;
#
#    my $i = 0; # Array starts w/index "0"
#    foreach my $ai (@{$array_items}) {
#
#        if ($ai->{ArrayType}) {
#            debug("#\n#I guess it's an array of arrays!\n#\n");
#            my $ai = $ai->{ArrayType}->{ArrayItem};
#            process_array_items($ai, "$path\[$i\]");
#        }
#        elsif ($ai->{HashType}) {
#            debug("#\n#I guess it's an array of hashies\n#\n");
#            my $hi = $ai->{HashType}->{HashItem};
#            process_hash_items($hi, "$path\[$i\]");
#        }
#
#        # What about:
#        # <ArrayItem>
#        #    <InstancePath>top.DUT.pc2mb_rep_ifc_0</InstancePath>
#        # </ArrayItem>
#
#        elsif ($ai->{InstancePath}) {
#            set_value("$path\[$i\]", $ai->{InstancePath});
#        }
#        else {
#            #print "$path\[$i\] = \"$ai->{Val}\";\n";
#            set_value("$path\[$i\]", $ai->{Val});
#        }
##        print "$path\[$i\] = \"$ai->{Val}\"\n"; $i++;
#
#        $i++;
#
#    }
#}
#
#sub process_hash_items {
#    my $hash_items = shift @_;
#    my $path       = shift @_;
#
#    print "$path = new Object();\n";
#    foreach my $hi (@{$hash_items}) {
#
#        my $key = $hi->{Key};
#
#        $key = default_hack($key); # Ugh
#
#        # BUG/TODO for somebody else maybe:
#        # It's a terrible thing!  But sometimes our users will
#        # want a key with odd characters embedded e.g. "$" or "."
#        # "Encode-dots" replaces these chars with "%24" and "%2E" respectively.
#        $key = encode_dots($key);
#
#        if ($hi->{ArrayType}) {
#            debug("#\n#I guess it's a hash of arrays!\n#\n");
#            my $hi = $hi->{ArrayType}->{ArrayItem};
#            process_array_items($hi, "$path.$key");
#        }
#        elsif ($hi->{HashType}) {
#            debug("#\n#I guess it's an array of hashies\n#\n");
#            my $hi = $hi->{HashType}->{HashItem};
#            process_hash_items($hi, "$path.$key");
#        }
#        else {
#
#            my $val = $hi->{Val};
#
#            # <Val></Val> results in $c of type "HASH" !??
#            if (ref($val) eq "HASH") { $val = ""; }
#
#            # <HashItem>
#            #    <InstancePath>top.DUT.mb1</InstancePath>
#            #    <Key>INST</Key>
#            #  </HashItem>
#            
#            elsif ($hi->{InstancePath}) {
#                $val = $hi->{InstancePath};
#            }
#
#
#            print "$path.$key = \"$val\";\n";
#        }
#    }
#}
#
#sub encode_dots {
#    # Replace all "." characters with "%2E"
#    # Replace all "$" characters with "%24"
#
#    my $oldstring = shift(@_);
#    my $newstring = "";
#    foreach my $c (split //, $oldstring) {
#        if    ($c eq "\$") { $c = "\%24"; }
#        elsif ($c eq  ".") { $c = "\%2E"; }
#        $newstring .= $c;
#    }
#    return $newstring;
#}
#
##    die "find_parameter_item() could not find parameter \"$name\"";
#
#
## Use "devtest" to visually verify functionality using "updatedesign.pl -test"
#sub devtest {
#    my $xmldata = shift @_;
#
#    require Data::Dumper;
#    print Data::Dumper->Dumper($xmldata);
#}
#

sub debug {
    if ($DBG) {
        my $s = shift @_;
        print "<!-- $s -->\n";
    }
}

# Copied from my friends at http://www.stonehenge.com/merlyn/UnixReview/col30.html
# BUG/TODO but not really thoroughly vetted or understood.!!

sub deep_copy {
    my $this = shift;
    if (not ref $this) {
      $this;
    } elsif (ref $this eq "ARRAY") {
      [map deep_copy($_), @$this];
    } elsif (ref $this eq "HASH") {
      +{map { $_ => deep_copy($this->{$_}) } keys %$this};
    } else { die "what type is $_?" }
  }


sub deep_copy_and_update_instancepaths {
    my $this = shift;
    if (not ref $this) {
        $this =~ s/^$copyfrom_str/$copyto_str/;

#        my $was = $this;
#        if ($this =~ s/^$copyfrom_str/$copyto_str/) {
#            print "foo $was\n";
#            print "bar $this\n\n";
#        }

        $this;


    } elsif (ref $this eq "ARRAY") {
      [map deep_copy_and_update_instancepaths($_), @$this];
    } elsif (ref $this eq "HASH") {
      +{map { $_ => deep_copy_and_update_instancepaths($this->{$_}) } keys %$this};
    } else { die "what type is $_?" }
  }


1;

