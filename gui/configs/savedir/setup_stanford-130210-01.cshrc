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
else
  source /cad/modules/init_modules.csh
  module load genesis2


#   # BROKEN as of 12/15
#   # Can you try it with r11349? if not than with r11012
#   # Do "module unload genesis2" followed by "module load genesis2/r11349"
# 
# #  echo FOO Debug: temporarily using Genesis2 version r11012
# #  echo
# #
# #  module unload genesis2
# #  module load genesis2/r11012
# 
#   echo FOO Debug: Ofer has something that he thinks will work: r11524
#   module unload genesis2
#   module load genesis2/r11524




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
#printenv | egrep 'GENESIS|PERL'

END_setup_stanford_cshrc:
