# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/Genesis2Tools/PerlLibs/Genesis2/UniqueModule.pm#5 $
# ** $DateTime: 2013/03/25 01:30:27 $
# ** $Change: 11788 $
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
######################### ACTUAL MANAGER CODE STARTS HERE ##########################
################################################################################
package Genesis2::UniqueModule;
use warnings;
use strict;
use 5.010;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use Carp qw(carp cluck confess croak); $Carp::MaxArgLen =16; $Carp::MaxArgNums = 1;
use Exporter;
use Cwd 'abs_path';
use File::Copy;
use File::Spec::Functions;
use List::Util qw(min max);

use FileHandle;
use Env; # Make environment variables available
use constant {
	GENESIS2_ZERO_PRIORITY => 0,
	GENESIS2_DECLARATION_PRIORITY => 1,
	GENESIS2_EXTERNAL_CONFIG_PRIORITY => 2,
	GENESIS2_EXTERNAL_XML_PRIORITY => 3,
	GENESIS2_CMD_LINE_PRIORITY => 4,
	GENESIS2_INHERITANCE_PRIORITY => 5,
	GENESIS2_IMMUTABLE_PRIORITY => 6,

      };

# OS: I admit, this is kind of ugly:
use constant GENESIS2_PRIORITY =>  qw(_GENESIS2_ZERO_PRIORITY_
				      _GENESIS2_DECLARATION_PRIORITY_
				      _GENESIS2_EXTERNAL_CONFIG_PRIORITY_
				      _GENESIS2_EXTERNAL_XML_PRIORITY_
				      _GENESIS2_CMD_LINE_PRIORITY_
				      _GENESIS2_INHERITANCE_PRIORITY_
				      _GENESIS2_IMMUTABLE_PRIORITY_
				     );


#use Time::HiRes;
use Term::ANSIColor;

@ISA = qw(Exporter);
@EXPORT = qw(mname iname bname sname generate generate_base generate_w_name
             generate_unq_numeric generate_unq_param
             clone parameter synonym error warning
            );
@EXPORT_OK = qw(GENESIS2_ZERO_PRIORITY 
		GENESIS2_DECLARATION_PRIORITY 
		GENESIS2_EXTERNAL_CONFIG_PRIORITY
		GENESIS2_EXTERNAL_XML_PRIORITY
		GENESIS2_CMD_LINE_PRIORITY
		GENESIS2_INHERITANCE_PRIORITY
		GENESIS2_IMMUTABLE_PRIORITY
                get_unq_styles
                default_unq_style
                str_to_unq_style
               );
$VERSION = '1.0';

use Genesis2::Manager;# 1.00;

use constant {
    PARAM_UNQ_STR => '_PARAM_UNQ',
    DEFAULT_UNQ_STYLE => 'param',
};

# Uniquification styles
#  - numeric: add a unique number to the end of the module name
#  - param: concatenate the parameters to the module name
use constant {
    GENESIS2_UNQ_NUMERIC => 0,
    GENESIS2_UNQ_PARAM => 1,
};

my %UNQ_STYLES = (
    'numeric' => GENESIS2_UNQ_NUMERIC,
    'param' => GENESIS2_UNQ_PARAM,
);


################################################################################
################################## Constructors ################################
################################################################################

## new:
## Main constructor for the Genesis2::UniqueModule class
sub new {
  my $package = shift;
  my $manager = shift;
  my $self = {};
  caller eq "Genesis2::Manager"
    or die("$package->new: Default constructor must only be caled by a Genesis2::Manager");

  # Set up Defaults
  $self->{Manager} = $manager;			# This is the Genesis Manager
  $self->{VersionInfo} = $manager->{VersionInfo};# Information file on version, date, etc
  $self->{LicenseInfo} = $manager->{LicenseInfo};# License information or educational use
  $self->{RawDir} = $manager->{RawDir};		# Where verilog files are initially placed
  $self->{BaseModuleName} = $package;		# keep this info for sub-pre-processors
  $self->{Parent} = undef;		
  $self->{Top} = $self;		
  $self->{InstanceName} = $package;		# default instance name	
  $self->{UniqueModuleName} = $package;		# default uniquified name
  $self->{CloneOf} = undef;			# If cloned, where from?
  $self->{SynonymFor} = $package->get_SynonymFor; # If synonym, what is the (absolute) source?
  $self->{InstancePath} = undef;                # Path to this instance (set by get_instance_path)


  $self->{CfgHandler} = $manager->{CfgHandler};		# An agent to handle all parameters IO


  $self->{Debug} = $manager->{Debug};			# The Debug value
  $self->{SrcSuffix} = $package->get_SrcSuffix;		# FileName suffix for input Genesis code
  $self->{InfileSuffix} = ".pm";			# FileName suffix for input perl modules
  $self->{OutfileSuffix} = $package->get_OutfileSuffix;	# FileName suffix for verilog output files


  $self->{OutputFileName} = $manager->{Top}.$self->{OutfileSuffix};	# Where to place the output
  $self->{OutfileHandle} = undef;


  $self->{LineComment} = '//';		# The Line Comment string for the target language (verilog)
  $self->{PrlEsc} = '//;';		# The Turn-to-Perl escape character


  # These hashes hold the non-unique modules, unique modules, instances and keys.
  # IMPORTANT: Note that each genesis2 instance has a local list of instances but all 
  # genesis instances share the list of modules
  $self->{SubInstance_InstanceObj} = {};# instance name => Instance Object (local to this engine!)
  $self->{SubInstanceList} = [];        # List of sub instances in order of creation
  $self->{ModuleName_NumDerivs} = {};	# non-unique module => count (global across engines!)
  $self->{UnUniquifiedModules} = {$package=>$self};	# modules that were generated WITHOUT uniquification (global across engines!)
  $self->{OutfileName_ContentCache} = {}; # Outfilename => cache of txt content for the file (global across engines!)
  $self->{Parameters} = {};		# All the parameters used by this module
  $self->{ParametersList} = [];         # List of Parameters in order of creation
  $self->{ParametersPriority} = GENESIS2_DECLARATION_PRIORITY;
  $self->{ParamsFromXML} = {};		# All parameters read from xml input file
  $self->{ParamsFromCfg} = {};		# All parameters read from config input file
  $self->{ParamsFromCmdLn} = {}; 	# All parameters read from the command line
  
  # Bless this package
  bless ($self, $package) ;
}


## private new_as_son:
## This is the hierarchical constructor to create a new module in the hierarchy
## Usage: $new_inst = $package_name->new_as_son($parent);
sub new_as_son {
  my $package = shift;
  my $parent = shift;
  my $self = {};
  caller eq __PACKAGE__ or
    die("$package->new_as_son: Call to a base class private method is not allowed");

  # Set up Defaults
  $self->{Manager} = $parent->{Manager};	# This is the Genesis Manager
  $self->{VersionInfo} = $parent->{VersionInfo};# Information file on version, date, etc
  $self->{LicenseInfo} = $parent->{LicenseInfo};# License information or educational use
  $self->{RawDir} = $parent->{RawDir};		# Where verilog files are initially placed
  $self->{BaseModuleName} = $package;		# keep this info for sub-pre-processors
  $self->{Parent} = $parent;		
  $self->{Top} = $parent->{Top};		
  $self->{InstanceName} = $package;		# default instance name	
  $self->{UniqueModuleName} = undef;		
  $self->{CloneOf} = undef;				# If you used this C'tor, it is not a clone
  $self->{SynonymFor} = $package->get_SynonymFor;	# If synonym, what is the (absolute) source?
  my $tmp = $self->{SynonymFor};
  while (defined $tmp){
      $self->{SynonymFor} = $tmp;
      $tmp = $tmp->get_SynonymFor();
  }
  $self->{InstancePath} = undef;                        # Path to this instance (set by get_instance_path)

  $self->{OutputFileName} = undef;			# Where to place the output
  $self->{OutfileHandle} = undef;


  $self->{CfgHandler} = $parent->{CfgHandler};			# An agent to handle all parameters IO


  $self->{Debug} = $parent->{Debug};				# The Debug value
  $self->{SrcSuffix} = $package->get_SrcSuffix;			# FileName suffix for input Genesis code
  $self->{InfileSuffix} = $parent->{InfileSuffix};		# FileName suffix for input files
  $self->{OutfileSuffix} = $package->get_OutfileSuffix;		# FileName suffix for verilog output files


  $self->{LineComment} = $parent->{LineComment};		# The Line Comment string
  $self->{PrlEsc} = $parent->{PrlEsc};				# The Turn-to-Perl escape character


  # These hashes hold the non-unique modules, unique modules, instances and keys.
  # IMPORTANT: Note that each genesis2 instance has a local list of instances but all 
  # genesis instances share the list of modules
  $self->{SubInstance_InstanceObj} = {};	# start with empty list	
  $self->{SubInstanceList} = [];        # List of sub instances in order of creation
  $self->{ModuleName_NumDerivs} = $parent->{ModuleName_NumDerivs} ; # (reference)
  $self->{UnUniquifiedModules} = $parent->{UnUniquifiedModules}; # (reference)
  $self->{OutfileName_ContentCache} = $parent->{OutfileName_ContentCache}; # (reference)
  $self->{Parameters} = {};		# All the parameters used by this module
  $self->{ParametersList} = [];         # List of Parameters in order of creation
  $self->{ParametersPriority} = GENESIS2_DECLARATION_PRIORITY;
  $self->{ParamsFromXML} = {};		# All parameters read from xml input file
  $self->{ParamsFromCfg} = {};		# All parameters read from config input file
  $self->{ParamsFromCmdLn} = {}; 	# All parameters read from the command line

  # Bless this package
  bless ($self, $package) ;
}


## private new_as_clone:
## This is the copy constructor to create a new module in based on an existing one
## Usage: $new_inst = $package_name->new_as_clone($parent, $src_inst)
sub new_as_clone {
  my $package = shift;
  my $parent = shift;
  my $src_inst = shift;

  my $self = {};
  caller eq __PACKAGE__ or
    die("$package->new_as_clone: Call to a base class private method is not allowed");

  # Set up Defaults
  $self->{Manager} = $src_inst->{Manager};	# This is the Genesis Manager
  $self->{VersionInfo} = $src_inst->{VersionInfo};# Information file on version, date, etc
  $self->{LicenseInfo} = $src_inst->{LicenseInfo};# License information or educational use
  $self->{RawDir} = $src_inst->{RawDir};	# Where verilog files are initially placed
  $self->{BaseModuleName} = $package;		# keep this info for sub-pre-processors
  $self->{Parent} = $parent;		
  $self->{Top} = $src_inst->{Top};		
  $self->{InstanceName} = $package;		# default instance name	
  $self->{UniqueModuleName} = $src_inst->get_module_name;		
  $self->{CloneOf} = $src_inst;
  $self->{SynonymFor} = $src_inst->{SynonymFor};# If synonym, what is the (absolute) source?
  $self->{InstancePath} = undef;                # Path to this instance (set by get_instance_path)

  $self->{OutputFileName} = $src_inst->{OutputFileName};		# Where the output WAS placed
  $self->{OutfileHandle} = $src_inst->{OutfileHandle};


  $self->{CfgHandler} = $parent->{CfgHandler};			# An agent to handle all parameters IO


  $self->{Debug} = $src_inst->{Debug};				# The Debug value
  $self->{SrcSuffix} = $src_inst->{SrcSuffix};			# FileName suffix for input Genesis code
  $self->{InfileSuffix} = $src_inst->{InfileSuffix};		# FileName suffix for input files
  $self->{OutfileSuffix} = $src_inst->{OutfileSuffix};	# FileName suffix for verilog output files


  $self->{LineComment} = $src_inst->{LineComment};		# The Line Comment string
  $self->{PrlEsc} = $src_inst->{PrlEsc};			# The Turn-to-Perl escape character


  # These hashes hold the non-unique modules, unique modules, instances and keys.
  # IMPORTANT: Note that each genesis2 instance has a local list of instances but all 
  # genesis instances share the list of modules
  $self->{SubInstance_InstanceObj} = $src_inst->{SubInstance_InstanceObj}; # This is a clone: Point to source's list
  $self->{SubInstanceList} = $src_inst->{SubInstanceList};                 # This is a clone: Point to source's list
  $self->{ModuleName_NumDerivs} = $src_inst->{ModuleName_NumDerivs}; # (reference)
  $self->{UnUniquifiedModules} = $src_inst->{UnUniquifiedModules}; # (reference)
  $self->{OutfileName_ContentCache} = $src_inst->{OutfileName_ContentCache}; # (reference)
  $self->{Parameters} = $src_inst->{Parameters};		# This is a clone: Point to source's list
  $self->{ParametersList} = $src_inst->{ParametersList};	# This is a clone: Point to source's list
  $self->{ParametersPriority} = GENESIS2_ZERO_PRIORITY;		# This is a clone: no params changes allowed
  $self->{ParamsFromXML} = {};		# All parameters read from xml input file
  $self->{ParamsFromCfg} = {};		# All parameters read from config input file
  $self->{ParamsFromCmdLn} = {}; 	# All parameters read from the command line

  # Bless this package
  bless ($self, $package) ;
}

################################################################################
################################## MAIN API ####################################
################################################################################
## sub get_parent
## Usage: my $parent_module = $self->get_parent();
sub get_parent{
  my $self = shift;
  return $self->{Parent};
}

## sub get_top
## Usage: my $top_module = $self->get_top();
sub get_top{
  my $self = shift;
  my $top = $self;
  while (defined $top->get_parent()){
      $top = $top->get_parent();
  }
  return $top;
}

## sub get_instance_name
## Usage: my $inst_name = $self->get_instance_name();
sub get_instance_name{
  my $self = shift;
  return $self->{InstanceName};
}

## sub get_module_name
## Usage: my $module_name = $self->get_module_name();
sub get_module_name{
  my $self = shift;
  return $self->{UniqueModuleName};
}

