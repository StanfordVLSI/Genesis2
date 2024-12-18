#!/usr/bin/env perl

#/*************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/TileTest/TileGenTest/scripts/RunSingleTest.pl#12 $
# ** $DateTime: 2010/07/19 21:43:40 $
# ** $Change: 8924 $
# ** $Author: shacham $
# *************************************************************************/


## included libraries:
######################
use Cwd;
use Cwd 'abs_path';
use Getopt::Long;
use File::Basename;
use File::Copy;
use File::Path;
use strict;

# package for handling command line options
use lib "$ENV{PROCESSOR_HOME}/Hardware/scripts";
use Options;

# package for handling and compiling diags:
use lib "$ENV{SMASH}/TileTest/TileGenTest/scripts";
use TileGen_DiagBuild;



print "***********************************************************\n";
print "************   RunSingleTest (tile) Started   *************\n";
print "***********************************************************\n";
print "\n---Command line: RunSingleTest.pl @ARGV\n";



# Environment variables
#########################
my $smash = $ENV{'SMASH'};
my $user = $ENV{'USER'};
my $testbench = $ENV{'TILEGEN_HOME'};

# Check all environment variables
if (!$smash || !$user || !$testbench){
  print "\nERROR: Missing environment definitions\n";
  print   "\tHint: First source \$SMASH/bin/setup.cshrc\n";
  system ("touch TEST_FAIL");
  exit 1;
}

# Global variable declaration
##############################
my $rtl = $smash . "/rtl/";
my $env_rtl = $smash . "/Env_rtl/";
my $configsDir = $testbench."/SysCfgs";
my $cur_path = getcwd();
my $home_path = abs_path($rtl);
my $test_path = abs_path($testbench);

my $Date=`date +%h%d_%H%M`;
chop($Date); #removing the carriage return
my $CommandLine = "RunSingleTest.pl @ARGV";
my $OutFile = '';


# declare some local variables
my $RTLBuildDir = 'RTLBuild';
my $executable = 'simv';
my $diagBuild_obj;
################################### MAIN SCRIPT BODY #########################

# Parse input
##############
print "\n";
print "--- Parsing input arguments ---\n";
ParseCommandLine();
CheckOptions();

# Output file
$OutFile = "TileTest_date${Date}__seed".getOption('seed').".log";

# cd rundir
print "cd ".getOption('rundir')."\n";
chdir getOption('rundir')
  or die "\nERROR: Cannot change directory to ".getOption('rundir');
print "*** Done parsing input arguments...\n\n";

# compare the current path to the home path:
if ( $cur_path eq $home_path or $cur_path eq $test_path){
  print "\n";
  print "WARNING: You are working in the rtl or test folder!!\n";
  print "\tIt is recomended to run the QuadShim environment from a seperate folder\n";
  print "\n\nContinuing Test-Run in spite of warring...\n";
  exit (7);
}

# Print parsed options to screen:
PrintOptionMessage();



# Actual Build + Test Sequence:
###############################
print "\n------ Build Sequence ------\n";
print   "----------------------------\n";
#compile rtl
RTLBuild();

# compile diags
my @expended_diags_list = DiagBuild();


print "\n------ Execute Sequence ------\n";
print   "------------------------------\n";
foreach my $diag (@expended_diags_list){
  # Now start the test:
  Execute($diag);
}

print "\n------ Cleanup/Stats ------\n";
print   "---------------------------\n";
CleanAndStats(@expended_diags_list);

# IF NO ERRORS ==> ALWAYS FINISH TEST WITH ZERO EXIT CODE
#############################################################
print "***********************************************************\n";
print "*************   RunSingleTest (tile) Ended   **************\n";
print "***********************************************************\n";
exit 0;





################################################################################
########################## AUXILIARY FUNCTIONS #################################
################################################################################

