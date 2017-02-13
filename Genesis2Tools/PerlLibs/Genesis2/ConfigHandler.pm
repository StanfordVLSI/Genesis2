# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/Genesis2Tools/PerlLibs/Genesis2/ConfigHandler.pm#8 $
# ** $DateTime: 2013/03/25 01:30:27 $
# ** $Change: 11788 $
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
################### ACTUAL CONFIGHANDLER CODE STARTS HERE ######################
################################################################################
package Genesis2::ConfigHandler;
use warnings;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

use Carp qw(carp cluck confess croak); $Carp::MaxArgLen =16; $Carp::MaxArgNums = 1;
use Exporter;
use FileHandle;
use File::Basename;
use Env; # Make environment variables available
use XML::Simple;
use Term::ANSIColor;
use Cwd;
use Cwd 'abs_path';
use Scalar::Util qw(looks_like_number);


@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw();
$VERSION = '1.0';

# We need to use some infor from the UniqueModule to extract the xml
use Genesis2::UniqueModule 1.00 qw(GENESIS2_ZERO_PRIORITY 
				   GENESIS2_DECLARATION_PRIORITY 
				   GENESIS2_EXTERNAL_CONFIG_PRIORITY
				   GENESIS2_EXTERNAL_XML_PRIORITY
				   GENESIS2_CMD_LINE_PRIORITY
				   GENESIS2_INHERITANCE_PRIORITY
				   GENESIS2_IMMUTABLE_PRIORITY);


################################################################################
################################## Constructors ################################
################################################################################
sub new{
    my $package = shift;
    my $manager = shift;
    my $self = {};
    caller eq "Genesis2::Manager"
	or die("$package->new: Constructor must only be caled by a Genesis2::Manager");

    $self->{Manager} = $manager;	# This is the Genesis Manager
    $self->{CallDir} = cwd();		# Directory where the script was called from

    $self->{Debug} = 0;			# Debug level (verbosity)
    $self->{TopObj} = undef;		# Pointer to the top UniqueModule in the design

    $self->{ConfigsPath} = [];		# Paths to find config files

    $self->{XmlInFileName} = undef;	# Name of xml config file
    $self->{XmlOutFileName} = undef;	# Name of output xml config file

    $self->{CfgInFileNames} = [];	# Names of scripted config files

    $self->{InXmlDB} = undef;		# Database after processing xml config file
    $self->{InCfgDB} = undef;		# Database after processing "simple" config file
    $self->{PrmOverrides} = undef;	# List of parameter override defintions

 
    # Bless this package
    bless ($self, $package) ;
}


################################################################################
############################## MAIN API FUNCTIONS ##############################
################################################################################

################################################
########### MANAGER API FUNCTIONS 
################################################

## SetDebugLevel
## API for Genesis2::Manager
## Sets the verbosity level of of the module
sub SetDebugLevel{
    my $self=shift;
    my $name = __PACKAGE__."->SetDebugLevel";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
    $self->{Debug}=shift;
    1;
} 

## SetTopObj
## API for Genesis2::Manager
## Sets a pointer to the top level of of the design
sub SetTopObj{
    my $self=shift;
    my $name = __PACKAGE__."->SetTopObj";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
    $self->{TopObj}=shift;
    1;
} 


## SetConfigsPath
## API method for Genesis2::Manager
## Sets the search path for config files of all types
sub SetConfigsPath{
    my $self=shift;
    my $name = __PACKAGE__."->SetConfigsPath";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
    $self->{ConfigsPath}=shift;
    1;
} 


## SetXmlInFileName
## API for Genesis2::Manager
## Sets a pointer to the top level of of the design
sub SetXmlInFileName{
    my $self=shift;
    my $name = __PACKAGE__."->SetXmlInFileName";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
    $self->{XmlInFileName}=shift;
    1;
} 

## SetXmlOutFileName
## API for Genesis2::Manager
## Sets a pointer to the top level of of the design
sub SetXmlOutFileName{
    my $self=shift;
    my $name = __PACKAGE__."->SetXmlOutFileName";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
    $self->{XmlOutFileName}=shift;
    1;
} 

## SetCfgInFileNames
## API for Genesis2::Manager
## Sets a pointer to the top level of of the design
sub SetCfgInFileNames{
    my $self=shift;
    my $name = __PACKAGE__."->SetCfgInFileNames";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
    $self->{CfgInFileNames}=shift;
    1;
} 

## ReadXml
## API for Genesis2::Manager
## Wrapper function for the XML Simple read tailored for Genesis
sub ReadXml{
    my $self = shift;
    my $name = __PACKAGE__."->ReadXml";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");

    # Read the input xml file if needed (using the XML::Simple package)
    print STDERR "$name: $self->{XmlInFileName}\n" if $self->{Debug} & 2;
    if (defined $self->{XmlInFileName}){
	print STDERR "$name: Now reading XML config file: $self->{XmlInFileName}\n";
	my $fname = $self->find_file($self->{XmlInFileName}, $self->{ConfigsPath});
	$self->{InXmlDB} = XMLin($fname, 
				 KeepRoot => 1,
				 NoAttr => 1,
				 KeyAttr => [],
				 ForceArray => ['ArrayItem', 'HashItem', 'ParameterItem', 'SubInstanceItem']);
	$self->error("$name: Root element of the xml_in_file must be HierarchyTop!") 
	    unless defined $self->{InXmlDB}->{HierarchyTop};
	$self->error("$name: Only single root element allowed for the xml_in_file (must be HierarchyTop)") 
	    if keys %{$self->{InXmlDB}} > 1;
    }
    return 1;
}

## ReadCfg
## API for Genesis2::Manager
## Wrapper function for the CfgFile parsing and reading
sub ReadCfg{
    my $self = shift;
    my $name = __PACKAGE__."->ReadCfg";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
    print STDERR "$name: $self->{CfgInFileNames}\n" if $self->{Debug} & 2;
    local $Genesis2::ConfigHandler::myself = $self;
    local $Genesis2::ConfigHandler::readcfg_on = 1;

    if (defined $self->{CfgInFileNames} && scalar(@{$self->{CfgInFileNames}})){   
	print STDERR "$name: Now reading config files: @{$self->{CfgInFileNames}}\n";
	
		my $header = <<END_OF_HEADER;
\# line 1 $name
package Genesis2::UserConfigScript;
use strict;
use warnings;
sub configure{Genesis2::ConfigHandler::configure(\@_);}
sub exists_configuration{return Genesis2::ConfigHandler::exists_configuration(\@_);}
sub remove_configuration{Genesis2::ConfigHandler::remove_configuration(\@_);}
sub get_configuration{return Genesis2::ConfigHandler::get_configuration(\@_);}
sub include{eval(Genesis2::ConfigHandler::read_cfg_file(\@_)); die \$@ if \$@; 1;}
sub print_configuration{Genesis2::ConfigHandler::print_configuration(); 1;}
sub get_top_name{return Genesis2::ConfigHandler::get_top_name();}
sub get_synthtop_path{return Genesis2::ConfigHandler::get_synthtop_path();}
sub error{Genesis2::ConfigHandler::user_error(\@_);}
END_OF_HEADER
    
    	foreach my $fn (@{$self->{CfgInFileNames}}){
	    $header .= "include('$fn');\n";
	}
	$header .= "1;\n";
    	eval $header;

    	# Check for errors
    	if ($@){
	   my $err_msg = 'Where is my error?';
	   my @errs = split(/\n/, $@);
	   # remove the last line of $@ it will always point to ConfigHandler.pm... I think 
 	   pop(@errs) if scalar(@errs)>1;
	   $err_msg = join("\n",@errs);
	   $self->error($err_msg);
        }   
    }
    return 1;
}


