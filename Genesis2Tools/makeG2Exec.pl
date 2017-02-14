#!/usr/bin/perl

# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/Genesis2Tools/bin/makeG2Exec.pl#5 $
# ** $DateTime: 2013/01/16 20:15:12 $
# ** $Change: 11524 $
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

################################################################################
# About this file:
# This script makes an executable from all Genesis source code
#
################################################################################

use strict;
use warnings;

# Clear the screen
system("clear");

print "\nGENESIS2 MAKE EXECUTABLE WARNING: THIS SCRIPTS OVERRIDES THE GENESIS2 EXECUTABLE!!!\n";
print "GENESIS2 MAKE EXECUTABLE WARNING: ARE YOU SURE YOU KNOW WHAT YOU ARE DOING? (NO):  ";
my $continue = <STDIN>;
if ($continue !~ /^y(es)?$/i){
    print "\nGENESIS2 MAKE EXECUTABLE ABORTS\n\n";
    exit;
}
my $verbose = 1;

my $pp = "/usr/bin/pp -P --clean -vv "; # add -vvv for verbos run, 
my $genesis_home = $ENV{GENESIS_HOME};
my $chipgen_home = $ENV{CHIPGEN};
my $perllibs = '';
print "\nWHERE SOURCE FILES ARE... \n";
print "\t (1) I found that \$GENESIS_HOME=$genesis_home\n" if defined $genesis_home;
print "\t (2) I found that \$CHIPGEN/bin/Genesis2Tools=${chipgen_home}/bin/Genesis2Tools\n" 
    if defined $chipgen_home && -e "${chipgen_home}/bin/Genesis2Tools";
print "WHICH LOCATION DO YOU PREFER? (abort):  ";
$continue = <STDIN>;
if ($continue !~ /^\d$/){
    print "\nGENESIS2 MAKE EXECUTABLE ABORTS\n\n";
    exit;
}
elsif ($continue =~ /1/ && defined $genesis_home){
    $perllibs = "$genesis_home/PerlLibs";
}elsif ($continue =~ /2/ && defined $chipgen_home && -e "${chipgen_home}/bin/Genesis2Tools"){
    $perllibs = "${chipgen_home}/bin/Genesis2Tools/PerlLibs"
}else{
    print "\nGENESIS2 MAKE EXECUTABLE ABORTS\n\n";
    exit 7;
}
   
my $genesis_src = "$perllibs/Genesis2";
my $genesis_pl = "$genesis_src/Genesis2.pl";
my @genesis_pm = qw(Manager UniqueModule ConfigHandler UserConfigBase);
@genesis_pm = map {"-M Genesis2::$_";} @genesis_pm;


my $extrainc = "$perllibs/ExtrasForOldPerlDistributions";
my @extralibs = ();
#my @extrafiles = ();
#my @list = `ls -R $extrainc`;
#my $prefix = '';
#foreach my $token (@list){
#    my $file = '';
#    chomp($token);
#    next if $token =~ /^\s*$/;
#    if ($token =~ /^${extrainc}\/(.*):/){
#	$prefix = $1;
#    }
#    elsif ($token =~ /(.*)\.pm/){
#	my $lib = $1;
#	$lib = "${prefix}/$lib" if $prefix ne '';
#	$lib =~ s/\//::/g; # replace '/' with '::'
#	push @extralibs, $lib;
#    }
#    else{
#	push @extrafiles, "-a $prefix/$token" if -f "$extrainc/$prefix/$token";
#    }
#}
@extralibs = map {"-M $_";} @extralibs;
mysystem("$pp --output Genesis2    -I $perllibs -I $extrainc @genesis_pm @extralibs $genesis_pl");
mysystem("$pp --output Genesis2.pl -I $perllibs -I $extrainc @genesis_pm @extralibs $genesis_pl");


sub mysystem{
    my $cmd = shift;
    if ($verbose){
	print "DEBUG: ".$cmd."\n";
    }
    system($cmd);
}
