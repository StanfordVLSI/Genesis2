# To test, try something like: perl -f <thisfile>
use strict;

#use XML::Simple;
use XML::Simple qw(:strict);

my $DBG9 = 0; # DBG9 = xtreme debug

my $use_tiny_xml = 0;     # Should be all caps (because global), but oh well. BUG/TODO

# Designed to prevent infinite failure in recursive search for missing parm.
my $SEARCHING_XMLREF = 0;

my $TROUBLE = 0;          # This is designed to prevent infinite loops
my $MAXTROUBLE = 10000;   # that crash your browser.

# These work well as globals, don't you think?
my $xmlref;            # loaded on demand
my $xmlref_fname;
my $MODPATH;

sub build_xml_change_file {

    #########################################################################################
    # Given the name of an existing hierarchy file $old_fname
    # and a name for a new hier. file to be created $new_fname
    # and a path e.g. "top.DUT.p0"
    # print new hierarchy file with new parameters inplace of the old ones
    #
    ##########################################################################################

    #########################################################################################
    # If "xmlref_fname" is not null, then $old_fname is a tiny-xml file and "xmlref_fname"
    # is the fully elaborated reference xml.
    # 
    # Enhance $old_fname with new parameters as before, but
    #  - if modpath for new parameters doesn't exist in $old_fname, must create it; 
    #  - if new parameters don't exist in $old_fname, then
    #    -  copy parameter names from $xmlref_fname to $old_fname.
    #########################################################################################

    # Subroutine parms and globals

    my $old_fname = shift(@_);   # E.g. "designs/tgt0/demo-110225-162146.xml"
    my $new_fname = shift(@_);   # E.g. "designs/tgt0/SysCfgs/demo-110225-162146-changes.xml"

    $xmlref_fname = shift(@_);   # E.g. "designs/tgt0/SysCfgs/demo-110225-161500-changes.xml"
    if ($xmlref_fname) {
        if ($DBG9) {
            print("<small><br>\n".
                  "I see xml ref filename \"$xmlref_fname\"<br>\n".
                  "This means that \"$old_fname\" is a tiny xml file, right?<br><br>\n"
                  );
        }
        $use_tiny_xml = 1;
    }

    # See /cad/genesis2/r9519/PerlLibs/Genesis2/Manager.pm for XMLin,XMLout prototypes.

    my $xmldata = XMLin($old_fname, 
                       KeepRoot => 1, # Don't throw away "HierarchyTop"
                       NoAttr => 1,
                       KeyAttr => [],
                       ForceArray => ['ArrayItem', 'HashItem', 'ParameterItem', 'SubInstanceItem']
                       );

    bxcf_optional_errcheck($xmldata); # Coupla error checks on XML input data.

    #######################################################################################
    # Use "devtest" to visually verify functionality using "updatedesign.pl -test"
    my $devtest=0; if ($devtest) { devtest($xmldata); }
    # BUG/TODO RETHINK DEVTEST (ABOVE)

    #######################################################################################
    # Process the desired changes to the xml
    process_changes($xmldata);

    #######################################################################################
    # Print the changes to the change file.
    if ($DBG9) { print "Okay now writing the result to \"$new_fname\"\n\n"; }
    XMLout($xmldata,
	   NoAttr => 1, 
	   KeyAttr => [],
#	   RootName => 'HierarchyTop',   # Add root "HierarchyTop"
           KeepRoot => 1,                # Don't throw away "HierarchyTop"
	   OutputFile => $new_fname
           );
}

##############################################################################

	# e.g. looking for "DUT.p0"
	#                                          
	# <HierarchyTop>                           
	#   <InstanceName>top</InstanceName>     path="top"
	#   <Parameters>...</Parameters>         path="top"
	#   <SubInstances>                       path="top"
	#     <SubInstanceItem>                  path="top"
	#       <InstanceName>DUT<InstanceName>  path="top.DUT"
	#       <Parameters>...</Parameters>     path="top.DUT"
	#       <SubInstances>                   path="top.DUT"
	#         <SubInstanceItem>              path="top.DUT"
	#           <InstanceName>p0</Insta...   path="top.DUT.p0" MATCH
	#           <Parameters>...</Parame...>    
	#         </SubInstanceItem>               
	#       </SubInstances>                    
	#     </SubInstanceItem>                   
	#   </SubInstances>                        


