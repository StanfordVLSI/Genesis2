#!/usr/bin/perl
use strict;
use XML::Simple qw(:strict);                      # use XML::Simple;

if ($#ARGV < 1) {
    print "E.g. \"xml_cp.pl samples/regression.xml top.DUT.drh0\"\n";
    print "prints indicated module \"top.DUT.drh0\" to stdout\n";
    exit;
}

my $DBG = 0;
#$DBG=1;

#print $ARGV[0];#print "\n";#exit;

my $xml_file = $ARGV[0];    # E.g. "hierarchy_out.xml"
my $targmod_str = $ARGV[1]; # E.g. "top.DUT.drh0"
my $targmod_ptr;

# E.g. "xml_cat.pl samples/regression.xml top.DUT.drh0"
xml_cat($xml_file, $targmod_str);
exit(0);

sub xml_cat {

    # Subroutine parms and globals

    my $xml_in    = shift(@_);   # E.g. "samples/regression.xml"

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

    process_instance($xmldata->{HierarchyTop}, "top");

    if (! $targmod_ptr) {
        die "ERROR Could not find target module $targmod_str\n";
    }

    debug( "" );
    debug( "found targmod instance ".$targmod_ptr->{InstanceName} );
    debug( "" );

    #######################################################################################
    # Print the changes to the change file.
    print
    XMLout($targmod_ptr,
	   NoAttr => 1, 
	   KeyAttr => [],
	   RootName => 'HierarchyTop',   # Add root "HierarchyTop"
           KeepRoot => 1,                # Don't throw away "HierarchyTop"
#	   OutputFile => $new_fname
#	   OutputFile => "tmpfoo"
           );
}

sub process_instance {
    my $instance = shift @_; # E.g. $xmldata->{HierarchyTop}
    my $path     = shift @_; # E.g. "top.DUT"

    debug("checking $path against $targmod_str");

    my $subinstances = $instance->{SubInstances}->{SubInstanceItem};
    if ($subinstances) {
        my $ix = 0;
        foreach my $si (@{$subinstances}) {
            my $in = $si->{InstanceName};
            my $si_path = "$path.$in";

            # print "checking $si_path against $targmod_str\n";

            if ($si_path eq $targmod_str) {
                debug("1. found target module ".$si->{InstanceName} );
                $targmod_ptr = $si;
            }
            else {
                process_instance($si, "$path.$in");
            }
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

1;

