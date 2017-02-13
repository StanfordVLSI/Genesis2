# Path can become too long if we don't do this occasionally
set path = `echo $path | awk '{for (i=1;i<=NF;i++){if (x[$i]++==0) print $i}}'`

# Without GENESIS_PROJECT_LIBS=$SMASH/bin/Genesis2LocalLibs
# TileGen-OS (at least) fails because cannot find e.g. "GenExt.pm"
if (! $?SMASH) then
  setenv SMASH /home/steveri/smart_memories/Smart_design/ChipGen
endif
if (! -e $SMASH/bin/Genesis2LocalLibs) then
  setenv SMASH /home/steveri/smart_memories/Smart_design/ChipGen
endif
if (! -e $SMASH/bin/Genesis2LocalLibs) then
  echo "WARNING: Cannot find $SMASH/bin/Genesis2LocalLibs"
  echo "WARNING: This could be trouble..."
  echo
endif

source $SMASH/bin/setup.cshrc

#setup.cshrc does this for us.
#setenv GENESIS_PROJECT_LIBS $SMASH/bin/Genesis2LocalLibs

#For local/perforce Genesis version:
#setenv GENESIS_LIBS "$SMASH/bin/PerlLibs"
#set path=($GENESIS_LIBS/Genesis2 $path)

### ##############################################################################
### ##############################################################################
### ##############################################################################
### # Things just get worse and worse.
### # This should only be temporary!!!!
### set load_module = "genesis2"
### set cur_version = `ls -l /cad/genesis2/latest | awk '{print $NF}' | sed 's/[^0-9]//g'`
### echo current version is $cur_version
### if ($cur_version < 11349) then
###     set load_module = "genesis2/r11349"
### endif
### ##############################################################################
### ##############################################################################
### ##############################################################################

unset tmp_use_dev
#set tmp_use_dev
if ($?tmp_use_dev) then
  # use current p4 version instead of the /cad official release.
  setenv GENESIS_LIBS "$SMASH/bin/PerlLibs"
  set path=($GENESIS_LIBS/Genesis2 $path)
else if (`hostname` == "kiwi") then
  # Note still need setup.cshrc above for e.g. to set SYNOPSYS env variable
  # else Genesis2 makefiles complain etc.

  source /cad/modules/tcl/init/csh
  module load base
 module load genesis2
 # module load $load_module
else
  source /cad/modules/init_modules.csh
 module load genesis2
 # module load $load_module
endif

#########################################################################
## As of 4/16/2011 still need hack below or vlsiweb fails.
## Hack to find libtcl8.4.so
#if (! $?LD_LIBRARY_PATH) then
#  setenv LD_LIBRARY_PATH /cad/xilinx/ise8.2i/bin/lin
#else
#  setenv LD_LIBRARY_PATH "$LD_LIBRARY_PATH"':/cad/xilinx/ise8.2i/bin/lin'
#endif
#setenv TCL_LIBRARY /usr/share/tcl8.4
#########################################################################
#
#echo ENVO1
printenv | egrep 'GENESIS|PERL'

END_setup_stanford_cshrc:
