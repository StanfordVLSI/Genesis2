#!/bin/csh -f

########################################################################
set decode = src/decode.py
set test = samples/tgt0.xml
set sdiff
unset sdiff
########################################################################

#echo "FULL TEST including range and doc"

echo "FULL TEST"
set new = /tmp/tmp.$$.0
#set echo
$decode < $test | grep -v "#" > $new

set old = samples/tgt0.js

if ($?sort_test) then
  sort $old | grep . | grep -v Comment > tmp.old
  sort $new | grep . | grep -v Comment > tmp.new

  diff tmp.{old,new}
  echo sdiff
  sdiff -w200 tmp.{old,new}
  exit
endif

echo diff -B samples/tgt0.js $new
diff -B samples/tgt0.js $new

if ($?sdiff) then
  echo sdiff
  sdiff samples/tgt0.js $new
endif

########################################################################
unset echo; echo;echo;echo
########################################################################

echo "COMPARE ALL PASSES"
set new = /tmp/tmp.$$.1
#set echo

$decode -123456 < $test > $new
set old = samples/tgt0-12345.out

unset sort_test; if ($?sort_test) then
  sort $old | grep . | grep -vi Comment > tmp.old
  sort $new | grep . | grep -vi Comment > tmp.new

  echo diff tmp.{old,new}
  diff tmp.{old,new}

  echo sdiff -w200 tmp.{old,new}
  sdiff -w200 tmp.{old,new}
  exit
endif

echo diff $old $new
diff $old $new

########################################################################
unset echo; echo;echo;echo
########################################################################

echo "WALLACE TEST"
set new = /tmp/tmp.$$.2

#$decode < samples/wallace.xml 
#exit

$decode < samples/wallace.xml | grep -v "#" > $new

echo diff -B samples/wallace.js $new
diff -B samples/wallace.js $new
#sdiff -w200 samples/wallace.js $new


unset echo; echo;echo;echo
