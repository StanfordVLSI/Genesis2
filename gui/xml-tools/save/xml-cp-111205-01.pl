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
    
    my $deepcopy = deep_copy_and_update_instancepaths($copyfrom_ptr);

    @{$copyto_array}[$copyto_ix] = $deepcopy;

    # Don't forget to update the instance name!!!
    $copyto_str =~ /[.]([^.]+)$/;
    my $in = $1;
    debug("copyto instance name should be $in\n");
    @{$copyto_array}[$copyto_ix]->{InstanceName} = $in;

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

        # Now, a word from our parser: because blocks and anonymous hash
        # constructors both use curly braces in roughly the same places in the
        # syntax tree, the compiler has to make ad hoc determinations about
        # which of the two you mean. If the compiler ever decides incorrectly,
        # you might need to provide a hint to get what you want. To show the
        # compiler that you want an anonymous hash constructor, put a plus sign
        # before the opening curly brace: +{ ... }. To be sure to get a block of
        # code, just put a semicolon (representing an empty statement) at the
        # beginning of the block: {; ... }.

        +{map { $_ => deep_copy($this->{$_}) } keys %$this};
    } else { die "what type is $_?" }
}

# if @numbers = (1,2,3,4,5) and square(n) = n*n, then
# map( square($_), @numbers) => (1,4,9,16,25)


sub deep_copy_and_update_instancepaths {
    my $this = shift;
    if (not ref $this) {
        $this =~ s/^$copyfrom_str/$copyto_str/;

#        my $was = $this;
#        if ($this =~ s/^$copyfrom_str/$copyto_str/) {
#            print "was: $was\n";
#            print "now: $this\n\n";
#        }
        $this;

    } elsif (ref $this eq "ARRAY") {
        # Sq. brackets casts list as an array?
        [map deep_copy_and_update_instancepaths($_), @$this];
    } elsif (ref $this eq "HASH") {

        # Now, a word from our parser: because blocks and anonymous hash
        # constructors both use curly braces in roughly the same places in the
        # syntax tree, the compiler has to make ad hoc determinations about
        # which of the two you mean. If the compiler ever decides incorrectly,
        # you might need to provide a hint to get what you want. To show the
        # compiler that you want an anonymous hash constructor, put a plus sign
        # before the opening curly brace: +{ ... }. To be sure to get a block of
        # code, just put a semicolon (representing an empty statement) at the
        # beginning of the block: {; ... }.

        +{map { $_ => deep_copy_and_update_instancepaths($this->{$_}) } keys %$this};
    } else { die "what type is $_?" }
}

1;

