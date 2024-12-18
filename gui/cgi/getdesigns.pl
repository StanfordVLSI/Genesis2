#!/usr/bin/perl
use strict;

##################################################################################
# Foreach subdirectory "dname" of "../designs" that contains one or more xml files,
# build an associative array
# Make an associative array $designs{dname} = "file1.xml file2.xml file3.xml ..."

##################################################################################
# To test standalone, set $testmode = 1 

my $testmode = 0; if ($ARGV[0] eq "-test") { shift (@ARGV); $testmode = 1; }

if ($testmode) {

    my $designs = getdesigns(1);

    foreach my $k (keys(%$designs)) {
	print "designdir = $k\n";
	print "designs:\n" . $designs->{$k};
	print "\n";
    }
    exit;
}

sub getdesigns {
    my $DBG = shift(@_); # 0 or 1

    ##############################################################################
    # Make sure design directories are up to date:

    # BUG/TODO ick ick ick where is utils.pl included, again?
    # The "ick" is that, to use this perl script, whoever includes it must also include "utils.pl"
    if (! $testmode) { updatedesigndirs($DBG); } # From utils.pl included in ?choosedesign.pl?

    #updatedesigndirs($DBG); BUG/TODO DBG doesn't exist here...

    ##############################################################################
    # Make a list of all files/directories in design directory "../designs"

    my $possible_designdirs = `cd ../designs; ls`;
#                 | egrep -v 'tgt0.broken|tmp.tgt0|^old$|^save'`;
#                 ! egrep -v 'tgt0.broken|tmp.tgt0|designs.old|designs.save'`;

    my @possible_designdirs = split /\n/, $possible_designdirs;
    my $exclude_dirs = qr/tgt0.broken|tmp.tgt0|^old$|^save/;

    ##############################################################################
    # If candidate is a dir and it contains at least one xml file, make a list
    # $designs{dirname} = "file1.xml file2.xml file3.xml ..."

    my %designs = (); # E.g. designs{"tgt0"} = "tgt0-baseline.xml design-110503.xml ..."
    
    foreach my $designdir (@possible_designdirs) {

#       if ($designdir =~ /tgt0.broken|tmp.tgt0|^old$|^save/) { next; }
        if ($designdir =~ /$exclude_dirs/) { next; }

        # This is how we flag deleted designs, e.g. "OferDesign.deleted" or "OferDesign.deleted.1"
        if ($designdir =~ /[.]deleted$/)        { next; } # E.g. "OferDesign.deleted"
        if ($designdir =~ /[.]deleted.[0-9]*$/) { next; } # E.g. "OferDesign.deleted.1"

#	print "designdir = $designdir\n\n";

	# If it's not even a directory, skip it!
	my $isdir = `test -d ../designs/$designdir && echo -n 1` or next;

	# If one or more xml files exist, make a list; otherwise skip it.
	my $xml_list =
	    `cd ../designs/$designdir;
             ls -1 *.xml 2> /dev/null | egrep -v 'igns.tgt0.tgt0.baseline.xml'` or next;

#	print "xml_list = $xml_list\n\n\n";

	$designs{$designdir} = $xml_list;
    }
    
#    print "FOOBY\n".keys(%designs)."\n";

    return \%designs;
}