## WriteXml
## API for Genesis2::Manager
## Wrapper function for the XML Simple read tailored for Genesis
sub WriteXml{
    my $self = shift;
    my $name = __PACKAGE__."->WriteXml";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");

    my ($fh, $fn_sml, $fh_sml, $fh_tiny, $fn_tiny);
    $fh = undef; $fh_sml=undef;
    my $db={}; my $db_sml={}; my $db_tiny={};
    
    # Open files for writing
    if (defined $self->{XmlOutFileName}){
	($db, $db_sml, $db_tiny) = $self->extract_stats($self->{TopObj});
	open($fh, ">$self->{XmlOutFileName}") || 
	    $self->error("$name: Couldn't open hierarchy file $self->{XmlOutFileName}: $!");
	$fn_sml = "small_".$self->{XmlOutFileName};
	open($fh_sml, ">$fn_sml") || 
	    $self->error("$name: Couldn't open hierarchy file ${fn_sml}: $!");
	$fn_tiny = "tiny_".$self->{XmlOutFileName};
	open($fh_tiny, ">$fn_tiny")||
	    $self->error("$name: Couldn't open hierarchy file ${fn_tiny}: $!");
	print STDERR "$name: Now writing output XML file: $self->{XmlOutFileName}\n";	
    }else{
	return 1;
    }

    # Write files
    XMLout($db,
	   NoAttr => 1, 
	   KeyAttr => [],
	   RootName => 'HierarchyTop',
	   OutputFile => $fh);
    XMLout($db_sml,
	   NoAttr => 1, 
	   KeyAttr => [],
	   RootName => 'HierarchyTop',
	   OutputFile => $fh_sml);
    XMLout($db_tiny, 
	   NoAttr => 1,
	   KeyAttr => [],
	   RootName => 'HierarchyTop',
	   OutputFile => $fh_tiny);

    # Close Files
    close $fh if defined $fh;
    close $fh_sml if defined $fh_sml;
    close $fh_tiny if defined $fh_tiny;
    1;
}

## SetPrmOverrides
## API for Genesis2::Manager
## A method for extracting a parameter database from the command line parameters
sub SetPrmOverrides{
    my $self = shift;
    my $name = __PACKAGE__."->SetPrmOverrides";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");
    print STDERR "$name: Now processing command line parameter overrides\n";	

    my $param_defs = shift;
    foreach my $prm_def (@$param_defs){
	my ($path, $prm, $val);
	if ($prm_def =~ /^(.+)\.(\w+)=(.+)$/){
	    $path = $1;
	    $prm = $2;
	    $val = $3;
	}elsif($prm_def =~ /^(.+)\.(\w+)$/){
	    $path = $1;
	    $prm = $2;
	    $val = '';
	}else{
	    $self->error("$name: Can not understand command line parameter override syntax.\n".
			 "Expected: 'path.name=val' Example: 'top.dut.subinst.prmname=prmval'. Found: '$prm_def'");
	}
	print STDERR "\tINFO:\tCommand line parameter override: path=$path, param name=$prm, override val='$val'\n";

	$self->error("$name: Second call to command line parameter override of '$path.$prm' found") 
	    if exists $self->{PrmOverrides}->{$path} && exists $self->{InCfgDB}->{$path}->{$prm};
	$self->{PrmOverrides}->{$path}->{$prm}->{Val} = $val; 
	$self->{PrmOverrides}->{$path}->{$prm}->{State} = 'NeverUsed'; 
    }
    1;
}

## Finalize
## API for Genesis2::Manager
## Wrapper function for cleanup of Config related issues
sub Finalize{
    my $self = shift;
    my $name = __PACKAGE__."->Finalize";
    caller eq __PACKAGE__ || caller eq 'Genesis2::Manager'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::Manager");


    foreach my $path (keys %{$self->{PrmOverrides}}){
	foreach my $prm (keys %{$self->{PrmOverrides}->{$path}}){
	    $self->error("Command line parameter override for $path.$prm was never used\n")
		unless $self->{PrmOverrides}->{$path}->{$prm}->{State} eq 'Used';
	}
    }
    foreach my $path (keys %{$self->{InCfgDB}}){
	foreach my $prm (keys %{$self->{InCfgDB}->{$path}}){
	    $self->error("Config file parameter $path.$prm was never used\n")
		unless $self->{InCfgDB}->{$path}->{$prm}->{State} eq 'Used';
	}
    }
    1;
}
################################################
########### UNIQUE MODULE API FUNCTIONS 
################################################

## GetXmlParamList
## API for Genesis2::UniqueModule
## Returns a list of parameters defined in the XML file for that instance
## Usage: $params = $cfgHandler_obj->getXMLParamList(pathToInst)
sub GetXmlParamList{
    my $self = shift;
    my $name = __PACKAGE__."->GetXmlParamList";
    caller eq __PACKAGE__ || caller eq 'Genesis2::UniqueModule'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::UniqueModule");

    my $path = shift;
    my $node = $self->find_xml_node($path);
    my $prms = $self->extract_param_list_from_xml_db($node, $path);
    return $prms;
}

## GetCfgParamList
## API for Genesis2::UniqueModule
## Returns a list of parameters defined in the config file for that instance
## Usage: $params = $cfgHandler_obj->getCfgParamList(pathToInst)
sub GetCfgParamList{
    my $self = shift;
    my $name = __PACKAGE__."->GetCfgParamList";
    caller eq __PACKAGE__ || caller eq 'Genesis2::UniqueModule'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::UniqueModule");

    my $path = shift or $self->error("$name: must be called with a path to the instance in question");
    return $self->{InCfgDB}->{$path};
}

## GetCmdLnParamList
## API for Genesis2::UniqueModule
## Returns a list of parameters defined in the config file for that instance
## Usage: $params = $cfgHandler_obj->getCmdLnParamList(pathToInst)
sub GetCmdLnParamList{
    my $self = shift;
    my $name = __PACKAGE__."->GetCmdLnParamList";
    caller eq __PACKAGE__ || caller eq 'Genesis2::UniqueModule'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::UniqueModule");

    my $path = shift or $self->error("$name: must be called with a path to the instance in question");
    return $self->{PrmOverrides}->{$path};
}

## GetXmlParamVal
## API for Genesis2::UniqueModule
## Returns the value of a parameter as extracted from the config file
## The input is a param ptr as returned by the GetXmlParamList method
## Usage: $param_val = $cfgHandler_obj->GetXmlParamVal($prm_ptr [, dbg_msg])
sub GetXmlParamVal{
    my $self = shift;
    my $name = __PACKAGE__."->GetXmlParamVal";
    caller eq __PACKAGE__ || caller eq 'Genesis2::UniqueModule'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::UniqueModule");
    my $item = shift;
    my $dbg_msg = '';
    $dbg_msg = shift if scalar(@_);
    my $be_safe = 0;

    # Usage: $prm_db = $self->extract_param_type_from_xml_db(ParametrItem, safe_mode, parent)
    return $self->extract_param_type_from_xml_db($item, $be_safe, $dbg_msg);
}


## GetCfgParamVal
## API for Genesis2::UniqueModule
## Returns the value of a parameter as extracted from the config file
## The input is a param ptr as returned by the GetCfgParamList method
## Usage: $param_val = $cfgHandler_obj->GetCfgParamVal($prm_ptr [, dbg_msg])
sub GetCfgParamVal{
    my $self = shift;
    my $name = __PACKAGE__."->GetCfgParamVal";
    caller eq __PACKAGE__ || caller eq 'Genesis2::UniqueModule'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::UniqueModule");
    my $item = shift;
    $item->{State} = 'Used';
    return $item->{Val};
}
sub PrintToString{
    my $self = shift;
    my $name = __PACKAGE__."->PrintToString";
    caller eq __PACKAGE__ || caller eq 'Genesis2::UniqueModule'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::UniqueModule");
    local $Genesis2::ConfigHandler::print_to_string_hash = {};
    return $self->internal_print_to_string(@_);
}


## GetCmdLnParamVal
## API for Genesis2::UniqueModule
## Returns the value of a parameter as extracted from the config file
## The input is a param ptr as returned by the GetCmdLnParamList method
## Usage: $param_val = $cfgHandler_obj->GetCmdLnParamVal($prm_ptr [, dbg_msg])
sub GetCmdLnParamVal{
    my $self = shift;
    my $name = __PACKAGE__."->GetCmdLnParamVal";
    caller eq __PACKAGE__ || caller eq 'Genesis2::UniqueModule'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::UniqueModule");
    my $item = shift;
    $item->{State} = 'Used';
    return $item->{Val};
}

