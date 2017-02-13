#!/bin/csh -f

# csh works as a cgi executable, right...?
# and/or could call it from a perl file...

# For this to work, we must be "www-data" (preferably)
# or "root" (ick) and we must be on vlsiweb

#################################################################################
# The only way to avoid help is to use any command-line option other than "-help"

unset help
if ($#argv == 0) then
  set help
else if ("$1" == "-help") then
  set help
endif

set sourcedir = /home/steveri/gui
set destdir   = /var/www/homepage/genesis

if ($?help) then
  echo
  echo "Note: Must be logged onto vlsiweb."
  echo
  echo "Recommended usage:"
  echo "  cd ~/gui"
  echo "  save publish.log; rm publish.log"
  echo "  sudo $0 -doit |& tee publish.log"
  echo "  save clean.log; rm clean.log"
  echo "  sudo cgi/cleanup.csh |& tee clean.log"
  echo
  echo -n "Check $destdir for unwanted/unnecessary files; "
  echo    "adjust '-clean' option accordingly."
  echo
  exit
endif

###############################################################################
# Error checking and such.

set h = `hostname`
if ("$h" != "vlsiweb") then
  echo; echo "ERROR: $0 only works from host 'vlsiweb'"; echo; exit;
endif

set whoami = `/usr/bin/whoami`
if ( ("$whoami" != "root") && ("$whoami" != "www-data")) then
  echo; echo "ERROR: Must be 'root' or 'www-data' (preferably 'www-data').";
  echo; exit
endif

if (! -e $sourcedir) then
  echo; echo "MAJOR BADNESS: could not find source directory $sourcedir"; echo;
  exit;
endif

if (! -e $destdir) then
  echo; echo "Creating missing destination directory $destdir"; echo
  mkdir $destdir
endif

########################################################################
# "-clean" option cleans out dead files from the pub site.
# BUG/TODO: should this be the default every time?  probably.
if ("$1" == "-clean") then

  echo "Run $sourcedir/cgi/cleanup.csh"
  exit
endif

#  cd $destdir
#  dutop $destdir
#
##  find . -exec /bin/csh -c 'cd ~steveri/gui; test \! -e {}' \;\
##          -exec echo rm {} \;\
##          -exec rm {} \;
#
#  # Delete files in pub dir ($destdir) if they don't also currently
#  # exist in source dir (~steveri/gui)
#  # BUG/TODO should be "$sourcedir" instead of "~steveri/gui"
#
#  # "rm" for plain files, then "rm -r" for directories
#  # BUG/TODO or could just do "rm -r" for all...!
#
#  echo Delete plain-file zombies from $destdir
#  find . -type f -exec /bin/csh -c 'cd ~steveri/gui; test \! -e {}' \;\
#          -exec echo rm {} \;\
#          -exec rm {} \;
#
#  echo; echo Delete zombie directories from $destdir
#  find . -type d -exec /bin/csh -c 'cd ~steveri/gui; test \! -e {}' \; -print | tee /tmp/tmp$$
#  set zombies = (`cat /tmp/tmp$$`)
#  foreach d ($zombies)
#    if (-e $d) then
#      echo Removing zombie directory $d
#      rm -r $d
#    endif
#  end
#
#  exit
#
#endif

########################################################################
# If source has any files/dirs that don't exist in dest,
# copy them in, preserving links

grep title /var/www/homepage/genesis/configs/index_stanford.htm

echo; 
echo Copying new files from source to dest
echo cp --preserve=timestamp -Rn $sourcedir $destdir
cp --preserve=timestamp -Rn $sourcedir/* $destdir
echo

grep title /var/www/homepage/genesis/configs/index_stanford.htm


########################################################################
# Copy anything in source dir that's different than dest dir

# (the "test -e" part shouldn't be necessary, because of the procedure just above;
# do we need to do a separate check?

#cd $sourcedir; find * -type f \
#  -exec $sourcedir/cgi/comparefiles.csh "$sourcedir"/"{}" "$destdir"/"{}" \;  \
#  -exec echo cp --preserve=timestamp "$sourcedir"/"{}"     "$destdir"/"{}" \; \
#  -exec      cp --preserve=timestamp "$sourcedir"/"{}"     "$destdir"/"{}" \;

echo Updating files in $destdir to match $sourcedir
#cd $sourcedir; time find * -type f \
cd $sourcedir; find * -type f \
  -not -exec test -L "$destdir"/"{}" \;  \
  -not -exec cmp --silent "$sourcedir"/"{}" "$destdir"/"{}" \;  \
  -exec echo cp --preserve=timestamp "$sourcedir"/"{}"     "$destdir"/"{}" \; \
  -exec      cp --preserve=timestamp "$sourcedir"/"{}"     "$destdir"/"{}" \; \

echo

grep title /var/www/homepage/genesis/configs/index_stanford.htm


echo;
echo cmp /home/steveri/gui/configs/index_stanford.htm /var/www/homepage/genesis/configs/index_stanford.htm;
     cmp /home/steveri/gui/configs/index_stanford.htm /var/www/homepage/genesis/configs/index_stanford.htm;
echo


#ln -s CONFIG_stanford.txt CONFIG.TXT
#ln -s index_stanford.htm  index.htm

cd $destdir
echo "Configuring for Stanford site."
configs/config.csh stanford

echo;
echo cmp /home/steveri/gui/configs/index_stanford.htm /var/www/homepage/genesis/configs/index_stanford.htm;
     cmp /home/steveri/gui/configs/index_stanford.htm /var/www/homepage/genesis/configs/index_stanford.htm;
echo


#sed 's|cgi-bin/ig|cgi-bin/genesis|' $sourcedir/index.htm > $destdir/index.htm

################################################################
# Fixup code: if we ran as root (or anyone other than www-data),
# set permissions so that server can use the files.

if ("$whoami" == "root") then
  echo chown -Rh www-data "$destdir"
  chown -Rh www-data "$destdir"

  echo chgrp -Rh www-data "$destdir"
  chgrp -Rh www-data "$destdir"
  echo

endif
