#!/usr/bin/perl

# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/PerlLibs/Genesis2/Genesis2.pl#17 $
# ** $DateTime: 2012/11/01 02:28:58 $
# ** $Change: 11190 $
# ** $Author: shacham $
# *************************************************************************



################################################################################
# Copyright by Ofer Shacham and Stanford University.  ALL RIGHTS RESERVED.     #
#              Exclusively Licensed by CHIP GENESIS INC.                       #
#                                                                              #
# The code, the algorithm, or any parts of it is not to be copied/reproduced.  #
# The code, the algorithm, or the results from running this code is not to be  # 
# used for any commercial use unless legally licensed.                         #
#                                                                              #
# For more information please contact                                          #
#   Ofer Shacham (Stanford Univ./Chip Genesis)   shacham@alumni.stanford.edu   #
#   Professor Mark Horowitz (Stanford Univ.)     horowitz@stanford.edu         #
#                                                                              #
# Genesis2 is patent pending. For information regarding the patent please      #
# contact the Stanford Technology Licensing Office:                            #
#   Web: http://otl.stanford.edu/                                              #
#   Email: info@otlmail.stanford.edu                                           #
################################################################################




use strict;
use warnings;

# add the genesis folder to the @INC path:
#use lib "$ENV{GENESIS_HOME}/PerlLibs/Genesis2/Auxiliary";
#use lib "$ENV{GENESIS_HOME}/PerlLibs/ExtrasForOldPerlDistributions";


# Now include the key genesis2 packages
use Genesis2::Manager 1.00;
use Genesis2::UniqueModule 1.00;

# add local per-project perl libraries (only when needed)
if (defined $ENV{GENESIS_PROJECT_LIBS}){
    require lib;
    lib->import("$ENV{GENESIS_PROJECT_LIBS}");
}


# check for Perl installation version
eval {require v5.8.5}; 
if ($@){
    my $ver = $];
    $ver =~ s/00//;
    $ver =~ s/00/\./;
    die "\n\tERROR: Genesis2 Requires Perl Version 5.8.5 or above. Found Perl $ver instead.\n\n";
}

# Now instantiate the manager and let's run...
my $manager = new Genesis2::Manager;
$manager->execute or die "ERROR: Genesis2 run encountered some errors:\n $@";






