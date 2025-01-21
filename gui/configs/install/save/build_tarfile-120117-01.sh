#!/bin/sh -f

# Want to begin in the same directory where the script lives.
# echo 'we should be here: gui/configs/install'

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

tar cvf /tmp/deleteme.gui.tar .\
  --exclude 'designs'\
  --exclude 'old'\
  --exclude '*.old'\
  --exclude 'save'\
  --exclude 'archive'\
  --exclude 'archives'\
  --exclude 'tmp*'\
  --exclude 'deleteme'\
  --exclude '*~'\
  --exclude 'scratch'\
  --exclude 'samples'\
  --exclude 'fpgbug'

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