# Function PrintHelp()
sub PrintHelp {

  print <<END_OF_MESSAGE;


***    RunSingleTest.sh -QuadShim - Usage Manual    ***
*******************************************************
RunSingleTest.sh [-option <value>]...

Possible options and values are:
 ## General Options
  -Clean                : Clean previous object files before running (default is 1)
  -Seed     num         : Set seed for random generator (default is 12345)
  -Wave                 : Run test with wave trace
  -MaxTime  num         : Maximum number of cycles for test to run
                          If this cycle limit is exceeded the test will stop
                          with an ERROR status.
  -email <recipient>	: Send final report summary to email recipient. Flag can be
			  used more than once to specify multiple recipients.
  -rundir dir           : Run test in directory dir, dir will be created if it doesn't
                          exist
  -skipBuild <rtl|libsim|lsp|diag|all>
			: Skip the compilation process for the RTL/Libsim library/
			  LSP/Diag/ALL. Multiple builds can be skipped using (for example)
			  -skipBuild diag_rtl.
  -help or -h           : Print this help

 ## Genesis2 elaborator
  -ConfigFile file      : Gives xml config file to Genesis compile stage.
  -parseGenesis <string>: Pass arguments to the Genesis2 tool for PARSING phase
  -genGenesis <string>	: Pass arguments to the Genesis2 tool for verilog GENERATION phase

 ## RTL compile/runtime options
  -makeRTL <string>	: Pass arguments to VCS tool for verilog compile phase
  -runtimeRTL <string>	: Pass arguments to VCS tool for runtime (i.e. runtime arguments
			  to the simv executable)

 ## Diag's compile/runtime options
  -diag <diag_name> or <diag_list_file>
			: Specify either a diag dir, a root directory of many diag dirs,
			  or a file containing a list diags.
			  Note that a diag with name XYZ implies that the folder XYZ has a
			  local makefile to make that diag (see tensilica diags for examples)
  -diagsDir		: Specify a root folder for diags. Default is ''.
  -memmap <file>        : Supply memory map file to use when compiling diags;
                          this option is required unless -nocompile is used.
  -makeDiag <string>	: Pass arguments to the Tensilica compiler tool for diag compilation
  -runtimeDiag <string>	: Pass arguments needed by the diag at runtime (i.e., to be read 
			  in software through argv and argc)

  Ofer/Andrew -- FIXME: Put execution examples here!

  Notes:
  1. The RTL+Environment code is compiled, and the compilation output
     is redirected to Makefile.log and Clean.logfile.
  2. By default old *.log files are removed before test sequence starts.
     =>Change your log files suffix in order to keep them.

  For bug reporting, modifications and questions, contact Danowitz or Shacham:
         danowitz\@stanford.edu
         shacham\@stanford.edu


END_OF_MESSAGE

}

#-------------------------------------------------------------------------------
sub Execute{
  my $diag = shift;
  my @runtime_args=();
  my ($return_val, $ExitStatus, $IsFinish, $IsError);
  my $cur_path = getcwd();

  ################################################################
  ####### DO NOT BREAK THE FOLLOWING EXECUTION BLOCK #############
  # cd to run folder
  chdir $diag->{Name} unless $diag->{Name} eq 'NoDiag';

  # remove old test files
  if( optionEnabled('clean') ){
    print "Cleaning run dir...\n";
    system ("rm -f Clean.logfile");
    system ("make -f $testbench/Makefile clean &> Clean.logfile");
  }

  # remove old TEST_PASS/FAIL files:
  system ("rm -f TEST_PASS TEST_FAIL");


  print "\n----- Running Test $diag->{Name}-----\n";


  # Any RTL runtime time definitions?
  push(@runtime_args, getOption('runtimeRTL')) if (optionOn('runtimeRTL'));
  push(@runtime_args, "+wave") if (optionOn('wave'));
  push(@runtime_args, "+seed=".getOption('seed'));
  push(@runtime_args, "+AppArgs=\"".$diag->{RuntimeArgs}."\"") 
    unless (($diag->{RuntimeArgs} eq 'NoDiag') ||
	    ($diag->{RuntimeArgs} eq ''));


  # START THE TEST
  $diag->{TestResult} = 'FAIL: Test started but never revisited';
  open(OUTFILE, ">", $OutFile);
  print OUTFILE "---Command line: $CommandLine\n";
  print OUTFILE "-------------------------------------------------------------\n";
  close(OUTFILE);
  print "run: ${RTLBuildDir}/${executable} @runtime_args >> $OutFile 2>&1\n";
  system ("${RTLBuildDir}/${executable} @runtime_args >> $OutFile 2>&1");

  #Check test status
  $return_val=$?;
  $ExitStatus = `grep "exit_status" $OutFile`;
  if ( $ExitStatus )
    {
      chop ($ExitStatus);#removing the carriage return
      $ExitStatus =~ s/\D*//; #take only the number
      $return_val |= $ExitStatus;
    }
  $IsFinish=`grep \"TEST FINISHED\" $OutFile`;
  $IsError=`grep ERROR *.log`;
  if ( $return_val ){
    print "";
    print "********* Exit code is ${return_val} ************************\n";
    print "**************** Test FAIL **********************\n";
    print "******************* Test FAIL *******************\n";
    $diag->{TestResult} = "FAIL: Exit code is ${return_val}";
    system ("touch TEST_FAIL");
    exit ${return_val};
  }elsif ( $IsError ){
    print "\n";
    print "************** Error(s) Detected ****************\n";
    print "**************** Test FAIL **********************\n";
    print "******************* Test FAIL *******************\n";
    $diag->{TestResult} = "FAIL: Error(s) Detected";
    system ("touch TEST_FAIL");
    exit 7;
  }elsif ( !($IsFinish) ){
    print "\n";
    print "*** Cannot Find \"Test Finished\" declaration ****\n";
    print "**************** Test FAIL **********************\n";
    print "******************* Test FAIL *******************\n";
    $diag->{TestResult} = "FAIL: Cannot Find \"Test Finished\" declaration";
    system ("touch TEST_FAIL");
    exit 7;

  }else{
    print "\n";
    print "**************** Test PASS **********************\n";
    print "******************* Test PASS *******************\n";
    $diag->{TestResult} = "PASS";
    system ("touch TEST_PASS");
  }

################## EXECUTION BLOCK END ######################
#############################################################
  chdir $cur_path;
}