# E.g. "find_parameter($xml, "top.DUT.p0", "USE_SHIM") returns $obj
# such that $obj->{"Name"} is "USE_SHIM"

sub find_parameter {
    my $xmldata = shift @_;
    my $path = shift @_;
    my $parmname = shift @_;

    if ($DBG9) { print "find_parameter() looking for parm $parmname in path $path<br>\n"; }

    # "top.DUT.p0" => ("DUT","p0")
    my @path = split /[.]/,$path;
    shift @path; # Get rid of "top"

    my $ref_obj;
    if ($use_tiny_xml) {
        check_for_xmlref();                 # Initialize $xmlref if not already exists
        $ref_obj = $xmlref->{HierarchyTop}; # Initialize $ref_obj
    }

    my $obj = $xmldata->{HierarchyTop};

    foreach my $pathname (@path) {
        my $basename;
        if ($use_tiny_xml) {
            $ref_obj = find_subinstance($ref_obj, $pathname);
            $basename = $ref_obj->{BaseModuleName};
            if ($DBG9) {
                print "Pathname \"$pathname\" appears to have basename \"$basename\"<br>\n";
            }
        }
        $obj = find_subinstance($obj, $pathname, $basename);
        #print "found $obj->{InstanceName}\n\n";
    }

    $obj = find_parameter_item($obj, $parmname);

    return $obj;
}

sub find_subinstance {
    my $obj = shift @_;
    my $name = shift @_;
    my $base = shift @_; # BaseModuleName

    foreach my $i (@{$obj->{SubInstances}->{SubInstanceItem}}) {
#       print $i->{InstanceName};
        if ($i->{InstanceName} eq $name) { return $i; }
    }
    if (! $use_tiny_xml) {
        die "find_subinstance() could not find subinstance \"$name\"";
    }
    else {
        if ($DBG9) {
            print "\nfind_subinstance() could not find subinstance \"$name\"; ";
            print "will try to create subinstance \"$name\"\n";
        }

        #######################################################################
        # Next: create new obj->{BaseModuleName} and obj->{InstanceName} hashes
        # for missing subinstance \"$name\", and add them to array
        # @{$obj->{SubInstances}->{SubInstanceItem}

        my $newsub = {};
        $newsub->{InstanceName} = $name;
        $newsub->{BaseModuleName} = $base;
        if ($DBG9) { print "Adding subinstance \"$name\" with base name \"$base\"; "; }
        push(@{$obj->{SubInstances}->{SubInstanceItem}}, $newsub);

        if ($DBG9) {
            print "now we have these subinstances:\n";
            foreach my $i (@{$obj->{SubInstances}->{SubInstanceItem}}) {
                print $i->{InstanceName} . "\n";
            } print "\n";
        }
        return $newsub;
    }
}

# E.g. name = "USE_SHIM" or "SPECIAL_DATA_MEM_OPS.0.tiecode"
sub find_parameter_item {
    my $obj = shift @_;
    my $name = shift @_;

    if ($TROUBLE++ > $MAXTROUBLE) { print "Oops fpi trouble=$TROUBLE"; exit; }

    if (! ($name =~ /[.]/)) { return find_simple_parameter_item($obj, $name); }

    # Trouble if there's a dot as in e.g. "SPECIAL_DATA_MEM_OPS.0.tiecode"

    my @parm_parts = split(/[.]/, $name); # E.g. ("SPECIAL_DATA_MEM_OPS","0","tiecode")

    if ($DBG9) { print "<br>\nRecursive call to fspi<br>\n"; }

    $obj = find_simple_parameter_item($obj, $parm_parts[0]);

    if ($DBG9) { print "<br>\nSuccessfully returned from recursive call to fspi<br>\n"; }

    if ($DBG9) {
        print "\n\n";
        print "arraytype? ".(defined $obj->{ArrayType})."\n";
        print "hashtype? ".(defined $obj->{HashType})."\n";
        print "\n\n";
    }

    shift @parm_parts;

    if ($DBG9) { use Data::Dumper; }

    foreach my $p (@parm_parts) {
        if ($DBG9) { print "next is $p\n"; }
        if (defined $obj->{ArrayType}) {
            $obj = $obj->{ArrayType}{ArrayItem}[$p];
            if ($DBG9) { print Data::Dumper->Dumper($obj); }
        }
        elsif (defined $obj->{HashType}) {
            $obj = find_hash_item($obj, $p);
            if ($DBG9) { print Data::Dumper->Dumper($obj); }
        }
    }
    return $obj;


#    foreach my $i (@{$obj->{Parameters}->{ParameterItem}}) {
#        print $i->{Name};
#        if ($i->{Name} eq $name) { return $i; }
#    }
#    die "find_parameter_item() could not find parameter \"$name\"";
}

