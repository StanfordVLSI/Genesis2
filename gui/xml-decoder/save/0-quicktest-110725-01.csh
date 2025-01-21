#!/bin/csh -f

########################################################################
set test = samples/new-new-regime.xml
set sdiff
unset sdiff
########################################################################

#echo "FULL TEST including range and doc"

echo "FULL TEST"
set new = /tmp/tmp.$$.0
#set echo
decode_new.pl < $test | grep -v "#" > $new

set old = samples/new-new-regime.js

if ($?sort_test) then
  sort $old | grep . | grep -v Comment > tmp.old
  sort $new | grep . | grep -v Comment > tmp.new

  diff tmp.{old,new}
  echo sdiff
  sdiff -w200 tmp.{old,new}
  exit
endif

diff samples/new-new-regime.js $new

if ($?sdiff) then
  echo sdiff
  sdiff samples/new-new-regime.js $new
endif

########################################################################
unset echo; echo;echo;echo
########################################################################

echo "COMPARE ALL PASSES"
set new = /tmp/tmp.$$.1
#set echo

decode_new.pl -01234 < $test > $new
set old = samples/new-new-regime-01234.out

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
set echo

#decode_new.pl < samples/wallace.xml 
#exit

decode_new.pl < samples/wallace.xml | grep -v "#" > $new

diff samples/wallace.js $new
#sdiff -w200 samples/wallace.js $new
exit
