# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/Genesis2Tools/PerlLibs/Genesis2/UserConfigBase.pm#4 $
# ** $DateTime: 2013/01/31 00:27:30 $
# ** $Change: 11627 $
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
################### ACTUAL USERCONFIGBASE CODE STARTS HERE #####################
################################################################################
package Genesis2::UserConfigBase;
use strict;
use warnings;
use Exporter;
use Carp;
use Term::ANSIColor;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT = qw(
 configure 
 exists_configuration 
 remove_configuration 
 get_configuration 
 include
 get_top_name
 get_synthtop_path
 print_configuration
 error
             );
@EXPORT_OK = qw();
$VERSION = '1.0';

BEGIN{
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_design_time = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: caller($i-1) == $package sub=$subroutine\n";
	last if $package eq 'Genesis2::UserConfigScript';
	if ($package eq 'Genesis2::UniqueModule' || $package eq 'Genesis2::Manager'){
	    die "Importing ".__PACKAGE__." into design files is forbidden\n";
	}
    }
}

sub configure{
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_design_time = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: caller($i-1) == $package sub=$subroutine\n";
	last if $package eq 'Genesis2::UserConfigScript';
	if ($package eq 'Genesis2::UniqueModule' || $package eq 'Genesis2::Manager'){
	    print STDERR "\n\n";
	    confess colored("ERROR: Using ".__PACKAGE__." from design files is forbidden\n",'bold red on_black');
	}
    }
    
    Genesis2::ConfigHandler::configure(@_);
}
sub exists_configuration{
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_design_time = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: caller($i-1) == $package sub=$subroutine\n";
	last if $package eq 'Genesis2::UserConfigScript';
	if ($package eq 'Genesis2::UniqueModule' || $package eq 'Genesis2::Manager'){
	    print STDERR "\n\n";
	    confess colored("ERROR: Using ".__PACKAGE__." from design files is forbidden\n",'bold red on_black');
	}
    }
    
    return Genesis2::ConfigHandler::exists_configuration(@_);
}
sub remove_configuration{
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_design_time = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: caller($i-1) == $package sub=$subroutine\n";
	last if $package eq 'Genesis2::UserConfigScript';
	if ($package eq 'Genesis2::UniqueModule' || $package eq 'Genesis2::Manager'){
	    print STDERR "\n\n";
	    confess colored("ERROR: Using ".__PACKAGE__." from design files is forbidden\n",'bold red on_black');
	}
    }
    
    Genesis2::ConfigHandler::remove_configuration(@_);
}
sub get_configuration{
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_design_time = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: caller($i-1) == $package sub=$subroutine\n";
	last if $package eq 'Genesis2::UserConfigScript';
	if ($package eq 'Genesis2::UniqueModule' || $package eq 'Genesis2::Manager'){
	    print STDERR "\n\n";
	    confess colored("ERROR: Using ".__PACKAGE__." from design files is forbidden\n",'bold red on_black');
	}
    }
    
    return Genesis2::ConfigHandler::get_configuration(@_);
}

sub include{
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_design_time = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: caller($i-1) == $package sub=$subroutine\n";
	last if $package eq 'Genesis2::UserConfigScript';
	if ($package eq 'Genesis2::UniqueModule' || $package eq 'Genesis2::Manager'){
	    print STDERR "\n\n";
	    confess colored("ERROR: Using ".__PACKAGE__." from design files is forbidden\n",'bold red on_black');
	}
    }

    eval(Genesis2::ConfigHandler::read_cfg_file(@_)); 
    die \$@ if \$@;
    1;
}

sub print_configuration{
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_design_time = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: caller($i-1) == $package sub=$subroutine\n";
	last if $package eq 'Genesis2::UserConfigScript';
	if ($package eq 'Genesis2::UniqueModule' || $package eq 'Genesis2::Manager'){
	    print STDERR "\n\n";
	    confess colored("ERROR: Using ".__PACKAGE__." from design files is forbidden\n",'bold red on_black');
	}
    }

    Genesis2::ConfigHandler::print_configuration(); 
    1;
}

sub get_top_name{
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_design_time = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: caller($i-1) == $package sub=$subroutine\n";
	last if $package eq 'Genesis2::UserConfigScript';
	if ($package eq 'Genesis2::UniqueModule' || $package eq 'Genesis2::Manager'){
	    print STDERR "\n\n";
	    confess colored("ERROR: Using ".__PACKAGE__." from design files is forbidden\n",'bold red on_black');
	}
    }

    return Genesis2::ConfigHandler::get_top_name(); 
}
sub get_synthtop_path{
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_design_time = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: caller($i-1) == $package sub=$subroutine\n";
	last if $package eq 'Genesis2::UserConfigScript';
	if ($package eq 'Genesis2::UniqueModule' || $package eq 'Genesis2::Manager'){
	    print STDERR "\n\n";
	    confess colored("ERROR: Using ".__PACKAGE__." from design files is forbidden\n",'bold red on_black');
	}
    }

    return Genesis2::ConfigHandler::get_synthtop_path(); 
}


sub error{
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_design_time = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: caller($i-1) == $package sub=$subroutine\n";
	last if $package eq 'Genesis2::UserConfigScript';
	if ($package eq 'Genesis2::UniqueModule' || $package eq 'Genesis2::Manager'){
	    print STDERR "\n\n";
	    confess colored("ERROR: Using ".__PACKAGE__." from design files is forbidden\n",'bold red on_black');
	}
    }

    return Genesis2::ConfigHandler::user_error(@_); 
}

1;
