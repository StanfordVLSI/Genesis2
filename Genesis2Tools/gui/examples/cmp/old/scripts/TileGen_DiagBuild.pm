 #########################################################################
 ## From Perforce:
 ##
 ## $Id: //Smart_design/ChipGen/TileTest/TileGenTest/scripts/TileGen_DiagBuild.pm#6 $
 ## $DateTime: 2010/07/20 20:50:07 $
 ## $Change: 8928 $
 ## $Author: shacham $
 #########################################################################/
#
#  Title: TileGen_DiagBuild
# This package handles the build of the diag code: from expending a diag list
# file to compile and linkage.

package TileGen_DiagBuild;

## included libraries:
######################
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

use Cwd;
use Carp; $Carp::MaxArgLen =16; $Carp::MaxArgNums = 1;
use Exporter;
use FileHandle;
use Env; # Make environment variables available
use File::Path;
use File::Spec::Functions;
use File::Basename;

# package for handling command line options
use lib "$ENV{PROCESSOR_HOME}/Hardware/scripts";
use Options;

@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw();

$VERSION = '1.0';


################################################################################
################################## Constructors ################################
################################################################################

## new:
## Main constructor for the Genesis2::UniqueModule class
sub new {
  my $package = shift;
  my $self = {};

  die "$package:ERROR: Can not create instance without definitions of diag and rundir"
    if (optionOff('diag') || optionOff('rundir'));
  # get and expend the diag list
  $self->{DiagDir} = getOption('diagsDir');
  $self->{Diag} = getOption('diag');

  # Find where diags should be built
  $self->{RunDir} = getOption('rundir');
  $self->{LspDir} = catdir($self->{RunDir}, "lsp");

  # 
  # Bless this package
  bless ($self, $package) ;
}


################################################################################
# API FUNCTIONS
################################################################################
# CompileDiags: returns an array of test hashes. Each hash contains the
# following fields:
# * Name
# * Dir
# * CompileResult
# * MakeArgs
# * RuntimeArgs
# * TestResult

sub CompileDiags{
  my $self = shift;
  my $cur_path = getcwd();

  #  Link to the common part of the diags makefile
  $self->CreateCommonDiagMakefile();

  # make the lsp
  $self->MakeLsp() or die "ERROR: Cannot make lsp";

  # make LibSim
  $self->MakeLibSim() or die "ERROR: Cannot make libsim";

  # expend the diag list
  my @diag_list = $self->ExpendDiagList();

  # make sure there is at least one test to run (after expansion)
  die"Test list is empty (after expansion)" unless @diag_list>0;

  # compile each diag
  foreach my $diag_ptr (@diag_list){
    print "---- Compiling Diag $diag_ptr->{Name} ----\n";
    $self->PrepareDiag($diag_ptr);
    $self->MakeDiag($diag_ptr);
  }

  return @diag_list;
}


