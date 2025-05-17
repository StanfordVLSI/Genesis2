# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/Genesis2Tools/PerlLibs/Genesis2/Manager.pm#6 $
# ** $DateTime: 2013/03/25 23:40:41 $
# ** $Change: 11789 $
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
######################### ACTUAL MANAGER CODE STARTS HERE ######################
################################################################################
package Genesis2::Manager;
use warnings;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

use Exporter;
use FileHandle;
use File::Basename;
use File::Copy;
use File::Spec::Functions;
use Getopt::Long;
use Pod::Usage;		# used for the fancy "-man" command line option
use Cwd;
use Cwd 'abs_path';
use Carp; $Carp::MaxArgLen =16; $Carp::MaxArgNums = 1;
use Env; # Make environment variables available
use Term::ANSIColor;
use File::Tee qw(tee);
use Genesis2::UniqueModule qw(get_unq_styles default_unq_style
                              str_to_unq_style);
#use IO::Tee; # Used to tee stderr to a file



@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw();
$VERSION = '1.0';

use Genesis2::ConfigHandler 1.00;

################################################################################
################################## Constructors ################################
################################################################################
sub new {
  my $package = shift;
  my $self = {};

  # Set up Defaults
  $self->{Package} = $package;		# keep this info for sub-pre-processors
  $self->{Top} = 'top';			# name of top module for generation phase
  $self->{SynthTop} = undef;		# name of synthesizable design top module for generation phase
  $self->{TopObj} = undef;		# Object of top module for generation phase
  $self->{CallDir} = cwd();		# Directory where the script was called from
  $self->{VersionInfoFileName} = 
      "$ENV{GENESIS_HOME}/Info/Genesis2.info"; # Information file on version, date, etc
  $self->{VersionInfo} = [];
  $self->{LicenseFileName} = 
      "$ENV{GENESIS_HOME}/Info/Genesis2.lic"; # License file
  $self->{LicenseInfo} = ["  Genesis2 is free software as governed by a BSD-style license,\n",
			  "  see LICENSE.txt for specific terms and conditions.\n"];

  $self->{OutputFileName} = 'STDOUT';	# Where to place the output
  $self->{OutfileHandle} = *STDOUT;
  $self->{LogFileName} = 'genesis.log'; # Name of log file for genesis2 and user stderr messages

  $self->{DependFileName} = undef;	# FileName for generating a depend file-list 
					# which is list of the input and included files
  $self->{DependHandle} = undef;	# File handle for the depend list file
  $self->{DependHistogram} = {};	# For each input file, how often was it used

  $self->{ProductFileName} = 'genesis_vlog.vf';	# filename for generating a product file-list 
					# which is a list of all the output files
  $self->{SynthProductFileName} = undef;# filename for generating a for-synthesis product file-list 
  $self->{VerifProductFileName} = undef;# filename for generating a for-verif only product file-list 
  
  $self->{CfgHandler} = undef;		# An agent to handle all parameters IO

  $self->{XmlOutFileName} = undef;	# filename for generating a hierarchy representation
  $self->{XmlInFileName} = undef;	# Input XML representation of parameters
  $self->{CfgInFileNames} = [];		# Input config file with more parameter definitions
  $self->{PrmOverrides} = [];		# List of parameter override defintions
  $self->{ConfigsPath} = [];		# Where to find config files (xml/scripts)

  $self->{InputFileLists} = [];		# this is a stack of files that contain names of files to process
  $self->{InputFileNames} = [];		# this is a stack of files to process
  $self->{SourcesPath} =[];		# shacham: Where to look for source files 
  $self->{IncludesPath} =[];		# Where to look for include files 

  $self->{PerlModules}=[];		# Perl Modules to load
  $self->{PerlLibs}=[];			# Perl Libs to load

  $self->{PrlEsc} = '//;';		# The Turn-to-Perl escape character
  $self->{LineComment} = '#';		# The Line Comment string in the target language (perl)
  $self->{Debug} = 0;			# The Debug value

  $self->{InfileSuffixes} = [".vp", ".svp", ".cp", ".tclp"];	# FileName suffix for input files
  $self->{CurInfileSuffix} = ".vp";   	# Default is the ".vp" extension 
  $self->{OutfileSuffix} = ".pm";	# FileName suffix for perl output files
  $self->{WorkDir} = "genesis_work";	# Where .pm files are placed
  $self->{RawDir} = "genesis_raw";	# Where verilog files are initially placed
  $self->{VerifDir} = "genesis_verif";	# Where generated verif files are placed
  $self->{SynthDir} = "genesis_synth";	# Where generated synth files are placed


  $self->{ModuleHead} = [];
  $self->{ModuleBody} = [];
  $self->{ModuleTail} = [];

  $self->{PRLESC} = quotemeta $self->{PrlEsc};

  $self->{UnqStyle} = undef;            # Module uniquification style
                                        # Use when 'generate' is called rather
                                        # than 'generate_unq_numeric' or
                                        # 'generate_unq_param'

  # what kind of work should we do?
  $self->{ParseMode} = 0;		# should we parse input file to generate perl modules?
  $self->{GenMode} = 0;			# should we generate a verilog hierarchy?
  
  # Bless this package
  bless ($self, $package) ;
}