## sub get_base_name
## Usage: my $base_module_name = $self->get_base_name();
sub get_base_name{
  my $self = shift;
  return $self->{BaseModuleName};
}

## sub get_source_name
## Usage: my $source_name = $self->get_source_name();
sub get_source_name{
  my $self = shift;
  return $self->{SynonymFor} if defined $self->{SynonymFor};
  return $self->{BaseModuleName};
}


## sub define_param
## API method for defining a new parameter
## Usage: my $val = $self->define_param(prm_name => prm_val);
## Usage: my $val = $self->define_param(prm_name , prm_val);
sub define_param{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->define_param";
  my %prm_hash;
  my ($key, $val, $pri, $str);

  if (scalar(@_) == 1){
    $key = shift;
    $prm_hash{$key} = $val;
  }elsif (scalar(@_) == 2){
    $key = shift;
    $val = shift;
    $prm_hash{$key} = $val;
  }else{
    $self->error("$name: Method accept EXACTLY one parameter definition per invocation");
  }
  # check for common errors
  $self->error("$name: Parameter name definition must be a simple string!") 
      if ref($key) ne '';
  $self->error("$name: Missing parameter name definition!") 
      if $key eq '';

  # put the param in the params db
  $self->set_param(%prm_hash);

  # Check for additional input from config file
  if (exists $self->{ParamsFromCfg}->{$key}){
      my $prev_priority = $self->{ParametersPriority};
      $self->{ParametersPriority} = GENESIS2_EXTERNAL_CONFIG_PRIORITY;
      $prm_hash{$key} = $self->{CfgHandler}->GetCfgParamVal($self->{ParamsFromCfg}->{$key},
							    $self->get_instance_path);
      $self->set_param(%prm_hash);
      $self->{ParametersPriority} = $prev_priority;
  }

  # Check for additional input from XML
  if (exists $self->{ParamsFromXML}->{$key}){
      my $prev_priority = $self->{ParametersPriority};
      $self->{ParametersPriority} = GENESIS2_EXTERNAL_XML_PRIORITY;
      $prm_hash{$key} = $self->{CfgHandler}->GetXmlParamVal($self->{ParamsFromXML}->{$key},
							 $self->get_instance_path.':Parameters:ParamItem('.$key.')');
      $self->set_param(%prm_hash);
      $self->{ParametersPriority} = $prev_priority;
  }

  # Check for additional input from command line
  if (exists $self->{ParamsFromCmdLn}->{$key}){
      my $prev_priority = $self->{ParametersPriority};
      $self->{ParametersPriority} = GENESIS2_CMD_LINE_PRIORITY;
      $prm_hash{$key} = $self->{CfgHandler}->GetCmdLnParamVal($self->{ParamsFromCmdLn}->{$key},
							      $self->get_instance_path);
      $self->set_param(%prm_hash);
      $self->{ParametersPriority} = $prev_priority;
  }

  # keep record of the parameter being used
  $self->{Parameters}->{$key}->{State} = 'Used';

  # read the final value and print to screen
  $val = $self->internal_get_param($key);
  $str = $self->{CfgHandler}->PrintToString($val, depth=>1, prefix=>"$self->{LineComment}\t");
  $pri = $self->get_param_priority($key);
  print { $self->{OutfileHandle} }  $self->{LineComment}.
    " $key (".(GENESIS2_PRIORITY)[$pri].") = ".$str."\n$self->{LineComment}\n";

      # return the parameter value
  return $self->internal_get_param($key);
}

## sub define_param_array
## API method for defining a new parameter ARRAY
## Usage: my $val = $self->define_param_array(prm_name => [prm_val1, prm_val2, ...]);
## Usage: my $val = $self->define_param_array(prm_name , [prm_val1, prm_val2, ...]);
sub define_param_array{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->define_param_array";
  my $ret = $self->define_param(@_);
  if (ref($ret) ne 'ARRAY'){
    return [$ret];
  }else{
    return $ret;
  }
}


## sub force_param
## API method for defining an IMMUTABLE parameter
## Usage: my $val = $self->force_param(prm_name => prm_val);
## Usage: my $val = $self->force_param(prm_name , prm_val);
sub force_param{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->force_param";
  my $ret;
  if ($self->{ParametersPriority} == GENESIS2_DECLARATION_PRIORITY){
    $self->{ParametersPriority} = GENESIS2_IMMUTABLE_PRIORITY;
    $ret = $self->define_param(@_);
    $self->{ParametersPriority} = GENESIS2_DECLARATION_PRIORITY;
  }else{
    $self->error("$name: Method only allowed within its own module declaration");
  }
  return $ret;
}



## exists_param
## API method for checking whether a parameter exists in a module
## Usage: my $exists = $self->exists_param(prm_name);
sub exists_param{
  my $self = shift;
  my $name =  $self->{BaseModuleName}."->exists_param";
  my ($prm_name);

  if (@_){
    $prm_name = shift;
  }else{
    $self->error("$name: Missing parameter name");
  }
  return 1 if defined $self->{Parameters}->{$prm_name} && $self->{Parameters}->{$prm_name}->{State} eq 'Used';
  return 0;
}


## list_params
## API method for extracting a list of params defined in a module
## Usage: my $list = $self->list_params();
sub list_params{
  my $self = shift;
  my $name =  $self->{BaseModuleName}."->list_params";
  my @prms = keys (%{$self->{Parameters}});
  return @prms;
}



## get_param
## API method for extracting parameters' value
## Usage: my $val = $self->get_param(prm_name);
sub get_param{
  my $self = shift;
  my $name =  $self->{BaseModuleName}."->get_param";
  my ($prm_name, $prm_val);

  if (@_){
    $prm_name = shift;
  }else{
    $self->error("$name: Missing parameter name");
  }

  # extract the parameter
  $prm_val = $self->internal_get_param($prm_name, check_used=>1);
  
#  # keep record that it is actually used
#  if ($self->{Parameters}->{$prm_name}->{State} eq 'CreatedNeverUsed') {
#      $self->{Parameters}->{$prm_name}->{State} = "UsedByOthers"; # first usage
#  }

  return $prm_val;
}


## get_top_param
## API method for extracting parameters' value from the top module
## Usage: my $val = $self->get_top_param(prm_name);
sub get_top_param{
  my $self = shift;
  return $self->{Top}->get_param(@_);
}

## doc_param
## API method for associating a short documentation message to a parameter
## Usage: $self->doc_param(prm_name, "message")
sub doc_param{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->doc_param";
  my $prm_name = shift or $self->error("$name: Missing argument(s).\n".
				       "Usage: \$self->doc_param(prm_name, \"message\")");
  my $msg = shift or $self->error("$name: Missing argument(s).\n".
				  "Usage: \$self->doc_param(prm_name, \"message\"");
  $self->("$name: Ilegal message. Message must be simple string or scalar.\n".
	  "Usage: \$self->doc_param(prm_name, \"message\"")      
      if (ref($msg) ne '');
  $self->error("$name: Cannot add documentation to un-existing parameter: $prm_name.\n".
	       "Perhaps you need to first call \$self->define_param($prm_name=>default_value)")
      if (! defined $self->{Parameters}->{$prm_name});
  $self->warning("$name: Re-documentation of parameter $prm_name. Overwriting!")
      if (defined $self->{Parameters}->{$prm_name}->{Doc});
  $self->{Parameters}->{$prm_name}->{Doc} = $msg;
  1;
}

## param_range
## API method for associating an allowed range to a parameter
## Usage: $self->param(prm_name, [min=>?, max=>?, step=>?] | [list=>[item, item, ...]]);
sub param_range{
    my $self = shift;
    my $name = $self->{BaseModuleName}."->param_range";
    my $usage = "Usage: \$self->param(prm_name, [min=>?, max=>?, step=>?] | [list=>[item, item, ...]]);";
    my $prm_name = shift or $self->error("$name: Missing argument(s).\n".
					 "Usage: \$self->param(prm_name, [min=>?, max=>?, step=>?] | [list=>[item, item, ...]])");
    $self->error("$name: Cannot add range to un-existing parameter: $prm_name.\n".
		 "Perhaps you need to first call \$self->define_param($prm_name=>default_value)")
	if (! defined $self->{Parameters}->{$prm_name});
    $self->error("$name: Re-definition of range for parameter $prm_name!")
	if (defined $self->{Parameters}->{$prm_name}->{Range});
    my $prm_val = $self->internal_get_param($prm_name);
#my @dbg = keys %{$prm_val};
#print STDERR "DEBUG: $prm_val, ".ref($prm_val). ", @dbg\n";
    my %rules = @_;
    
    $self->error("$name: Range is not yet supported for data structures or pointers. Only numbers and strings allowed!")
	unless ref($prm_val) eq '';
    
    # First we extract the information
    foreach my $rule (keys %rules){
	if ($rule =~ m/^list$/i) {
	    $self->{Parameters}->{$prm_name}->{Range}->{List} = $rules{$rule};
	}elsif ($rule =~ m/^min$/i) {
	    $self->{Parameters}->{$prm_name}->{Range}->{Min}=$rules{$rule};
	}elsif ($rule =~ m/^max$/i) {
	    $self->{Parameters}->{$prm_name}->{Range}->{Max}=$rules{$rule};
	}elsif ($rule =~ m/^step$/i) {
	    $self->{Parameters}->{$prm_name}->{Range}->{Step}=$rules{$rule};
	}else{
	    $self->error("$name: Illegal range rule \'$rule\'!\n".$usage);
	}
    }
    
    # Now check for legal combinations
    # 1. List and min/max/step are mutually exclusive
    if (defined $self->{Parameters}->{$prm_name}->{Range}->{List}){
	foreach my $rule ('Min','Max','Step'){
	    $self->error("$name: Parameter=$prm_name: Range rule \'$rule\' not allowed in combination with \'List\'!\n".$usage)
		if defined $self->{Parameters}->{$prm_name}->{Range}->{$rule};
	}
    }
    # 2. Step only makes sense if min or max are defined and step!=0
    if (defined $self->{Parameters}->{$prm_name}->{Range}->{Step}){
	$self->error("$name: Parameter=$prm_name: Range rule \'Step' not allowed unless in combination with \'Min\' or \'Max\'!\n".$usage)
	    unless (defined $self->{Parameters}->{$prm_name}->{Range}->{Min} ||
		    defined $self->{Parameters}->{$prm_name}->{Range}->{Max});
	$self->error("$name: Range rule \'Step' of size zero not allowed!\n".$usage)
	    unless ($self->{Parameters}->{$prm_name}->{Range}->{Step} != 0);
    }
    # 3. min < max
    if (defined $self->{Parameters}->{$prm_name}->{Range}->{Min} && 
	defined $self->{Parameters}->{$prm_name}->{Range}->{Max}){
	$self->error("$name: Parameter=$prm_name: Range rule \'Min\'=$self->{Parameters}->{$prm_name}->{Range}->{Min} ".
		     "must be less then range rule \'Max\'=$self->{Parameters}->{$prm_name}->{Range}->{Max}!\n".
		     $usage) 
	    unless $self->{Parameters}->{$prm_name}->{Range}->{Min} <= $self->{Parameters}->{$prm_name}->{Range}->{Max};
    }
    # 4. (max-min)/step = integer
    if (defined $self->{Parameters}->{$prm_name}->{Range}->{Step} &&
	defined $self->{Parameters}->{$prm_name}->{Range}->{Min}  && 
	defined $self->{Parameters}->{$prm_name}->{Range}->{Max}){
	my $diff = $self->{Parameters}->{$prm_name}->{Range}->{Max} - $self->{Parameters}->{$prm_name}->{Range}->{Min};
	my $steps = $diff / $self->{Parameters}->{$prm_name}->{Range}->{Step};
	$self->error("$name: Parameter=$prm_name: Range rule \'Max\'=$self->{Parameters}->{$prm_name}->{Range}->{Max} ".
		     "not an integer number of \'Steps\'=$self->{Parameters}->{$prm_name}->{Range}->{Step} ".
		     "away from \'Min\'=$self->{Parameters}->{$prm_name}->{Range}->{Min}!\n".$usage)
	    unless ($steps == int($steps));
    }
	
    
    # Now check for legal range
    # 1. List
    if (defined $self->{Parameters}->{$prm_name}->{Range}->{List}){
	my $valid = 0;
	foreach my $item (@{$self->{Parameters}->{$prm_name}->{Range}->{List}}){
	    if ($prm_val eq $item){
		$valid = 1;
		last;
	    }
	}
	$self->error("$name: Range check failed. Parameter $prm_name=$prm_val ".
		     "not in specified list range!\n".
		     "List=@{$self->{Parameters}->{$prm_name}->{Range}->{List}}")
	    unless $valid == 1;
    }
    # 2. Min
    if (defined $self->{Parameters}->{$prm_name}->{Range}->{Min}){
	$self->error("$name: Range check failed. Parameter $prm_name=$prm_val not greater than or equal ".
		     "to Min=$self->{Parameters}->{$prm_name}->{Range}->{Min} range!")
	    unless ($prm_val >= $self->{Parameters}->{$prm_name}->{Range}->{Min});
    }
    # 3. Max
    if (defined $self->{Parameters}->{$prm_name}->{Range}->{Max}){
	$self->error("$name: Range check failed. Parameter $prm_name=$prm_val not less than or equal ".
		     "to Max=$self->{Parameters}->{$prm_name}->{Range}->{Max} range!")
	    unless ($prm_val <= $self->{Parameters}->{$prm_name}->{Range}->{Max});
    }
    # 4. Step
    if (defined $self->{Parameters}->{$prm_name}->{Range}->{Step}){
	if (defined $self->{Parameters}->{$prm_name}->{Range}->{Min}){
	    my $diff = $prm_val - $self->{Parameters}->{$prm_name}->{Range}->{Min};
	    my $steps = $diff / $self->{Parameters}->{$prm_name}->{Range}->{Step};
	    $self->error("$name: Range check failed. Parameter $prm_name=$prm_val not an integer of ".
			 "Steps=$self->{Parameters}->{$prm_name}->{Range}->{Step} from ".
			 "Min=$self->{Parameters}->{$prm_name}->{Range}->{Min} range!")
		unless ($steps == int($steps));
	}elsif(defined $self->{Parameters}->{$prm_name}->{Range}->{Max}){
	    my $diff = $self->{Parameters}->{$prm_name}->{Range}->{Max} - $prm_val;
	    my $steps = $diff / $self->{Parameters}->{$prm_name}->{Range}->{Step};
	    $self->error("$name: Range check failed. Parameter $prm_name=$prm_val not an integer of ".
			 "Steps=$self->{Parameters}->{$prm_name}->{Range}->{Step} from ".
			 "Max=$self->{Parameters}->{$prm_name}->{Range}->{Max} range!")
		unless ($steps == int($steps));
	}
    }
    1;
}