################################################################################
# AUXILIARY FUNCTIONS
################################################################################
#---------------------------------------------------------------------------
#		  --- Expend the diags list ---
#---------------------------------------------------------------------------
sub ExpendDiagList{
  my $self = shift;
#  caller eq __PACKAGE__ or
#    die("$self->ExpendDiagList: ERROR: Call to a private method is not allowed");

  my $diags;
  if (@_){$diags = shift;}  else  {$diags = $self->{Diag};}

  my @expendedlist=();

  # Remove any trailing slashes from tests (in case user used tab completion)
  $diags =~ s/\/$//;

  # check if this is already a diag(s) directory
#print "top: ".catdir($self->{DiagDir}, $diags)."\n";
  if (-d catdir($self->{DiagDir}, $diags)){
    my $dir = $self->{DiagDir}."/".$diags;

    # The diag name can specify only part of the hierarchy in which case we
    # need to find all diags in the sub-tree
    opendir(DIAGDIR, $dir)
      or die "$self->ExpendDiagList: ERROR: Cannot open directory $dir";

    # If there is a makefile than it's probably a diag folder
    my @subdirs = readdir DIAGDIR;
#print "inner: @subdirs\n";
    if (grep(m/Makefile/, @subdirs) > 0){
#print "grep found!\n";
      push(@expendedlist, {Name=>$diags,
			   Dir=>$dir,
			   CompileResult=>'FAIL: Diag did not compile yet',
			   MakeArgs=>'',
			   RuntimeArgs=>'',
			   TestResult=>'FAIL: Test did not run yet'});
    }
    # else, it is probably a folder that has sub-folders with diags
    # so we prepend the current path to the subfolder names and run
    # again recursivaly
    else{
#print "grep faild!\n";
      foreach my $subdir (@subdirs){
	next if $subdir =~ /^$/ ;
	next if $subdir =~ /^\./ ;
#print "dir recursive call to $diags/$subdir\n";
	push(@expendedlist,
	     $self->ExpendDiagList($diags."/".$subdir));
      }
    }
  } # end of "if (-d $self->{Dia..."

  # Not a diag directory
  # now check if this was a diags list
  elsif (-e $diags){
#print "It's a file! $diags\n";
    my $diag;
    my $filehandle = new FileHandle;
    my $result = open($filehandle, $diags);
    die "$self->ExpendDiagList: ERROR: Can not open file $diags" if (!$result );
    while($diag = <$filehandle>) {
      chomp($diag);
      next if $diag =~ m/^\s*#/;	# skip comments
      next if $diag =~ m/^\s*$/;	# skip empty lines
      # recursive call
#print "file recursive call to $diag\n";
      push(@expendedlist,
	   $self->ExpendDiagList($diag));
    }
    close($filehandle);
  }else{
    #die "$self->ExpendDiagList: ERROR: Diag $diags is neither a list nor a test folder";
  }

    return @expendedlist;
}


#---------------------------------------------------------------------------
#		  --- Create LSP Scripts ---
#---------------------------------------------------------------------------
# sub MakeLsp
# This function makes the lsp (something like linking scripts) for the tensilica compiler
sub MakeLsp {
  my $self = shift;
  my $cwd = cwd();
  my $smash_path = $ENV{SMASH};

  print "--- Make LSP ---\n";
  # Do you really want to build LSP?
  if (optionOn('skipBuild')){
    if (getOption('skipBuild') =~ m/lsp/i ||
	getOption('skipBuild') =~ m/all/i){
      print "- Skipping LSP build -\n";
      return 1;
    }
  }

  my $lsp_src_dir = catdir( $smash_path, "TileTest", "TileGenTest", "lsp" );
  my $lsp_dir = $self->{LspDir};
  die "Could not rmdir lsp directory" if system("rm -rf $lsp_dir");
  die "Could not copy lsp directory" if system("cp -r $lsp_src_dir $lsp_dir");

  my $memmap = getOption('memmap');

  # Search for memory map file
  # Has to be updated if directory structure changes
  if( ! -r $memmap ) {
    # Look in TestCommonLib:
    if( -e catfile( $smash_path, "TestCommonLib", "MemMapFiles", $memmap ) ) {
      $memmap = catfile( $smash_path, "TestCommonLib", "MemMapFiles", $memmap );
    }
    else {
      die "Could not find memory map file ".$memmap;
    }
  }

  my $xtcore = $ENV{XTENSA_CORE};

  my @lspcmd = ( "xt-genldscripts", "--xtensa-core=$xtcore", "-b $lsp_dir", "-m $memmap", "-hush" );
  my $cmd = "@lspcmd";

  print "run: @lspcmd\n";
  die "ERROR: Could not generate lsp" if system("@lspcmd");
  1;
}


#---------------------------------------------------------------------------
#		  --- Create Common Diag Makefile ---
#---------------------------------------------------------------------------
sub CreateCommonDiagMakefile {
  my $self = shift;

  my $smash_path = "$ENV{SMASH}";

  my $target = catfile($self->{RunDir}, 'Makefile.common');
  my $source = catfile($smash_path, 'TileTest', 'TileGenTest', 'MakefileForDiags.common');

  # Added loop for reliability: when multiple parallel runs are trying to create
  # a link there is a race between check and link creation
  for( my $i = 0; ! -l $target && ($i<10); $i++ ) {
    symlink($source, $target);
  }
  die "Could not create link from $source to $target" if ( ! -l $target );
}


