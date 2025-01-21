#!/usr/bin/perl
use strict;

my $DBG = 1;

#use XML::Simple;
use XML::Simple qw(:strict);

my $DBG9  = 0; # DBG9 = xtreme debug
my $RPDBG = 0; # I forget what RP stands for...!?

#xml2js("samples/regression.xml", "tmp-regression.js");
xml2js("samples/regression.xml");
exit(0);

sub xml2js {

    #########################################################################################
    # Given the name of an existing hierarchy file $xml_in
    # and a name for a new hier. file to be created $new_fname
    # and a path e.g. "top.DUT.p0"
    # print new hierarchy file with new parameters inplace of the old ones
    #
    ##########################################################################################

    # Subroutine parms and globals

    my $xml_in = shift(@_);   # E.g. "samples/regression.xml"
#    my $new_fname = shift(@_);   # E.g. "regression.js"

    # See /cad/genesis2/r9519/PerlLibs/Genesis2/Manager.pm for XMLin,XMLout prototypes.

    my $xmldata = XMLin($xml_in, 
                       KeepRoot => 1, # Don't throw away "HierarchyTop"
                       NoAttr => 1,
                       KeyAttr => [],
                       ForceArray => ['ArrayItem', 'HashItem', 'ParameterItem', 'SubInstanceItem']
                       );

    #######################################################################################
    # Coupla error checks

    my $msg = "Root element of the xml_in_file must be HierarchyTop!";
    if (! defined $xmldata->{HierarchyTop}) { die $msg; }

    my $msg = "Only single root element allowed for the xml_in_file (must be HierarchyTop)";
    if (keys %{$xmldata} > 1) { die $msg; }

    #######################################################################################
    # Use "devtest" to visually verify functionality using "updatedesign.pl -test"
    my $devtest=0; if ($devtest) { devtest($xmldata); }

    #######################################################################################
    # One thing at a time, I a-reckon.

    # Rewrite HierarchyTop names to be "cgtop" instead of "top" or whatever.

#    $xmldata->{HierarchyTop}->{BaseModuleName} = "cgtop";
#    $xmldata->{HierarchyTop}->{InstanceName} = "cgtop";


    process_instance($xmldata->{HierarchyTop}, "cgtop.");
    return;

    my $instance = $xmldata->{HierarchyTop};
}

sub process_instance {
    my $instance = shift @_; # E.g. $xmldata->{HierarchyTop}
    my $path     = shift @_; # E.g. "" or "cgtop.SubInstances"
    
    my $script_begin = '<script type="text/javascript"><!--';
    my $script_end   = '//--></script>';

    if ($path eq "cgtop") { print "$script_begin\n"; }

    print "var $path = new Object();\n";

#    foreach my $name ("BaseModuleName","InstanceName") {
    foreach my $name ("BaseModuleName") {
        print "$path$name = \"$instance->{$name}\";\n";
    }

    my $parms = $instance->{ImmutableParameters}->{ParameterItem};
    if (! $parms) { debug("#    oops no *immutable* parms\n"); }
    else          { process_parameters($parms, $path."Immutable"); }

    foreach my $name ("InstanceName") {
        print "$path$name = \"$instance->{$name}\";\n";
    }


    my $parms = $instance->{Parameters}->{ParameterItem};
    if (! $parms) { debug("    oops no parms\n");      }
    else          { process_parameters($parms, $path); }

    print "$script_end\n\n";

    my $e = $instance;



#    foreach my $e ($instance) {
#        print "instancename $e->{InstanceName}\n";
#        print "subinstances $e->{SubInstances}\n";


    my $subinstances = $instance->{SubInstances}->{SubInstanceItem};
    if (! $subinstances) {
        debug("#    oops no subitems\n");
        return;
    }
    else {
        print "$script_begin\n";
        foreach my $si (@{$subinstances}) {
#            print "si= $si\n";
            print $path."Subinstances = new Object();\n";
            process_instance($si, $path."Subinstances.$si->{InstanceName}.");
        }
    }
}

sub loop_through_subinstances {
    my $instance = shift @_;

    my @subinstances = @{$instance->{SubInstances}->{SubInstanceItem}};

#    my $array_ptr = shift @_;
#    print "AP $array_ptr\n";
#    foreach my $si (@{$array_ptr}) {

    foreach my $si (@subinstances) {
#        print "$si->{InstanceName}\n";
        process_instance("$si.");
    }

}


