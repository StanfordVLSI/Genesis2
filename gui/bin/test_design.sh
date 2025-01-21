#!/bin/csh -f
# Note: must test as "csh" not "sh" (duh!)

# What I do: attempt to run "make gen" after
# sourcing $GUI/configs/setup.cshrc
# If no errors, then stewie/gui should be able to run make correctly.

# Example usages:
#   cd ~/gui/examples/cmp; $0
#   cd /tmp/mystewie/designs/FloatingPointGen; $0

if (! -e __SOURCEDIR__) then
  echo 'ERROR: Cannot find file "__SOURCEDIR__"; are you in a design directory?'
  echo; exit -1;
endif

set srcdir=`cat __SOURCEDIR__`;

set setup=../../configs/setup.cshrc
if (! -e $setup) then
  echo "ERROR: Cannot find file '$setup'. Bye!"
  echo; exit -1;
endif

echo "Sourcing '$setup'"; source $setup
echo

# Little hacky-poo for stupid outdated "example" designs
unset example
#set echo
expr $srcdir : '.*examples.*' > /dev/null && set example
if ($?example) then
  #if (! -e SysCfgs) mkdir SysCfgs
  #touch SysCfgs/config.xml
  echo Found example file
  if (! -e empty.xml) then
    echo "<HierarchyTop></HierarchyTop>" > empty.xml
  endif
  setenv GENESIS_CFG_XML ./empty.xml
endif

if ("$1" == "-clean" || "$1" == "clean") then
  make -f $srcdir/Makefile clean;
  if (-e genesis_clean.cmd) rm genesis_clean.cmd
  exit

else if ("$1" != "") then
  echo "Usage: $0 [ -clean ]"
endif

####################################################
# Example designs "tgt0 and "demo" are deprecated...
#set design = `pwd`
#set design = $design:t
#echo $design; exit

#if ($design == "tgt0" || $design == "demo") then
#  foreach f ($srcdir/*.pm)
#    if (! -e $f:t) echo ln -s $f
#    if (! -e $f:t) ln -s $f
#  end
#endif

####################################################

set echo
make -f $srcdir/Makefile gen