#---------------------------------------------------------------------------
#	   --- Make the libsim archive for the diag to use (later) ---
#---------------------------------------------------------------------------
sub MakeLibSim
{
  my $self = shift;
  my $cwd = cwd();
  my $smash_path = "$ENV{SMASH}";

  print "--- Make Libsim ---\n";
  # Do you really want to build libsim?
  if (optionOn('skipBuild')){
    if (getOption('skipBuild') =~ m/libsim/i ||
	getOption('skipBuild') =~ m/all/i){
      print "- Skipping LIBSIM build -\n";
      return 1;
    }
  }

  my $libsim_src_dir = catdir( $smash_path, "runtime", "libsim_for_rtl" );
  my $libsim_dir = catdir( $self->{RunDir}, 'libsim_for_rtl' );
  die "Could not rmdir libsim directory" if system("rm -rf $libsim_dir");
  die "Could not copy libsim directory" if system("cp -pr $libsim_src_dir $libsim_dir" );

  # Setup args, link files to source, and change to the libsim directory.
  print "cd $libsim_dir\n";
  chdir $libsim_dir;

  my @makecmd = ('make', 'clean', 'all');
  print("run: @makecmd\n");
  die "Could not compile libsim (see $libsim_dir/Build.log for Errors)" 
    if system ("@makecmd &> $libsim_dir/Build.log");

  chdir $cwd;
  print "cd back to $cwd\n";
  1;
}


#---------------------------------------------------------------------------
#	     --- Prepare the diag folder and data structure ---
#---------------------------------------------------------------------------
sub PrepareDiag{
  my $self = shift;
  my $diag = shift;
  my $cur_path = cwd();
  my $file;
  my @srcFiles;

  print "--- Prepare Diag $diag->{Name}---\n";
  # Read command line for compile and runtime arguments for the diag
  if (optionOn('makeDiag')){
    $diag->{MakeArgs} = getOption('makeDiag');
  }
  if (optionOn('runtimeDiag')){
    $diag->{RuntimeArgs} = getOption('runtimeDiag');
  }

  # create the directory for this diag to run at
  mkpath($diag->{Name});
  die "Could not make Diag directory: $diag->{Name}" if (! -d $diag->{Name});
  chdir($diag->{Name}) or die "Could not cd to Diag's directory: $diag->{Name}";
  print "cd to $diag->{Name}\n";

  # Read the source directory
  opendir DIAGDIR, $diag->{Dir} or
    die "Could not open directory ".$diag->{Dir};
  while ( $file = readdir (DIAGDIR) ) {
    next if $file=~ m/^$/ ;
    next if $file=~ m/^\./ ;
    push(@srcFiles, $file);
  }
  closedir DIAGDIR;
  die "Could not find test program in $diag->{Dir}" unless @srcFiles > 0;

  # create links to sources
  foreach $file (sort @srcFiles) {
    my $src = catfile($diag->{Dir}, $file);
    CreateSymlink($src, $file) or
      die "Could not create symbolic link $file -> $src";
  }

  # Tensilica also has the notion of a info file for additional compile/
  # runtime args. (see $PROCESSOR_HOME/Hardware/scriptsInfoFile.pm)
  # For now, I'll leave that as a fixme for future revisions
  # FIXME: Read diag specific info file for compile and runtime arguments


  chdir $cur_path;
  print "cd back to $cur_path\n";
  1;
}