## GetXmlParamBrief
## API for Genesis2::UniqueModule
## Returns the value of a parameter as extracted from the XML file
## The input is a param ptr as returned by the GetXmlParamList method
## Usage: $param_val = $cfgHandler_obj->GetXmlParamBrief($prm_ptr [, dbg_msg])
sub GetXmlParamBrief{
    my $self = shift;
    my $name = __PACKAGE__."->GetXmlParamBrief";
    caller eq __PACKAGE__ || caller eq 'Genesis2::UniqueModule'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::UniqueModule");
    my $item = shift;
    my $dbg_msg = '';
    $dbg_msg = shift if scalar(@_);
    my $be_safe = 1;

    # Usage: $prm_db = $self->extract_param_type_from_xml_db(ParametrItem, safe_mode, parent)
    return $self->extract_param_type_from_xml_db($item, $be_safe, $dbg_msg);
}

## GetCfgParamBrief
## API for Genesis2::UniqueModule
## Returns the value of a parameter as extracted from the config file
## The input is a param ptr as returned by the GetCfgParamList method
## Usage: $param_val = $cfgHandler_obj->GetCfgParamBrief($prm_ptr [, dbg_msg])
sub GetCfgParamBrief{
    my $self = shift;
    my $name = __PACKAGE__."->GetCfgParamBrief";
    caller eq __PACKAGE__ || caller eq 'Genesis2::UniqueModule'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::UniqueModule");
    my $item = shift;
    if (ref($item->{Val}) eq ''){
	return $item->{Val};
    }else{
	return ref($item->{Val})." (To be dynamically loaded from config script)";
    }
}

## GetCmdLnParamBrief
## API for Genesis2::UniqueModule
## Returns the value of a parameter as extracted from the config file
## The input is a param ptr as returned by the GetCmdLnParamList method
## Usage: $param_val = $cfgHandler_obj->GetCmdLnParamBrief($prm_ptr [, dbg_msg])
sub GetCmdLnParamBrief{
    my $self = shift;
    my $name = __PACKAGE__."->GetCmdLnParamBrief";
    caller eq __PACKAGE__ || caller eq 'Genesis2::UniqueModule'
	or $self->error("$name: access restricted to ".__PACKAGE__." or Genesis2::UniqueModule");
    my $item = shift;
    return $item->{Val};
}

################################################################################
################################### Auxiliary ##################################
################################################################################


############################################################
### Extracting data out of the UniqueModules structure
############################################################

## sub extract_stats
## Collect a summary of statistics about the hierarchy.
## Usage: $self->extract_stats($UniqueModule_obj)
##	GENESIS2_ZERO_PRIORITY => 0,
##	GENESIS2_DECLARATION_PRIORITY => 1,
##	GENESIS2_EXTERNAL_CONFIG_PRIORITY => 2,
##	GENESIS2_EXTERNAL_XML_PRIORITY => 3,
##	GENESIS2_CMD_LINE_PRIORITY => 4,
##	GENESIS2_INHERITANCE_PRIORITY => 5,
##	GENESIS2_IMMUTABLE_PRIORITY => 6,
sub extract_stats{
  my $self = shift;
  my $unq_module = shift;
  my $name = __PACKAGE__."->extract_stats";
  caller eq __PACKAGE__ 
    or $self->error("$name: access restricted to ".__PACKAGE__);


  my ($param, $subinst_name, $subinst_obj);
  my $db  = {};
  my $db_sml = {};
  my $db_tiny = {};

  $db->{InstanceName} = $unq_module->{InstanceName} if defined $unq_module->{InstanceName};
  $db->{UniqueModuleName} = $unq_module->{UniqueModuleName} if defined $unq_module->{UniqueModuleName};
  $db->{BaseModuleName} = $unq_module->{BaseModuleName} if defined $unq_module->{BaseModuleName};
  $db->{SynonymFor} = $unq_module->{SynonymFor} if defined $unq_module->{SynonymFor};
  $db_sml->{InstanceName} = $unq_module->{InstanceName} if defined $unq_module->{InstanceName};
  $db_tiny->{InstanceName} = $unq_module->{InstanceName} if defined $unq_module->{InstanceName};

  if (defined $unq_module->{CloneOf}){
    $db->{CloneOf}->{InstancePath} = $unq_module->{CloneOf}->get_instance_path();
  }else{
    $db->{Parameters} = {};
    $db_sml->{Parameters} = {} if scalar(@{$unq_module->{ParametersList}});
    $db->{ImmutableParameters} = {};
    foreach $param (@{$unq_module->{ParametersList}}){
	# (only log params that are actually used)
	next if ($unq_module->{Parameters}->{$param}->{State} =~ /NeverUsed/i);

	local $Genesis2::ConfigHandler::extract_stats_hash = {};
	my $ParameterItem = {};
	$ParameterItem = $self->extract_param_stats($unq_module->{Parameters}->{$param}->{Val});
	my $param_is_recursive = 0;
	$param_is_recursive = 1 if keys %{$Genesis2::ConfigHandler::extract_stats_hash};

	if ($unq_module->{Parameters}->{$param}->{Pri} < GENESIS2_INHERITANCE_PRIORITY &&
	    $param_is_recursive == 0){
	    $ParameterItem->{Doc} = $unq_module->{Parameters}->{$param}->{Doc};
	    $ParameterItem->{Doc} = '' if !defined $ParameterItem->{Doc};
	    $ParameterItem->{Range} = $unq_module->{Parameters}->{$param}->{Range} 
	    	if defined $unq_module->{Parameters}->{$param}->{Range};
	    $ParameterItem->{Opt} = $unq_module->{Parameters}->{$param}->{Opt} 
	    	if defined $unq_module->{Parameters}->{$param}->{Opt};
	    $ParameterItem->{Name} = $param;

	    push(@{$db->{Parameters}->{ParameterItem}} , $ParameterItem);
	    push(@{$db_sml->{Parameters}->{ParameterItem}} , $ParameterItem);
	    # for Tiny, only log parameters that were specified in the XML/Cfg/CmdLn configuration (non-default)
	    if ($unq_module->{Parameters}->{$param}->{Pri} >= GENESIS2_EXTERNAL_XML_PRIORITY){
		$db_tiny->{Parameters} = {} if !(defined $db_tiny->{Parameters});
		push(@{$db_tiny->{Parameters}->{ParameterItem}}, $ParameterItem);
	    }
	}
	# for parameters that are tied by inheritance, write them as immutable
	#if($unq_module->{Parameters}->{$param}->{Pri} >= GENESIS2_INHERITANCE_PRIORITY || $param_is_recursive == 1){
	else {
	    $ParameterItem->{Doc} = $unq_module->{Parameters}->{$param}->{Doc};
	    $ParameterItem->{Range} = $unq_module->{Parameters}->{$param}->{Range} 
	       if defined $unq_module->{Parameters}->{$param}->{Range};
	    $ParameterItem->{Opt} = $unq_module->{Parameters}->{$param}->{Opt} 
	       if defined $unq_module->{Parameters}->{$param}->{Opt};
	    $ParameterItem->{Opt} = 'NotRightNow' if ((defined $ParameterItem->{Opt}) && ($ParameterItem->{Opt} =~ /yes|try/i));
	    $ParameterItem->{Name} = $param;
	    push(@{$db->{ImmutableParameters}->{ParameterItem}} , $ParameterItem);
      }
    }

    $db->{SubInstances} = {} if scalar(@{$unq_module->{SubInstanceList}});
    $db_sml->{SubInstances} = {} if scalar(@{$unq_module->{SubInstanceList}});
    foreach $subinst_name (@{$unq_module->{SubInstanceList}}){
	$subinst_obj = $unq_module->{SubInstance_InstanceObj}{$subinst_name};
	my ($recursive_db, $recursive_db_sml, $recursive_db_tiny) = $self->extract_stats($subinst_obj);
	push (@{$db->{SubInstances}->{SubInstanceItem}}, $recursive_db);
	push (@{$db_sml->{SubInstances}->{SubInstanceItem}}, $recursive_db_sml);
	#only add this subinstance to the tiny list if it had some relevant params or subinstances.
	if ((exists $recursive_db_tiny->{SubInstances}) || (exists $recursive_db_tiny->{Parameters})){
	    $db_tiny->{SubInstances} = {} if !(defined $db_tiny->{SubInstances});
	    push (@{$db_tiny->{SubInstances}->{SubInstanceItem}}, $recursive_db_tiny);
	}
    }
  }
  return ($db,$db_sml,$db_tiny);
}


