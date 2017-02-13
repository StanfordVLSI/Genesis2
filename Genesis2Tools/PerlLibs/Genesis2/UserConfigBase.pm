# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/Genesis2Tools/PerlLibs/Genesis2/UserConfigBase.pm#4 $
# ** $DateTime: 2013/01/31 00:27:30 $
# ** $Change: 11627 $
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