## optimize_param
## API method for telling external tools that this parameter should (not) be optimized
## Usage: $self->optimize_param(prm_name, "Yes"/"No"/"try")
sub optimize_param{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->optimize_param";
  my $prm_name = shift or $self->error("$name: Missing argument(s).\n".
				       "Usage: \$self->optimize_param(prm_name, \"Yes/No/Try\")");
  my $opt = shift or $self->error("$name: Missing argument(s).\n".
				  "Usage: \$self->argument_param(prm_name, \"Yes/No/Try\"");
  $self->("$name: Ilegal value. Value must be simple Yes/No/Try string.\n".
	  "Usage: \$self->argument_param(prm_name, \"Yes/No/Try\"")
      if (ref($opt) ne '');
  $self->error("$name: Cannot add optimization attributes to un-existing parameter: $prm_name.\n".
	       "Perhaps you need to first call \$self->define_param($prm_name=>default_value)")
      if (! defined $self->{Parameters}->{$prm_name});
  $self->error("$name: Illegal value '$opt'. Allowed values are 'Yes', 'No', 'Try'") unless $opt =~ m/^(yes|no|try)$/i;

  $self->error("$name: Re-assignment of optimization attributes for parameter $prm_name is not allowed.")
      if (defined $self->{Parameters}->{$prm_name}->{Opt});
  $self->{Parameters}->{$prm_name}->{Opt} = 'Yes' if $opt =~ /yes/i;
  $self->{Parameters}->{$prm_name}->{Opt} = 'No' if $opt =~ /no/i;
  $self->{Parameters}->{$prm_name}->{Opt} = 'Try' if $opt =~ /try/i;
  1;
}

## get_subinst
## API method for getting a handle to a sub instance object
## Usage: my $subinst = $self->get_subinst('subinst_name');
sub get_subinst{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->get_subinst";
  my $inst_name = shift or $self->error("$name: Missing argument for instance name to lookup");
  my $inst;
  if (defined $self->{SubInstance_InstanceObj}{$inst_name}) {
     $inst = $self->{SubInstance_InstanceObj}{$inst_name};
  } else {
     $self->error("$name: ".caller()."->Could not find subinst $inst_name in ".$self->{BaseModuleName}.
                    " using get_subinst");
  }
  return $inst;
}


## exists_subinst
## API method for checking if a sub instance object exists
## Usage: my $subinst = $self->exists_subinst('subinst_name');
sub exists_subinst{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->exists_subinst";
  my $inst_name = shift or $self->error("$name:Missing argument for instance name to lookup");
  return (defined $self->{SubInstance_InstanceObj}{$inst_name})?1:0;
}

## search_subinst
## API method for searching the entire design hierarchy or portions of it
## according to user defined criteria
## Usage: $subinst_arr = $anyObj->search_subinst(From=>$ObjToStartFrom/'path.to.objToStartFrom', 
##						 Depth=>HowDeepToSearch, 
##						 PathRegex=>Path.to.Inst, INameRegex=>InstanceName, 
##						 MNameRegex=>ModuleName, BNameRegex=>BaseModuleName, 
##						 SNameRegex=>SourceTemplateName, HasParamRegex=>ParamName, 
##						 ApplyMap=>\&func
##						 Reverse=>0/1);
sub search_subinst{
    my $self = shift;
    my $name = $self->{BaseModuleName}."->search_subinst";
    my %options = @_;
    my @keys = keys %options;
    my @results = ();
    my $from = $self->get_top();
    my $depth = 10000;
    my $reverse = 0;
    
    # get the starting point
    foreach my $key (@keys){
	if ($key =~ m/^From$/i){
	    $from = $self->get_instance_obj($options{$key});
	    delete $options{$key};
	}elsif($key =~ m/^Depth$/i){
	    $depth = $options{$key};
	    delete $options{$key};	    
	}elsif($key =~ m/^Reverse$/i){
	    $reverse = $options{$key};
	    delete $options{$key};	    
	}
    }

    # get the complete list of subinsts from $from up to depth $depth
    if ($depth>=0 && !$reverse){ # DFS
	push (@results, $from);
    }
    if ($depth>=1){
	my @subinsts = $from->get_subinst_array();
	foreach my $subinst (@subinsts){
	    my @subresults = $subinst->search_subinst(From=>$subinst, Depth=>($depth-1), Reverse=>$reverse);
	    push (@results, @subresults);
	}
    } 
    if ($depth>=0 && $reverse){ # Reverse DFS
	push (@results, $from);
    }
    
    # test for instances that don't meet the user criterias
    @keys = keys %options; # Take the keys that were not deleted
    foreach my $key (@keys){   
	if($key =~ m/^PathRegex$/i){
	    my $regex = $options{$key};
	    @results = grep {my $subinst = $_; 
			     my $property = $subinst->get_instance_path();
			     my $ret = ($property =~ m/$regex/ || $regex eq '')? 1:0;
			     $ret;
	    } @results;
	}
	elsif($key =~ m/^INameRegex$/i){
	    my $regex = $options{$key};
	    @results = grep {my $subinst = $_; 
			      my $property = $subinst->iname();
			      my $ret = ($property =~ m/$regex/ || $regex eq '')? 1:0;
			      $ret;
	    } @results;
	}
	elsif($key =~ m/^MNameRegex$/i){
	    my $regex = $options{$key};
	    @results = grep {my $subinst = $_; 
			     my $property = $subinst->mname();
			     my $ret = ($property =~ m/$regex/ || $regex eq '')? 1:0;
			     $ret;
	    } @results;
	}
	elsif($key =~ m/^BNameRegex$/i){
	    my $regex = $options{$key};
	    @results = grep {my $subinst = $_; 
			     my $property = $subinst->bname();
			     my $ret = ($property =~ m/$regex/ || $regex eq '')? 1:0;
			     $ret;
	    } @results;
	}
	elsif($key =~ m/^SNameRegex$/i){
	    my $regex = $options{$key};
	    @results = grep {my $subinst = $_; 
			     my $property = $subinst->sname();
			     my $ret = ($property =~ m/$regex/ || $regex eq '')? 1:0;
			     $ret;
	    } @results;
	}
	elsif($key =~ m/^HasParamRegex$/i){
	    my @regexs = ();
	    if (ref($options{$key}) eq 'ARRAY'){
		# array of regex
		@regexs = @{$options{$key}};
	    }elsif(ref($options{$key}) eq ''){
		# make it look like an array of regex of size 1
		$regexs[0] = $options{$key};
	    }else{
		$self->error("$name: Expected type for HasParamRegex option must be a string or an array of strings reference. Found: $options{$key} \n");
	    }
	    foreach my $regex (@regexs){
		@results = grep {my $subinst = $_; 
				 my @params = $subinst->list_params();
				 my $regex_found = grep {m/$regex/ || $regex eq ''} @params;
				 my $ret = ($regex_found>0)? 1:0;
				 $ret;
		} @results;
	    }
	}
	elsif($key =~ m/^ApplyMap$/i){
	    my $func;
	    if (ref($options{$key}) eq 'CODE'){
		# this is a function pointer
		$func = $options{$key};
	    }else{
		$self->error("$name: Expected type for ApplyMap option must be a function pointer. Found: ".ref($options{$key})." \n");
	    }
	    @results = grep {&$func($_);} @results;
	}
	else{
	    $self->error("$name: Illegal option flag '$key'. Did you have a typo?");
	}
    }
    return @results;
}


## get_subinst_array
## API method for getting a handle to an array of sub instance objects
## that match the subinst_pattern
## Usage: my $subinst = $self->get_subinst_array('subinst_pattern');
sub get_subinst_array{
  my $self = shift;
  my $inst_pattern = ''; # default to match anything
  $inst_pattern = shift if @_; # check for user specified pattern
  my $name = $self->{BaseModuleName}."->get_subinst_array";
  my @inst_array=();
  foreach my $inst_name (@{$self->{SubInstanceList}}){
     if ($inst_name=~/$inst_pattern/ || $inst_pattern eq ''){
        push (@inst_array, $self->get_subinst($inst_name));
     }
  }
  return @inst_array;
}

## get_instance_path
## API method that returns a complete path to the instance object given
## Usage: my $inst_path = $inst_obj->get_instance_path();
sub get_instance_path{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->get_instance_path";

  if (defined $self->{InstancePath}) {
    return $self->{InstancePath};
  }

  my $string = '';
  if (defined $self->{Parent}){
    $string = ($self->{Parent})->get_instance_path(). ".";
  }
  #else{
  #  $string = "INSTANCE_PATH:";
  #}
  $string .= $self->get_instance_name();

  $self->{InstancePath} = $string;

  return $string;
}


## get_instance_obj
## API method that accepts an instance path (or an instance
## object) and returns the corresponding instance object
## Usage: my $inst_obj = $self->get_instance_obj($inst_path);
sub get_instance_obj{
  my $self = shift;
  my $inst = shift;
  my $inst_path = $inst;
  my $name = $self->{BaseModuleName}."->get_instance_obj";

  # if this is an instance object, simply return
  if(UNIVERSAL::isa($inst,'Genesis2::UniqueModule')){
    return $inst;
  }

  # if this is not a string that represents an instance path -- error out
  # (this is just a sanity check for structure resembling "top.module.submodule")
  my $top_name = $self->{Top}->get_instance_name();
  if ($inst !~ m/^$top_name(\.\w+)*$/){
    $self->error("$name: Input must be an instance object or a legal instance path.\n".
		 "Found -->$inst<-- instead.");
  }

  # else, find the object (start from top)
  $inst =~ s/^$top_name(\.)?//;
  my @path = split('\.',$inst);

  # now overwrite $inst with the real inst object
  $inst = $self->{Top};
  foreach my $token (@path){
    if (defined $inst->{SubInstance_InstanceObj}{$token}){
      $inst = $inst->{SubInstance_InstanceObj}{$token};
    }else{
      $self->error("$name: Cannot find subinst $token of $inst_path");
    }
  }
  return $inst;
}


