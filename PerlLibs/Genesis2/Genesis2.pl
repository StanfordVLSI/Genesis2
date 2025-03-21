#!/usr/bin/env perl

# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/PerlLibs/Genesis2/Genesis2.pl#17 $
# ** $DateTime: 2012/11/01 02:28:58 $
# ** $Change: 11190 $
# ** $Author: shacham $
# *************************************************************************



###################################################################################
# Copyright (c) 2013, Ofer Shacham and Stanford University                        #
# All rights reserved.                                                            #
#                                                                                 #
# Redistribution and use in source and binary forms, with or without              #
# modification, are permitted provided that the following conditions are met:     #
#                                                                                 #
# 1. Redistributions of source code must retain the above copyright notice, this  #
#    list of conditions and the following disclaimer.                             #
# 2. Redistributions in binary form must reproduce the above copyright notice,    #
#    this list of conditions and the following disclaimer in the documentation    #
#    and/or other materials provided with the distribution.                       #
#                                                                                 #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"     #
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE  #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR #
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES  #
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;    #
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND     #
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      #
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF        #
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.               #
#                                                                                 #
# The views and conclusions contained in the software and documentation are those #
# of the authors and should not be interpreted as representing official policies, #
# either expressed or implied, of Stanford University.                            #
#                                                                                 #
# For more information please contact                                             #
#   Ofer Shacham (Stanford Univ./Chip Genesis)   shacham@alumni.stanford.edu      #
#   Professor Mark Horowitz (Stanford Univ.)     horowitz@stanford.edu            #
###################################################################################




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