# E.g. name = "USE_SHIM"
sub find_simple_parameter_item {
    my $obj = shift @_;
    my $name = shift @_;

    if ($TROUBLE++ > $MAXTROUBLE) { print "Oops fspi trouble=$TROUBLE"; exit; }

    foreach my $i (@{$obj->{Parameters}->{ParameterItem}}) {
#        print $i->{Name};
        if ($i->{Name} eq $name) { return $i; }
    }
    if (! $use_tiny_xml) {
        my $die_msg = "ERROR: find_parameter_item() could not find parameter \"$name\""; 
        print "<br>\n${die_msg}<br>\n";
        die $die_msg;
    }
    elsif ($SEARCHING_XMLREF) {
        my $die_msg = "ERROR: find_parameter_item() could not find parm \"$name\" in xmlref";
        print "<br>\n${die_msg}<br>\n";
        die $die_msg;
    }
    else {
        # Could not find parameter in $curdesign;
        # find it in $xmlref and do a deepcopy; return the copy; e.g.
        #
        # &USE_SHIM=bar ;                        => copies and returns pointer to "USE_SHIM"
        # &SPECIAL_DATA_MEM_OPS.0.name=4bart ;   => copies and returns pointer to "SPECIAL_DATA_MEM_OPS"

        if ($DBG9) {
            print "<br>find_parameter_item() could not find parameter \"$name\"; ";
            print "will try to find and insert it<br>\n";
        }

        check_for_xmlref(); # Load xmlref if not already loaded.

        if ($DBG9) { print "<br>Looking for \"$name\" in \$xmlref<br><br>\n\n"; }

        # Find parm in ref file and copy it to main xml data struct.
        # Is it too hacky, using a global (MODPATH) to pass modpath around?
        $SEARCHING_XMLREF++;
        my $ref_obj = find_parameter($xmlref, $MODPATH, $name);
        $SEARCHING_XMLREF--;

#        if ($name eq "SPECIAL_DATA_MEM_OPS") {
#            print "\n\nFound it??\n\n"; print "Here's what I see:\n\n";
#            use Data::Dumper; print Data::Dumper->Dumper($ref_obj);
#        }

        my $newparm = deep_copy($ref_obj);
        if ($DBG9) {
            my $cr = "<br>\n";
            print "${cr}Did this work?${cr}";
            print " - old parm value was " . $ref_obj->{Val} .$cr;
            print " - new copy value is  " . $newparm->{Val} .$cr.$cr;
            # $ref_obj->{Val} = "foofroo";
        }
        push(@{$obj->{Parameters}->{ParameterItem}}, $newparm);
        return $newparm;
    }
}

sub find_hash_item($obj, $name) {
    my $obj = shift @_;
    my $key = shift @_;

    foreach my $i (@{$obj->{HashType}->{HashItem}}) {
        if ($i->{Key} eq $key) { return $i; }
    }
    die "find_find_hash_item() could not find hash_item w/key \"$key\"";
}