################################################################################
##################################### API ######################################
################################################################################
sub execute{
  my $self = shift;
  my $name = __PACKAGE__."->execute";
  my @commandline = ($0 , @ARGV);
  
  # Parse the command line
  $self->parse_command_line();

  # Create a genesis_clean.cmd file
  $self->create_clean_file;

  # Print the command line you saw
  $self->print_cmdline(@commandline);

  # Make a log for stderr
  tee STDERR, ">> $self->{LogFileName}";

  print STDERR "\n";
  print STDERR "-----------------------------------------------\n" ;
  print STDERR "--- Genesis Is Starting Work On Your Design ---\n" ;
  print STDERR "-----------------------------------------------\n" ;
  
  if (-e $self->{VersionInfoFileName}){
      open(VERSION_INFO, $self->{VersionInfoFileName}); # Open the file
      @{$self->{VersionInfo}} = <VERSION_INFO>;		# Read it into an array
      print STDERR @{$self->{VersionInfo}};		# Print to screen/log
      close(VERSION_INFO);                      	# Close the file
  }else{
      $self->error("$name: Genesis Release Info Not Found\n");
  }
 
  # Check license
  $self->check_license() or $self->error("License Check Failed");

  # Some setting up of the engine
  $self->add_perl_libs;
  $self->add_perl_modules;

  #open statistics files if needed
  if ($self->{ParseMode} && defined $self->{DependFileName}){
    open($self->{DependHandle}, ">$self->{DependFileName}") || 
      $self->error("$name: Couldn't open file dependants list $self->{DependFileName}: $!");
  }

  ###########################################
  # The main dish: Parsing and Generating
  print STDERR "\n$name: Starting Source File Parsing Phase\n" if $self->{ParseMode};
  $self->parse_files if $self->{ParseMode};
  print STDERR "$name: Done With Source File Parsing Phase\n" if $self->{ParseMode};
  print STDERR "\n$name: Starting Verilog Code Generation Phase\n" if $self->{GenMode};
  $self->gen_verilog if $self->{GenMode};
  print STDERR "$name: Done With Verilog Code Generation Phase\n" if $self->{GenMode};
  ###########################################


  print STDERR "\n$name: Starting Auxiliary File Generation Phase\n";
  # print the product lists if needed
  if ($self->{GenMode}){
      $self->create_product_lists;
  }

  # print hierarchy if needed
  if ($self->{GenMode}){
      $self->{CfgHandler}->WriteXml();
      $self->{CfgHandler}->Finalize();
  }

  # Some cleanning up of the engine
  close $self->{DependHandle} if defined $self->{DependHandle};
  # Re-Create a genesis_clean.cmd file
  $self->create_clean_file;

  print STDERR "$name: Done With Auxiliary File Generation Phase\n\n";

  print STDERR "-----------------------------------------------\n" if $self->{GenMode};
  print STDERR "--- Genesis Finished Generating Your Design ---\n" if $self->{GenMode};
  print STDERR "-----------------------------------------------\n\n" if $self->{GenMode};

1;
}

################################################################################
################################### Options ####################################
################################################################################

sub usage {
  my $self = shift;
  my $unq_styles = join(' ', get_unq_styles());
  print <<END_OF_MESSAGE;
Usage:	
	$0 [-option value, ...]

Parsing Options:
	[-parse]			# should we parse input file to generate perl modules?
	[-sources|srcpath dir]		# Where to find source files
	[-includes|incpath dir]		# Where to find included files
	[-input file1 .. filen]		# List of files to process
        [-safe]                         # Enforce rule that relative-path files must exist in top-level dir
	[-inputlist filelist1 .. filelistn]	# List of files that each contain a list of files to process

Generating Options:
	[-generate]			# should we generate a verilog hierarchy?
	[-top topmodule]		# Name of top module to start generation from
	[-synthtop top.module.des_top]	# Name of top module for synthesis
	[-depend filename]		# Should Genesis2 generate a dependency file list? (list of input files)
	[-product filename]		# Should Genesis2 generate a product file list? (list of output files)
	[-hierarchy filename]		# Should Genesis2 generate a hierarchy representation tree?
        [-cfgpath|configs dir]		# Where to find config files (xml/scripts)
	[-xml filename]			# Input XML representation of definitions
	[-cfg filename]			# Input config file with more parameter definitions
	[-parameter path.to.param1=value1 .. path.to.other.param2=value2]
					# List of parameter override defintions

	[-unqstyle style]		# Preferred module uniquification style [$unq_styles]
Help and Debuging Options:
	[-log filename]			# Name of log file for genesis2 and user stderr messages
	[-debug level]			# Set debug level. Same as the inline debug directive.
	[-help]				# prints this message
	[-man [extenssion_name]]	# prints the complete man page for Genesis2 or the
					# specified extenssion (e.g. -man Verilog)

Auxiliary Options:
	[-perl_libs path] 		# Additional perl libraries locations (folders). 'path' can 
					# be absolute or relative.
	[-perl_modules path/name] 	# Additional perl modules to load. 'path' can be absolute 
					# or relative. Perl module 'name' is expected to be located 
					# in 'name.pm', and contain a package named 'name'.
	[-license file]			# Pointer to license file

END_OF_MESSAGE
1;
}

sub parse_command_line {
# Parse the command line using the Getopt::Long module
#
  my $self = shift;
  my $name = __PACKAGE__."->parse_command_line";
  my $help = 0;
  my $man;
  my %options =
    (
     "parse" => \$self->{ParseMode},			# should we parse input file to generate perl modules?
     "safe" => \$self->{SafeMode},			# should rel-path input file(s) be limited to top-level dir?
     "top=s" => \$self->{Top},				# name of top module for generation phase
     "synthtop=s" => \$self->{SynthTop},		# Name of top module for synthesis
     "generate" => \$self->{GenMode},			# should we generate a verilog hierarchy?
     "srcpath|sources=s@" => $self->{SourcesPath},	# Where to find source files
     "incpath|includes=s@" => $self->{IncludesPath},	# Where to find include files
     "input=s{,}" => $self->{InputFileNames},		# List of files to process
     "inputlist=s{,}" => $self->{InputFileLists},	# List of files that each contain a list of files to process
     "perl_modules=s@" => $self->{PerlModules},		# Additional Perl modules to load
     "perl_libs=s@" => $self->{PerlLibs},		# Additional Perl library locations
     "depend=s" => \$self->{DependFileName},		# Should Genesis2 generate a dependency list?

     "cfgpath|configs=s@" => $self->{ConfigsPath},	# Where to find config files (xml/scripts)
     "product=s" => \$self->{ProductFileName},		# Should Genesis2 generate a product file list? (list of output files)
     "hierarchy=s" => \$self->{XmlOutFileName},		# Should Genesis2 generate a hierarchy representation?
     "xml=s" => \$self->{XmlInFileName},		# Input XML representation of definitions
     "cfg=s{,}" => $self->{CfgInFileNames},		# Input config file with more parameter definitions
     "parameter=s{,}" => $self->{PrmOverrides},		# List of parameter override defintions
     "unqstyle=s" => \$self->{UnqStyle},                # Set preferred module uniquification style

     "log=s" => \$self->{LogFileName},			# Name of log file for genesis2 and user stderr messages
     "debug=i" => \$self->{Debug},			# Set the (initial) debug level
     "help" => \$help,					# prints this message
     "man:s" => \$man,					# prints the complete man page for Genesis2 
							# or the specified extenssion
     "license=s" => \$self->{LicenseFileName}		# Pointer to license file
    );

  my $res = GetOptions(%options);

  # Catch some common command line errors
  $self->error("$name: '-input' flag used but no input file specified") 
      if (scalar(@{$self->{InputFileNames}})==1 && ${$self->{InputFileNames}}[0] =~ /^\s*$/);
  $self->error("$name: '-inputlist' flag used but no inputlist file specified") 
      if (scalar(@{$self->{InputFileLists}})==1 && ${$self->{InputFileLists}}[0] =~ /^\s*$/);
  $self->error("$name: '-parameter' flag used but no parameter is specified") 
      if (scalar(@{$self->{PrmOverrides}})==1 && ${$self->{PrmOverrides}}[0] =~ /^\s*$/);

  $self->{UnqStyle} = default_unq_style() if !defined($self->{UnqStyle});
  my @unq_styles = get_unq_styles();
  $self->error("$name: Invalid module uniquification style specified: " .
      "'$self->{UnqStyle}'. Valid styles: " . join(', ', @unq_styles))
      if (!grep {$_ eq $self->{UnqStyle}} @unq_styles);

  # Special cases:
  $self->usage() if !$res || $help;
  exit 0 if $help;
  die "$@ $!" if !$res;

  if (defined $man){
      print STDERR "\n\n\t\tGENESIS MANUAL AVAILABLE AT URL: http://genesis2.stanford.edu \n\n";
  }
  1;
}