## unique_inst
## The main function call for instantiating a new module
## Usage: my $unique_inst = $self->unique_inst(base_module_name, inst_name [, prm1 => val1, prm2 => val2, ...]);
sub unique_inst{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->unique_inst";
  my ($base_module_name, $inst_name, $instance);
  my ($other_module, $other_file);
  my $idx;
  my $iterator;
  my $match = 0;
  my @params = ();
  my $usage = "Usage:\n".
    $self->{PrlEsc}.
      " my \$newObj = \$self->unique_inst(base_module_name, inst_name [, prm1 => val1, prm2 => val2, ...]);";

  #####################
  # make sure the sub instance don't mess with our parameters!
  my $prev_priority = $self->{ParametersPriority};
  $self->{ParametersPriority} = GENESIS2_ZERO_PRIORITY;

  # flush the buffer to be safe for comparisons (important for recursion)
  $self->{OutfileHandle}->flush;

  #####################
  # Parse Inputs: module base name
  if (@_){
    $base_module_name = shift;
  }else{
    $self->error("$name: Missing base module name.\n".$usage);
  }
  # Parse Inputs: instance name
  if (@_){
    $inst_name = shift;
    $self->error("$name: Instance -->$inst_name<-- already exists in module -->".caller()."<--\n".$usage)
      if defined $self->{SubInstance_InstanceObj}{$inst_name};
  }else{
    $self->error("$name: Missing instance name.\n".$usage);
  }

  # Parse Inputs: parameters
  @params = @_ if @_;

  # debug print:
  print STDERR "$name: Called for base module -->$base_module_name<-- and instance -->$inst_name<--\n"
    if $self->{Debug} & 4;

  #####################
  # Analyze Inputs:
  # module must exists and be imported:
  my $load_module_msg = $self->load_base_module($base_module_name);
  $self->error("$name: Failed to instantiate \"$inst_name\". Cannot locate/compile module \"${base_module_name}\".\n".
	       "Error Message: $load_module_msg")
      unless $load_module_msg eq '';

  # make an instance:
  $instance = $base_module_name->new_as_son($self);
  $self->{SubInstance_InstanceObj}{$inst_name} = $instance;
  push(@{$self->{SubInstanceList}}, $inst_name);

  #####################
  # Decide what the new submodule name and the generated filename will be
  if (defined $self->{ModuleName_NumDerivs}{$base_module_name}){
    $self->{ModuleName_NumDerivs}{$base_module_name} =
      $self->{ModuleName_NumDerivs}{$base_module_name}+1;
  }else{
    $self->{ModuleName_NumDerivs}{$base_module_name} = 1;
  }
  $idx = $self->{ModuleName_NumDerivs}{$base_module_name};


  $instance->{InstanceName} = $inst_name;
  $instance->{UniqueModuleName} = $base_module_name."_unq".$idx;
  $instance->{OutputFileName} = $instance->{UniqueModuleName}.$instance->{OutfileSuffix};


  #####################
  # Set the values for the sub-pre-processor based on instantiation line
  $instance->{ParametersPriority} = GENESIS2_INHERITANCE_PRIORITY;
  $instance->set_param(@params) if @params;
  $instance->{ParametersPriority} = GENESIS2_DECLARATION_PRIORITY;


  #####################
  # Now, generate the verilog file, with the new init conditions
  $instance->execute;

  # no more parameter changes allowed
  $instance->{ParametersPriority} = GENESIS2_ZERO_PRIORITY;

  #####################
  # Show extensive debug info
  if ($self->{Debug} & 8) {
      foreach my $key (sort keys %{$instance}) {
          print STDERR "- instance key '$key' = $instance->{$key}\n";
      }
  }

  # TODO clean this up if no problems in a month or so...today is 8 May 2025
  my ($OLD,$NEW); ($OLD,$NEW)=(0,1);
if ($OLD) {
  #####################
  # Compare against previously generated files
  $match = 0;
  if ($idx == $self->{ModuleName_NumDerivs}{$base_module_name}){
      # TO ME: 
      #   I added the condition of "$idx == $self->{ModuleName_NumDerivs}{$base_module_name}". 
      #   This is for the case of recursion, which is the only time a higher index is 
      #   finalized before a lower index for the same base module. Recursion may happen if
      #   this module has a decendant which has the same base module. 
      #   Since $self->{ModuleName_NumDerivs}{$base_module_name} is a variable shared by all
      #   packages that inherit from UniqueModule, if recursion happend it will be incremented
      #   inside the "$instance->execute;" call a few lines up.
      #
      # In addition, if a higher index was finalized and kept
      #   (i.e. $idx < $self->{ModuleName_NumDerivs}{$base_module_name}), then there is no 
      #   need for comparing to lower level indexs. 
      # Proof by negation: Say a lower idx module is identical to this one 
      #                    AND a module with a higher idx exists.
      #   Then the lower level's sub-tree would have already been generated, 
      #   but since this module matches it, it means that this module's sub-tree would 
      #   have had to match that lower level module's sub-tree, and un-uniquified. 
      #   Therefore this module's idx would be the highest.
    for ($iterator = 1; $iterator < $idx; $iterator++){
      $other_module = $base_module_name."_unq".$iterator;
      $other_file = $other_module.$instance->{OutfileSuffix};
      $match = $self->compare_generated_files($instance->{OutputFileName},	# the file we just created
					      $other_file,			# previously created file
					      $instance->{UniqueModuleName} =>
					      $other_module # mapping of key words between files
	  				     );
      last if $match;
    }
  }
}

if ($NEW) {
  #####################
  # Find previously generated files e.g. 'flop_unq[123].sv'

  my $splitfile = qr/(.*)(_unq[0-9]*\.[^.]*)/;
  my $me = $instance->{OutputFileName};         # E.g. $me='flop_unq2.sv'
  my ($root,$suffix) = $me =~ $splitfile;       # E.g. $root='flop'

  # OutputFileName should be in the form <root>_unq<d>.<sfx> maybe
  # If not, we get root=<null> and no uniquification maybe
  $self->warning("OutputFileName '$me' != '<root>_unq<num>.<suffix>'") if ($root eq "");

  # Find all files in genesis_raw that match 'root_*'
  # e.g. root=flop  =>  rootfiles=( flop_unq2.sv, flop_D_0_T_RFlop_W_4.sv )
  my $rootfiles = `cd genesis_raw; /bin/ls ${root}_*`;
  print STDERR "Found rootfiles '$rootfiles' maybe\n" if ($self->{Debug} & 8);

  my @rootfiles = split(/\n/, $rootfiles);

  #####################
  # Compare against previously generated files in dir 'genesis_raw'

  # foreach my $other_file (@rootfiles) {
  $match = 0;
  foreach my $rf (@rootfiles) {

      # Don't compare to self or there will be trouble!
      if ($me eq $rf) { next; }

      # Assume module name is just filename with extension stripped off
      # E.g. other_file="flop_unq2.sv" => other_module="flop_unq2"
      my ($f, $suffix) = $rf =~ /(.*)[.]([^.]*)/;

      # Assign to non-local homes for later
      $other_module = $f;
      $other_file = $rf;

      if ($self->{Debug} & 8) {
          print STDERR "I am instance '$instance->{OutputFileName}'\n";
          print STDERR "-- OutputFileName   = $instance->{OutputFileName}\n";
          print STDERR "-- UniqueModuleName = $instance->{UniqueModuleName}\n";
          print STDERR "-- other_file       = $other_file\n";
          print STDERR "-- other_module     = $other_module\n";
      }

      $match = $self->compare_generated_files(
          $instance->{OutputFileName},	                 # the file we just created
          $other_file,			                 # previously created file
          $instance->{UniqueModuleName} => $other_module # mapping of key words between files
          );
      last if $match;
  }
}

  # need to revert a bunch of values if there was a match to a nother unique module
  if ($match){
    # NumDerivs not used anymore, but that's okay, right?
    $self->{ModuleName_NumDerivs}{$base_module_name}--;
    $instance->{UniqueModuleName} = $other_module; # instead, use the previously created module
    unlink(catfile($instance->{RawDir}, $instance->{OutputFileName}));	# remove the newly created file
    delete $self->{OutfileName_ContentCache}{$instance->{OutputFileName}}; # Clean the file from the cache
    $instance->{OutputFileName} = $other_file;	# instead, use the previously created file
  }

  #####################
  # Reassign the parameter priority
  $self->{ParametersPriority} = $prev_priority;

  return $instance;
}


## unique_inst_param
## The main function call for instantiating a new module with module
## uniquification based on the parameters.
## Usage: my $unique_inst_param = $self->unique_inst_param(base_module_name, inst_name [, prm1 => val1, prm2 => val2, ...]);
sub unique_inst_param{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->unique_inst_param";
  my ($base_module_name, $inst_name, $instance);
  my ($other_module, $other_file);
  state $idx = 0;
  my $match = 0;
  my @params = ();
  my $usage = "Usage:\n".
    $self->{PrlEsc}.
      " my \$newObj = \$self->unique_inst_param(base_module_name, inst_name [, prm1 => val1, prm2 => val2, ...]);";

  #####################
  # make sure the sub instance don't mess with our parameters!
  my $prev_priority = $self->{ParametersPriority};
  $self->{ParametersPriority} = GENESIS2_ZERO_PRIORITY;

  # flush the buffer to be safe for comparisons (important for recursion)
  $self->{OutfileHandle}->flush;

  #####################
  # Parse Inputs: module base name
  if (@_){
    $base_module_name = shift;
  }else{
    $self->error("$name: Missing base module name.\n".$usage);
  }
  # Parse Inputs: instance name
  if (@_){
    $inst_name = shift;
    $self->error("$name: Instance -->$inst_name<-- already exists in module -->".caller()."<--\n".$usage)
      if defined $self->{SubInstance_InstanceObj}{$inst_name};
  }else{
    $self->error("$name: Missing instance name.\n".$usage);
  }

  # Parse Inputs: parameters
  @params = @_ if @_;

  # debug print:
  print STDERR "$name: Called for base module -->$base_module_name<-- and instance -->$inst_name<--\n"
    if $self->{Debug} & 4;

  #####################
  # Analyze Inputs:
  # module must exists and be imported:
  my $load_module_msg = $self->load_base_module($base_module_name);
  $self->error("$name: Failed to instantiate \"$inst_name\". Cannot locate/compile module \"${base_module_name}\".\n".
               "Error Message: $load_module_msg")
             unless $load_module_msg eq '';

  # make an instance:
  $instance = $base_module_name->new_as_son($self);
  $self->{SubInstance_InstanceObj}{$inst_name} = $instance;
  push(@{$self->{SubInstanceList}}, $inst_name);

  #####################
  # Decide what the new submodule name and the generated filename will be
  $idx++;
  $instance->{InstanceName} = $inst_name;
  $instance->{UniqueModuleName} = $base_module_name.PARAM_UNQ_STR."_tmp".$idx;
  $instance->{OutputFileName} = $instance->{UniqueModuleName}.$instance->{OutfileSuffix};


  #####################
  # Set the values for the sub-pre-processor based on instantiation line
  $instance->{ParametersPriority} = GENESIS2_INHERITANCE_PRIORITY;
  $instance->set_param(@params) if @params;
  $instance->{ParametersPriority} = GENESIS2_DECLARATION_PRIORITY;

  # FIXME: Avoid regenerating the same module multiple times

  #####################
  # Now, generate the verilog file, with the new init conditions
  $instance->execute;

  # no more parameter changes allowed
  $instance->{ParametersPriority} = GENESIS2_ZERO_PRIORITY;


  #####################
  # Compare against previously generated files
  my $instance_param_list = $instance->get_mod_param_list();
  my $tgt_module_name = $base_module_name . $instance_param_list;
  my $tgt_file_name = $tgt_module_name . $instance->{OutfileSuffix};
  if (defined($self->{OutfileName_ContentCache}{$tgt_file_name})) {
    $match = $self->compare_generated_files(
              $instance->{OutputFileName},      # newly generated file
              $tgt_file_name,                   # existing file
              $instance->{UniqueModuleName} =>  # new instance name
              $tgt_module_name                  # existing instance name
          );
    # The files should match -- we've got a problem if they don't
    $self->error(
      "$name: Newly generated parameter-uniquified $base_module_name does not\n".
      "match previous parameter-uniquified generation!\n".
      "Compare $instance->{OutputFileName} and previously generated $tgt_file_name")
        unless $match;

    # Use the existing file since they match and delete
    # the newly generated file
    $instance->{UniqueModuleName} = $tgt_module_name;
    unlink(catfile($instance->{RawDir}, $instance->{OutputFileName}));
    delete $self->{OutfileName_ContentCache}{$instance->{OutputFileName}};
    $instance->{OutputFileName} = $tgt_file_name;
  } else {
    # This is the only copy of the module
    my $orig_file_path = catfile($instance->{RawDir}, $instance->{OutputFileName});
    my $new_file_path = catfile($instance->{RawDir}, $tgt_file_name);

    my ($fhi, $fho);
    open($fhi, "<$orig_file_path") ||
        $self->error("$name: Couldn't open input file $orig_file_path: $!");
    open($fho, ">$new_file_path") ||
        $self->error("$name: Couldn't open output file $new_file_path: $!");

    # Read the file and replace the temporary module name
    my $inpat = $instance->{UniqueModuleName};
    my @content = map { s/$inpat/$tgt_module_name/g; $_; } <$fhi>;

    # Write the output file
    map { print $fho $_; } @content;

    close($fhi) or
      $self->error("$name: Can not close file \"$orig_file_path\"");
    close($fho) or
      $self->error("$name: Can not close file \"$new_file_path\"");

    $self->{OutfileName_ContentCache}{$tgt_file_name} = \@content;
    unlink($orig_file_path);     # remove the newly created file
    delete $self->{OutfileName_ContentCache}{$instance->{OutputFileName}}; # Clean the file from the cache

    $instance->{UniqueModuleName} = $tgt_module_name; # Update the module name
    $instance->{OutputFileName} = $tgt_file_name;     # Update the module filename
  }

  if (!defined $self->{ModuleCache}{$instance->{UniqueModuleName}}){
    $self->{ModuleCache}{$instance->{UniqueModuleName}} = $instance;
  }


  #####################
  # Reassign the parameter priority
  $self->{ParametersPriority} = $prev_priority;

  return $instance;
}


## clone_inst
## An API method for instantiating a new module based on an existing one
## Usage: my $clone_inst = $self->clone_inst(src_inst, new_inst_name);
## <src_inst> can either be a path (e.g., top.sub_inst.subsub_inst)
## or it can be just an instance object (like the ones returned by 
## unique_inst and clone_inst)
sub clone_inst{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->clone_inst";
  my ($src_inst, $base_module_name, $inst_name, $instance);
  my $match = 0;
  my @params = ();
  my $usage = "Usage:\n".
    $self->{PrlEsc}.
      " my \$clonObj = \$self->clone_inst(src_obj_or_inst_name, new_inst_name );";

  #####################
  # Parse Inputs: module base name
  if (@_){
    $src_inst = shift;
    $src_inst = $self->get_instance_obj($src_inst);
    $base_module_name = $src_inst->{BaseModuleName};
  }else{
    $self->error("$name: Missing source instance path.\n".$usage);
  }
  # Parse Inputs: instance name
  if (@_){
    $inst_name = shift;
    $self->error("$name: Instance -->$inst_name<-- already exists in module -->".caller()."<--\n".$usage)
      if defined $self->{SubInstance_InstanceObj}{$inst_name};
  }else{
    $self->error("$name: Missing instance name.\n".$usage);
  }

  if (@_){
    $self->error("$name: Too many arguments\n".$usage);
  }

  # debuf print:
  print STDERR "$name: Called for base module -->$base_module_name<-- and instance -->$inst_name<--\n"
    if $self->{Debug} & 4;

  # Make sure there is no weird case of a module instantiating it's antecessor
  my $parent = $self;
  while (defined $parent){
    $self->error("$name: Instance ".$self->get_instance_path().
		 ": is trying to instantiate a clone of itself or its antecessor (".
		 $parent->get_instance_path().") !")
      if ($src_inst->{UniqueModuleName} eq $parent->{UniqueModuleName});
    $parent = $parent->{Parent};
  }

  #####################
  # make an instance:
  $instance = $base_module_name->new_as_clone($self, $src_inst);
  $self->{SubInstance_InstanceObj}{$inst_name} = $instance;
  push(@{$self->{SubInstanceList}}, $inst_name);
  $instance->{InstanceName} = $inst_name;

  return $instance;
}

