#!/bin/csh -f

# Assumes updatedesign lives two levels up in, dir "..",
# updatedesign helper files live in "../updatedesign.dir"
# and updatedesign test files (including this one)
#  live in "../updatedesign.dir/test"

cd ../..

# Setup

set refdbg = updatedesign.dir/test/udtest-fulldebug-out.txt
set newdbg = updatedesign.dir/test/tmp-udtest-fulldebug-out.txt

if (-e $newdbg) mv $newdbg $newdbg.old.$$

set refxml = updatedesign.dir/test/tgt0-baseline.xml
set newxml = updatedesign.dir/test/tmp-udtest-out.xml

if (-e $newxml) mv $newxml $newxml.old.$$


echo "RUN"; echo

set nd = "newdesign=udtest";
set cd = "&curdesign=updatedesign.dir%2Ftest%2Ftgt0-baseline.js";
set xr = "&xmlref=";
set xr = "";
set mp = "&modpath=top.DUT.p0&DBG=1";
set p0 = "&USE_SHIM=bar";
set p1 = "&SPECIAL_DATA_MEM_OPS.0.name=4bart";
set p2 = "&SPECIAL_DATA_MEM_OPS.0.tiecode=0foo";
set p3 = "&SPECIAL_DATA_MEM_OPS.2.tiecode=2baz";;


# Tests to run:
# 0. Base test, tests simple parm and hash/array parms
# 1. Missing parm in existing modpath, must be fetched from a ref file
# 2. XML file does not contain desired module, must be fetched from ref
# 3. Missing module is several missing-layers deep
# 4. Deep missing module with hash/array parms.

set whichtest = 4

if ($whichtest > 0) then
  set cd = "&curdesign=updatedesign.dir%2Ftest%2Ftgt0-baseline-tiny.xml";
  set xr = "&xmlref=updatedesign.dir%2Ftest%2Ftgt0-baseline.xml";
  set refxml = updatedesign.dir/test/tgt0-baseline-tiny.xml
endif

if ($whichtest == 1) then
  # Check for missing parm in existing modpath.
  # "USE_XT" exists in tgt0-baseline but NOT tgt0-baseline-tiny.xml
  set p0 = "&USE_SHIM=bar&USE_XT=hootyhoot";
endif

if ($whichtest == 2) then
  # Check for simple missing modpath
  set mp = "&modpath=top.DUT.dam0&DBG=1";
  set p0 = "&INT_SIZE=333_333";
  set p1 = "";
  set p2 = "";
  set p3 = "";
endif

if ($whichtest == 3) then
  # Check for deep missing modpath
  set mp = "&top.DUT.dam0.rf_0.r0_reg&DBG=1";
  set p0 = "&FLOP_TYPE=flippityflop";
  set p1 = "";
  set p2 = "";
  set p3 = "";
endif

# How about arrays!??
if ($whichtest == 4) then
  set cd = "&curdesign=updatedesign.dir%2Ftest%2Ftgt0-baseline-blank.xml";
  set xr = "&xmlref=updatedesign.dir%2Ftest%2Ftgt0-baseline.xml";
  set refxml = updatedesign.dir/test/tgt0-baseline-blank.xml
  set p0 = "&USE_SHIM=bar&USE_XT=hootyhoot";
  set p1 = "&SPECIAL_DATA_MEM_OPS.0.name=4bart";
  set p2 = "";
  set p3 = "";
endif



set t = "$nd$cd$xr$mp$p0$p1$p2$p3";
updatedesign.pl -test "$t" | & tee $newdbg

# If change-file test passes, that's all that matters.
goto CHANGEFILE_TESTS


########################################################################
# Full-debug test
#
# For this test to work well, $DBG9 should be set to 1 in .pl source file(s)

echo "========================================================================"
echo "OUTPUT DIFF"
echo diff $refdbg $newdbg
diff $refdbg $newdbg



########################################################################
CHANGEFILE_TESTS:

echo; echo "========================================================================"

echo "LS CHANGEFILE"
ls -l $refxml $newxml

echo; echo "========================================================================"
echo "WC CHANGEFILE"
wc -l $refxml $newxml

#set ftmp = `ls -t tgt0/SysCfgs | head -1` 
#ls -l tgt0/SysCfgs/$ftmp *.xml

echo; echo "========================================================================"
echo "CHANGEFILE DIFF"

echo diff $refxml $newxml
diff $refxml $newxml