#---------------------------------------------------------------------------
#		   --- Make the diag itself ---
#---------------------------------------------------------------------------
# Compile the diag, if compile option not disabled.
sub MakeDiag {
  my $self = shift;
  my $diag = shift;
  my $cur_path = cwd();
  my $makeexe = 'make';
  my $smash_path = "$ENV{SMASH}";
  my $build_log = catfile($self->{RunDir}, $diag->{Name}, 'Diag_Build.log');

  print "--- Make Diag $diag->{Name}---\n";
  chdir($diag->{Name}) or die "Could not cd to Diag's directory: $diag->{Name}";
  print "cd to $diag->{Name}\n";

  # Do you really want to build diag?
  if (optionOn('skipBuild')){
    if (getOption('skipBuild') =~ m/diag/i ||
	getOption('skipBuild') =~ m/all/i){
      $diag->{CompileResult} = 'PASS: Compile Skipped';
      print "- Skipping diag $diag->{Name} build -\n";
      return 1;
    }
  }

  # FIXME: This is where software configuration falls in.
  # In SM, we had scripts that based on the command line options 'Sys' and 'CSys'
  # would generate the Vera/C config code. This is still a Fixme issue for
  # TileGen however. The releveant scripting code that controlled that cfg code
  # generation is located at:
  # Vera generation: $SMASH/QuadTest/QuadBenchXT/Scripts/QuadXT_Simulator.pm (sub build)
  # C generation: $SMASH/QuadTest/QuadBenchXT/Scripts/QuadXT_Bench.pm (sub reallyRunTest)
  # Meanwhile, the workaround is to generate an empty config file:
  open (QUAD_CFG_FIXME, ">Quad_Config.c") or die "Could not open Quad_Config.c for writing";
  print QUAD_CFG_FIXME <<END_OF_QUAD_CONFIG_CODE;
	//  Quad_Config.c --- null configuration file for Quad tests
	//  ----------------------------------------------------------
	#define CONFIG_QUAD_FUN Quad_Config0
	#include "runtime_quad_config.h"
	void CONFIG_QUAD_FUN(int quad) {}
END_OF_QUAD_CONFIG_CODE
  close QUAD_CFG_FIXME;



  # Tell diag Makefile where it can find its Makefile.common
  my $makefile   = 'MAKEFILE='.catfile($self->{RunDir}, 'Makefile.common');
  my $srcfile    = 'SRCFILE='.basename($diag->{Name});
  my $lsp_dir    = 'LSPDIR='.$self->{LspDir};
  my $libsim_dir = 'LIBSIMDIR='.catdir( $self->{RunDir}, 'libsim_for_rtl' );
  my $seed = 'SEED='.getOption('seed');

  my @makecmd = ($makeexe, 'target-all', $diag->{MakeArgs}, $makefile, $srcfile, $lsp_dir, $libsim_dir, $seed);

  if (optionEnabled('clean')) {
    system("$makeexe clean $makefile")==0 or die"Could not delete temporary files";
  }

  print "run: @makecmd\n";
  if (system ("@makecmd &> $build_log")) {
    $diag->{CompileResult} = 'FAIL: Compile Failure';
    die "Could not compile the diag program ".($diag->{Name})." (see $build_log for Errors)";
    return(1);
  }else{
    $diag->{CompileResult} = 'PASS: Compile Success';
  }

  chdir $cur_path;
  print "cd back to $cur_path\n";
  1;
}


################################################################################
# LOW LEVEL AUXILIARY FUNCTIONS
################################################################################
#---------------------------
#--- Create one symlink ---
# Create a single symlink from $src to $dest.
sub CreateSymlink {
  my $src = shift;
  my $dest = shift;

  # if the file exists and is not a symbolic link already --> rename it first
  if ( -f $dest && ! -l $dest){
    rename($dest, $dest . '.BAK') or die "Could not rename file $dest to $dest.BAK";
  }

  # if the file is not a link
  if (! -l $dest) {
    symlink($src, $dest) or
      die "Could not create link $src -> $dest";
  }else {
    # Link already exists; make sure it's correct.
    die "$dest != $src\nPerhaps your results directory is from a different era and should be removed" if 
      ($src cmp readlink($dest));
  }
  1;
}
