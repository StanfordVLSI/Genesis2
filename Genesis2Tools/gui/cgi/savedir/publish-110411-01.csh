#!/bin/csh -f

# csh works as a cgi executable, right...?
# and/or could call it from a perl file...

# For this to work, we must be "www-data" (preferably)
# or "root" (ick) and we must be on vlsiweb

set h = `hostname`
if ("$h" != "vlsiweb") then
  echo; echo "ERROR: $0 only works from host 'vlsiweb'"; echo;
  exit;
endif

set whoami = `/usr/bin/whoami`
if ( ("$whoami" != "root") && ("$whoami" != "www-data")) then
  echo; echo "ERROR: Must be 'root' or 'www-data' (preferably 'www-data')."; echo;
  exit
endif

#echo "Okay here we go."

set sourcedir = /home/steveri/gui
set destdir   = /var/www/homepage/genesis

if (! -e $sourcedir) then
  echo; echo "MAJOR BADNESS: could not find source directory $sourcedir"; echo;
  exit;
endif

if (! -e $destdir) then
  echo; echo "Creating missing destination directory $destdir"; echo
  mkdir $destdir
endif

# BUG/TODO: should this be the default every time?  probably.
if ("$1" == "-clean") then
  cd $destdir
#  find . -exec /bin/csh -c 'cd ~steveri/gui; test -e {} || echo rm {}; rm {}' \;
#  find . -exec /bin/csh -c 'cd ~steveri/gui; test -e {} || echo rm {}; echo rm {}' \;
   find . -exec /bin/csh -c 'cd ~steveri/gui; test \! -e {}' \;\
           -exec echo rm {} \;\
           -exec rm {} \;
  exit
endif


## If a filename got passed in, copy the file from source to dest
#if ($#argv > 0) then
#  echo cp "$sourcedir/$1" "$destdir/$1"
#  cp "$sourcedir/$1" "$destdir/$1"
#  exit
#endif

# Otherwise, copy new/changed files from source to dest.
# BUG/TODO (Note zombie files in dest dir never go away...)

# If source has any files/dirs that don't exist in dest, copy them in, preserving links

echo; echo cp -Rn $sourcedir $destdir; echo
cp -Rn $sourcedir/* $destdir

# Copy anything in source dir that's changed since last update

# If file in sourcedir is newer than equiv file in destdir, call self w/name of file.

set awfulhack = $sourcedir/cgi/publish.csh      # Hey that's me!!!


#set local_oldest = `\
#  /bin/ls -l --time-style=full-iso * */* \
#  | sort -k 6 -k 7 | awk 'NF>3 { print $NF; exit; }'\
#`

#echo find foo -type f -exec test "$sourcedir"/"{}" -nt "$destdir"/"{}" \; -exec echo yes \;

#find foo -type f -exec test "$sourcedir"/"{}" -nt "$destdir"/"{}" \; -exec echo yes \;


cd $sourcedir
find . -type f \
  -exec echo test "$sourcedir"/"{}" -nt "$destdir"/"{}" \;

find . -type f \
  -exec test    "$sourcedir"/"{}" -nt "$destdir"/"{}" \; \
  -exec echo cp "$sourcedir"/"{}"     "$destdir"/"{}" \; \
  -exec      cp "$sourcedir"/"{}"     "$destdir"/"{}" \; \



#find foo -type f -exec test "$sourcedir"/"{}" -nt "$destdir"/"{}" \; -exec $awfulhack {} \;


#set local_oldest = `ls -dt * */* | tail -1`
#
#
#echo "Oldest local file: '$local_oldest'"
#ls -ld "$destdir"/$local_oldest
#echo
#
#cd $sourcedir
#
##echo find . -type f -newer "$destdir"/$local_oldest -exec $awfulhack {} \;
##find . -type f -newer "$destdir"/$local_oldest -exec $awfulhack {} \;
#
#find . -type f -exec awk 'BEGIN{print "a" '{}'; exit}'
#
#
#

#echo
#echo find . -type l -newer "$destdir"/$local_oldest -exec $awfulhack {} \;
#find . -type l -newer "$destdir"/$local_oldest -exec $awfulhack {} \;
##find . -type l -newer "$destdir"/{} -exec $awfulhack {} \;
##find . -type l -newer "$destdir"/last_update -exec $awfulhack {} \;

#echo
#
#cd $destdir
##touch last_update
#
##ln -s CONFIG_stanford.txt CONFIG.TXT
##ln -s index_stanford.htm  index.htm

cd $destdir
echo "Configuring for Stanford site."
configs/config.csh stanford

#sed 's|cgi-bin/ig|cgi-bin/genesis|' $sourcedir/index.htm > $destdir/index.htm

# Fixup code: if we ran as root (or anyone other than www-data),
# set permissions so that server can use the files.

if ("$whoami" == "root") then
  echo chown -R www-data "$destdir"
  chown -R www-data "$destdir"

  echo chgrp -R www-data "$destdir"
  chgrp -R www-data "$destdir"
  echo

endif
