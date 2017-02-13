#!/bin/csh -f

set TRUE = 0
set FALSE = -1

#set echo

# return TRUE if $1 is newer than $2 modulo ten minutes (600 seconds)

if (! -e $1) exit $FALSE
if (! -e $2) exit $FALSE

set f1_time = `stat --print="%Y" $1`
set f2_time = `stat --print="%Y" $2`

#ls -l $1 $2
@ diff = $f1_time - $f2_time
#echo $diff

if ($diff > 600) then
  exit $TRUE
else
  exit $FALSE
endif

#if ($diff > 600) then
#  #echo $1
#  ls -lt $1 $2
#  echo
#endif