sub process_parameters {
    my $parms = shift @_;  # E.g. array $xmldata->{HierarchyTop}->{Parameters}->{ParameterItem}
    my $path = shift @_;  # E.g. "cgtop.SubInstances.wallace_3
    
    if ($DBG) { print "# processing parms using path $path\n#\n"; }


    foreach my $obj ("Parameters","Comments","Range") {
        print "$path$obj = new Object();\n";
    }




    foreach my $parm (@{$parms}) {
        my $n = $parm->{Name};
        my $c = $parm->{Doc};
        
        #print "found parm $n\n";
        #print "found parm comment of type ". ref($c)."\n";

        # <Doc></Doc> results in $c of type "HASH" !??
        if (ref($c) eq "HASH") { $c = "no comment"; }


        print $path."Comments.$n = \"$c\";\n";

        # ParameterItem can be a array ("ArrayType"), hash ("HashType"), or simple

        if ($parm->{ArrayType}) {

#            print "\nI guess it's an array\n\n";
            # if (! $ai) { print "    oops no array items\n"; } else {
#            print $path."Parameters.$n = new Object();\n";

            my $ai = $parm->{ArrayType}->{ArrayItem};
            process_array_items($ai, $path."Parameters.$n");

        }
        elsif ($parm->{HashType}) {
            debug("#\n#I guess it's a hashy\n#\n");

            my $hi = $parm->{HashType}->{HashItem};
            process_hash_items($hi, $path."Parameters.$n");

        }
        else {
            debug("#\n#I guess it's simple\n#\n");
            print $path."Parameters.$n = \"$parm->{Val}\";\n";
            if ($parm->{Range}) {
                debug("#oh it has a range.\n");
                process_ranges($parm->{Range}, $path."Parameters.$n");
            }
        }

    }
}

#          <Range>
#            <List>1</List>
#            <List>2</List>
#            <List>3</List>
#            <List>4</List>
#...
#            <List>16</List>
#            <List>32</List>
#            <List>64</List>
#          </Range>
#
# => cgtop.SubInstances.wallace_3.ImmutableRange.N = "1 2 3 4 5 6 7 8 9 16 32 64";


#          <Range>
#            <Max>410</Max>
#            <Step>2</Step>
#          </Range>
#
# => cgtop.SubInstances.wallace_3.Range.ParMaxStep = ",410,2";

sub process_ranges {
    my $ranges = shift @_;
    my $path   = shift @_;

    debug("#oh it has a range. is it lists?  mn/max/step???\n");

    if ($ranges->{List}) {
        #print "oh looks like a list maybe\n";
        my @list;
        foreach my $i (@{$ranges->{List}}) {
            #print " i see $i\n";
            push( @list, $i);
        }
        my $liststring = join(" ", @list);
        print "$path = \"$liststring\";\n";
    }
    else {
        #print "oh no maybe it's a min/max/step\n";

        my $min = $ranges->{Min};
        my $max = $ranges->{Max};
        my $step = $ranges->{Step};

        my $rangestring = "$min,$max,$step";
        print "$path = \"$rangestring\";\n";
    }


}



sub process_array_items {
    my $array_items = shift @_;
    my $path        = shift @_;

    print "$path = new Object();\n"; # $i++;


    my $i = 0; # Array starts w/index "0"
    foreach my $ai (@{$array_items}) {

        if ($ai->{ArrayType}) {
            debug("#\n#I guess it's an array of arrays!\n#\n");
            my $ai = $ai->{ArrayType}->{ArrayItem};
            process_array_items($ai, "$path\[$i\]");
        }
        elsif ($ai->{HashType}) {
            debug("#\n#I guess it's an array of hashies\n#\n");
            my $hi = $ai->{HashType}->{HashItem};
            process_hash_items($hi, "$path\[$i\]");
        }
        else {
            print "$path\[$i\] = \"$ai->{Val}\"\n";
        }
#        print "$path\[$i\] = \"$ai->{Val}\"\n"; $i++;

        $i++;

    }
}

sub process_hash_items {
    my $hash_items = shift @_;
    my $path       = shift @_;

    print "$path = new Object();\n";
    foreach my $hi (@{$hash_items}) {

        my $key = $hi->{Key};


        if ($hi->{ArrayType}) {
            debug("#\n#I guess it's a hash of arrays!\n#\n");
            my $hi = $hi->{ArrayType}->{ArrayItem};
            process_array_items($hi, "$path.$key");
        }
        elsif ($hi->{HashType}) {
            debug("#\n#I guess it's an array of hashies\n#\n");
            my $hi = $hi->{HashType}->{HashItem};
            process_hash_items($hi, "$path.$key");
        }
        else {

            my $val = $hi->{Val};

            print "$path.$key = \"$val\";\n";
        }
    }
}



#    die "find_parameter_item() could not find parameter \"$name\"";


# Use "devtest" to visually verify functionality using "updatedesign.pl -test"
sub devtest {
    my $xmldata = shift @_;

    require Data::Dumper;
    print Data::Dumper->Dumper($xmldata);
}

sub debug { if ($DBG) { print @_; } }

1;
