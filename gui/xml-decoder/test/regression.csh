#!/bin/csh -f

set tmp = /tmp/tmp.$$

foreach test (wallace tgt0)
    echo
    ./xml2js.csh samples/$test.xml > $tmp
    echo diff -B $tmp samples/$test.js
    diff -B $tmp samples/$test.js
    if ($?status) then
        echo "PASSED"; echo
    else
        echo "FAILED"; echo
    endif
end

