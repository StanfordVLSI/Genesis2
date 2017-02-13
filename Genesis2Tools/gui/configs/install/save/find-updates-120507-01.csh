#!/bin/csh -f

# Run this script from vlsiweb to see what needs updating.

set h = `hostname`
if ($h != "vlsiweb") then
  echo "Should run this script from host 'vlsiweb'"
  exit
endif

set brief = "--brief"

set dev = /home/steveri/gui
set pub = /var/www/homepage/genesis

while ($#argv > 0) 
  switch ($1)
    case "--brief":
    case "-brief":
    case "-q":
      echo "found arg '--brief'";
      set brief = "--brief"
      shift
      breaksw;
    case "--verbose":
    case "-verbose":
    case "-v":
      echo "found arg '--verbose'";
      set brief = ""
      shift
      breaksw;
    default:
      if ($#argv == 2) then
        set dev = $1
        set pub = $2
        shift; shift
      else
        goto HELP
      endif
  endsw
end

if (! -d $dev) then
  echo "ERROR: Could not find dev dir $dev"; goto HELP
else if (! -d $pub) then
  echo "ERROR: Could not find pub dir $pub"; goto HELP
endif

echo -n "Comparing $pub to $dev "
if ("$brief" == "") then
  echo "  (brief)"
else
  echo "  (verbose)"
endif

# Set up EXCLUSIONS file
set tmp = /tmp/tmp.$$
cat <<EOF > $tmp
archives
*old
tmp*
save
design_list*backup*
designs
design_list*
index.htm
CONFIG.TXT
examples
scratch
xml-tools
fpgbug
publish.log

EOF

echo Comparing $pub to $dev
echo
diff -r $pub $dev -X $tmp $brief
rm $tmp
exit
########################################################################
HELP:
echo "Usage: $0 [ -q | -v ]";
echo "Or:    $0 /home/steveri/gui /var/ww/homepage/genesis"
echo
echo "  [ -q | --brief ] => Just say whether or not files differ (default)"
echo "  [ -v | --verbose ] => Display detailed diff of each file"
echo
exit



########################################################################
OLD:
diff -r $pub $dev\
  -x archives\
  -x \*old\
  -x tmp\*\
  -x save\
  -x design_list\*backup\*\
  -x designs