################################################################################
################################# Parsing Engine ###############################
################################################################################

# parse_files:
# parse_files iterates over all given input files to parse them and dump the
# coresponding perl module file
sub parse_files{
  my $self = shift;
  my $name = __PACKAGE__."->parse_files";
  my ($infile, $suffix, $target, $directories);
  local (*FILE);

  # First, process all the inputlist files
  if (scalar(@{$self->{InputFileLists}})) {
    $self->{UnprocessedInputLists} = [];
    $self->{ProcessedInputLists} = [];    # absolute paths of processed inputlists
                                          # to avoid processing the same inputlist twice

    @{$self->{UnprocessedInputLists}} = @{$self->{InputFileLists}};

    while (scalar(@{$self->{UnprocessedInputLists}})) {
      $self->parse_inputlist(shift @{$self->{UnprocessedInputLists}});
    }
  }

  # create and move into work directory
  unless (-e $self->{WorkDir} && -d $self->{WorkDir}) {
      mkdir $self->{WorkDir} or 
	  $self->error("Cannot find and cannot create work folder \"".$self->{WorkDir}."\"");
  }
  chdir $self->{WorkDir} or $self->error("Cannot cd into $self->{WorkDir}");
  
  # Now work those file baby
  foreach $infile (@{$self->{InputFileNames}}){
    # Don't re-parse files that have already been parsed.
    next if defined($self->{DependHistogram}{$infile});

    # Parse the file
    $self->parse_file_core($infile);
  }
  
  # move back to home folder
  chdir $self->{CallDir} or $self->error("Cannot cd back to $self->{CallDir} from $self->{WorkDir}");

  1;
}

## parse_unprocessed_file:
## parse_unprocessed_file parses a single file and dumps the coresponding perl
## module file only if the file has not been parsed yet.
sub parse_unprocessed_file {
  my $self = shift;
  my $infile = shift;
  my $name = __PACKAGE__."->parse_unprocessed_file";

  # Don't re-parse files that have already been parsed.
  return if defined($self->{DependHistogram}{$infile});

  # create and move into work directory
  unless (-e $self->{WorkDir} && -d $self->{WorkDir}) {
      mkdir $self->{WorkDir} or
	  $self->error("Cannot find and cannot create work folder \"".$self->{WorkDir}."\"");
  }
  chdir $self->{WorkDir} or $self->error("Cannot cd into $self->{WorkDir}");

  $self->parse_file_core($infile);

  # move back to home folder
  chdir $self->{CallDir} or $self->error("Cannot cd back to $self->{CallDir} from $self->{WorkDir}");

  1;
}

