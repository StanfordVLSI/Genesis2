#!/bin/csh -f

if (! -d scratch) then
  echo
  echo "I don't see a scratch directory.  Try this:"
  echo "% cd <guidir>; bin/clean-scratchdir.csh"
  echo
  exit
endif

#cd scratch
find scratch -name \*.php -mtime +1 -exec echo delete {} \; -exec rm -f {} \;