## ununique_inst
## A function call for instantiating a new module WITHOUT uniquification
## Usage: my $UNunique_inst = $self->ununique_inst(base_module_name, inst_name [, prm1 => val1, prm2 => val2, ...]);
sub ununique_inst{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->ununique_inst";
  my ($base_module_name, $inst_name, $instance);
  my ($other_module, $other_file);
  my $rnd;
  my $match = 0;
  my @params = ();
  my $usage = "Usage:\n".
    $self->{PrlEsc}.
      " my \$newObj = \$self->ununique_inst(base_module_name, inst_name [, prm1 => val1, prm2 => val2, ...]);";

  #####################
  # make sure the sub instance don't mess with our parameters!
  my $prev_priority = $self->{ParametersPriority};
  $self->{ParametersPriority} = GENESIS2_ZERO_PRIORITY;

  # flush the buffer to be safe for comparisons (important for recursion)
  $self->{OutfileHandle}->flush;

  #####################
  # Parse Inputs: module base name
  if (@_){
    $base_module_name = shift;
  }else{
    $self->error("$name: Missing base module name.\n".$usage);
  }
  # Parse Inputs: instance name
  if (@_){
    $inst_name = shift;
    $self->error("$name: Instance -->$inst_name<-- already exists in module -->".caller()."<--\n".$usage)
      if defined $self->{SubInstance_InstanceObj}{$inst_name};
  }else{
    $self->error("$name: Missing instance name.\n".$usage);
  }

  # Parse Inputs: parameters
  @params = @_ if @_;

  # debug print:
  print STDERR "$name: Called for base module -->$base_module_name<-- and instance -->$inst_name<--\n"
    if $self->{Debug} & 4;

  #####################
  # Analyze Inputs:
  # module must exists and be imported:
  my $load_module_msg = $self->load_base_module($base_module_name);
  $self->error("$name: Failed to instantiate \"$inst_name\". Cannot locate/compile module \"${base_module_name}\".\n".
	       "Error Message: $load_module_msg")
      unless $load_module_msg eq '';

  # make an instance:
  $instance = $base_module_name->new_as_son($self);
  $self->{SubInstance_InstanceObj}{$inst_name} = $instance;
  push(@{$self->{SubInstanceList}}, $inst_name);

  #####################
  # Decide what the new submodule name and the generated filename will be
  if (defined $self->{UnUniquifiedModules}{$base_module_name}){
      #$time = Time::HiRes::time();
      #$time =~ s/\.//; # remove that annoying decimal point
      $rnd = int(rand(10000));
      $instance->{UniqueModuleName} = $base_module_name."_tmp".$rnd;
  }else{
      $instance->{UniqueModuleName} = $base_module_name;
  }
  $instance->{InstanceName} = $inst_name;
  $instance->{OutputFileName} = $instance->{UniqueModuleName}.$instance->{OutfileSuffix};
  
  
  #####################
  # Set the values for the sub-pre-processor based on instantiation line
  $instance->{ParametersPriority} = GENESIS2_INHERITANCE_PRIORITY;
  $instance->set_param(@params) if @params;
  $instance->{ParametersPriority} = GENESIS2_DECLARATION_PRIORITY;
  
  
  #####################
  # Now, generate the verilog file, with the new init conditions
  $instance->execute;
  
  # no more parameter changes allowed
  $instance->{ParametersPriority} = GENESIS2_ZERO_PRIORITY;
  
  
  #####################
  # Compare against previously generated files
  if (defined $self->{UnUniquifiedModules}{$base_module_name}){
      $match = 0;
      $other_module = $base_module_name;
      $other_file = $other_module.$instance->{OutfileSuffix};
      $match = $self->compare_generated_files($instance->{OutputFileName},	# the file we just created
					      $other_file,			# previously created file
					      $instance->{UniqueModuleName} =>
					      $other_module # mapping of key words between files
	  );
      # If the files did not match, we're in a big problem so error out
      $self->error("$name: Newly generated UN-uniquified $base_module_name does not\n".
		   "match previous UN-uniquified generation!\n".
		   "Compare $instance->{OutputFileName} and previously generated $other_file") unless $match;
  }
  
  # if a module already exists, ignore new version (since we already established that they match)
  if (defined $self->{UnUniquifiedModules}{$base_module_name}){
      $instance->{UniqueModuleName} = $other_module; # instead, use the previously created module
      unlink(catfile($instance->{RawDir}, $instance->{OutputFileName}));     # remove the newly created file
      delete $self->{OutfileName_ContentCache}{$instance->{OutputFileName}}; # Clean the file from the cache
      $instance->{OutputFileName} = $other_file;	# instead, use the previously created file
  }
  
  # if a module did not already exists, mark that it exists now.
  if (!defined $self->{UnUniquifiedModules}{$base_module_name}){
      $self->{UnUniquifiedModules}{$base_module_name} = 1;
  }


  #####################
  # Reassign the parameter priority
  $self->{ParametersPriority} = $prev_priority;
  
  return $instance;
}


## sub synonym:
## Usage:
## //; synonym("SourceTemplate", "TargetTemplate");
## OR
## //; $self->synonym("SourceTemplate", "TargetTemplate");
sub synonym{
    my $self = $Genesis2::UniqueModule::myself;
    my $name = $self->{BaseModuleName}."->synonym";
    $self->error("$name->synonym: Called without arguments")
	unless @_;
    if (check_if_self($_[0])){
	# This was a "method call"
	shift;
    }
    my $src_name = shift or $self->error("$name: Missing source template name.\n");
    my $src_file_name = $src_name . $self->{InfileSuffix};
    my $trgt_name = shift or $self->error("$name: Missing target template name.\n");
    my $trgt_file_name = $trgt_name . $self->{InfileSuffix};
    print STDERR "Creating synonym \"$trgt_name\" based on module template \"$src_name\"\n"
	if $self->{Debug} & 4;

    my $full_file_name = '';
    my $found_it = 0;

    # See if target package was already called cause we don't want to overwrite it and funky stuff may happen...
    if ($INC{$trgt_file_name}) {
	if ($INC{$trgt_file_name} eq $INC{$src_file_name}){
	    # The user called synonym one too many times?   Just ignore...
	    return 1;
	}else{
	    # Target name is a package already in use... Bad user!
	    $self->error("$name: Cannot create synonym to $src_name as $trgt_name because $trgt_name already exists at $INC{$trgt_file_name}!");
	}
    }
    
    # See if the package, although not used already, already exsists in the INC path
    foreach my $inc_path (@INC) {
	$full_file_name = "$inc_path/$trgt_file_name";
	$full_file_name = abs_path($full_file_name) if (-e $full_file_name);
	$self->error("$name: Cannot create synonym \"$trgt_name\" for module template \n".
		     "\"$src_name\" because similar module already exists: $full_file_name") 
	    if (-f $full_file_name);
    }

    # target does not exits. This is good. But does the source package exits? Does it compile?
    my $load_module_msg = $self->load_base_module($src_name);
    $self->error("$name: Cannot create synonym \"$trgt_name\" for \"${src_name}\" ".
		 "because I cannot locate/compile module \"${src_name}\".\n".
		 "Error Message: $load_module_msg")
	unless $load_module_msg eq '';
    #print STDERR "DEBUG: src for $trgt_file_name comes from $INC{$src_file_name} --\n";
    
    # Create it.
    my $synonym = <<END_OF_SYNONYM;
    package $trgt_name;
    use strict;
    use vars qw(\$VERSION \@ISA \@EXPORT \@EXPORT_OK);
    use Exporter;
    \@ISA = qw(Exporter $src_name);
    \@EXPORT = qw();
    \@EXPORT_OK = qw();
    \$VERSION = '1.0';
    sub get_SynonymFor{Genesis2::UniqueModule::private_to_me(); return "$src_name";};
    1;
END_OF_SYNONYM
    
    print STDERR $synonym if $self->{Debug} & 16;
    eval $synonym;
    $self->error("$name: Synonym for \"${src_name}\" failed compilation... Not sure why... Needs further debugging...\n".
		 "Error message: $@") if ($@);

    # this is where we cheat to create a synonym of a synonym
    $INC{$trgt_file_name} = $INC{$src_file_name};
    
    1;
}

######################## SYNTACTIC SUGAR FOR MAIN API ##########################
## sub instantiate
## Usage: `$newObj->instantiate()` 
## Syntactic sugar for `$self->get_instance_name()`  `$self->get_module_name()`
sub instantiate{
    my $self = shift;
    return $self->get_module_name()."  ".$self->get_instance_name();
}

## sub mname
## Syntactic sugar for $anyObj->get_module_name
sub mname{
    my $obj = $Genesis2::UniqueModule::myself;
    $obj = shift if (@_);
    return $obj->get_module_name();
}

## sub bname
## Syntactic sugar for $anyObj->get_base_name
sub bname{
    my $obj = $Genesis2::UniqueModule::myself;
    $obj = shift if (@_);
    return $obj->get_base_name();
}

## sub sname
## Syntactic sugar for $anyObj->get_source_name
sub sname{
    my $obj = $Genesis2::UniqueModule::myself;
    $obj = shift if (@_);
    return $obj->get_source_name();
}

## sub iname
## Syntactic sugar for $anyObj->get_instance_name
sub  iname{
    my $obj = $Genesis2::UniqueModule::myself;
    $obj = shift if (@_);
    return $obj->get_instance_name();
}

# Syntactic sugar for $self->unique_inst
sub generate {
    my $arg1 = shift 
	or $Genesis2::UniqueModule::myself->error($Genesis2::UniqueModule::myself->{BaseModuleName}.
						  "generate: Called without arguments");
    if (check_if_self($arg1)){
	# This was a "method call" of this object, that's good.
	if ($arg1->{CfgHandler}->{UnqStyle} == GENESIS2_UNQ_NUMERIC) {
	    return $arg1->generate_unq_numeric(@_);
	} else {
	    return $arg1->generate_unq_param(@_);
	}
    }else{
	# this was a "function call" (pass all arguments forward to the method)
        return $Genesis2::UniqueModule::myself->generate($arg1, @_);
    }
}

# Syntactic sugar for $self->unique_inst
sub generate_unq_numeric {
    my $arg1 = shift
	or $Genesis2::UniqueModule::myself->error($Genesis2::UniqueModule::myself->{BaseModuleName}.
						  "generate_unq_numeric: Called without arguments");
    if (check_if_self($arg1)){
	# This was a "method call" of this object, that's good.
	return $arg1->unique_inst(@_);
    }else{
	# this was a "function call" (pass all arguments forward to the method)
	return $Genesis2::UniqueModule::myself->unique_inst($arg1, @_);
    }
}

# Syntactic sugar for $self->unique_inst_param
sub generate_unq_param {
    my $arg1 = shift
	or $Genesis2::UniqueModule::myself->error($Genesis2::UniqueModule::myself->{BaseModuleName}.
						  "generate_unq_param Called without arguments");
    if (check_if_self($arg1)){
	# This was a "method call" of this object, that's good.
	return $arg1->unique_inst_param(@_);
    }else{
	# this was a "function call" (pass all arguments forward to the method)
	return $Genesis2::UniqueModule::myself->unique_inst_param($arg1, @_);
    }
}

## sub clone:
## Syntactic sugar for $self->clone_inst 
## Usage:
## //; my $clonObj = $self->clone(src_obj_or_inst_name, new_inst_name );
## OR
## //; my $clonObj = clone(src_obj_or_inst_name, new_inst_name );
sub clone {
    my $arg1 = shift 
	or $Genesis2::UniqueModule::myself->error($Genesis2::UniqueModule::myself->{BaseModuleName}.
						  "->clone: Called without arguments");
    if (check_if_self($arg1)){
	# This was a "method call"
	return $Genesis2::UniqueModule::myself->clone_inst(@_);
    }else{
	# This was a "function call" (pass all arguments forward to the method)
	return $Genesis2::UniqueModule::myself->clone_inst($arg1, @_);
    }
}

# Syntactic sugar for $self->ununique_inst
sub generate_base {
    my $arg1 = shift 
	or $Genesis2::UniqueModule::myself->error($Genesis2::UniqueModule::myself->{BaseModuleName}.
						  "generate_base: Called without arguments");
    if (check_if_self($arg1)){
	# This was a "method call" of this object, that's good.
	return $arg1->ununique_inst(@_);
    }else{
	# this was a "function call" (pass all arguments forward to the method)
	return $Genesis2::UniqueModule::myself->ununique_inst($arg1, @_);
    }
}

## Create a module with a given name
## Syntactic sugar for synonym + ununique_inst
## Usage:
## //; my $inst = $self->generate_w_name(base_module_name, gen_module_name,
## //;                                   inst_name [, prm1 => val1,
## //;                                                prm2 => val2, ...]);
sub generate_w_name {
    my $arg1 = shift
        or $Genesis2::UniqueModule::myself->error($Genesis2::UniqueModule::myself->{BaseModuleName}.
                                                  "generate_w_name: Called without arguments");
    if (check_if_self($arg1)){
        # This was a "method call" of this object, that's good.
        my $base_module_name = shift
            or $Genesis2::UniqueModule::myself->error($Genesis2::UniqueModule::myself->{BaseModuleName}.
                                                      "generate_w_name: Called without base module name.");
        my $gen_module_name = shift
            or $Genesis2::UniqueModule::myself->error($Genesis2::UniqueModule::myself->{BaseModuleName}.
                                                      "generate_w_name: Called without generated module name.");

        synonym($base_module_name, $gen_module_name);
        return $arg1->ununique_inst($gen_module_name, @_);
    }else{
        # this was a "function call" (pass all arguments forward to the method)
        return $Genesis2::UniqueModule::myself->generate_w_name($arg1, @_);
    }
}