# parse_file_core:
# parse_file_core parses a file and dumps the coresponding perl
# module file. Used by both parse_files and parse_unprocessed_file.
sub parse_file_core{
  my $self = shift;
  my $infile = shift;
  my $name = __PACKAGE__."->parse_file_core";

  $self->{ModuleHead} = [];
  $self->{ModuleBody} = [];
  $self->{ModuleTail} = [];
  print STDERR "$name: Now parsing file $infile\n";

  # make an output file
  my ($target, $directories) = fileparse($infile);
  foreach my $suffix (@{$self->{InfileSuffixes}}) {
      $self->{CurInfileSuffix} = $suffix;
      last if ($target =~ s/\Q$suffix\E$//); # remove the input suffix
  }
  $self->{OutputFileName} = $target . $self->{OutfileSuffix};
  $self->{OutfileHandle} = new FileHandle;
  open($self->{OutfileHandle}, ">$self->{OutputFileName}") ||
    $self->error("$name: Couldn't open output file $self->{OutputFileName}: $!");

  # save the name for your records
  if (defined $self->{DependHistogram}{$infile}){
    $self->{DependHistogram}{$infile} = $self->{DependHistogram}{$infile}+1
  }else{
    print {$self->{DependHandle}} "src $infile\n" if defined $self->{DependHandle};
    $self->{DependHistogram}{$infile} = 1;
  }

  #initialize output file
  $self->init_perl_module($target);

  # parse the input
  $self->parse_file($infile, $self->{SourcesPath}, "src");

  # finalize output file
  $self->finish_perl_module;

  # clean up
  close($self->{OutfileHandle});

  1;
}

## Parse an inputlist file.
##
## inputlist file can contain -incpath, -srcpath, -input, and -inputlist
## commands, in addition to files to process.
##
## Args: inputlist filename (string)
## Returns: none
## Modifies: $self->{InputFileLists}
##           $self->{InputFileNames}
##           $self->{SourcesPath}
##           $self->{IncludesPath}
sub parse_inputlist{
    my $self = shift;
    my $filename = shift;

    my $name = __PACKAGE__."->parse_inputlist";

    my ($infile, $suffix, $target, $directories);

    print STDERR "--- Processing inputlist file $filename...\n"
        if $self->{Debug};

    # Check whether we've already processed this file
    my $il_path = abs_path($filename);
    foreach my $p (@{$self->{ProcessedInputLists}}) {
        if ($il_path eq $p) {
            print STDERR "   --- Info: Already processed $il_path; skipping.\n"
                if $self->{Debug};
            return;
        }
    }
    push @{$self->{ProcessedInputLists}}, $il_path;

    # Save current directory for this file so that we can
    # use it for subsequent files and directories.

    my $dir = dirname($il_path);

    my $IL_FILE;
    open $IL_FILE, '<', $il_path or
        $self->error("$name: Cannot open inputlist file '$il_path'. $!\n");

    my $line;
    while ($line = <$IL_FILE>) {
        # Strip comments and trailing whitespace
        $line =~ s/#.*//;
        chomp $line;

        next if $line eq "";

        $line =~ s/^\s+//;

        # Match command with args: -cmd <arg1> <arg2> ...
        if ($line =~ m{^(-\w+)\s+(.*)}) { # -cmd <file or dir list>
            my $cmd = $1;
            my @paths = split ' ', $2;


            # Convert relative paths to absolute paths and expand env vars
            my @new_paths = ();
            foreach my $path (@paths) {
                my $orig = $path;

                # Expand environment variables
                while ($path =~ m/\$\{?(\w+)\}?/) {
                    my $env_var = $1;
                    if (defined $ENV{$env_var}) {
                        $path =~ s/\$\{?(\w+)\}?/$ENV{$env_var}/e;
                    } else {
                        print STDERR "   --- WARNING: ignoring path $orig: " .
                            "environment var $env_var is undefined " .
                            "at $il_path:$.\n";
                        next;
                    }
                }

                # Prepend current directory if path is not absolute
                if (!file_name_is_absolute($path)) {
                    $path = catfile($dir, $path);
                }

                # Convert to an absolute path
                my $abspath = abs_path($path);
                if (!$abspath) {
                    print STDERR "   --- WARNING: ignoring path $path " .
                        "(derived from $orig): non-existent path on " .
                        "$il_path:$.\n";
                    next;
                }
                push @new_paths, $abspath;
            }
            @paths = @new_paths;

            if ($cmd eq '-input' or $cmd eq '-inputlist' or
                $cmd eq '-incpath' or $cmd eq '-srcpath') {
                my ($var, $comment, $addUnprocInputLists);
                $addUnprocInputLists = 0;
                if ($cmd eq '-input') {
                    $var = 'InputFileNames';
                    $comment = 'file';
                } elsif ($cmd eq '-inputlist') {
                    $var = 'InputFileLists';
                    $comment = 'inputlist';
                    $addUnprocInputLists = 1;
                } elsif ($cmd eq '-incpath') {
                    $var = 'IncludesPath';
                    $comment = 'incpath';
                } elsif ($cmd eq '-srcpath') {
                    $var = 'SourcesPath';
                    $comment = 'srcpath';
                }
                foreach my $file (@paths) {
                    push @{$self->{$var}}, $file;
                    print STDERR "   --- adding $comment $file.\n"
                        if ($self->{Debug});
                    push @{$self->{UnprocessedInputLists}}, $file
                        if $addUnprocInputLists;

                }
            }
        }

        # Match file names (no leading hyphen)
        elsif ($line =~ m{^([^-][^\s]*)$}) {
            push @{$self->{InputFileNames}}, $1;
            print STDERR "   --- adding file $1.\n" if ($self->{Debug});
            next LINE;
        }

        else {
            $self->error("$name: Syntax error in file $il_path at line $.\n");
        }
    }
    close $IL_FILE;

    1;
}

## include:
## include is likely to be called by the user from the vp files.
## Otherwise, it is identical to parse_file.
sub include{
  my $self = shift;
  my $infile = shift;

  # save the name for your records
  if (defined $self->{DependHistogram}{$infile}){
    $self->{DependHistogram}{$infile} = $self->{DependHistogram}{$infile}+1
  }else{
    print {$self->{DependHandle}} "inc $infile\n" if defined $self->{DependHandle};
    $self->{DependHistogram}{$infile} = 1;
  }
  $self->parse_file($infile, $self->{IncludesPath}, "inc");
}


## parse_file:
## Main engine that parse VerilogPerl (.vp) files into PerlModule (.pm) files
sub parse_file{
  my $self = shift;
  local $Genesis2::Manager::infile = shift;
  my $path = shift;
  my $what = shift;
  my ($out, $perl_mode, $i, $char, $next_char);
  local $Genesis2::Manager::inline;
  my $name = __PACKAGE__."->parse_file";
  local(*FILE);

  print STDERR "$name: Starting work on file $Genesis2::Manager::infile\n" if $self->{Debug};
  # search directories for the input file and open it
  $Genesis2::Manager::infile = $self->find_file($Genesis2::Manager::infile, $path);
  open(FILE, $Genesis2::Manager::infile) ||
    $self->error("$name: Cannot open input file $Genesis2::Manager::infile: $!\n");

  # For the main file, also add an header
  if ($what =~ /src/i){
      push @{$self->{ModuleBody}}, 
      "	\$self->SUPER::to_verilog(\'$Genesis2::Manager::infile\');\n";
  }elsif($what =~ /inc/i){
      push @{$self->{ModuleBody}},
      "print { \$Genesis2::UniqueModule::myself->{OutfileHandle} } \"\$self->{LineComment} ----- Start Include Of $Genesis2::Manager::infile -----\\n\"; \n";
  }
 
  # Cheat the interpreter error reports about line number and file
  push (@{$self->{ModuleBody}}, "# START USER CODE FROM $Genesis2::Manager::infile PARSED INTO PACKAGE >>>\n");
  push (@{$self->{ModuleBody}}, "# line 1 \"$Genesis2::Manager::infile\"\n");

  # Now process the file
  my $line = '';
  while ($line = <FILE>) {
    $Genesis2::Manager::inline = $.;
    my $orig_line = $line;
    my $veri_macro = '';
    my $warn = undef;


    # first we put a few hooks to catch intersting events that need more handling
    # perl lines
    if ($line =~ m/^\s*$self->{PRLESC}/) {
      $line =~ s/^(\s*)$self->{PRLESC}/$1/g; # we keep the spaces to allow nicer indentation

      if ($line =~ m/^\s*include\s*\(/) {
	$line = "\$self->".$line;
	if (! eval $line) {
	  $self->error("$name: \"$Genesis2::Manager::infile\", line $Genesis2::Manager::inline: include failed\n");
	}
	push (@{$self->{ModuleBody}}, "# line ".($Genesis2::Manager::inline+1)." \"$Genesis2::Manager::infile\"\n");
      }
      else {
	push (@{$self->{ModuleBody}}, $line);
      }
    }

    # text lines (potentially with perl escapes)
    else {
      chomp($line);       $out = "";      $perl_mode = 0;
      if ($Genesis2::Manager::inline % 10 == 0 && $self->{Debug}) {
	$out = qq/print { \$Genesis2::UniqueModule::myself->{OutfileHandle} } "\$Genesis2::UniqueModule::myself->{LineComment} From $Genesis2::Manager::infile line $Genesis2::Manager::inline\\n"; \n/;
      }
      $out .= qq/print { \$Genesis2::UniqueModule::myself->{OutfileHandle} } \'/;

      # allow the special verilog compile time `timescale/`default_nettype/`include thingies
      # (and remove it from the line)
      if ($line =~ s/^(\s*\/?\/?)(\s*`)(timescale|default_nettype|include) //){ #`
	$veri_macro = $1.$2.$3." ";
	$out .= $veri_macro;
      }
      # allow the special verilog compile time uvm (universal verif methodology) thingies
      # (and remove it from the line)
      if ($line =~ s/^(\s*\/?\/?)(\s*`)(uvm_)//){ 
	$veri_macro = $1.$2.$3;
	$out .= $veri_macro;
      }


      for ($i = 0; $i < length($line); $i++) {
	$char = substr($line, $i, 1);
	$next_char = '';
	$next_char = substr($line, $i+1, 1) if ($i+1<length($line));
	if ($char.$next_char eq '\`'){ # i.e., user is escaping the back-tick
	    $out .= $next_char;
	    $i++;
	    $warn = "You are using an old Verilog style macro. This is not safe and thus highly unrecommended.\n".
		"\t\t---> You should be using Genesis2 parameters instead"
		unless $perl_mode;
	} elsif ($char eq "`") {
	  # toggle perl mode and text mode
	  $out .= $perl_mode ? "; print { \$Genesis2::UniqueModule::myself->{OutfileHandle} } '" : "'; print { \$Genesis2::UniqueModule::myself->{OutfileHandle} } ";
	  $perl_mode = ! $perl_mode;
	} else {
	  # keep the character, but need to quote it in text mode
	  if (! $perl_mode && ($char eq "'" || $char eq "\\")) {
	      $char = "\\$char";
	  }
	  $out .= $char;
	}
      }
      $out .= $perl_mode ? ";" : "';";
      if ($perl_mode) {
	$self->error("$name: Missing closing ' (back-tic):\n".
		     "In Code: ". $orig_line) if ($veri_macro eq '');
	$self->error("$name: Missing closing ' (back-tic).\n".
		     "In Code: ". $orig_line .
		     "Note that this line started with a macro definition $veri_macro so first back-tick was ignored") 
	    if ($veri_macro ne '');
      }

      if (defined $warn){
	  print STDERR "WARNING: Line ${Genesis2::Manager::inline}, of File $Genesis2::Manager::infile \n". 
	      "WARNING: $warn\n" if defined $warn;
	  #$warn = qq/print { \$Genesis2::UniqueModule::myself->{OutfileHandle} } \"\\n\\nWARNING: In This File: $warn \\n\\n\"; \n/;
	  #unshift (@{$self->{ModuleBody}}, $warn);
      }
      $out .= qq/print { \$Genesis2::UniqueModule::myself->{OutfileHandle} } "\\n"; \n/;
      push (@{$self->{ModuleBody}}, $out);
    }
  }

  push (@{$self->{ModuleBody}}, "# <<< END USER CODE FROM ".$Genesis2::Manager::infile." PARSED INTO PACKAGE\n\n\n");
  if($what =~ /inc/i){
      push @{$self->{ModuleBody}},
      "print { \$Genesis2::UniqueModule::myself->{OutfileHandle} } \"\$self->{LineComment} ----- End Include Of $Genesis2::Manager::infile -----\\n\"; \n";
  }
  close FILE;
  1;
}
sub init_perl_module{
  my $self = shift;
  my $target = shift;
  my $orig_suffix = $self->{CurInfileSuffix};
  my $final_suffix = $orig_suffix;
  $final_suffix =~ s/p$//; # remove the 'p' from .vp or .svp
  push @{$self->{ModuleHead}}, "package $target;\n";
  push @{$self->{ModuleHead}}, <<END_OF_HEADER;
use strict;
use vars qw(\$VERSION \@ISA \@EXPORT \@EXPORT_OK);

use Exporter;
use FileHandle;
use Env; # Make environment variables available


use Genesis2::Manager 1.00;
use Genesis2::UniqueModule 1.00;

\@ISA = qw(Exporter Genesis2::UniqueModule);
\@EXPORT = qw();
\@EXPORT_OK = qw();
\$VERSION = '1.0';
sub get_SrcSuffix {Genesis2::UniqueModule::private_to_me(); return "$orig_suffix";};
sub get_OutfileSuffix {Genesis2::UniqueModule::private_to_me(); return "$final_suffix"};
############################### Module Starts Here ###########################


END_OF_HEADER
  1;
}

sub finish_perl_module{
  my $self = shift;

  # Create the top of the to_verilog method
  unshift @{$self->{ModuleBody}}, <<END_OF_TO_VERILOG_PREFIX;
  sub to_verilog{ 
      # START PRE-GENERATED TO_VERILOG PREFIX CODE >>>
      my \$self = shift;
      
      print STDERR \"\$self->{BaseModuleName}->to_verilog: Start user code\\n\" 
	  if \$self->{Debug} & 8;
      # <<< END PRE-GENERATED TO_VERILOG PREFIX CODE
END_OF_TO_VERILOG_PREFIX


  push @{$self->{ModuleBody}}, <<END_OF_TO_VERILOG_SUFFIX;
      # START PRE-GENERATED TO_VERILOG SUFFIX CODE >>>
      print STDERR \"\$self->{BaseModuleName}->to_verilog: Done with user code\\n\" 
	  if \$self->{Debug} & 8;

      #
      # clean up code comes here...
      #
      # <<< END PRE-GENERATED TO_VERILOG SUFFIX CODE
  }
END_OF_TO_VERILOG_SUFFIX

  print { $self->{OutfileHandle} } @{$self->{ModuleHead}};
  print { $self->{OutfileHandle} } @{$self->{ModuleBody}};
  print { $self->{OutfileHandle} } @{$self->{ModuleTail}};

  1;
}


################################################################################
########################### Generating Verilog Engine###########################
################################################################################
sub gen_verilog{
  my $self = shift;
  my $name = __PACKAGE__."->gen_verilog";
  my $module = $self->{Top};
  my $filename;
  print STDERR "$name: Starting code generation from module $module\n" if $self->{Debug};
  $filename = $module . $self->{OutfileSuffix};

  # create generated verilog directory
  unless (-e $self->{RawDir} && -d $self->{RawDir}) {
      mkdir $self->{RawDir} or 
	  $self->error("Cannot find and cannot create folder for generated (raw) verilog files: \"".$self->{RawDir}."\"");
  }

  # Now import the top module
  if ($INC{$filename}) {
  } 
  else{
      eval {require $filename};
      # Check for errors
      if ($@){
	  my @errs = split(/\n/, $@);
	  # remove the last line of $@ it will always point to UniqueModule.pm 
	  pop(@errs) if scalar(@errs)>1;
	  my $err_msg = join("\n",@errs);
	  $self->error("$name: Cannot locate/compile module \"${filename}\".\n".
		       "Error Message: $err_msg");
      }
      $module->import();
  }

  # Instantiate a ConfigHandler
  $self->{CfgHandler} = new Genesis2::ConfigHandler($self);
  $self->{CfgHandler}->SetDebugLevel($self->{Debug});
  $self->{CfgHandler}->SetConfigsPath($self->{ConfigsPath});
  $self->{CfgHandler}->SetXmlInFileName($self->{XmlInFileName});
  $self->{CfgHandler}->SetXmlOutFileName($self->{XmlOutFileName});
  $self->{CfgHandler}->SetCfgInFileNames($self->{CfgInFileNames});

  # Read the input xml file if needed 
  $self->{CfgHandler}->ReadCfg();
  $self->{CfgHandler}->ReadXml();
  $self->{CfgHandler}->SetPrmOverrides($self->{PrmOverrides});

  # Set some back and forth pointers
  $self->{TopObj} = $module->new($self);
  $self->{CfgHandler}->SetTopObj($self->{TopObj});
  $self->{CfgHandler}->SetUnqStyle(str_to_unq_style($self->{UnqStyle}));

  # Start working from the top level
  print STDERR "$name: Starting code generation from module $module\n";
  $self->{TopObj}->execute;

  1;
}

################################################################################
############################## Auxiliary Functions##############################
################################################################################

## find_file_safe:
## This function receives a file name and a search path and returns
## the absolute file name if found. Error and die otherwise.
## Usage: $self->find_file(file_name, path_by_ref=[])
sub find_file_safe{
  my $self = shift;
  my $file = shift;
  my $name = __PACKAGE__."->find_file_safe";
  my $path = [];
  my ($dir, $filefound);
  if (@_){
    $path = shift;
  }

  # find the file:
  $filefound = 0;
  print STDERR "$name: Searching path '$self->{CallDir}:@$path' for file '$file'\n" if $self->{Debug} & 8;
  if ($file =~ /^\//) {
    # file is absolute path
    $filefound = 1 if (-e $file);
  }else {
    foreach $dir ($self->{CallDir}, @{$path}) {
	# if relative path, start it from the dir from which the script was called
	unless ($dir =~ /^\//) { $dir = $self->{CallDir}."/".$dir;}
        print STDERR "$name: Searching in dir '$dir'\n" if $self->{Debug} & 8;

	$filefound = 1 if (-e "${dir}/${file}");
	if ($filefound) {
	    # Change file path so it is now absolute.
	    $file = "${dir}/${file}";
	    last; # got one, so exit the loop
	}
    }
  }

  $file = abs_path($file) if $filefound;
  print "$name: found source: $file\n" if ($filefound && ($self->{Debug} & 2));
  $self->error("$name: Can not find file $file \n Search Path: @{$path}") unless $filefound;
  return $file;
}

## find_file:
## This function receives a file name and a search path and returns
## the absolute file name if found. Error and die otherwise.
## Usage: $self->find_file(file_name, path_by_ref=[])
sub find_file{
  my $self = shift;
  my $file = shift;
  my $name = __PACKAGE__."->find_file";
  my $path = [];
  if (@_){
    $path = shift;
  }
  my $filefound = $self->find_file_safe($file, $path);
  $self->error("$name: Can not find file $file \n Search Path: @{$path}") unless defined $filefound;
  return $filefound;
}


## add_suffix:
## Add one of the infile suffixes to the file name to match a file in the
## search path. No suffix is added if the file name already matches an existing
## file.
## Usage: $self->add_suffix(file_name)
sub add_suffix{
  my $self = shift;
  my $file = shift;
  my $name = __PACKAGE__."->add_suffix";

  # "No suffix is added if the file name already matches an existing file"
  my $foundfile = $self->find_file($file, $self->{SourcesPath});
  if (defined $foundfile) {
    return $file;
  }

  # Note this only works in safe mode i.e. only finds top-level files :(
  foreach my $suffix ('', @{$self->{InfileSuffixes}}) {
    my $file_w_suffix = $file . $suffix;
    my $foundfile = $self->find_file_safe($file_w_suffix, $self->{SourcesPath});
    if (defined $foundfile) {
      return $file_w_suffix;
    }
  }
  $self->error("$name: Can not find suffix for file $file\n" .
               "Search path: @{$self->{SourcesPath}}");
  return undef;
}


## sub error
## usage: $self->error("error message");
sub error {
  my $self = shift;
  my $message= shift;
  my @message_arr = ();
  my $prefix=''; my $prefix0=''; my $prefix1=''; my $prefix2=''; my $perlmsg=''; my $suffix1='';

  # add a tab before the message:
  $prefix0 = "ERROR    ERROR    ERROR    ERROR    ERROR    ERROR    ERROR    ERROR\n";
  $prefix1 = "Genesis2::Manager ERROR in Line $Genesis2::Manager::inline of File $Genesis2::Manager::infile\n"
      if $Genesis2::Manager::inline || $Genesis2::Manager::infile;
  $prefix2 = "ERROR Message:\n";
  $suffix1 = "Exiting Genesis2 due to fatal error... bye bye... \n";


  $prefix = $prefix0.$prefix1.$prefix2;

  #print to file as well as to stderr
  print "\n".$prefix."\n";

  @message_arr = split(/\n/, $message);
  map {print "\t".$_."\n"} @message_arr; # print to file
  print "\n".$suffix1; 

  print STDERR "\n".$prefix."\n";
  map {my @tokens = split(//,$_);
       my $len = scalar(@tokens);
       my $space = '';
       $space = ' ' x (80-$len) if $len<80; 
       print STDERR "\t"; 
       print STDERR colored ($_ . $space,'bold red on_black'); 
       print STDERR "\n"; 
      } @message_arr; # print stderr

  # print suffix and call stack
  confess "\n".$suffix1."\nFull Call Stack" if $self->{Debug}; # will append the file and line number + stack
  print STDERR "\n".$suffix1; exit 7;
#-------------
#
#  $message = $prefix0. $prefix1.$prefix2.$message.$suffix1;
#
#  #print to stdout as well as to stderr
#  print "\n".$message;
#  confess "\n".$message."\nFull Call Stack" if $self->{Debug}; # will append the file and line number + stack
#  print STDERR "\n".$message."\n"; exit 7;; # die will append the file and line number
}



## sub add_perl_modules
## If any modules are specified on the command line, load them dynamically.
sub add_perl_modules {
  my $self = shift;
  my $name = __PACKAGE__."->add_perl_modules";
  caller eq __PACKAGE__ or $self->error("$name: Call to a private method is not allowed");
  my $module;
  my $filename;
  foreach my $item (@{$self->{PerlModules}}) {
    $module = $item;
    $filename = $module;
    $filename .= ".pm" unless $filename =~ m/\.pm$/; # add the .pm suffix to the module name
    next if $INC{$filename};
    eval {require $filename};
    # Check for errors
    if ($@){
	my @errs = split(/\n/, $@);
	# remove the last line of $@ it will always point to UniqueModule.pm 
	pop(@errs) if scalar(@errs)>1;
	  my $err_msg = join("\n",@errs);
	$self->error("$name: Cannot locate/compile module \"${filename}\".\n".
		     "Error Message: $err_msg");
    }
    $module =~ s/(\.pm)$//; # getting rid of the .pm suffix if existed
    $module =~ s/^(.*\/)//g; # getting rid of the /path/to/pkg/loc if existed
    push(@Genesis2::UniqueModule::ISA, $module); # push it to the base template class ISA
    #$module->import();
  }
  1;
}


## sub add_perl_libs
## If any library locations are specified on the command line, load them dynamically.
sub add_perl_libs{
    my $self = shift;
    my $name = __PACKAGE__."->add_perl_libs";
    caller eq __PACKAGE__ or $self->error("$name: Call to a private method is not allowed");
    # Add the work dir and user specified libs locations to the include path
    require lib; lib->import( $self->{WorkDir}, @{$self->{PerlLibs}} );
}


## sub create_product_lists
## Traverse the hierarchy, separate verif and synth files, and create the product lists
sub create_product_lists{
    my $self = shift;
    my $name = __PACKAGE__."->create_product_lists";
    caller eq __PACKAGE__ or $self->error("$name: Call to a private method is not allowed ".caller);
    
    # Any reason to be here?
    return unless ($self->{GenMode} && defined $self->{ProductFileName});
    
    # Open product files
    my $product_fh;
    my $synth_product_fh;
    my $verif_product_fh;
    open($product_fh, ">$self->{ProductFileName}") || 
	$self->error("$name: Couldn't open product list file $self->{ProductFileName}: $!");
    
    # for synth
    $self->{SynthProductFileName} = $self->{ProductFileName};
    if ($self->{SynthProductFileName} =~ s/(\.[^\.]*)$/.synth/){# replace file extenssion with .synth
	$self->{SynthProductFileName} .= $1;			# add original file extenssion
    }else{
	$self->{SynthProductFileName} .= '.synth';		# no file extenssion found -> add .synth suffix
    }
    open($synth_product_fh, ">$self->{SynthProductFileName}") || 
	$self->error("$name: Couldn't open synthesis product list file $self->{SynthProductFileName}: $!");

    # for verif
    $self->{VerifProductFileName} = $self->{ProductFileName};
    if ($self->{VerifProductFileName} =~ s/(\.[^\.]*)$/.verif/){# replace file extenssion with .verif
	$self->{VerifProductFileName} .= $1;			# add original file extenssion
    }else{
	$self->{VerifProductFileName} .= '.verif';		# no file extenssion found -> add .verif suffix
    }
    open($verif_product_fh, ">$self->{VerifProductFileName}") || 
	$self->error("$name: Couldn't open verifesis product list file $self->{VerifProductFileName}: $!");
    
    # Add product dirs to incdir lists
    #print { $product_fh } "+incdir+".$self->{SynthDir}." +incdir+".$self->{VerifDir}."\n";
    #print { $synth_product_fh } "+incdir+".$self->{SynthDir}."\n";

    # Get a list of all instances in REVERSED DFS order
    my @rev_dfs_list = $self->{TopObj}->search_subinst(Reverse=>1);

    # Process the list into synth and verif single appearance file list
    my %seen = ();
    my @product_list = ();
    foreach my $inst (@rev_dfs_list){
	my $path = $inst->get_instance_path();
	my $file = $inst->get_out_file_name();
	my $type = 'verif';
	if ( defined $self->{SynthTop} && 
	     ($path eq $self->{SynthTop} || $path =~ /^$self->{SynthTop}\./)
	    ){
	    $type = 'synth';
	}
	# if this file is first seen then add to the list and put the verif/synth tag
	if (!defined $seen{$file}){
	    push(@product_list, $file);
	    $seen{$file} = $type;
	}
	# if this file was previously seen we might need to add a tag
	elsif ($seen{$file} ne $type){
	    $seen{$file} = 'synth_and_verif';
	}
    }

    # Create verif and synth folders for generated verilog
    unless (-e $self->{VerifDir} && -d $self->{VerifDir}) {
	mkdir $self->{VerifDir} or 
	    $self->error("Cannot find and cannot create folder for generated (verif) verilog files: \"".$self->{VerifDir}."\"");
    }
    unless (-e $self->{SynthDir} && -d $self->{SynthDir}) {
	mkdir $self->{SynthDir} or 
	    $self->error("Cannot find and cannot create folder for generated (synth) verilog files: \"".$self->{SynthDir}."\"");
    }

    # Move files to final location; Print the  file lists
    foreach my $file (@product_list){
	if ($seen{$file} eq 'verif'){
            print STDERR "Move $file from $self->{RawDir} to $self->{VerifDir}\n" if \$self->{Debug} & 8;
	    move(catfile($self->{RawDir}, $file), catfile($self->{VerifDir},$file)) or
		$self->error("$name: Couldn't move $file from $self->{RawDir} to $self->{VerifDir}");
	    print { $product_fh } catfile($self->{VerifDir},$file)."\n";
	    print { $verif_product_fh } catfile($self->{VerifDir},$file)."\n";
	}else{
            print STDERR "Move $file from $self->{RawDir} to $self->{SynthDir}\n" if \$self->{Debug} & 8;
	    move(catfile($self->{RawDir}, $file), catfile($self->{SynthDir},$file)) or
		$self->error("$name: Couldn't move $file from $self->{RawDir} to $self->{SynthDir}");
	    print { $product_fh } catfile($self->{SynthDir},$file)."\n";
	    print { $synth_product_fh } catfile($self->{SynthDir},$file)."\n";
	    print { $verif_product_fh } catfile($self->{SynthDir},$file)."\n" if ($seen{$file} eq 'synth_and_verif');
	}
    }

  close $product_fh if defined $product_fh;
  close $synth_product_fh if defined $synth_product_fh;
  close $verif_product_fh if defined $synth_product_fh;

}


## create_clean_file
## protected subroutine that generates a file with shell commands for cleaning that run
sub create_clean_file{
  my $self = shift;
  my $name = __PACKAGE__."->create_clean_file";
  caller eq __PACKAGE__ or $self->error("$name: Call to a private method is not allowed ".caller);
  my $cfh;
  
  # open file
  open($cfh, ">genesis_clean.cmd") or
      $self->error("$name: Couldn't open file genesis_clean.cmd: $!");

  if ($self->{ParseMode} && defined $self->{DependFileName}){
      print {$cfh} "\\rm -f $self->{DependFileName};\n";
  }
  print {$cfh} "\\rm -rf $self->{LogFileName};\n";
  print {$cfh} "\\rm -rf $self->{WorkDir};\n";
  print {$cfh} "\\rm -rf $self->{RawDir};\n";
  print {$cfh} "\\rm -rf $self->{VerifDir};\n";
  print {$cfh} "\\rm -rf $self->{SynthDir};\n";
  print {$cfh} "\\rm -f $self->{XmlOutFileName} small_$self->{XmlOutFileName} tiny_$self->{XmlOutFileName};\n"
      if ($self->{GenMode} && defined $self->{XmlOutFileName});
  print {$cfh} "\\rm -f $self->{ProductFileName};\n" 
      if ($self->{GenMode} && defined $self->{ProductFileName});
  print {$cfh} "\\rm -f $self->{SynthProductFileName};\n" 
      if ($self->{GenMode} && defined $self->{SynthProductFileName});
  print {$cfh} "\\rm -f $self->{VerifProductFileName};\n" 
      if ($self->{GenMode} && defined $self->{VerifProductFileName});
  
  # remove self
  print {$cfh} "\\rm -f genesis_clean.cmd;\n";

  # make the file executable
  my $perm = (stat $cfh)[2] & 07777;
  chmod ($perm | 0700, $cfh);
  
  # close file
  close $cfh;
}


## create_clean_file
## pretty print of the command line used to invoke genesis
sub print_cmdline {
  my $self = shift;
  my @commandline = @_;
  my $name = __PACKAGE__."->print_cmdline";
  caller eq __PACKAGE__ or $self->error("$name: Call to a private method is not allowed ".caller);

  open(LOG, "> $self->{LogFileName}");
  print LOG "\n$name: Your Complete Genesis2 Command Line:\n";

  my $cnt = 0;
  foreach my $token (@commandline){
      if ($cnt==0 || ($cnt+length($token)<100 && $token !~ /^-\w+/)){
	  print LOG $token.' ';
	  $cnt += length($token)+1;
      }else{
	  print LOG ' ' x (100-$cnt) if 100-$cnt>0;
	  print LOG "\\\n";
	  print LOG "    " if ($token =~ /^-\w+/);
	  print LOG "        " if ($token !~ /^-\w+/);
	  print LOG $token.' ';
	  $cnt = length($token)+1;
	  $cnt += 4;
	  $cnt += 4 if ($token !~ /^-\w+/);
      }
  }
  print LOG "\n";
  close (LOG);
}

sub check_license{
    my $self = shift;
    if (-e $self->{LicenseFileName}){
	open(LICENSE_INFO, $self->{LicenseFileName}); 	# Open the file
	@{$self->{LicenseInfo}} = <LICENSE_INFO>;	# Read it into an array
	close(LICENSE_INFO);                      	# Close the file
    }
    print STDERR "---------------------------------------------------------------------------\n";
    print STDERR "  ".join("  ",@{$self->{LicenseInfo}});	# Print to screen/log
    print STDERR "---------------------------------------------------------------------------\n";
    1;
}

1;