## sub extract_param_stats
## Extract an un-ambigueous structure for xml represantation of the parameters
## Usage: $prm_db = $self->extract_param_stats($self->{Parameters}->{$param}->{Val})
sub extract_param_stats{
  my $self = shift;
  my $name = __PACKAGE__."->extract_param_stats";
  caller eq __PACKAGE__ or
    $self->error("$name: Call to a base class private method is not allowed");

  my $prm = shift;
  my $type = ref($prm);
  my $db;

  if ($type eq ''){
      $db->{Val} = $prm if defined $prm;
      $db->{Val} = '' if !defined $prm;
    }elsif (defined $Genesis2::ConfigHandler::extract_stats_hash->{$prm}){
      # If this pointer was seen already, don't copy again (avoid infinite loops)
      $db->{Val} = 'Recursive Declaration';
      $Genesis2::ConfigHandler::extract_stats_hash->{Recursive} = 1;
  }elsif($type eq 'ARRAY'){
      $Genesis2::ConfigHandler::extract_stats_hash->{$prm} = 1;
      $db->{ArrayType} = {};
      foreach my $element (@{$prm}){
	  push(@{$db->{ArrayType}->{ArrayItem}}, $self->extract_param_stats($element));
      }
      delete $Genesis2::ConfigHandler::extract_stats_hash->{$prm};
  }elsif($type eq 'HASH'){
      $Genesis2::ConfigHandler::extract_stats_hash->{$prm} = 1;
      $db->{HashType}->{HashItem} = [];
      foreach my $key (sort(keys %{$prm})){
	  my $key_val_pair = {};
	  $key_val_pair = $self->extract_param_stats($prm->{$key});
	  $key_val_pair->{Key} = $key;
	  push(@{$db->{HashType}->{HashItem}}, $key_val_pair);
      }
      delete $Genesis2::ConfigHandler::extract_stats_hash->{$prm};
  }elsif(UNIVERSAL::isa($prm,'Genesis2::UniqueModule')){
      # if this is a blessed ref it might just be an instance reference
      $db->{InstancePath} = $prm->get_instance_path();  
  }elsif(UNIVERSAL::can($prm,'can') && $prm->can('extract_param_stats')){
      # if this is a blessed ref it might have a extract_param_stats method
      $db->{ref($prm)} = $prm->extract_param_stats($prm);
  }else{
      $self->error("$name: Parameter statistics of type ".ref($prm).
		   " is not supported. Add an 'extract_param_stats' method if you want it to be supported.".
		   "An extract_param_stats method extracts an un-ambigueous structure for xml represantation of the parameter");
  }
  return $db;
}


############################################################
### Extracting data out of the XML structure
############################################################

## sub find_xml_node
## This method returns a pointer to an xml node according to the given (verilog) path
## usage: $self->find_xml_node($path)
sub find_xml_node{
  my $self = shift;
  my $name = __PACKAGE__."->find_xml_node";
  caller eq __PACKAGE__ or
    $self->error("$name: Call to a base class private method is not allowed");
  my $path = shift;
  my @tokens = split(/\./,$path);

  my $pos;
  
  # is there a database?
  if(defined $self->{InXmlDB}){
      $pos = $self->{InXmlDB};
  }else{
      return undef;
  }

  # if there was a database, there must also be a 'top'
  if(defined $pos->{HierarchyTop}){
      $pos = $pos->{HierarchyTop};
  }else{
      $self->error("$name: Found XML file, but no <HierarchyTop> at root");
  }
  
  # is there anything in the database?
  if (exists $pos->{InstanceName}){
      $self->error("$name: Unexpected instance name of top level:\n".
		   "Expected <InstanceName>$tokens[0]</InstanceName>\n".
		   "Found: <InstanceName>$pos->{InstanceName}</InstanceName>") 
	  unless $pos->{InstanceName} =~ /^$tokens[0]$/;
      shift(@tokens);
  }else{
      $self->error("$name: No <InstanceName> node in <HierarchyTop>") 
	  unless ref($pos) eq '' || scalar(%{$pos})==0;
      return undef;
  }	
  
  while(@tokens){
      my $found_one = 0;
      my $token = shift(@tokens);
      if (defined $pos->{SubInstances}){
	  foreach my $SubInstanceItem (@{$pos->{SubInstances}->{SubInstanceItem}}){
	      if (defined $SubInstanceItem->{InstanceName}){
		  if ($SubInstanceItem->{InstanceName} =~ /^$token$/){
		      $pos = $SubInstanceItem;
		      $found_one = 1;
		      last;
		  }
	      }else{
		  $self->error("$name: Cannot find <InstanceName> for one of <SubInstanceItem>");
	      }
	  } # end of foreach loop
      }
      return undef unless $found_one;
  } # end of while loop
  return $pos;
}



## sub extract_param_list_from_xml_db
## This unction takes the db that was generated by xml and returns
## a hash of param names and their corresponding ParameterItem
## in the xml data struct. This ParameterItem can later be processed 
## by extract_param_type_from_xml_db.
sub extract_param_list_from_xml_db{
  my $self = shift;
  my $name = __PACKAGE__."->extract_param_list_from_xml_db";
  caller eq __PACKAGE__ or
    $self->error("$name: Call to a base class private method is not allowed");

  my $xml_ptr = shift;
  my $path = shift; # For debug only
  my $db;

  if (defined $xml_ptr->{Parameters}){
      $xml_ptr = $xml_ptr->{Parameters};
      if (exists $xml_ptr->{ParameterItem}){
	  $self->error("$name: Illegal XML structure <$path>: When using Parameter, only array of ParameterItem allowed")
	      if keys %{$xml_ptr} > 1;
	  $db = {};
	  foreach my $item (@{$xml_ptr->{ParameterItem}}){
	      $self->error("$name: Illegal XML structure <$path>: Parameter has no name")
		  if !exists $item->{Name};
	      $self->error("$name: Illegal XML structure <$path>: Parameter name is not a simple (none-empty) string!")
		  if ref($item->{Name}) ne '';
	      $self->error("$name: Illegal XML structure <$path>: Parameter ".$item->{Name}." defined more than once")
		  if exists $db->{$item->{Name}};
	      delete $item->{Range} if exists $item->{Range};
	      delete $item->{Doc} if exists $item->{Doc};
	      $self->error("$name: Illegal XML structure <$path>: Cell must contain ONE, and ONLY one".
			   "of Val OR HashType OR ArrayType OR InstancePath")
		  if (keys %{$item} != 2);
	      
	      # Now read the content:
	      $db->{$item->{Name}} = $item;
	  }
      }else{
	  $self->error("$name: Illegal XML structure <$path>: When using Parameter, only array of ParameterItem allowed")
	      if keys %{$xml_ptr} > 0;
      }
  }
  return $db;
}


