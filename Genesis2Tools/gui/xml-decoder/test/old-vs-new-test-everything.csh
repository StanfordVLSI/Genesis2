#!/bin/csh -f

set test = "~steveri/gui/xml-decoder/test/old-vs-new.csh -q"

set d1 = ~steveri/gui/examples
find $d1 -name \*.xml -exec $test {} \;

set d2 = ~steveri/gui/designs
find $d1 -name \*.xml -exec $test {} \;

set d3 = /var/www/homepage/genesis/designs
if (-d $d3) then
  find $d3 -name \*.xml -exec $test {} \;
endif

