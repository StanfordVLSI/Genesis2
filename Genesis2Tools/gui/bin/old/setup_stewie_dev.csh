# *Source* this file, don't execute it.

# This is all so stoopid.

if ($?MODULEPATH) then
  setenv MODULEPATH "$MODULEPATH":/home/steveri/gui/configs/install/modulefiles
else
  setenv MODULEPATH /home/steveri/gui/configs/install/modulefiles
endif

# setenv LD_LIBRARY_PATH /cad/modules/3.2.6/x86/lib
if ($?LD_LIBRARY_PATH) then
  setenv LD_LIBRARY_PATH "$LD_LIBRARY_PATH":/cad/modules/3.2.6/x86/lib
else
  setenv LD_LIBRARY_PATH /cad/modules/3.2.6/x86/lib
endif

#old
#eval `/cad/modules/3.2.6/x86/bin/modulecmd csh load stewie`


# new
eval `/usr/bin/tclsh /hd/cad/modules/tcl/modulecmd.tcl csh load stewie`