#-------------------------------------------------------------------------------
# Compile test files (vera and verilog)
sub RTLBuild{
  my ($cur_path, $return_val);
  my @compile_args = ();

  print "\n----- Making RTL -----\n";

  # Do you really want to build RTL?
  if (optionOn('skipBuild')){
    if (getOption('skipBuild') =~ m/rtl/i ||
	getOption('skipBuild') =~ m/all/i){
      print "- Skipping RTL build -\n";
      if (-d "$RTLBuildDir" && -x "$RTLBuildDir/$executable"){
	$RTLBuildDir = abs_path($RTLBuildDir);
      }else{
	die"Cannot skip RTL build: $RTLBuildDir/$executable does not exists";
      }
      return 1;
    }
  }

  # cd to a build rtl folder
  $cur_path = getcwd();
  mkpath($RTLBuildDir);
  $RTLBuildDir = abs_path($RTLBuildDir);
  print "cd $RTLBuildDir\n";
  chdir($RTLBuildDir);

  if( optionEnabled('clean') ){
    print "Cleaning $RTLBuildDir dir...\n";
    system ("rm -f Clean.logfile");
    system ("make -f $testbench/Makefile clean &> Clean.logfile");
  }

  # Any Genesis parsing time definitions?
  if (optionOn('parseGenesis')){
    push(@compile_args, "PARSE=\"".getOption('GenesisParse')."\"");
  }

  # Any Genesis generation time definitions?
  if (optionOn('genGenesis')){
    push(@compile_args, "GEN=\"".getOption('GenesisGen')."\"");
  }
  if (optionOn('configFile')){   
    push(@compile_args, "GENESIS_CFG_XML=".getOption('configFile'));
  }

  # Any RTL compile time definitions?
  if (optionOn('makeRTL')){
    push(@compile_args, "COMP=\"".getOption('makeRTL')."\"");
  }

  # '&>' means redirect stdout and stderr to file
  system ("make -f $testbench/Makefile $executable @compile_args &> RTLBuild.log");
  $return_val=$?;

  # return to rundir
  chdir($cur_path);
  print "cd back to $cur_path\n";

  if ($return_val){
    print "ERROR: RunSingleTest Can not compile testbench + RTL\n";
    print "\tPlease see $RTLBuildDir/RTLBuild.log for more details\n";
    system ("touch TEST_FAIL");
    exit 1;
  }
  1;
}


#-------------------------------------------------------------------------------
# sub DiagBuild
# This function expands the diag list, builds the directories and compiles all 
# diags. It returns an array of tests' structures representing an expanded diag 
# to be run. Each hash contains the following fields:
# * Name
# * Dir
# * CompileResult
# * MakeArgs
# * RuntimeArgs
# * TestResult
sub DiagBuild{
  # if there was no diag specified -- return a list with only one (NoDiag) item
  return (({Name=>'NoDiag',
	    Dir=>'NoDiag',
	    CompileResult=>'NoDiag',
	    MakeArgs=>'NoDiag',
	    RuntimeArgs=>'NoDiag',
	    TestResult=>'FAIL: Test did not run yet'})) if optionOff('diag');

  print "\n----- Making Diag(s) -----\n";

  # create a diag build object
  $diagBuild_obj = TileGen_DiagBuild->new();
  my @list = $diagBuild_obj->CompileDiags();

  return (@list);
}



