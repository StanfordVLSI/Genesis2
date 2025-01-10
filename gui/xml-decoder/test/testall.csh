#!/bin/csh -f

if (! -d samples) then
  echo
  echo '  ERROR: Cannot find "samples" subdirectory'
  echo '  Are you in the right place?'
  echo '  Test script should be run in directory "test/.." where the source files live.'
  echo
  exit
endif

set decode = src/decode.py

set test = wallace
set test = regression

goto FT

BCTP:
##################################################################################
echo BRIEF COMPARE TO PREV

set sedscript = '/#DBG/d; s/^#//;'

# Remove hash-marks and DBG sttmts from comparison files, for more brevity
set cmp = /tmp/tmp$$
foreach i (1 2 3 4 5 6)
  @ j = $i - 1
  cat samples/$test.xml.pass$j | sed "$sedscript" > $cmp.$i
end

alias dif sdiff --suppress-common-lines

foreach i (1 2 3 4 5 6)
#foreach i (5)
  echo; echo `alias dif` tmp$i $cmp.$i
  cat samples/$test.xml | $decode -$i | sed "$sedscript" > tmp$i ; dif tmp$i $cmp.$i
end

FFCTP:
echo; echo "########################################################################"
echo FILTERED FULL COMPARE TO PREV
alias dif sdiff
foreach i (1 2 3 4 5 6)
  echo; echo `alias dif` tmp$i $cmp.$i; echo
  cat samples/$test.xml | $decode -$i | sed 's/^#//' > tmp$i ; dif tmp$i samples/$test.xml
end

UFCTP:
echo; echo "########################################################################"
echo UNFILTERED FULL COMPARE TO PREV
alias dif sdiff
foreach i (1 2 3 4 5)  # pass6 comparison not useful...!
  echo; echo `alias dif` tmp$i $cmp.$i; echo
  cat samples/$test.xml | $decode -$i > tmp$i ; dif tmp$i samples/$test.xml
end

echo
echo "sdiff tmp6 not done"
echo "pass6 comparison not useful here"
echo

CTR:
##################################################################################
echo COMPARE TO REF

foreach i (1 2 3 4 5)
  echo; echo "########################################################################"
  echo "diff tmp$i samples/$test.xml.pass$i"
  cat samples/$test.xml | $decode -$i > tmp$i ; diff tmp$i samples/$test.xml.pass$i;
  if ($status == 0) echo TEST$i PASSED # NOTE: $status only reliable for first usage after being set!
end

FT:
echo FINAL TEST
echo; echo "########################################################################"

echo "Decode samples/$test.xml, output to tmp6.js"
cat samples/$test.xml | $decode | grep -v "#" > tmp6.js

echo "diff -B tmp6.js samples/wallace.js"
diff -B tmp6 samples/wallace.js





#cat samples/$test.xml | $decode -2 > tmp2 ; diff tmp2 samples/$test.xml.pass2; cat /tmp/tmp.$$
#cat samples/$test.xml | $decode -3 > tmp3 ; diff tmp3 samples/$test.xml.pass3; cat /tmp/tmp.$$
#cat samples/$test.xml | $decode -4 > tmp4 ; diff tmp4 samples/$test.xml.pass4; cat /tmp/tmp.$$
#cat samples/$test.xml | $decode -5 > tmp5 ; diff tmp5 samples/$test.xml.pass5; cat /tmp/tmp.$$

#set i = '$i'
#alias dotest\
#  "cat samples/$test.xml | $decode -$i | sed 's/^#//' > tmp$i ; sdiff tmp$i samples/$test.xml"
#
#foreach i (1 2 3 4)
#  dotest
#exit