## sub extract_param_type_from_xml_db
## This is the mirror/reverse function of extract_param_stats (see above).
## It takes the db that was generated by xml and generates the normal Perl db.
## Usage: $prm_db = $self->extract_param_type_from_xml_db(ParametrItem, safe_mode, parent)
## * ParametrItem is the raw xml db for a single param
## * If safe_mode==1 then we skip searches for the object represented by InstancePath
sub extract_param_type_from_xml_db{
    my $self = shift;
    my $name = __PACKAGE__."->extract_param_type_from_xml_db";
    caller eq __PACKAGE__ or
	$self->error("$name: Call to a base class private method is not allowed");
    
    my $item = shift;
    my $be_safe = shift;
    my $parent = shift;
    my $db;
    
    $self->error("$name: Illegal XML structure <$parent>: Parameter has no name")
	if !exists $item->{Name};
    $self->error("$name: Illegal XML structure <$parent>: Parameter name is not a simple (none-empty) string!")
	if ref($item->{Name}) ne '';
    $self->error("$name: Illegal XML structure <$parent>: Parameter ".$item->{Name}." defined more than once")
	if exists $db->{$item->{Name}};
    delete $item->{Range} if exists $item->{Range};
    delete $item->{Doc} if exists $item->{Doc};
    $self->error("$name: Illegal XML structure <$parent>: Cell must contain ONE, and ONLY one ".
		 "of Val OR HashType OR ArrayType OR InstancePath")
	if (keys %{$item} != 2);
    my @keys = keys %{$item};
    $self->error("$name: Illegal XML structure <$parent>: Cell must contain ONE, and ONLY one ".
		 "of Val OR HashType OR ArrayType OR InstancePath.\n".
		 " Instead, found: @keys")
	unless ((exists $item->{Val}) | (exists $item->{HashType}) | 
		(exists $item->{ArrayType}) | (exists $item->{InstancePath}));
    
    # Now read the content:
    $db = $self->extract_param_Val_from_xml_db($item->{Val}, $be_safe,
					       $parent.":Val")
	if exists $item->{Val};
    $db = $self->extract_param_Hash_from_xml_db($item->{HashType}, $be_safe,
						$parent.":HashType")
	if exists $item->{HashType};
    $db = $self->extract_param_Array_from_xml_db($item->{ArrayType}, $be_safe,
						 $parent.":ArrayType")
	if exists $item->{ArrayType};
    $db = $self->extract_param_InstPath_from_xml_db($item->{InstancePath}, $be_safe,
						    $parent.":InstancePath")
	if exists $item->{InstancePath};
    return $db;
}


