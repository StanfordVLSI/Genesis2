#!/bin/csh -f

if ($#argv != 1) then
  USAGE:
  echo "Usage: $0 <xml-file>"
  exit
endif

# E.g. $0 = $CHIPGEN/bin/Genesis2Tools/gui/xml-decoder/xml2js.csh
set decodedir = "$0:h"
if ("$decodedir" == "$0") set decodedir = .
if (-e $decodedir/xml2js.pl) then

  # This should always work.  Right!??
  $decodedir/xml2js.pl $1 | egrep -v '^#'
  exit
endif

##############################################################################
# THIS SHOULD NEVER HAPPEN.  RIGHT??

echo "ERROR xml2js.csh: Could not find $decodedir/xml2js.pl" > /dev/stderr
echo "ERROR xml2js.csh: THIS SHOULD NEVER HAPPEN" > /dev/stderr

# System-dependent directory names etc. are in CONFIG.TXT
set config = ../CONFIG.TXT

# Outrageous hack to search for CONFIG.TXT if it's not where we first looked.
if (! -e $config) set config = "$0:h"/../CONFIG.TXT
#echo config = $config; ls $config; exit

if (! -f $config) then
  echo "ERROR xml2js.csh: could not find config file: $config"; > /dev/stderr
  exit -1
endif

# E.g. GUI_HOME_DIR = "~steveri/gui" or "/var/www/homepage/genesis"
set GUI_HOME_DIR = `awk '$1 == "GUI_HOME_DIR" { print $2 }' $config`
set decodedir    = $GUI_HOME_DIR/xml-decoder

#set decodedir = /home/steveri/smart_memories/Smart_design/ChipGen/bin/Genesis2Tools/gui/xml-decoder

#  $decodedir/src/decode.py < $1 | egrep -v '^#'

$decodedir/xml2js.pl $1 | egrep -v '^#'
