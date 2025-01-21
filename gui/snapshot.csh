#!/bin/csh -f

# Example: "snapshot 6"

if ($#argv == 0) then
  echo "Example: snapshot 6"
  echo ""
  ls -1d ~/genesis/xml-decoder-snapshot*
  exit
endif

set i = $1

set ig = ~/genesis/xml-decoder
set snapdir = ~/genesis/xml-decoder-snapshot-$i

if (-e $snapdir) then
  echo "Dir $snapdir already exists; try another."
  echo
  exit
endif

echo "Writing $snapdir"
cp -r $ig $snapdir
chmod -R -w $snapdir/*



