#!/bin/csh -f

alias otime '/usr/bin/time -f "    old: %U %S %e"'
alias ntime '/usr/bin/time -f "    new: %U %S %e"'

unset quiet
if ($argv[1] == "-q") then
  set quiet;
  shift argv
endif

set decodedir    = ~steveri/gui/xml-decoder

set oldbin = $decodedir/src/decode.py
set newbin = $decodedir/xml2js.pl

set old_out = /tmp/tmp-xml2js-test.js.old
set new_out = /tmp/tmp-xml2js-test.js.new

foreach f ($*)

  echo $f | grep old > /dev/null
  if ($status == 0) then
    echo -n $f": "
    echo not processing '"old"' files
    continue
  endif

  if ( `cat $f | wc -l` < 5) then
    echo $f": not processing tiny files"
    continue
  endif

  head -1 $f | grep top > /dev/null
  if ($status == 0) then
    echo -n $f": not processing old-regime files"
    continue
  endif

  if ($?quiet) echo "TEST $f"

  if (! $?quiet) echo "$oldbin $f > $old_out"
  otime $oldbin < $f | egrep -v '^#' > $old_out
  if ($status) then
    echo "old decoder failed."
    continue
  endif
  if (! $?quiet) echo

  if (! $?quiet) echo "$newbin $f > $new_out"
  ntime $newbin $f | egrep -v '^#' \
    | sed 's/\([^-]\)[-][>]/\1-\&gt;/g' \
    > $new_out
  if ($status) then
    echo "new decoder failed."
    continue
  endif
  if (! $?quiet) echo

  sort $old_out > $old_out.sorted
  sort $new_out > $new_out.sorted

#  echo "Compare old vs. new (sorted)"
#  echo diff $old_out.sorted $new_out.sorted
#  diff $old_out.sorted $new_out.sorted
#  echo

  if ($?quiet) then
    diff $old_out $new_out

  else
    echo "Compare old vs. new (unsorted)"
    echo sdiff -w150 $old_out $new_out
    sdiff -w150 $old_out $new_out
    echo

  endif

end