## sub parameter:
## Syntactic sugar for $self->define_param, $self->force_param, $self->doc_param, $self->param_range
## Usage:
## //; my $prmVal = parameter(name=>'prmName', 
## //;                        val=>$prmVal,
## //;                        force=>0/1
## //;                        doc=>'message' 
## //;                        min=>$minVal, max=>$maxVal, step=>$step OR list=>[$valA, $valB, ...],
## //;			      Opt=>'Yes'/'No'/'Try');
## OR
## //; my $prmVal = $self->parameter(name=>'prmName', 
## //;                               val=>$prmVal,
## //;                               force=>0/1
## //;                               doc=>'message' 
## //;                               min=>$minVal, max=>$maxVal, step=>$step OR list=>[$valA, $valB, ...],
## //;			      	     Opt=>'Yes'/'No'/'Try'));
sub parameter{
    my $self = $Genesis2::UniqueModule::myself;
    my $name = $self->{BaseModuleName}."->parameter";
    $self->error("$name->parameter: Called without arguments")
	unless @_;
    if (ref($self) eq ref($_[0]) &&  $self == $_[0]){
	# This was a "method call"
	shift;
    }
    $self->error ("Illegal parameter declaration: Un-even argument list.\n".
		  "Expected list of optionName=>optionValue. \n".
		  "Note -- If specifying 'Val' which is array or hash, remember to pass a pointer:\n".
		  "E.g.: Val=>[1,2,3] for an array, and Val=>{key1=>val1, key2=>val2} for a hash.\n".
		  "For empty arrays/hashes use Val=>[] and Val=>{} and not Val=>()") unless @_ % 2 == 0;
    my %args = @_;
    my $prm_name = '';
    my $doc = '';
    my $doc_seen = 0;
    my %range = ();
    my $force = '0';
    my $force_seen = 0;
    my $val;
    my $val_seen = 0;
    my $opt;
    foreach my $key (keys %args){
	if ($key =~ m/^name$/i){
	    $self->error("$name: Only one argument of type 'Name' allowed per ". 
			 "parameter definition call!") unless $prm_name eq '';
	    $prm_name = $args{$key};
	    $self->error("$name: Illegal argument '$prm_name' for field 'Name' in parameter ". 
			 "definition call! (Name must consist of alphanumeric characters only)") 
		if  $prm_name !~ m/^\w+$/i;
	}
	elsif($key =~ m/^force$/i){
	    $self->error("$name: Only one argument of type 'Force' allowed per ". 
			 "parameter definition call!") if $force_seen != 0;
	    $force = $args{$key};
	    $force_seen ++;
	    $self->error("$name: Illegal value for argument of type 'Force' at ". 
			 "parameter definition call!") unless $force =~ m/^(0|1|on|off)$/i;

	}
	elsif($key =~ m/val/i){
	    $self->error("$name: Only one argument of type 'Val' allowed per ". 
			 "parameter definition call!") if $val_seen != 0;
	    $val = $args{$key};
	    $val_seen ++;
	}
	elsif($key =~ m/doc/i){
	    $self->error("$name: Only one argument of type 'Doc' allowed per ". 
			 "parameter definition call!") if $doc_seen != 0;
	    $doc =  $args{$key};
	    $doc_seen++;
	}
	elsif($key =~ m/list/i){
	    $self->error("$name: Only one argument of type 'List' allowed per ". 
			 "parameter definition call!") if defined $range{List};
	    $range{List} =  $args{$key};
	}
	elsif($key =~ m/min/i){
	    $self->error("$name: Only one argument of type 'Min' allowed per ". 
			 "parameter definition call!") if defined $range{Min};
	    $range{Min} =  $args{$key};
	}
	elsif($key =~ m/max/i){
	    $self->error("$name: Only one argument of type 'Max' allowed per ". 
			 "parameter definition call!") if defined $range{Max};
	    $range{Max} =  $args{$key};
	}
	elsif($key =~ m/step/i){
	    $self->error("$name: Only one argument of type 'Step' allowed per ". 
			 "parameter definition call!") if defined $range{Step};
	    $range{Step} =  $args{$key};
	}
	elsif($key =~ m/^opt$/i){
	    $self->error("$name: Only one argument of type 'Opt' allowed per ". 
			 "parameter definition call!") if defined $opt;
	    $opt = $args{$key};
	}
    }

    # Check for minimal conditions for a parameter definition
    $self->error("$name: One argument of type 'Name' is required per ". 
		 "parameter definition call!") if $prm_name eq '';
    $self->error("$name: One argument of type 'Val' is required per ". 
		 "parameter definition call!") if $val_seen != 1;
    
    # Define the parameter:
    if($force =~ m/^(0|off)$/i){
	$val = $self->define_param($prm_name=>$val);
    }else{
	$val = $self->force_param($prm_name=>$val);
    }

    # Documentation:
    $self->doc_param($prm_name, $doc) if $doc ne '';

    # Range:
    $self->param_range($prm_name, %range) if keys %range >= 1;

    # Optimize
    $self->optimize_param($prm_name, $opt) if defined $opt;

    return $val;
}


################################################################################
############################ API For Manager Package ###########################
################################################################################
sub execute{
  my $self = shift;
  local $Genesis2::UniqueModule::myself = $self;
  my $name = $self->{BaseModuleName}."->execute";
  caller eq __PACKAGE__ || caller eq 'Genesis2::Manager' 
    or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
  
  my $prev_outfile_handle;
  my $prev_priority;

  # parse the xml input to actual parameters
  my $path = $self->get_instance_path();
  $self->{ParamsFromXML} = $self->{CfgHandler}->GetXmlParamList($path);
  $self->{ParamsFromCfg} = $self->{CfgHandler}->GetCfgParamList($path);
  $self->{ParamsFromCmdLn} = $self->{CfgHandler}->GetCmdLnParamList($path);

  # open the output file (save the previous file handle for later)
  my $fullFileName = catfile($self->{RawDir}, $self->{OutputFileName});
  open($self->{OutfileHandle}, ">$fullFileName") || 
    $self->error("$name: Couldn't open output file $fullFileName: $!");
  $prev_outfile_handle = select $self->{OutfileHandle};

  # Print the Verilog
  eval {
      if ($self->{Debug} & 8){
	  my $t0 = time;
	  $self->to_verilog;
	  my $t1 = time;
	  print STDERR "$name: Spent ".($t1-$t0)." seconds on call to 'to_verilog'\n";
      }else{
	  $self->to_verilog;
      }
  };
  # Check for errors
  if ($@){
      my @errs = split(/\n/, $@);
      # remove the last line of $@ it will always point to UniqueModule.pm 
      pop(@errs) if scalar(@errs)>1;
      my $err_msg = join("\n",@errs);
      $self->error($err_msg);
  }
  # check for unused parameters
  foreach my $param (@{$self->{ParametersList}}){
      $self->warning("Parameter '$param' was passed to ".$self->get_instance_path().
		     " but it was never actually declared/used in ".$self->iname())
	  if ($self->{Parameters}->{$param}->{State} =~ /NeverUsed/i);
  }

  # revert back to the previous file handle
  select $prev_outfile_handle;
  close($self->{OutfileHandle}) or 
      $self->error("$name: Can not close file \"$fullFileName\"");

  # cache the file
  if (! exists $self->{OutfileName_ContentCache}{$self->{OutputFileName}}){
      my $filename = $self->{OutputFileName};
      my $fh;
      open($fh, "<$fullFileName") || 
	  $self->error("$name: Couldn't open output file $fullFileName: $!");
      @{$self->{OutfileName_ContentCache}{$filename}} = <$fh>;
      close($fh) or 
	  $self->error("$name: Can not close file \"$fullFileName\"");
  }else{
      $self->error("INTRNAL ERROR: \"$fullFileName\" already cached");
  }
  
  1;
}

sub get_out_file_name{
    my $self = shift;
    my $name = $self->{BaseModuleName}."->get_out_file_name";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager' 
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
    return $self->{OutputFileName};
}

## get_unq_styles
## Get the uniquification styles
sub get_unq_styles {
  my $name = __PACKAGE__."->get_unq_styles";
  caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
      or error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
  return keys(%UNQ_STYLES);
}

## default_unq_style
## Get the default uniquification style
sub default_unq_style {
  my $name = __PACKAGE__."->default_unq_style";
  caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
      or error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
  return DEFAULT_UNQ_STYLE;
}

## str_to_unq_style
## Parse the uniquification style
sub str_to_unq_style {
  my $name = __PACKAGE__."->str_to_unq_style";
  caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
      or error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");

  my $style = shift;
  return $UNQ_STYLES{$style} if defined($UNQ_STYLES{$style});
  return undef;
}

################################################################################
############################## Auxiliary Functions #############################
################################################################################
## private: internal_get_param
## Usage: $self->internal_get_param($prm_name);
sub internal_get_param{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->internal_get_param";
  caller eq __PACKAGE__
    or $self->error("$name: Call to a base class private method is not allowed");

  my ($prm_name, $prm_val);
  my %options = ();
  if (@_){
    $prm_name = shift;
  }else{
    $self->error("$name: Missing parameter name");
  }
  if (@_){
      %options = @_;
  }
  
  $self->error("$name: Trying to extract the value of an undefined parameter\n".
	       "Parameter -->$prm_name<-- does not exists in instance -->".
	       $self->get_instance_name."<-- of module -->".$self->get_module_name."<--") 
      unless defined $self->{Parameters}->{$prm_name};
	       
  foreach my $opt (keys %options){
      if ($opt =~ /check_used/i){
	  $self->error("$name: Trying to extract the value of a parameter that was never ".
		       "explicitely declared. Use the \"parameter(Name=>'$prm_name', Val=>...)\" ".
		       "notation to declare a parameter with its default value")
	      unless $self->{Parameters}->{$prm_name}->{State} eq 'Used' || !$options{$opt};
      }
  }
  
  # extract the parameter
  $prm_val = $self->deep_copy($self->{Parameters}->{$prm_name}->{Val}, $prm_name);

  return $prm_val;
}

## private: get_param_priority
## Usage: $self->get_param_priority($prm_name);
sub get_param_priority{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->get_param_priority";
  caller eq __PACKAGE__
    or $self->error("$name: Call to a base class private method is not allowed");

  my ($prm_name, $prm_pri);
  if (@_){
    $prm_name = shift;
  }else{
    $self->error("$name: Missing parameter name");
  }

  # extract the parameter
  if (defined $self->{Parameters}->{$prm_name}){
      $prm_pri = $self->{Parameters}->{$prm_name}->{Pri};
  }else{
      $self->error("$name: Trying to extract the priority of an undefined parameter\n".
		   "Parameter -->$prm_name<-- does not exists in module -->".caller()."<--");
  }

  return $prm_pri;
}


## private: set_param_priority
## Usage: $self->set_param_priority($prm_name);
sub set_param_priority{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->set_param_priority";
  caller eq __PACKAGE__
    or $self->error("$name: Call to a base class private method is not allowed");

  my ($prm_name, $prm_pri);
  if (scalar(@_)==2){
    $prm_name = shift;
    $prm_pri = shift;
  }else{
    $self->error("$name: Missing parameter name or parameter new priority");
  }

  # extract the parameter
  if (defined $self->{Parameters}->{$prm_name}){
      $self->{Parameters}->{$prm_name}->{Pri} = $prm_pri;
  }else{
      $self->error("$name: Trying to set the priority of an undefined parameter\n".
		   "Parameter -->$prm_name<-- does not exists in module -->".caller()."<--");
  }
  return 1;
}


## private: set_param
## Usage: $self->set_param(prm_name => prm_value [, more_prm_name => more_prm_value, ...]);
sub set_param{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->set_param";
  caller eq __PACKAGE__
    or $self->error("$name: Call to a base class private method is not allowed");
  $self->{ParametersPriority} > GENESIS2_ZERO_PRIORITY or 
    $self->error("$name: Adding parameter definitions not allowed at this point");

  my %prm_hash;
  my ($prm_name);
  if (@_){
    %prm_hash = @_;
  }else{
    $self->error("$name: Missing parameter hash");
  }

  print STDERR "$name: Called at priority -->".
      (GENESIS2_PRIORITY)[$self->{ParametersPriority}].
      "=".$self->{ParametersPriority}."<--\n" 
      if $self->{Debug} & 4;
  foreach $prm_name (keys %prm_hash){
    if (!defined $self->{Parameters}->{$prm_name}){
      $self->{Parameters}->{$prm_name}->{Val} = $self->deep_copy($prm_hash{$prm_name}, $prm_name);
      $self->set_param_priority($prm_name, $self->{ParametersPriority});
      $self->{Parameters}->{$prm_name}->{State} = "NeverUsed"; # We add the param to the DB but 
      			             			       # mark it as not used for now, until
      			             			       # we see an explicit definition
      push (@{$self->{ParametersList}}, $prm_name);  # this helps us keep the chronological order of params
      print STDERR "$name: New param -->$prm_name<-- first seen. Setting -->$prm_name<-- to -->".
	$self->internal_get_param($prm_name)."<--\n" if $self->{Debug} & 4;
    }
    # Else, make sure we haven't seen this key. If we have seen this key:
    # a. if seen with a higher priority priority, ignore the new deinition
    # b. if seen with lower priority priority, overwrite it
    # c. if seen with the same priority priority, error-out
    elsif ($self->get_param_priority($prm_name) > $self->{ParametersPriority}){
	# do nothing
	print STDERR "$name: Param -->$prm_name<-- already defined with higher priority\n\t".
	    "Current priority: ".(GENESIS2_PRIORITY)[$self->{ParametersPriority}].
	    "=".$self->{ParametersPriority}."\n\t".
	    "Previous priority: ".(GENESIS2_PRIORITY)[$self->get_param_priority($prm_name)].
	    "=".$self->get_param_priority($prm_name)."\n\t-->Ignoring new definition.\n" 
	    if $self->{Debug} & 4;
    }elsif ($self->get_param_priority($prm_name) < $self->{ParametersPriority}){
      $self->{Parameters}->{$prm_name}->{Val} = $self->deep_copy($prm_hash{$prm_name}, $prm_name);
      $self->set_param_priority($prm_name, $self->{ParametersPriority});
      print STDERR "$name: Param -->$prm_name<-- already defined but with lower priority.\n\t".
	  "Current priority: ".(GENESIS2_PRIORITY)[$self->{ParametersPriority}].
	  "=".$self->{ParametersPriority}."\n\t".
	  "Previous priority: ".(GENESIS2_PRIORITY)[$self->get_param_priority($prm_name)].
	  "=".$self->{ParametersPriority}."\n\tSetting -->$prm_name<-- to -->".
	  $self->internal_get_param($prm_name)."<--\n" if $self->{Debug} & 4;
    }else{
	# Same priority re-definition is handles next
    }
    
    # Was this parameter already seen at the current level?
    if (defined $self->{Parameters}->{$prm_name}->{SeenAt}->{$self->{ParametersPriority}}){
	$self->error("$name: Parameter $prm_name already declared/seen at the same priority ".
		     (GENESIS2_PRIORITY)[$self->{ParametersPriority}]."($self->{ParametersPriority})");
    }else{
	# Keep record for future re-definitions
	$self->{Parameters}->{$prm_name}->{SeenAt}->{$self->{ParametersPriority}} = 1;
    }
  }
  1;
}

