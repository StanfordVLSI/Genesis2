#!/bin/sh -f

# Want to begin in the same directory where the script lives.
# echo 'we should be here: gui/configs/install'

# This seems to work why muck with it?
if [ "$1" = "-q" ]; then quiet=1; else quiet=0; fi
#echo "quiet = $quiet"

scriptpath=$0       # E.g. "build_tarfile.sh" or "foo/bar/build_tarfile.sh"
scripthead=${0%/*}  # E.g. "build_tarfile.sh" or "foo/bar"

if test "$scripthead" != "$scriptpath";
then
  echo cd "$scripthead";
  cd "$scripthead";
fi

# pwd
# echo

cd ../..
# pwd
# echo

if (! test -d ../gui)
then
  echo 'ERROR: Something is wrong; cannot find dir "gui"'
fi

# ls -l ../gui

time_to_go=0
tarfile=/tmp/gui.tar
if (test -f $tarfile) then
  echo ""
  echo "ERROR: Oops tarfile '$tarfile' already exists; please delete it and try again:"
  echo "/bin/rm $tarfile"
  echo ""
  time_to_go=1
fi
if (test -f $tarfile.bz2) then
  echo ""
  echo "ERROR: Oops tarfile '$tarfile.bz2' already exists; please delete it and try again:"
  echo "/bin/rm $tarfile.bz2"
  echo ""
  time_to_go=1
fi

test $time_to_go -eq 1 && exit -1



# 1. Don't write over existing config files (first "exclude" group)
# 2. Don't propagate trash to the tar file (second "exclude" group)

# local "stewie clone" is nicer if have pre-existing "designs" file
#  --exclude 'configs/design_*'\

cd -P ..
tar cf $tarfile gui \
  --exclude 'CONFIG.TXT'\
  --exclude 'index.htm'\
  --exclude 'configs/index.htm'\
  --exclude 'configs/install/latest-release'\
\
  --exclude 'designs/*'\
  --exclude 'designs_*'\
  --exclude 'fpgbug'\
  --exclude 'samples'\
  --exclude 'scratch/*'\
\
  --exclude 'archive'\
  --exclude 'archives'\
  --exclude '*deleteme*'\
  --exclude 'old'\
  --exclude '*.old'\
  --exclude 'save'\
  --exclude 'savedir'\
  --exclude 'tmp*'\
  --exclude '*~'\
\
  --exclude 'examples/*/SysCfgs/*'\
  --exclude 'examples/*/*.save'\
  --exclude 'examples/*/*.tar'

cd gui/configs/install
#tar f $tarfile --append README.txt

bzip2 $tarfile

echo ""
echo "Built tarfile '$tarfile.bz2'; should be about 200 KB:"
wc -c $tarfile.bz2

if [ "$quiet" -ne 0 ]; then
    exit;
fi

echo ""
echo "Remember to move it to its final home:"
echo '    cd $CHIPGEN/bin/Genesis2Tools/gui/configs/install/latest-release'
echo "    p4 edit gui.tar.bz2"
echo "    mv $tarfile.bz2 ."
echo "    p4 submit"
echo "    set cnum=(Change number 'ddddd' of submit)"
echo "    echo \$cnum > ~/gui/configs/install/version_number.txt"
echo "    cp gui.tar.bz2 gui--r\$cnum.tar.bz2"
echo "    edit and update ~/gui/configs/install/release-notes.txt"
echo ""
echo "Then:"
echo "    ssh neva"
echo '    $CHIPGEN/bin/Genesis2Tools/gui/configs/install/build_release.sh |& tee /tmp/$$'
echo ""
echo "To check the tarfile:"
echo "    tar tjf gui.tar.bz2"
echo ""
echo "Tarfile should be about 300 KB:";
echo -n "    "; wc -c $tarfile.bz2
echo ""
exit



# $ tar -zcvf /tmp/mybackup.tar.gz --exclude='abc' --exclude='xyz' /home/me

# $ tar -zcvf /tmp/mybackup.tar.gz -X exclude.txt /home/me
# where exclude.txt contains:
#
# abc
# xyz
# *.bak

#--anchored
#--no-anchored
#
#    If anchored, a pattern must match an initial subsequence of the
#    name's components. Otherwise, the pattern can match any
#    subsequence. Default is --no-anchored for exclusion
#    members and --anchored inclusion members.

#--ignore-case
#--no-ignore-case
#
# When ignoring case, upper-case patterns match lower-case names and
# vice versa. When not ignoring case (the default), matching is
# case-sensitive.

#--wildcards-match-slash
#--no-wildcards-match-slash