sub process_changes {

    my $xmldata = shift @_;

    my $pairnum = 0;

    my $parms = $ENV{QUERY_STRING};
    if ($DBG9) { print "\n"."process_changes sees parms: $parms\n\n"; }

    my @parmpairs = split /\&/ , $parms;

    # Ignore the first four
    my $newdesign = shift @parmpairs; # newdesign=udtest
    my $curdesign = shift @parmpairs; # curdesign=updatedesign.dir%2Ftest%2Ftgt0-baseline.js

#    if ($use_tiny_xml) {
#        my $xmlref_dummy = shift @parmpairs; # xmlref=updatedesign.dir%2Ftest%2Ftgt0-baseline.js
#    }


    my $modpath   = shift @parmpairs; # modpath=top.DUT.p0
    my $DBG       = shift @parmpairs; # DBG=1

    $MODPATH=$modpath;  # too hacky?  using a global to pass modpath around?

    # Now get the parms = e.g.
    #
    # USE_SHIM=bar
    # SPECIAL_DATA_MEM_OPS.0.name=4bart
    # SPECIAL_DATA_MEM_OPS.0.tiecode=0foo
    # SPECIAL_DATA_MEM_OPS.2.tiecode=2baz
    # SPECIAL_DATA_MEM_OPS.2=%.deleteme

    foreach my $p (@parmpairs) {

	if ( $p =~ m/([^=]+)=(.*)/) {
	    my $field = $1; my $value = $2;
	    $value =~ s/\+/ /g;
	    $value =~ s/%([\dA-Fa-f]{2})/pack("C", hex($1))/eg;

            # Could (should?) wrap these (below) into a single call like
            # "process_parameter($xmldata, $modpath, $field, $value)"

            if ($value eq "%.deleteme") {
                delete_array_item($xmldata, $modpath, $field)
            }
            elsif ($value eq "%.cloneme") {
                clone_array_item($xmldata, $modpath, $field)
            }
            else {
                my $obj = find_parameter($xmldata, $modpath, $field);
                $obj->{Val} = $value;
            }
        }
        else {
            die "process_changes - bad parm pair\n";
        }
        if ($DBG9) { print "$p\n"; }
    }
    print "\n";
}


sub delete_array_item {
    # E.g. delete_array_item($xmldata, "top.DUT.p0", "SPECIAL_DATA_MEM_OPS.0");
    edit_array_item(@_, "deleteme");
}

sub clone_array_item {
    # E.g. clone_array_item($xmldata, "top.DUT.p0", "SPECIAL_DATA_MEM_OPS.0");
    edit_array_item(@_, "cloneme");
}

sub edit_array_item {

  # E.g. edit_array_item($xmldata, "top.DUT.p0", "SPECIAL_DATA_MEM_OPS.0", "deleteme");
  # or   edit_array_item($xmldata, "top.DUT.p0", "SPECIAL_DATA_MEM_OPS.0", "cloneme");

    my $xmldata  = shift @_;
    my $path     = shift @_;
    my $parmname = shift @_;
    my $command  = shift @_; # "deleteme" or "cloneme"

    $parmname =~ /^(.+)[.]([^.]+)$/; # E.g. (SPECIAL_DATA_MEM_OPS).(0)
    my $arrname = $1;
    my $arrnum  = $2;

    my $obj = find_parameter($xmldata, $path, $arrname);

    # Now to delete item $arrnum in $arrname->{ArrayType}->{ArrayItem}

   #my $DBG9 = 1;
    if ($DBG9) { use Data::Dumper; }
    if ($DBG9) { print "before:\n".Data::Dumper->Dumper($obj); }
    if ($DBG9) { print "-----------------------------------\n\n"; }

    if ($command eq "deleteme") {
        splice(@{$obj->{ArrayType}->{ArrayItem}}, $arrnum, 1);
    }
    elsif ($command eq "cloneme") {
        print "cloneme $arrname $arrnum\n\n";

        # Need a DEEP COPY of the array item.

        my $deepcopy = deep_copy(
                                 $obj->{ArrayType}->{ArrayItem}[$arrnum]
                                 );

        if ($DBG9) { print_crazy_deepcopy_debug_messages($obj,$deepcopy,$arrnum); }

#        my $obj2 = $obj->{ArrayType}->{ArrayItem}[$arrnum];
#        if ($DBG9) { print "foo obj2=$obj2:\n".Data::Dumper->Dumper($obj2); }
#        if ($DBG9) { print "foo deepcopy=$deepcopy:\n".Data::Dumper->Dumper($deepcopy); }
#
#        exit;

        splice(@{$obj->{ArrayType}->{ArrayItem}}, $arrnum, 0,
#               $obj->{ArrayType}->{ArrayItem}[$arrnum]
               $deepcopy
               );
    }
    else {
        die "bad command was sent to edit_array_item()";
    }


    if ($DBG9) { print "after:\n".Data::Dumper->Dumper($obj); }
}


