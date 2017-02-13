#!/usr/bin/perl

use strict;

# my $testmode = 0; if ($ARGV[0] eq "-test") { shift (@ARGV); $testmode = 1; }

my $testmode = 0;

if ($testmode) {
    test_getdesigns();
    exit;
}


sub test_getdesigns {

    my $designs = getdesigns();

    foreach my $k (keys(%$designs)) {
	print "designdir = $k\n";
	print "designs:\n" . $designs->{$k};
	print "\n";
    }
}

sub getdesigns() {

    ##############################################################################
    # Make a list of all files/directories in design directory "../designs"

    my $possible_designdirs = `cd ../designs; ls |
                  egrep -v 'tgt0.broken|tmp.tgt0|designs.old|designs.save'`;

    my @possible_designdirs = split /\n/, $possible_designdirs;

    ##############################################################################
    # If candidate is a dir and it contains at least one xml file, make a list
    # $designs{dirname} = "file1.xml file2.xml file3.xml ..."

    my %designs = (); # E.g. designs{"tgt0"} = "tgt0-baseline.xml design-110503.xml ..."
    
    foreach my $designdir (@possible_designdirs) {

	# If it's not even a directory, skip it!
	my $isdir = `test -d ../designs/$designdir && echo -n 1` or next;

#	my $xml_list =
#	    `cd ../designs; test -d $designdir && ls -1 $designdir/*.xml | egrep -v 'igns.tgt0.tgt0.baseline.xml'` or next;

	# If one or more xml files exist, make a list; otherwise skip it.
	my $xml_list =
	    `cd ../designs/$designdir;
             ls -1 *.xml | egrep -v 'igns.tgt0.tgt0.baseline.xml'` or next;

	$designs{$designdir} = $xml_list;
#	print "FOO found $designdir/*.xml = $xml_list\n";
    }
    
#    print "FOOBY\n".keys(%designs);
#    print "\n";

    return \%designs;
}