## split_param_name
## Usage: split_param_name($prm_name);
## Split a parameter name into words. Word starts are:
##  - lowercase to uppercase transition
##  - character following underscore
##  - alpha -> number or number -> alpha
sub split_param_name {
  my $name = "split_param_name";
  caller eq __PACKAGE__
    or error("$name: Call to a base class private method is not allowed");

  my $param = shift;

  my $words = [];
  my $curr = "";
  my $prev_uscore = 1;
  my $prev_num = 0;
  my $prev_uc = 0;
  foreach my $c (split//, $param) {
    my $is_uscore = $c eq "_";
    my $is_num = $c =~ /[0-9]/;
    my $is_uc = $c =~ /[A-Z]/;

    if (!$is_uscore) {
      # Transitions: lowercase to uppercase, alpha to number, number to alpha
      if (!$prev_uscore &&
           ($is_num && !$prev_num ||
            !$is_num && $prev_num ||
            !$prev_num && $is_uc && !$prev_uc)) {
        push @$words, uc($curr) if $curr ne "";
        $curr = $c;
      } else {
        $curr .= $c;
      }
    } else {
      push @$words, uc($curr) if $curr ne "";
      $curr = "";
    }

    $prev_uscore = $is_uscore;
    $prev_num = $is_num;
    $prev_uc = $is_uc;
  }

  push @$words, uc($curr) if $curr ne "";

  return $words;
}

## get_initial_regions
## Usage: get_initial_regions($words);
## Get the initial regions for a list of words to include in an abbreviation.
## The initial region is 1 for non-numeric words and the length of the word for
## numeric words.
sub get_initial_regions {
  my $name = "get_initial_regions";
  caller eq __PACKAGE__
    or error("$name: Call to a base class private method is not allowed");

  my $words = shift;

  my $regions = [];
  foreach my $word (@$words) {
    if ($word =~ /^[0-9]/) {
      push @$regions, length($word);
    } else {
      push @$regions, 1;
    }
  }

  return $regions;
}

## get_abbrev_from_regions
## Usage: get_abbrev_from_regions($words, $regions);
## Get an abbreviation from a list of words and their regions.
## The $words and $region lists are the same length. The region value indicates
## the number of characters to include in the abbreviation from the corresponding
## word.
sub get_abbrev_from_regions {
  my $name = "get_initial_regions";
  caller eq __PACKAGE__
    or error("$name: Call to a base class private method is not allowed");

  my $words = shift;
  my $regions = shift;

  if (scalar(@$words) != scalar(@$regions)) {
    error("$name: words/regions are different lengths\n");
  }

  my $abbrev = "";
  for (my $i = 0; $i < scalar(@$words); $i++) {
    $abbrev .= substr($words->[$i], 0, $regions->[$i]);
  }

  return $abbrev;
}

## Abbreivation cache to potentially eliminate having to do the
## abbreviation calculation multiple times.
my %abbrev_cache;

## gen_param_abbrevs
## Usage: gen_param_abbrevs(@params);
## Generate abbreviations for the ParameterList.
sub gen_param_abbrevs {
  my $self = shift;
  my $name = $self->{BaseModuleName}."->get_param_abbrevs";
  caller eq __PACKAGE__
    or $self->error("$name: Call to a base class private method is not allowed");

  # Check if we already have the abbreviation cached
  if (!exists $self->{SortedParameterString}) {
    $self->{SortedParameterString} = join(' ', sort @{$self->{ParametersList}});
  }

  if (exists $abbrev_cache{$self->{SortedParameterString}}) {
    return $abbrev_cache{$self->{SortedParameterString}};
  }

  # Calculate the starting word/region pairs
  my %wr_pairs;
  foreach my $param (@{$self->{ParametersList}}) {
    my $words = split_param_name($param);
    my $regions = get_initial_regions($words);

    $wr_pairs{$param} = [$words, $regions];
  }

  # Repeatedly generate the abbreviations and adjust the regions until we have
  # no conflicts.
  # FIXME: Should only need to regenerate the abbreviations that change.
  my %abbrevs;
  my $done = 0;
  my $iter = 0;
  while (!$done) {
    $done = 1;
    $iter++;
    print STDERR "$name: Iteration $iter:\n" if $self->{Debug} & 2;

    print STDERR "  Abbreviations:\n" if $self->{Debug} & 2;
    my %abbrev_srcs;
    map { delete $abbrevs{$_} } keys %abbrevs;
    foreach my $param (@{$self->{ParametersList}}) {
      my ($words, $regions) = @{$wr_pairs{$param}};
      my $abbrev = get_abbrev_from_regions($words, $regions);
      print STDERR "    $param -> $abbrev\n" if $self->{Debug} & 2;  # MUST BE STDERR else appears in verilog :(
      $abbrevs{$param} = $abbrev;
      if (!exists $abbrev_srcs{$abbrev}) {
        $abbrev_srcs{$abbrev} = [];
      }
      push @{$abbrev_srcs{$abbrev}}, $param;
    }

    while (my ($abbrev, $params) = each(%abbrev_srcs)) {
      next if (scalar(@$params) <= 1);

      # MUST BE STDERR else appears in verilog instead :(
      print STDERR "  Conflicting parameters: " . join(' ', @$params) . "\n"
        if $self->{Debug} & 2;
      $done = 0;
      my $i_idx = each @$params;
      my $i_param = $params->[$i_idx];
      my $i_abbrev = $abbrevs{$i_param};
      my ($i_words, $i_regions) = @{$wr_pairs{$i_param}};
      while (my $j_idx = each @$params) {
        my $j_param = $params->[$j_idx];
        print STDERR "  Disabmiguating $i_param and $j_param\n"
          if $self->{Debug} & 2;

        my $j_abbrev = $abbrevs{$j_param};
        my ($j_words, $j_regions) = @{$wr_pairs{$j_param}};

        my $w_max = min(scalar(@$i_words), scalar(@$j_words));
        my $updated = 0;
        for (my $w_num = 0; $w_num < $w_max; $w_num++) {
          my $i_word = $i_words->[$w_num];
          my $j_word = $j_words->[$w_num];

          if ($i_word ne $j_word) {
            for (my $w_idx = 0; $w_idx < length($i_word); $w_idx++) {
              if (substr($i_word, $w_idx, 1) ne substr($j_word, $w_idx, 1)) {
                my $i_region = $i_regions->[$w_num];
                my $j_region = $j_regions->[$w_num];

                if ($w_idx + 1 > $i_region) {
                  $i_regions->[$w_num] = $w_idx + 1;
                  $updated = 1;
                  print STDERR "  $i_param: $w_num set to " . ($w_idx + 1) . "\n"
                    if $self->{Debug} & 2;
                }
                if ($w_idx + 1 > $j_region) {
                  $j_regions->[$w_num] = $w_idx + 1;
                  $updated = 1;
                  print STDERR "  $j_param: $w_num set to " . ($w_idx + 1) . "\n"
                    if $self->{Debug} & 2;
                }

                last;
              }
            }
          }
          last if ($updated);
        }
        if (!$updated) {
          error("$name: could not disambiguate abbreviations for $i_param and $j_param\n");
        }
      }
    }
  }

  return \%abbrevs;
}


## private: get_mod_param_list
## Usage: $self->get_mod_param_list();
## Generates a string of parameters that have been changed from their defaults.
## The parameter names are abbreviated to reduce the size of the string.
##
## This string can be appended to the module name to create a unique module
## name.
sub get_mod_param_list{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->get_mod_param_list";
  caller eq __PACKAGE__
    or $self->error("$name: Call to a base class private method is not allowed");

  print STDERR "$name: Creating instance parameter list for \"" . $self->get_instance_path . "\"\n"
      if $self->{Debug} & 4;


  my $abbrevs = $self->gen_param_abbrevs();

  # Create a list of non-default parameters
  my @nondef_params;
  foreach my $param (@{$self->{ParametersList}}) {
    push @nondef_params, $param
      if ($self->get_param_priority($param) > GENESIS2_DECLARATION_PRIORITY);
  }

  # Generate the parameter list string
  my $ret = "";
  foreach my $param (sort(@nondef_params)) {
    next if $param =~ /^__/;
    my $abbrev = $abbrevs->{$param};
    my $val = $self->internal_get_param($param);

    if (defined $val) {
      $val =~ s/\./_/g;
      $val =~ s/\'/_/g;
      $val = 'FALSE_OR_EMPTY' if $val eq "";
      $ret .= "_${abbrev}_${val}";
    }
    else {
      $ret .= "_${abbrev}";
    }
  }

  print STDERR "$name: Returning instance parameter list \"$ret\" for " .
      "instance \"" . $self->get_instance_path . "\"\n"
      if $self->{Debug} & 4;


  return $ret;
}

