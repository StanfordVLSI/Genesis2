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

# Set up EXCLUSIONS file
set tmp = /tmp/tmp.$$
cat <<EOF > $tmp
archives
*old
tmp*
save
savedir
samples
*deleteme*
latest-release
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
designs_dev_sr_clean

EOF

echo -n "Comparing $dev to $pub "
if ("$brief" == "") then
  echo "  (brief)"
else
  echo "  (verbose)"
endif

#echo Comparing $pub to $dev
echo
diff -r $dev $pub -X $tmp $brief\
  | awk '\
         /Files.*differ$/{ print $0 "\ndiff " $2 " " $4 "\nsudo cp " $2 " " $4 "\n"; next; }\
                         { nc = $3; sub(/:/,"",nc) }\
         /Only in .home/ { print $0 "\nrm " nc "/" $4 "\n"; next; }\
         /Only in .var/  { print $0 "\nsudo rm " nc "/" $4 "\n"; next; }\
                         { print }'
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