## sub extract_param_Val_from_xml_db
sub extract_param_Val_from_xml_db{
    my $self = shift;
    my $name = __PACKAGE__."->extract_param_Val_from_xml_db";
    caller eq __PACKAGE__ or
	$self->error("$name: Call to a base class private method is not allowed");

    my $prm = shift;
    my $be_safe = shift;
    my $parent = shift; # only used for error messages
    my $db;
    
    # make sure Val is not a compound data type
    $self->error("$name: Illegal XML structure <$parent>: Cell must contain only scalar/string. Found ".ref($prm)." instead!")
	unless ( (ref($prm) eq '') ||                             # this is the typical value extracted from xml
		 ((ref($prm) eq 'HASH') && (keys %{$prm} == 0))); # this is for an empty cell in the xml
    
    # extract the value
    $db = $prm if (ref($prm) eq '');
    $db = '' if (ref($prm) ne '');

      # TO ME: We were worried that someone might submit a Perl script as the value of a parameter. 
      # 	     So as a precaution, we added this check that the value of parameters does not
      # 	     contain perl eval constracts such as 'eval()', \"double quotes\", {execution block} etc.
      $self->error("$name: Unsupported parameter value in xml input: \"$db\"\n".
		   "(Due to security issues with perl eval constracts such as 'eval()', \"double quotes\", {execution block} etc.)\n\n".
		   "Offending expression at $parent\n\n") if 
		   ($db =~ m/\Weval\W/ || # eval command
		    $db =~ m/\(.*\)/ || # parenthesis 
		    $db =~ m/\".*\"/ || # double quotes
		    $db =~ m/\{.*\}/ || # execution block
		    $db =~ m/\Wsystem\s*\(.*\)/ || # system()
		    $db =~ m/\`.*\`/ # back-ticks as system calls
		   ); 	

    return $db;
}

## sub extract_param_Hash_from_xml_db
sub extract_param_Hash_from_xml_db{
    my $self = shift;
    my $name = __PACKAGE__."->extract_param_Hash_from_xml_db";
    caller eq __PACKAGE__ or
	$self->error("$name: Call to a base class private method is not allowed");

    my $prm = shift;
    my $be_safe = shift;
    my $parent = shift; # only used for error messages
    my $db;

    # Make sure this is either empty or a hash that contains HashItem(s)
    $self->error("$name: Illegal XML structure <$parent>: HashType must contain ".
		 " elements of type HashItem (or nothing at all)")
	unless (ref($prm) eq 'HASH' || $prm eq '');

    # extract the value
    $db = {};
    if ($be_safe){
	$db = 'Hash (To be dynamically loaded from XML)';
    }elsif (exists $prm->{HashItem}){
	$self->error("$name: (internal error) How come $parent ->{HashItem} is not an array ref?")
	    if ref($prm->{HashItem}) ne 'ARRAY';
	$self->error("$name: Illegal XML structure <$parent>: HashType must only contain elements of type HashItem")
	    if (keys %{$prm} != 1);
	      
	foreach my $item (@{$prm->{HashItem}}){
	    $self->error("$name: Illegal XML structure <$parent>: HashItem has no Key")
		if !exists $item->{Key};
	    $self->error("$name: Illegal XML structure <$parent>: HashItem's Key is not a simple string")
		if ref($item->{Key}) ne '';
	    $self->error("$name: Illegal XML structure <$parent>: HashItem ".$item->{Key}." defined more than once")
		if exists $db->{$item->{Key}};
	    $self->error("$name: Illegal XML structure <$parent>: Cell must contain ONE, and ONLY one ".
			 "of Val OR HashType OR ArrayType OR InstancePath")
		if (keys %{$item} != 2);
	    my @keys = keys %{$item};
	    $self->error("$name: Illegal XML structure <$parent>: Cell must contain ONE, and ONLY one ".
			 "of Val OR HashType OR ArrayType OR InstancePath.\n".
			 " Instead, found: @keys")
		unless ((exists $item->{Val}) | (exists $item->{HashType}) | 
			(exists $item->{ArrayType}) | (exists $item->{InstancePath}));

	    # Now read the content:
	    $db->{$item->{Key}} = $self->extract_param_Val_from_xml_db($item->{Val}, $be_safe,
								       $parent.":HashItem(".$item->{Key}."):Val")
		if exists $item->{Val};
	    $db->{$item->{Key}} = $self->extract_param_Hash_from_xml_db($item->{HashType}, $be_safe,
									$parent.":HashItem(".$item->{Key}."):HashType")
		if exists $item->{HashType};
	    $db->{$item->{Key}} = $self->extract_param_Array_from_xml_db($item->{ArrayType}, $be_safe,
									 $parent.":HashItem(".$item->{Key}."):ArrayType")
		if exists $item->{ArrayType};
	    $db->{$item->{Key}} = $self->extract_param_InstPath_from_xml_db($item->{InstancePath}, $be_safe,
									    $parent.":HashItem(".$item->{Key}."):InstancePath")
		if exists $item->{InstancePath};
	}
    }else{
	# chcek for HashType with elements which are not HashItem
	$self->error("$name: Illegal XML structure <$parent>: HashType must only contain elements of type HashItem")
	    if (keys %{$prm} != 0);
    }
  return $db;
}

## sub extract_param_Array_from_xml_db
sub extract_param_Array_from_xml_db{
    my $self = shift;
    my $name = __PACKAGE__."->extract_param_Array_from_xml_db";
    caller eq __PACKAGE__ or
	$self->error("$name: Call to a base class private method is not allowed");

    my $prm = shift;
    my $be_safe = shift;
    my $parent = shift; # only used for rror messages
    my $db;

    # Make sure this is either empty or a hash that contains ArrayItem(s)
    $self->error("$name: Illegal XML structure <$parent>: ArrayType must contain ".
		 " elements of type ArrayItem (or nothing at all)")
	unless (ref($prm) eq 'HASH' || $prm->{ArrayType} eq '');

    # extract the value
    $db = [];
    if ($be_safe){
	$db = 'Array (To be dynamically loaded from XML)';
    }elsif (exists $prm->{ArrayItem}){
	$self->error("$name: (internal error) How come $parent ->{ArrayItem} is not an array ref?")
	    if ref($prm->{ArrayItem}) ne 'ARRAY';
	my $idx = 0;
	foreach my $item (@{$prm->{ArrayItem}}){
	    $self->error("$name: Illegal XML structure <$parent>: Cell must contain ONE, and ONLY one ".
			 "of Val OR HashType OR ArrayType OR InstancePath")
		if (keys %{$item} != 1);
	    my @keys = keys %{$item};
	    $self->error("$name: Illegal XML structure <$parent>: Cell must contain ONE, and ONLY one ".
			 "of Val OR HashType OR ArrayType OR InstancePath.\n".
			 " Instead, found: @keys")
		unless ((exists $item->{Val}) | (exists $item->{HashType}) | 
			(exists $item->{ArrayType}) | (exists $item->{InstancePath}));
	    
	    # Now read the content:
	    my $content;
	    $content = $self->extract_param_Val_from_xml_db($item->{Val}, $be_safe,
							    $parent.":ArrayItem(".$idx."):Val")
		if exists $item->{Val};
	    $content = $self->extract_param_Hash_from_xml_db($item->{HashType}, $be_safe,
							     $parent.":ArrayItem(".$idx."):HashType")
		if exists $item->{HashType};
	    $content = $self->extract_param_Array_from_xml_db($item->{ArrayType}, $be_safe,
							      $parent.":ArrayItem(".$idx."):ArrayType")
		if exists $item->{ArrayType};
	    $content = $self->extract_param_InstPath_from_xml_db($item->{InstancePath}, $be_safe,
								 $parent.":ArrayItem(".$idx."):InstancePath")
		if exists $item->{InstancePath};
	    
	    push (@{$db}, $content);
	    $idx++;
	}
    }else{
	# chcek for ArrayType with elements which are not ArrayItem
	$self->error("$name: Illegal XML structure <$parent>: ArrayType must only contain elements of type ArrayItem")
	    if (keys %{$prm} != 0);
    }
  return $db;
}

## sub extract_param_InstPath_from_xml_db
sub extract_param_InstPath_from_xml_db{
    my $self = shift;
    my $name = __PACKAGE__."->extract_param_InstPath_from_xml_db";
    caller eq __PACKAGE__ or
	$self->error("$name: Call to a base class private method is not allowed");

    my $prm = shift;
    my $be_safe = shift;
    my $parent = shift; # only used for error messages
    my $db;
    
    # make sure InstancePath is not a compound data type
    $self->error("$name: Illegal XML structure <$parent>: Cell must contain only string")
	if (ref($prm) ne '');
    
    # extract the value
    $db = $self->{TopObj}->get_instance_obj($prm) if (!$be_safe);
    $db = "InstancePath:$prm (preview -- to be dynamically loaded from XML as instance pointer)" if ($be_safe);
    return $db;
}

############################################################
### Extract Data From Config File
############################################################
sub read_cfg_file{
    my $self = $Genesis2::ConfigHandler::myself;
    my $name = __PACKAGE__."->read_cfg_file";
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_user_code = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	if ($filename !~ m/^\(eval \d*\)$/ && $package ne __PACKAGE__ && $package ne 'Genesis2::UserConfigBase'){
	    $is_user_code = 1;
	    last;
	}
    }
    die "\n\tERROR: $name: Called by $package outside of configuration time (Line $line File $filename) Died" 
	unless $Genesis2::ConfigHandler::readcfg_on && $Genesis2::ConfigHandler::myself;
    caller eq __PACKAGE__ || caller eq 'Genesis2::UserConfigBase' || caller eq 'Genesis2::UserConfigScript'  
	or $self->error("$name: Private Method: Access restricted to ".__PACKAGE__.
			", Genesis2::UserConfigBase, Genesis2::UserConfigScript -- Found ".caller);

    my $fname = shift or $self->error("$name: File Name Not Specified");
    my ($fh, $readdline, $readdlines);
    my $dont_die_on_empty_cfg_files = "\n1;";
    
    $fname = $self->find_file($fname, $self->{ConfigsPath});
    open ($fh,"<$fname") ||
	$self->error("$name: Couldn't open config file '$fname': $!");

    $readdlines = "# line 1 \"$fname\"\n";
    while($readdline = <$fh>){
	$readdlines .= $readdline; 
	$dont_die_on_empty_cfg_files = '' unless $readdline =~ m/^\s*(\#.*)?$/ ; # this means an empty or a comment line.
    }
    close($fh);
    $readdlines .= $dont_die_on_empty_cfg_files;
    print "Found config file $fname: \n$readdlines\nEnd of config file $fname\n" if $self->{Debug} & 4;
    return $readdlines;
}

sub configure{
    my $self = $Genesis2::ConfigHandler::myself;
    my $name = __PACKAGE__."->configure";
    my $g2_package = __PACKAGE__;
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_user_code = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	if ($filename !~ m/^\(eval \d*\)$/ && $filename !~ m/^$g2_package/ && 
	    $package ne __PACKAGE__ && $package ne 'Genesis2::UserConfigBase'){
	    $is_user_code = 1;
	    last;
	}
    }

    die "\n\tERROR: $name: Called by $package outside of configuration time (Line $line File $filename) Died" 
	unless $Genesis2::ConfigHandler::readcfg_on && $Genesis2::ConfigHandler::myself;
    caller eq __PACKAGE__ || caller eq 'Genesis2::UserConfigBase' || caller eq 'Genesis2::UserConfigScript'  
	or $self->error("$name: Private Method: Access restricted to ".__PACKAGE__.
			", Genesis2::UserConfigBase, Genesis2::UserConfigScript -- Found ".caller);

    $self->error("$name: First argument must be of kind path.to.param") unless @_;
    my $path_to_prm = shift;
    $self->error("$name: Second argument must be parameter value.") unless @_;
    my $val = shift;
    $self->error("$name: Only two arguments expected. Found: $path_to_prm, $val, @_") if @_;

    $path_to_prm =~ m/^((\w+\.)*\w+)\.\w+$/;
    my $path = $1;
    $path_to_prm =~ m/^($path)\.(\w+)$/;
    my $prm = $2;
    $self->error("$name: Expected first argument structure to have both path and param name separated by a dot.\n".
		 "\tExample: 'top.dut.subinst.prmname'. Found: '$path_to_prm'")
	unless ($path && $prm);
    if (exists $self->{InCfgDB}->{$path} && exists $self->{InCfgDB}->{$path}->{$prm}){
	my $val1_str = $self->PrintToString($self->{InCfgDB}->{$path}->{$prm}->{Val}, depth=>3, prefix=>"  " );
	my $val2_str = $self->PrintToString($val, depth=>3, prefix=>"  " );
	print STDERR 
	    "WARNING: Config file re-definition of $path_to_prm:\n".
	    "    Previous definition at Line $self->{InCfgDB}->{$path}->{$prm}->{FromLine} of File $self->{InCfgDB}->{$path}->{$prm}->{FromFile}\n".
	    "      ${val1_str}\n".
	    "    New definition at Line $line of File ".fileparse($filename)."\n".
	    "      ${val2_str}\n";
    }

    $self->{InCfgDB}->{$path}->{$prm}->{FromLine} = $line;
    $self->{InCfgDB}->{$path}->{$prm}->{FromFile} = fileparse($filename);
    $self->{InCfgDB}->{$path}->{$prm}->{Val} = $self->deep_copy($val);
    $self->{InCfgDB}->{$path}->{$prm}->{State} = 'NeverUsed'; 
    1;
}
sub remove_configuration{
    my $self = $Genesis2::ConfigHandler::myself;
    my $name = __PACKAGE__."->remove_configuration";
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_user_code = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	if ($filename !~ m/^\(eval \d*\)$/ && $package ne __PACKAGE__ && $package ne 'Genesis2::UserConfigBase'){
	    $is_user_code = 1;
	    last;
	}
    }
    die "\n\tERROR: $name: Called by $package outside of configuration time (Line $line File $filename) Died" 
	unless $Genesis2::ConfigHandler::readcfg_on && $Genesis2::ConfigHandler::myself;
    caller eq __PACKAGE__ || caller eq 'Genesis2::UserConfigBase' || caller eq 'Genesis2::UserConfigScript'  
	or $self->error("$name: Private Method: Access restricted to ".__PACKAGE__.
			", Genesis2::UserConfigBase, Genesis2::UserConfigScript -- Found ".caller);

    $self->error("$name: First argument must be of kind path.to.param") unless @_;
    my $path_to_prm = shift;
    $self->error("$name: Only One argument expected. Found: $path_to_prm, @_") if @_;

    $path_to_prm =~ m/^((\w+\.)*\w+)\.\w+$/;
    my $path = $1;
    $path_to_prm =~ m/^($path)\.(\w+)$/;
    my $prm = $2;
    $self->error("$name: Expected first argument structure to have both path and param name separated by a dot.\n".
		 "\tExample: 'top.dut.subinst.prmname'. Found: '$path_to_prm'")
	unless ($path && $prm);
    print STDERR "\tWARNING:\tConfig file asks to REMOVE previous config file definition of $path_to_prm: ".
	"Was '$self->{InCfgDB}->{$path}->{$prm}->{Val}' -- At Line $line of File $filename\n"
      if exists $self->{InCfgDB}->{$path} && exists $self->{InCfgDB}->{$path}->{$prm};

    delete $self->{InCfgDB}->{$path}->{$prm};
    1;
}

sub exists_configuration{
    my $self = $Genesis2::ConfigHandler::myself;
    my $name = __PACKAGE__."->exists_configuration";
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_user_code = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	if ($filename !~ m/^\(eval \d*\)$/ && $package ne __PACKAGE__ && $package ne 'Genesis2::UserConfigBase'){
	    $is_user_code = 1;
	    last;
	}
    }
    die "\n\tERROR: $name: Called by $package outside of configuration time (Line $line File $filename) Died" 
	unless $Genesis2::ConfigHandler::readcfg_on && $Genesis2::ConfigHandler::myself;
    caller eq __PACKAGE__ || caller eq 'Genesis2::UserConfigBase' || caller eq 'Genesis2::UserConfigScript'  
	or $self->error("$name: Private Method: Access restricted to ".__PACKAGE__.
			", Genesis2::UserConfigBase, Genesis2::UserConfigScript -- Found ".caller);

    my $path_to_prm = shift or $self->error("$name: First argument must be of kind path.to.param");
    $self->error("$name: Only one argument expected. Found: $path_to_prm, @_") if @_;

    $path_to_prm =~ m/^((\w+\.)*\w+)\.\w+$/;
    my $path = $1;
    $path_to_prm =~ m/^($path)\.(\w+)$/;
    my $prm = $2;
    $self->error("$name: Expected first argument structure to have both path and param name separated by a dot.\n".
		 "\tExample: 'top.dut.subinst.prmname'. Found: '$path_to_prm'")
	unless ($path && $prm);
    return 1 if exists $self->{InCfgDB}->{$path} && exists $self->{InCfgDB}->{$path}->{$prm};
    return 0;
}

sub get_configuration{
    my $self = $Genesis2::ConfigHandler::myself;
    my $name = __PACKAGE__."->get_configuration";
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_user_code = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	if ($filename !~ m/^\(eval \d*\)$/ && $package ne __PACKAGE__ && $package ne 'Genesis2::UserConfigBase'){
	    $is_user_code = 1;
	    last;
	}
    }
    die "\n\tERROR: $name: Called by $package outside of configuration time (Line $line File $filename) Died" 
	unless $Genesis2::ConfigHandler::readcfg_on && $Genesis2::ConfigHandler::myself;
    caller eq __PACKAGE__ || caller eq 'Genesis2::UserConfigBase' || caller eq 'Genesis2::UserConfigScript'  
	or $self->error("$name: Private Method: Access restricted to ".__PACKAGE__.
			", Genesis2::UserConfigBase, Genesis2::UserConfigScript -- Found ".caller);
    
    my $path_to_prm = shift or $self->error("$name: First argument must be of kind path.to.param");
    $self->error("$name: Only one argument expected. Found: $path_to_prm, @_") if @_;
    $self->error("$name: Could not find parameter '$path_to_prm'") unless exists_configuration($path_to_prm);

    $path_to_prm =~ m/^((\w+\.)*\w+)\.\w+$/;
    my $path = $1;
    $path_to_prm =~ m/^($path)\.(\w+)$/;
    my $prm = $2;
    $self->error("$name: Expected first argument structure to have both path and param name separated by a dot.\n".
		 "\tExample: 'top.dut.subinst.prmname'. Found: '$path_to_prm'")
	unless ($path && $prm);
    return $self->deep_copy($self->{InCfgDB}->{$path}->{$prm}->{Val});
}

sub print_configuration{
    my $self = $Genesis2::ConfigHandler::myself;
    my $name = __PACKAGE__."->configuration";
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_user_code = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	if ($filename !~ m/^\(eval \d*\)$/ && $package ne __PACKAGE__ && $package ne 'Genesis2::UserConfigBase'){
	    $is_user_code = 1;
	    last;
	}
    }
    die "\n\tERROR: $name: Called by $package outside of configuration time (Line $line File $filename) Died" 
	unless $Genesis2::ConfigHandler::readcfg_on && $Genesis2::ConfigHandler::myself;
    caller eq __PACKAGE__ || caller eq 'Genesis2::UserConfigBase' || caller eq 'Genesis2::UserConfigScript'  
	or $self->error("$name: Private Method: Access restricted to ".__PACKAGE__.
			", Genesis2::UserConfigBase, Genesis2::UserConfigScript -- Found ".caller);

    print STDERR "\n\n    Begin Configuration Setting By Config Script:\n";
    print STDERR     "=====================================================\n";
    foreach my $path (sort keys %{$self->{InCfgDB}}){
	foreach my $prm (sort keys %{$self->{InCfgDB}->{$path}}){
	    print STDERR "At path $path, parameter $prm = ";
	    print STDERR  $self->PrintToString($self->{InCfgDB}->{$path}->{$prm}->{Val}, depth=>1, prefix=>"\t" );
	    print STDERR "\n\n";
	}
	print STDERR "\n";
    }
    1;
}

sub get_top_name{
    return $Genesis2::ConfigHandler::myself->{Manager}->{Top};
}
sub get_synthtop_path{
    return $Genesis2::ConfigHandler::myself->{Manager}->{SynthTop};
}

sub user_error{
    my $self = $Genesis2::ConfigHandler::myself;
    my $name = __PACKAGE__."->user_error";
    my $package = '-'; my $filename = '-'; my $line = '-'; my $subroutine = '-';
    my $i = 0; my $is_user_code = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	if ($filename !~ m/^\(eval \d*\)$/ && $package ne __PACKAGE__ && $package ne 'Genesis2::UserConfigBase'){
	    $is_user_code = 1;
	    last;
	}
    }
    die "\n\tERROR: $name: Called by $package outside of configuration time (Line $line File $filename) Died" 
	unless $Genesis2::ConfigHandler::readcfg_on && $Genesis2::ConfigHandler::myself;
    caller eq __PACKAGE__ || caller eq 'Genesis2::UserConfigBase' || caller eq 'Genesis2::UserConfigScript'  
	or $self->error("$name: Private Method: Access restricted to ".__PACKAGE__.
			", Genesis2::UserConfigBase, Genesis2::UserConfigScript -- Found ".caller);
    $self->error(@_);
}

############################################################
### General subroutines
############################################################

## sub error
## usage: $self->error("error message");
sub error {
    my $name = __PACKAGE__."->error";
    my $self = shift;
    my $message= shift;
    my ($prefix, $prefix0, $prefix1, $prefix2, $perlmsg, $suffix1);
    my @message_arr = ();
    print STDERR "\n\n";
    my ($package, $filename, $line, $subroutine);
    
    my $i = 0; my $is_user_code = 0;
    while (($package, $filename, $line, $subroutine) = caller($i++)){
	#print STDERR "DEBUG: Caller($i): $package, $filename, $line, $subroutine\n";
	last if ( $package eq 'main' || $package eq 'PAR' ); # No chance it is user code if we're here
	if ( # this is a config script, but we must find the actual file name
	     ($package =~ /^Genesis2::UserConfigScript$/ && $filename !~ /^\(eval \d+\)$/ && $filename !~ /^Genesis2(\/|::)/) ||
	     # this is a user's package, NOT a "Genesis2::" one (it is just calling Genesis2::UserConfigBase::error)
	     ($package !~ /^Genesis2::/ && $filename !~ /^\(eval \d+\)$/ && $filename !~ /^Genesis2(\/|::)/) 
	    )
	     {
	    #print STDERR "DEBUG1: Caller($i): $package, $filename, $line, $subroutine\n";
	    $is_user_code = 1;
	    last;
	}
    }
    
    $prefix0 = "ERROR    ERROR    ERROR    ERROR    ERROR    ERROR    ERROR    ERROR\n";
    $prefix1 = '';
    $prefix1 = "ERROR While processing line $line of file $filename\n" if $is_user_code;
    $prefix2 = "ERROR Genesis2::ConfigHandler Message:\n";
    $prefix = $prefix0.$prefix1.$prefix2;
    $suffix1 = "Exiting Genesis2 due to fatal error... bye bye... \n\n";
    
    
    #print to file as well as to stderr
    @message_arr = split(/\n/, $message);
    print "\n".$prefix."\n";
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
  my ($dir, $filefound);
  if (@_){
    $path = shift;
  }

  # find the file:
  $filefound = 0;
  print "$name: Searching for file $file\n" if $self->{Debug} & 2;
  if ($file =~ /^\//) {
    # file is absolute path
    $filefound = 1 if (-e $file);
  }
  else {
    foreach $dir ($self->{CallDir}, @{$path}) {
	# if relative path, start it from the dir from which the script was called
	unless ($dir =~ /^\//) { $dir = $self->{CallDir}."/".$dir;}

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


sub internal_print_to_string{
    my $self = shift;
    my $name = __PACKAGE__."->internal_print_to_string";
    caller eq __PACKAGE__ or
	$self->error("$name: Call to a base class private method is not allowed");

    my $item = ''; $item = shift;
    my %options = @_;
    my $prefix = '';  $prefix = $options{prefix} if defined $options{prefix};
    my $depth = 1;    $depth = $options{depth} if defined $options{depth};
    my $space = '  '; $space = $options{space} if defined $options{space};
    my $out = '';
    my $indent = $space x $depth;
    my $prev_indent = $space x ($depth-1);
    my $ref=ref($item);

    $out .= "\n" if $ref ne ''  && $depth == 1; 

    if (!defined $item){
	$out .= 'undef';
    }elsif ($ref eq '') {
	$item = sprintf("0x%x", $item) if (looks_like_number($item) && $item > 128);
	$out .= "${item}";
    }elsif (defined $Genesis2::ConfigHandler::print_to_string_hash->{$item}){
	# If this pointer was seen already, don't copy again (avoid infinite loops)
	$out .= "Recursive pointer to '".ref($item)."'";
    }elsif ($ref eq 'ARRAY'){
	$Genesis2::ConfigHandler::print_to_string_hash->{$item} = 1;
	my $not_one_line = 0;
	$out .= "[ ";
	for (my $idx = 0; $idx < @{$item}; $idx++){
	    my $element  = $item->[$idx];
	    $out .= $self->internal_print_to_string($element, depth=>$depth+1);
	    $out .= ", " if (ref($element) eq '' && $idx+1<@{$item});          # add comma unless last item
	    $out .= ",\n${indent}" if (ref($element) ne '' && $idx+1<@{$item});# add comma and new line if last element was struct unless last item
	    $out .= "\n${indent}" if (ref($element) eq '' && $idx+1<@{$item} && $idx>0 && ($idx+1)%8==0);# add new line if many simple elements unless last item
	    $not_one_line = 1 if (ref($element) ne '');
	}
	$out .= "\n$prev_indent" if ($not_one_line);	    
	$out .= " " unless ($not_one_line);	    
	$out .= "]";
	delete $Genesis2::ConfigHandler::print_to_string_hash->{$item};
    }elsif ($ref eq 'HASH'){
	$Genesis2::ConfigHandler::print_to_string_hash->{$item} = 1;
	my $not_one_line = 0;
	$out .= "{ ";
	my @keys = sort keys %{$item};
	for (my $idx = 0; $idx < @keys; $idx++){
	    my $key = $keys[$idx];
	    $out .= "\n${indent}" if (ref($item->{$key}) ne '' && $idx != 0 && ref($item->{$keys[$idx-1]}) eq ''); # if struct and prev item was not struct
	    $out .= "${key}=>";
	    $out .= "\n${indent}" if (ref($item->{$key}) ne ''); 
	    $out .= $self->internal_print_to_string($item->{$key}, depth=>$depth+1);
	    $out .= ", " if (ref($item->{$key}) eq '' && $idx+1<@keys);          # add comma unless last item
	    $out .= ",\n${indent}" if (ref($item->{$key}) ne '' && $idx+1<@keys);# add comma and new line if last element was struct unless last item
	    $out .= "\n${indent}"  if (ref($item->{$key}) eq '' && $idx+1<@keys && $idx>0 && ($idx+1)%8==0);# add new line if many simple elements unless last item
	    $not_one_line = 1 if (ref($item->{$key}) ne '');
	}
	$out .= "\n${prev_indent}" if ($not_one_line);	    
	$out .= " " unless ($not_one_line);	    
	$out .= "}";
	delete $Genesis2::ConfigHandler::print_to_string_hash->{$item};
    }elsif(UNIVERSAL::isa($item,'Genesis2::UniqueModule')){
	# if this is a blessed ref it might just be an instance reference
	$out .= "InstancePath:".$item->get_instance_path()." (".$item->mname().")";  
    }elsif(UNIVERSAL::can($item,'can') && $item->can('to_string')){
	# if this is a blessed ref it might have a to_string method
	$out .= $item->to_string($item);
    }else{
	$out .= "${item}";
    }
    $out =~ s/\n/\n$prefix/g if $prefix ne ''; # add line prefix if needed
    return $out;
}


# private: deep_copy
# Deep copy of hash and array structures
sub deep_copy{
  my $self = shift;
  my $name = $self->{BaseModuleName}."->deep_copy";
  caller eq __PACKAGE__ or
    $self->error("$name: Call to a base class private method is not allowed");
  
  # create a local stack of addresses that I visited to avoid endless loops
  local $Genesis2::ConfigHandler::deep_copy_hash = {};
  return $self->internal_deep_copy(@_);
}

sub internal_deep_copy{
  my $self = shift;
  my $name = __PACKAGE__."->internal_deep_copy";
  caller eq __PACKAGE__ or
    $self->error("$name: Call to a base class private method is not allowed");

  my $src = shift;
  my $type = ref($src);
  my $trgt;

  if (!defined $src){
      $trgt = $src;
  }
  elsif ($type eq ''){ # not a reference
      $trgt = $src;
  }elsif (defined $Genesis2::ConfigHandler::deep_copy_hash->{$src}){
      # If this pointer was seen already, don't copy again (avoid infinite loops)
      $trgt = $Genesis2::ConfigHandler::deep_copy_hash->{$src};
  }elsif($type eq 'SCALAR'){
      my $tmp = $self->internal_deep_copy(${$src});
      $trgt = \$tmp;
  }elsif($type eq 'ARRAY'){
      $trgt = [];
      $Genesis2::ConfigHandler::deep_copy_hash->{$src} = $trgt; # keep for your records
      foreach my $element (@{$src}){
	  push(@{$trgt}, $self->internal_deep_copy($element));
      }
      delete $Genesis2::ConfigHandler::deep_copy_hash->{$src};
  }elsif($type eq 'HASH'){
      $trgt = {};
      $Genesis2::ConfigHandler::deep_copy_hash->{$src} = $trgt; # keep for your records
      foreach my $key (keys %{$src}){
	  $trgt->{$key} = $self->internal_deep_copy($src->{$key});
      }
      delete $Genesis2::ConfigHandler::deep_copy_hash->{$src};
  }elsif($src==$self){
      $self->error("$name: Cannot deep_copy self... Only other structures");
  }elsif(UNIVERSAL::can($src,'can')){
      # if this is a blessed ref it might have a deep_copy method
      if ($src->can('deep_copy')){
	  $trgt = $src->deep_copy($src);
      }else{
	  # I guess it does not have a deep_copy method...
	  $self->error("$name: src of type ".ref($src).
		       " is not supported (perhaps add a ".ref($src).
		       "->deep_copy method?)");
      }
  }else{
      $self->error("$name: src of type ".ref($src).
		   " is not supported (perhaps make it a blessed reference and add a ".ref($src).
		   "->deep_copy method?)");
  }
  return $trgt;
}

1;