#################################################################
## error
sub error {
  my $self = $Genesis2::UniqueModule::myself;
  my $message = 'No error message found!';
  
  if (scalar(@_) == 0){
      # nothing to do, use defult self and message
  }
  elsif (scalar(@_) == 1){
      $message = shift;
  }
  else { # two args or more
      $self = shift;
      $message = shift;
  }

  my @message_arr = ();
  my ($prefix, $prefix0, $prefix1, $prefix2, $prefix3, $perlmsg, $suffix1, $suffix2);
  my ($package, $filename, $line, $subroutine);

  my $i = 0;
  while (($package, $filename, $line, $subroutine) = caller($i++)){
      # print STDERR "DEBUG: Caller($i): $package, $filename, $line, $subroutine\n";
      last if ($package ne "Genesis2::UniqueModule" && $package ne "Genesis2::Manager");
  }
  
  # add a tab before the message:
  $prefix0 = "ERROR    ERROR    ERROR    ERROR    ERROR    ERROR    ERROR    ERROR\n";
  $prefix1 = "ERROR While processing Genesis2 template \'${package}\' at line $line of file $filename\n";
  $prefix2 = "ERROR while at instance ".$self->get_instance_path()."\n";
  $prefix3 = "ERROR Message:\n";
  $suffix1 = "Exiting Genesis2 due to fatal error... bye bye... \n";


  $prefix = $prefix0.$prefix1.$prefix2.$prefix3;
  
  #print to file as well as to stderr
  print "\n".$prefix."\n";
  print STDERR "\n".$prefix."\n";

  @message_arr = split(/\n/, $message);
  map {print "\t".$_."\n"} @message_arr; # print to file
  map {my @tokens = split(//,$_);
       my $len = scalar(@tokens);
       my $space = '';
       $space = ' ' x (80-$len) if $len<80; 
       print STDERR "\t"; 
       print STDERR colored ($_ . $space,'bold red on_black'); 
       print STDERR "\n"; 
      } @message_arr; # print stderr

  # print suffix and call stack
  print "\n".$suffix1; 
  confess "\n".$suffix1."\nFull Call Stack" if $self->{Debug}; # will append the file and line number + stack
  print STDERR "\n".$suffix1; exit 7;
}

## warning
sub warning {
  my $self = $Genesis2::UniqueModule::myself;
  my $message = 'No warning message found!';

  if (scalar(@_) == 0){
      # nothing to do, use defult self and message
  }
  elsif (scalar(@_) == 1){
      $message = shift;
  }
  else { # two args or more
      $self = shift;
      $message = shift;
  }

  my ($prefix0, $prefix1, $prefix2, $prefix3, $perlmsg, $suffix1, $suffix2);
  my ($package, $filename, $line, $subroutine);

  my $i = 0;
  while (($package, $filename, $line, $subroutine) = caller($i++)){
      # print STDERR "DEBUG: Caller($i): $package, $filename, $line, $subroutine\n";
      last if ($package ne "Genesis2::UniqueModule" && $package ne "Genesis2::Manager");
  }

  # add a tab before the message:
  $message =~ s/\n/\n\t/g;
  $message = "\t".$message."\n";
  $prefix0 = "WARNING    WARNING    WARNING    WARNING    WARNING    WARNING    WARNING    WARNING\n";
  $prefix1 = "WARNING While processing Genesis2 template \'${package}\' at line $line of file $filename\n";
  $prefix2 = "WARNING while at instance ".$self->get_instance_path()."\n";
  $prefix3 = "WARNING Message:\n";
  $suffix1 = "Continuing Genesis2 despite warning... \n";

  $message = $prefix0.$prefix1.$prefix2.$prefix3.$message.$suffix1;

  #print to stdout as well as to stderr
  my $comment = $message;
  $comment =~ s/\n/\n$self->{LineComment}/g;
  print "\n".$self->{LineComment}."\n".$self->{LineComment}.$comment."\n\n";
  cluck "\n".$message."\nCall Stack" if $self->{Debug}; # will append the file and line number + stack
  print  STDERR "\n".$message."\n" if ! $self->{Debug}; 

}

## 
sub to_string {
  my $self = shift;
  my $name = $self->{BaseModuleName}."->to_string";
  $self->isa(__PACKAGE__) or
    $self->error("$name: Call to a protected method is not allowed");
  $self->error("$name: Expected a data structure to print. Found no arguments.") unless @_;
  my $str = '';
  foreach  my $elem (@_){
        $str .= $self->{CfgHandler}->PrintToString($elem, depth=>1, prefix=>"") . "\n";
  }
  chomp($str);
  return $str;
}


# protected: to_verilog:
# This is a virtual task to be overwriten by the derived modules
sub to_verilog{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->to_verilog";
  $self->isa(__PACKAGE__) or
    $self->error("$name: Call to a protected method is not allowed");
  my $srcfile = shift;

  print STDERR "$name: Generating ".$self->get_instance_path()."\n"
      if $self->{Debug};
  print STDERR "$name: Started printing to ".catfile($self->{RawDir},$self->{OutputFileName})."\n"
    if $self->{Debug} & 1;

  $self->error("Internal error: Why is VersionInfo not defined?") 
      unless defined $self->{VersionInfo};
  my $version = join($self->{LineComment}."\t", @{$self->{VersionInfo}});
  chomp($version);

  $self->error("Internal error: Why is LicenseInfo not defined?") 
      unless defined $self->{LicenseInfo};
  my $license = join($self->{LineComment}."  ", @{$self->{LicenseInfo}});
  chomp($license);

  print { $self->{OutfileHandle} } <<END_OF_MESSAGE;
$self->{LineComment}
$self->{LineComment}--------------------------------------------------------------------------------
$self->{LineComment}          THIS FILE WAS AUTOMATICALLY GENERATED BY THE GENESIS2 ENGINE        
$self->{LineComment}  FOR MORE INFORMATION: OFER SHACHAM (CHIP GENESIS INC / STANFORD VLSI GROUP)
$self->{LineComment}  $license
$self->{LineComment}--------------------------------------------------------------------------------
$self->{LineComment}
$self->{LineComment}  $version
$self->{LineComment}
$self->{LineComment}  Source file: $srcfile
$self->{LineComment}  Source template: $self->{BaseModuleName}
$self->{LineComment}
END_OF_MESSAGE

  print { $self->{OutfileHandle} } $self->{LineComment}.
      " --------------- Begin Pre-Generation Parameters Status Report ---------------\n";
  print { $self->{OutfileHandle} } $self->{LineComment}. "\n";

  # GENESIS2_INHERITANCE_PRIORITY
  print { $self->{OutfileHandle} } $self->{LineComment}. 
      "\tFrom 'generate' statement (priority=".GENESIS2_INHERITANCE_PRIORITY."):\n";
  foreach my $prm (keys %{$self->{Parameters}}){
      print { $self->{OutfileHandle} } $self->{LineComment}.
	  " Parameter $prm \t= undef\n" if !defined $self->{Parameters}->{$prm}->{Val};
      my $type = ref($self->{Parameters}->{$prm}->{Val});
      print { $self->{OutfileHandle} } $self->{LineComment}.
	  " Parameter $prm \t= $self->{Parameters}->{$prm}->{Val}\n" if $type eq '';
      print { $self->{OutfileHandle} } $self->{LineComment}.
	  " Parameter $prm \t= Data structure of type $type\n" if $type ne '';
  }
  print { $self->{OutfileHandle} } $self->{LineComment}. "\n";
  print { $self->{OutfileHandle} } $self->{LineComment}. 
      "\t\t---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----\n";
  print { $self->{OutfileHandle} } $self->{LineComment}. "\n";

  # GENESIS2_CMD_LINE_PRIORITY
  print { $self->{OutfileHandle} } $self->{LineComment}. 
      "\tFrom Command Line input (priority=".GENESIS2_CMD_LINE_PRIORITY."):\n";
  foreach my $prm (keys %{$self->{ParamsFromCmdLn}}){
      my $prm_val = $self->{CfgHandler}->GetCmdLnParamBrief($self->{ParamsFromCmdLn}->{$prm},
							    $self->get_instance_path.':Parameters:ParamItem('.$prm.')'); 
      $prm_val = 'undef' if !defined $prm_val;
      print { $self->{OutfileHandle} } $self->{LineComment}." Parameter $prm \t= $prm_val\n";
  }
  print { $self->{OutfileHandle} } $self->{LineComment}. "\n";
  print { $self->{OutfileHandle} } $self->{LineComment}. 
      "\t\t---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----\n";
  print { $self->{OutfileHandle} } $self->{LineComment}. "\n";

  # GENESIS2_EXTERNAL_XML_PRIORITY
  print { $self->{OutfileHandle} } $self->{LineComment}. 
      "\tFrom XML input (priority=".GENESIS2_EXTERNAL_XML_PRIORITY."):\n";
  foreach my $prm (keys %{$self->{ParamsFromXML}}){
      my $prm_val = $self->{CfgHandler}->GetXmlParamBrief($self->{ParamsFromXML}->{$prm},
						       $self->get_instance_path.':Parameters:ParamItem('.$prm.')'); 
      $prm_val = 'undef' if !defined $prm_val;
      print { $self->{OutfileHandle} } $self->{LineComment}." Parameter $prm \t= $prm_val\n";
  }
  print { $self->{OutfileHandle} } $self->{LineComment}. "\n";
  print { $self->{OutfileHandle} } $self->{LineComment}. 
      "\t\t---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----\n";
  print { $self->{OutfileHandle} } $self->{LineComment}. "\n";


  # GENESIS2_EXTERNAL_CONFIG_PRIORITY
  print { $self->{OutfileHandle} } $self->{LineComment}. 
      "\tFrom Config File input (priority=".GENESIS2_EXTERNAL_CONFIG_PRIORITY."):\n";
  foreach my $prm (keys %{$self->{ParamsFromCfg}}){
      my $prm_val = $self->{CfgHandler}->GetCfgParamBrief($self->{ParamsFromCfg}->{$prm},
						       $self->get_instance_path.':Parameters:ParamItem('.$prm.')');
      $prm_val = 'undef' if !defined $prm_val;
      print { $self->{OutfileHandle} } $self->{LineComment}." Parameter $prm \t= $prm_val\n";
  }

  print { $self->{OutfileHandle} } $self->{LineComment}. "\n";
  print { $self->{OutfileHandle} } $self->{LineComment}.
      " ---------------- End Pre-Generation Pramameters Status Report ----------------\n\n";
1;
}



# private: deep_copy
# Deep copy of hash and array structures
sub deep_copy{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->deep_copy";
  caller eq __PACKAGE__ or
    $self->error("$name: Call to a base class private method is not allowed");
  
  # create a local stack of addresses that I visited to avoid endless loops
  local $Genesis2::UniqueModule::deep_copy_hash = {};
  return $self->internal_deep_copy(@_);
}

sub internal_deep_copy{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->internal_deep_copy";
  caller eq __PACKAGE__ or
    $self->error("$name: Call to a base class private method is not allowed");

  my $src = shift;
  my $msg = '';
  $msg = shift if @_;
  my $type = ref($src);
  my $trgt;

  if (!defined $src){
      $trgt = $src;
  }
  elsif ($type eq ''){ # not a reference
      # Check special numeric formats
      if ($src =~ /^\s*0x([0-9,a-f])+\s*$/i  || # special case for hex numbers
	  $src =~ /^\s*0b([0,1])+\s*$/i) {      # special case for binary numbers
	  $trgt = oct($src);
      }else{
	  $trgt = $src;
      }
  }elsif (defined $Genesis2::UniqueModule::deep_copy_hash->{$src}){
      # If this pointer was seen already, don't copy again (avoid infinite loops)
      $trgt = $Genesis2::UniqueModule::deep_copy_hash->{$src};
  }elsif($type eq 'SCALAR'){
      my $tmp = $self->internal_deep_copy(${$src}, $msg); # get the unreferenced version
      $trgt = \$tmp; # create a referenced version
  }elsif($type eq 'ARRAY'){
      $trgt = [];
      $Genesis2::UniqueModule::deep_copy_hash->{$src} = $trgt; # keep for your records
      foreach my $element (@{$src}){
	  push(@{$trgt}, $self->internal_deep_copy($element, $msg));
      }
      delete $Genesis2::UniqueModule::deep_copy_hash->{$src};
  }elsif($type eq 'HASH'){
      $trgt = {};
      $Genesis2::UniqueModule::deep_copy_hash->{$src} = $trgt; # keep for your records
      foreach my $key (keys %{$src}){
	  $trgt->{$key} = $self->internal_deep_copy($src->{$key}, $msg);
      }
      delete $Genesis2::UniqueModule::deep_copy_hash->{$src};
  }elsif($src == $self){
      $trgt = $src;
  }elsif(UNIVERSAL::can($src,'can')){
      # if this is a blessed ref it might have a deep_copy method
      if ($src->can('deep_copy')){
	  $trgt = $src->deep_copy($src, $msg);
      }else{
	  # I guess it does not have a deep_copy method...
	  $self->error("$name: src of type ".ref($src).
		       " is not supported (perhaps add a ".ref($src).
		       "->deep_copy method?)");
      }
  }else{
    $self->error("$name: src of type ".ref($src).
		 " is not supported (perhaps add a ".ref($src).
		 "->deep_copy method?)");
  }
  return $trgt;
}



## compare_generated_files:
## Compares two files for the unique_inst directive. First two arguments are
## the file names. Any following argument is a mapping of allowed replacements
## between the two files (e.g., if the key word 'submodule_unq5' in file A and
## is just as 'submodule_unq17' in file B, then use the option 
## 'submodule_unq5 => submodule_unq17'. It will result in the lines:
## 'submodule_unq5 instance (.in(in), .out(out)' and 
## 'submodule_unq17 instance (.in(in), .out(out)' matching rather then being
## different).
sub compare_generated_files{
    my $self = shift;
    my $name = $self->{BaseModuleName}."->compare_generated_files";
    caller eq __PACKAGE__ or
	$self->error("$name: Call to a base class private method is not allowed");
    
    my $filenameA = shift;
    my $filenameB = shift;
    my %options = @_;
    my $filehandleA = new FileHandle;
    my $filehandleB = new FileHandle;
    my $lineA = '';
    my $lineB = '';
    my $match = 1; # initialize to having a match.
    
    print STDERR "$name: Comparing $filenameA to $filenameB\n" if $self->{Debug} & 4;

    # check that all files are already in cache
    if (! exists $self->{OutfileName_ContentCache}{$filenameA}){
	# This is a bad sign... a file we just finished generating should be in the cache...
	$self->error("$name: Can't find $filenameA in the cache");
    }
    if (! exists $self->{OutfileName_ContentCache}{$filenameB}){
	# this is a sign of recursion because it means a file we started generating 
	# earlier was not yet finalized --> They cannot match or this is a never ending recursion
	$match = 0;
	return $match;
    }
    
    my $idxA = 0; my $idxB = 0;
    my $linesA = $self->{OutfileName_ContentCache}{$filenameA};
    my $linesB = $self->{OutfileName_ContentCache}{$filenameB};
    while ($idxA < scalar(@{$linesA}) && $idxB < scalar(@{$linesB}) && $match==1){
	$lineA = ${$linesA}[$idxA++];
	$lineB = ${$linesB}[$idxB++];

	# remove full line comments and empty lines
	while ($lineA =~ /^\s*$self->{LineComment}.*$/ ||
	       $lineA =~ /^\s*$/){
	    if ($idxA < scalar(@{$linesA})){
		$lineA = ${$linesA}[$idxA++];
	    }else{
		$lineA = undef;
		last;
	    }
	}
	while ($lineB =~ /^\s*$self->{LineComment}.*$/ ||
	       $lineB =~ /^\s*$/){
	    if ($idxB < scalar(@{$linesB})){
		$lineB = ${$linesB}[$idxB++];
	    }else{
		$lineB = undef;
		last;
	    }
	}
	
	# Do the mapping of words as requested
	foreach my $key (keys %options){
	    $lineA =~ s/(^|\W)$key(?=\W|$)/$1$options{$key}/g if defined $lineA;
	}
	if (defined $lineA && defined $lineB){
	    $match = ($lineA =~ /^\Q$lineB\E$/) ? 1:0;
	}elsif (!defined $lineA && !defined $lineB){
	    $match = 1;
	}else{
	    $match = 0;
	}
    }
    print STDERR "$name: Match is $match\n" if (($self->{Debug} & 4));
    return $match;
}


## sub load_base_module
## private method that loads automatically generated modules from the parsing step.
## If successful, returns an empty error message. Otherwise return a string.
sub load_base_module{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->load_base_module";
  caller eq __PACKAGE__ || caller eq "Genesis2::Manager" or
    $self->error("$name: Call to a base class private method is not allowed");

  my $base_module_name = shift;
  my $base_module_file = $base_module_name . $self->{InfileSuffix};  # E.g. 'jtag.pm' (right?)
  my $err_msg = '';  # ?? what kind of err_msg is this??

  if ($INC{$base_module_file}) {
      return $err_msg;
  }
  else{
    use Try::Tiny;
    try {
      # This is the original code for e.g. when jtag.pm already exists
      eval {require $base_module_file};
    } catch {
      # New code searches for a file e.g. 'jtag.svp' and generates missing 'jtag.pm' (why?)
      my $base_module_name_adj =
          $self->{Manager}->add_suffix($base_module_name);
      $self->{Manager}->parse_unprocessed_file($base_module_name_adj);
      eval {require $base_module_file};
    };
      # Check for errors
      if ($@){
	  my @errs = split(/\n/, $@);
	  # remove the last line of $@ it will always point to UniqueModule.pm 
	  pop(@errs) if scalar(@errs)>1;
	  $err_msg = join("\n",@errs);
	  return $err_msg;
      }
      $base_module_name->import();
  }
  return $err_msg;
}


## sub get_SynonymFor
## Private subroutine to be overwritten by synonyms
sub get_SynonymFor{
    private_to_me();
    return undef;
}


## sub private_to_me
## A subroutine that errors if the caller of the parent sub was not UniqueModule
sub private_to_me{
    my ($package, $filename, $line, $subroutine) = caller(1);
    $subroutine =~ s/(\w+::)*//;
    $package eq __PACKAGE__ or
	confess("ERROR ERROR ERROR\n".$package."->".$subroutine.
	    ": Call to a base class private method is not allowed\n");
    1;
}  
  

# sub check_if_self
sub check_if_self{
    my $arg = shift;
    return 1 if (ref($arg) eq ref($Genesis2::UniqueModule::myself) && $arg==$Genesis2::UniqueModule::myself);
    return 0;
}
1;
