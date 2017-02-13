#!/bin/csh -f

unset standalone;
if ($?GUI_STANDALONE) set standalone

# Driven by "cgi/updatedesign.pl"

# Example: "$0 -dir designs/tgt0 -ch SysCfgs/changes.xml -out newdesign.xml"

# Use -test to test from command line for debugging purposes
if ("$1" == "-test") goto TEST   

# Given an xml change file $arg2="SysCfgs/changes.xml" and a
# design directory $arg1="designs/tgt0", produce a new design
# $arg3="newdesign.xml" and its equivalent javascript file "newdesign.js"

if ($#argv != 6) then
  USAGE:
    echo "Usage: $0 -dir <dir> -ch <changefile> -out <outputfile>"
    echo "Or:    $0 -test"
  exit -1
endif

while ($#argv > 0)
  switch ($1)

  case "-dir":
    shift; set designdir = $1;  # E.g. "../designs/tgt0"
    breaksw

  case "-ch":
    shift; set changefile = $1; # Relative to $designdir
    breaksw                     # E.g. "SysCfgs/tgt0-baseline-clyde-100807,0815.xml"

  case "-out":
    shift; set newdesign = $1;  # Relative to $designdir
    breaksw                     # E.g. "tgt0-baseline-clyde-100807,0915.xml"

  default:
    goto USAGE
    breaksw

  endsw
  shift;
end

# E.g. cgi_dir = /home/steveri/smart_memories/Smart_design/ChipGen/bin/Genesis2Tools/gui/cgi
set cgi_dir = `pwd`; echo "cgi_dir is '$cgi_dir'"

if ($?standalone) then
  # Use $GUI_CGI_DIR env var set by updatedesign() in utils.pl
  set GUI_HOME_DIR = "$GUI_CGI_DIR/.." 
  echo "Standalone: GUI_HOME_DIR = $GUI_HOME_DIR";      # SDBG

else
  # System-dependent directory names etc. are in CONFIG.TXT
  set config = ../CONFIG.TXT

  # Outrageous hack to search for missing CONFIG.TXT
  if (! -e $config) set config = "$0:h"/../CONFIG.TXT
  #echo config = $config; ls $config; exit

  if (! -f $config) then
    echo "ERROR: could not find config file: $config"; exit -1
  endif

  # E.g. GUI_HOME_DIR = "~steveri/gui" or "/var/www/homepage/genesis"
  set GUI_HOME_DIR = `awk '$1 == "GUI_HOME_DIR" { print $2 }' $config`
endif

set decodedir    = $GUI_HOME_DIR/xml-decoder

if (0) then                             #SDBG
  echo Found dir $designdir;
  echo Found change file $changefile;
  echo Found newdesign $newdesign;
endif

if (! -d $designdir) then
  echo "ERROR: could not find design directory: $designdir"; exit -1
endif

cd $designdir

# BUG/TODO slight testing hack
set tmpfile = /tmp/tmp$$.xml
if ($changefile == "NONE") then
    echo "<HierarchyTop></HierarchyTop>" > $tmpfile
  set changefile = $tmpfile
endif

if (! -f $changefile) then
  echo "ERROR: could not find change file: $changefile"; exit -1
endif

if ("$newdesign" == "") then
  echo "ERROR: no output file designated"; exit -1;
endif

# Don't want e.g. "newdesign.xml"; just want root name "newdesign"
if ("$newdesign:e" == "xml") set newdesign = $newdesign:r
if ("$newdesign:e" == "js" ) set newdesign = $newdesign:r

# This is specific to Stanford install (and shouldn't be necessary anyway!!!) TODO/BUG
# Correct fix is...? Fix makefile(s)...?  Yes!  TODO/BUG
# There's a lotta steveri-specific crap in here...

echo changefile = $changefile
echo first line = `head -n 1 $changefile`

echo

# unset ofermode
# if ($?OFER_MODE) then
#   if ("$OFER_MODE" == "ON") then
#     set ofermode
#   endif
# endif

# Below file should be a link to the correct site-specific setup
set setup = $GUI_HOME_DIR/configs/setup.cshrc
if (! -e $setup) then
    echo "ERROR: updatedesign.csh could not find setup file '$setup'."
    exit -1
endif
source $setup

# Check to see that we can find Genesis2.
echo; echo -n "Genesis lives here: "; which Genesis2.pl

########################################################################
# Check for conflicting locks from other users
set locks = (`ls | grep LOCK_DELETEME`)

########################################################################
# Make sure each lock found actually belongs to an active process
foreach lock ($locks)
  echo; echo "Found LOCK file $lock.  Maybe it's an orphan?"

  set lockpid = $lock:e  # e.g. for "LOCK_DELETEME.4082", lockpid = 4082
  ps | egrep '(^|[^0-9])'$lockpid'([^0-9]|$)' && set lockpid = 0
  if ($lockpid != 0) then
    echo "Yes it's an orphan.  Delete and ignore this lock."; echo
    rm $lock
  else
    echo; echo "Not an orphan.  You must wait on the above process to finish."
    echo "Use browser's BACK button to go back and try again in a minute or two."; echo
    exit
  endif
end

########################################################################
# Uncomment the following line to test collision detection
# touch LOCK_DELETEME.99999

########################################################################
# Lock and go.

touch LOCK_DELETEME.$$
rm -f *.v *.sv |& grep -v "No match"    # TODO/BUG should be able to use "make clean...!"

########################################################################
# Make sure SysCfgs subdir exists
# So...this happens everywhere, does it?  Sure, why not.
# See: updatedesign.csh, updatedesigndirs.csh, updatedesign.pl
if (! -e SysCfgs) mkdir SysCfgs

########################################################################
# Get name of source dir w/makefile, etc.
set curdir = `pwd`             # e.g. "/var/www/homepage/genesis/designs/tgt0"
set design = $curdir:t         # e.g. "tgt0"

unset yakky # "set verbose" equates to "set echo"
set yakky
if ($?yakky) then
  echo; echo; echo "Curdir: $curdir"; echo "Design name: $design"
endif

if ($?standalone) then
    set ddir = .
    if (-e "__SOURCEDIR__") set ddir = `cat "__SOURCEDIR__"`
else
  if ($?yakky) echo "<br>Not standalone; looking in config file for design list<br>"
  # Chasing pointers...
  #set CONFIG = ../../CONFIG.TXT
  set CONFIG = $cgi_dir/../CONFIG.TXT
  if ($?yakky) echo "<br>Looking for DESIGN_LIST definition in '$cgi_dir/../CONFIG.TXT'<br>"
  set DL   = `awk '$1=="DESIGN_LIST"{print $2}' $CONFIG`
  set ddir = `awk '$1 == "'$design'"{print $2}' $DL`

  if ("$ddir" == "") then
    echo "ERROR<br>"
    echo "ERROR: Could not find design '$design' in design list '$DL'<br>"
  endif

endif

if ($?yakky) echo "Design source dir: '$ddir'"

# !?WTF!?
#foreach f ($ddir/*.pm)
#  if (! -e $f) mv $f /tmp
#end
 
##############################################################################
# Update *.pm links for archaic design dirs
# BUG/TODO Can/should we fix this?

if ($design == "tgt0" || $design == "demo") then
  foreach f ($ddir/*.pm)
    #if (! -e $f:t) echo ln -s $f
    if (! -e $f:t) ln -s $f
  end
endif

##############################################################################
# Now continue with make command etc.

set xml_out = $newdesign.xml
set makefile_log = /tmp/genesis$$-makefile.log

echo "make -f $ddir/Makefile gen GENESIS_HIERARCHY=$xml_out GENESIS_CFG_XML=$changefile"
/usr/bin/time -p make -f $ddir/Makefile gen GENESIS_HIERARCHY=$xml_out GENESIS_CFG_XML=$changefile >& $makefile_log
cat $makefile_log

if (! $?status) then
  echo Oops looks like there was an error
  rm LOCK_DELETEME.$$
  exit
endif

echo; echo tar
set tiny = tiny_$newdesign.xml
if (! -e $tiny) set tiny = ""

set small = small_$newdesign.xml
if (! -e $small) set small = ""

set echo

# I kinda tested this and believe it will work even if some of the 
# listed files don't exist (i.e. if nothing matches "*/*.{v,sv}"
/usr/bin/time -p tar cf\
     $newdesign.tar $xml_out $small $tiny *ake*\
      *.{v,sv} */*.{v,sv}\
     LOCK_DELETEME*\
     >& $makefile_log
cat $makefile_log; echo;
rm $makefile_log

########################################################################
# Check to make sure nobody else got through

set locks = (`tar tf $newdesign.tar | egrep '^LOCK_DELETEME'`)
if ($#locks != 1) then
  echo; echo "OOOPS found evidence of a possible collision."
  echo "Conflicting processes: $locks"
  echo "Use browser's BACK button to go back and try again in a minute or two."; echo
  rm LOCK_DELETEME.$$
  exit
endif

if (0) then                          #SDBG
  echo "Maybe I built something?"; echo -n "time now: "; date
  ls -lt *.xml | head -n 3; echo; echo
endif

########################################################################
# Build a valid javascript file

set xml2js_log = /tmp/genesis$$-xml2js.log

echo; echo xml2js
(/usr/bin/time -p $decodedir/xml2js.csh $xml_out > $newdesign.js) >& $xml2js_log
cat $xml2js_log; echo;
rm $xml2js_log

########################################################################
# Remove the lock
rm LOCK_DELETEME.$$

if (0) then #SDBG
  echo "Maybe I built something?"; echo -n "time now: "; date; echo
  ls -lt *.js | head -n 1;      echo
  ls -lt *.xml | head -n 3;     echo; echo
endif

exit;

TEST:
  # Standalone test for debugging purposes
  set designdir = ~steveri/gui/designs/tgt0
  cd $designdir
  set changefile = `/bin/ls -t SysCfgs/*changes.xml | head -n 1`
  #echo Most recent changefile appears to be $changefile
  #echo
  #ls -lt SysCfgs/*changes.xml | head -n 3
  set outfile = deleteme

  echo; echo "Do this:"; echo
  echo "cd $designdir"
  echo "../$0:t -dir . -ch $changefile -out $outfile"
  echo "or"
  echo "../$0:t -dir . -ch NONE -out $outfile"
  echo
exit