# Copied from my friends at http://www.stonehenge.com/merlyn/UnixReview/col30.html
# BUG/TODO but not really thoroughly vetted or understood.!!

sub deep_copy {
    my $this = shift;
    if (not ref $this) {
      $this;
    } elsif (ref $this eq "ARRAY") {
        # For each element of array @$this, do a deep copy, return result as an array.
      [map deep_copy($_), @$this];
    } elsif (ref $this eq "HASH") {
      +{map { $_ => deep_copy($this->{$_}) } keys %$this};
    } else { die "what type is $_?" }
  }

sub print_crazy_deepcopy_debug_messages {
    my $obj      = shift @_;
    my $deepcopy = shift @_;
    my $arrnum   = shift @_;

    my $otype = $obj->{ArrayType}->{ArrayItem}[$arrnum]->{HashType};
    my $oitem = $obj->{ArrayType}->{ArrayItem}[$arrnum]->{HashType}->{HashItem};
    my $oval  = $obj->{ArrayType}->{ArrayItem}[$arrnum]->{HashType}->{HashItem}[0]->{Val};

    my $dtype = $deepcopy->{HashType};
    my $ditem = $deepcopy->{HashType}->{HashItem};
    my $dval  = $deepcopy->{HashType}->{HashItem}[0]->{Val};

    print "obj      hashtype, hashitem, Val is $otype, $oitem, \"$oval\"\n";
    print "deepcopy hashtype, hashitem, Val is $dtype, $ditem, \"$dval\"\n";
    print "\n";
}

# Use "devtest" to visually verify functionality using "updatedesign.pl -test"
sub devtest {
    my $xmldata = shift @_;

    $DBG9 = 1;
    clone_array_item($xmldata, "top.DUT.p0", "SPECIAL_DATA_MEM_OPS.0");
    exit;

    delete_array_item($xmldata, "top.DUT.p0", "SPECIAL_DATA_MEM_OPS.0");
    exit;

    require Data::Dumper;
    print Data::Dumper->Dumper($xmldata);

    # E.g. to change top.DUT.p0 parm "USE_SHIM" to have value "flart":

    my $obj = find_parameter($xmldata, "top.DUT.p0", "USE_SHIM");
    $obj->{Val} = "flarty";

    # Now try something harder: e.g. 
    # process command "SPECIAL_DATA_MEM_OPS.0.tiecode=0foo" for top.DUT.p0

    my $obj = find_parameter($xmldata, "top.DUT.p0", "SPECIAL_DATA_MEM_OPS.0.tiecode");
    $obj->{Val} = "0foo";
}

sub bxcf_optional_errcheck {
    my $xmldata = shift @_;

    #######################################################################################
    # Coupla error checks

    my $msg = "Root element of the xml_in_file must be HierarchyTop!";
    if (! defined $xmldata->{HierarchyTop}) { die $msg; }

    my $msg = "Only single root element allowed for the xml_in_file (must be HierarchyTop)";
    if (keys %{$xmldata} > 1) { die $msg; }

}

sub check_for_xmlref {
    # If $xmlref not defined yet, then define it!
    if (! (defined $xmlref)) {
        if ($DBG9) { print "<br>\nLoading \$xmlref from \"$xmlref_fname\"...<br>\n<br>\n"; }
        $xmlref = XMLin($xmlref_fname, 
                        KeepRoot => 1, # Don't throw away "HierarchyTop"
                        NoAttr => 1,
                        KeyAttr => [],
                        ForceArray => ['ArrayItem', 'HashItem', 'ParameterItem', 'SubInstanceItem']
                        );
    }
}

1;