#-------------------------------------------------------------------------------
# sub CleanAndStats
sub CleanAndStats{
  my @diags_list = @_;
  my $cnt=0;
  my $pass_cnt=0;
  my $diag_build_fail_cnt=0;
  my $fail_cnt=0;
  my $msg = '';
  foreach my $diag (@diags_list){
    if ($diag->{CompileResult} =~ m/PASS/ && $diag->{TestResult} =~ m/PASS/){
      $msg .= "$diag->{Name}:: PASS;\n";
      $cnt += 1;
      $pass_cnt += 1;
      # FIXME: Post test clean up comes here if one wants it
    }else{
      $cnt += 1;
      $fail_cnt += 1;
      if ($diag->{CompileResult} !~ m/PASS/){
	$msg .= "$diag->{Name}:: FAIL; Reason::CompileResult=$diag->{CompileResult}\n";
	$diag_build_fail_cnt += 1;
      }elsif ($diag->{TestResult} !~ m/PASS/){
	$msg .= "$diag->{Name}:: FAIL; Reason::TestResult=$diag->{TestResult}\n";
      }
    }
  }

  $msg .= "\n";
  $msg .= "TOTAL STATS ==> Num Tests:$cnt, PASS:$pass_cnt, FAIL:$fail_cnt, Diag Build Error:$diag_build_fail_cnt\n";
  print $msg;

  # Should I also send you an email?
  if (optionOn('email')){
    my $cwd = cwd();
    open (EMAIL, ">emailfile.txt");
    my $mailto = getOption('email');
    map(s/^(.*)$/$1,/ ,@{$mailto}); # add semicolumns
    print EMAIL "Subject: Test Results: Num Tests:$cnt, PASS:$pass_cnt, FAIL:$fail_cnt\n";
    print EMAIL "From: RunSingleTest.pl\n";
    print EMAIL "To: @{$mailto}\n\n";
    print EMAIL "\n\nTEST RESULTS REPORT\n";
    print EMAIL     "----------------------\n\n";
    print EMAIL "\nRundir: $cwd\n\n";
    print EMAIL "\nCommand Line: $CommandLine\n\n";
    print EMAIL $msg;
    close EMAIL;
    system("ssh csl-node-master /usr/sbin/sendmail -t < $cwd/emailfile.txt");
    print "Mail sent...\n\n\n";
  }
  1;
}

#---------------------------------------------------------------------------
#		      --- Command Line Parsing ---
#---------------------------------------------------------------------------
sub ParseCommandLine {
    my @options = qw(
		     wave
		     seed=i
		     rundir=s
		     help
		     clean!
		     configFile=s
		     diag=s
		     diagsDir=s
		     memmap=s
		     makeDiag=s
		     runtimeDiag=s
		     makeRTL=s
		     runtimeRTL=s
		     parseGenesis=s
		     genGenesis=s
		     skipBuild=s
		     email=s@
		    );


    # Parse command line options 
    my $ret = parseOptions(\@options);

    # Print usage summary
    if (optionOn('help')){
      PrintHelp();
      exit 0;
    }

    # Die if needed
    if (!$ret){
      system ("touch TEST_FAIL");
      die "ERROR: Undefined command line arguments";
    }
    1;
}

#---------------------------------------------------------------------------
#			 --- Check Options ---
#---------------------------------------------------------------------------
sub CheckOptions {
  # default values
  setOption('seed', int(rand()*0xffffffff)) if optionOff('seed');
  setOption('configFile', $configsDir."/config.xml") if optionOff('configFile');
  setOption('clean', 1) unless optionOn('clean'); # i.e. if we did not use neither clean nor noclean

  #rundir
  my $rundir = "./rundir"; # default rundir
  $rundir = getOption('rundir') if optionOn('rundir');
  if( ! -d $rundir ) {
    mkpath($rundir) or die "\nERROR: Cannot create rundir $rundir";
  }
  setOption('rundir', abs_path($rundir));

  # Diag flags
  die "ERROR: The -memmap option is required whenever compiling a diag"
    if optionOn('diag') && optionOff('memmap');

  1;
}

#---------------------------------------------------------------------------
#			 --- Print Users's Options  ---
#-------------------------------------------------------------------------------
# The following function prints the parsed options to screen
sub PrintOptionMessage{
  print "**************************** Test Info: ****************************\n";
  print "* General simulation info:\n";
  print "* * Logfile: $OutFile\n";
  if( optionOn('rundir') ) {   print "* * rundir is ".getOption('rundir')."\n";  }
  if (optionEnabled('clean'))  {   print "* * CLEAN before testing\n";}
  else {   print "* * NO clean before testing\n";}
  print "* * Seed is ".getOption('seed')."\n";
  if (optionOn('wave'))    {   print "* * Running test with wave trace\n";}

  print "*\n* Diagnostic info:\n";
  print "* * No Diagnostic specified\n" if optionOff('diag');
  print "* * Diagnostic(s) requested is ".getOption('diag')."\n" if optionOn('diag');
  print "* * Diagnostic(s) home directory is ".getOption('diagsDir')."\n"
    if optionOn('diag') && optionOn('diagsDir');
  print "* * Memory mapping file for compiling the diag is ".getOption('memmap')."\n";

  print "*\n* Shim test info:\n";
  print "* * FIXME--shim tests not yet supported\n";


  print "*\n";
  print "***********************************************************************\n";
}

