#!/usr/bin/perl

# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/Genesis2Tools/bin/makeG2Exec.pl#5 $
# ** $DateTime: 2013/01/16 20:15:12 $
# ** $Change: 11524 $
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
