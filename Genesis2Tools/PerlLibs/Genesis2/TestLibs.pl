#!/usr/bin/perl

# add the genesis folder to the @INC path:
use lib "$ENV{GENESIS_LIBS}";
use lib "$ENV{GENESIS_LIBS}/Genesis2/Auxiliary";

# This is similar to "use lib LIST;" but it adds the library at the end 
# of the search path, instead of the begining of the search path
use lib "$ENV{GENESIS_LIBS}/ExtrasForOldPerlDistributions";
#BEGIN { push(@INC, "$ENV{GENESIS_LIBS}/ExtrasForOldPerlDistributions") }


# add local per-project perl libraries (only when needed)
use if (defined $ENV{GENESIS_PROJECT_LIBS}), lib => "$ENV{GENESIS_PROJECT_LIBS}";

map {print "Searching in: $_ \n";} @INC;
print "\n-------------------------\n\n";

use XML::Simple;
print "XML::Simple --".$INC{'XML/Simple.pm'}."--\n";
#use Time::HiRes;
#print "Time::HiRes --".$INC{'Time/HiRes.pm'}."--\n";
use Getopt::Long;
print "Getopt::Long --".$INC{'Getopt/Long.pm'}."--\n";

print "Rand returned: ".int(rand(10000))." -- ".int(rand(10000))."\n";
#print "Time returned: ".time()." -- ".time()."\n";
