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
  echo "  ssh vlsiweb"
  echo ""
  echo "  cd ~/gui"
  echo "  save clean.log.before; rm clean.log.before"
  echo "  sudo cgi/cleanup.csh |& tee clean.log.before"
  echo "  ls clean.log.before"
  echo '   - (SHOULD BE EMPTY\!\!\!?)'
  echo ""
  echo "  cd ~"
  echo "  if (! -e genesis.save) mkdir genesis.save"
  echo "  pushd /var/www/homepage"
  echo "  tar cf - genesis | gzip -c > ~/genesis.save/genesis.tar.gz.$$"
  echo "  popd"
  echo "  ls -lt genesis.save"
  echo ""
  echo "  cd ~/gui"
  echo "  save publish.log; rm publish.log"
  echo "  sudo cgi/publish.csh -doit |& tee publish.log"
  echo "  save clean.log.after; rm clean.log.after"
  echo "  sudo cgi/cleanup.csh |& tee clean.log.after"
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
# "-clean": Deprecated option
if ("$1" == "-clean") echo "Run $sourcedir/cgi/cleanup.csh"
if ("$1" == "-clean") exit

#######################################################################################
# If source has any files/dirs that don't exist in dest, copy them in, preserving links
# (The (undocumented?) -n switch means "noclobber"

echo; 
echo Copying new files from source to dest
echo cp --preserve=timestamp -Rn $sourcedir $destdir
cp --preserve=timestamp -Rn $sourcedir/* $destdir
echo

########################################################################
# Copy anything in source dir that's different than dest dir
# DON'T try to copy onto a symbolic link---that only leads to trouble.

echo Updating files in $destdir to match $sourcedir

#cd $sourcedir; find * -type f \
#  -not -exec test -L "$destdir"/"{}" \;  \                                       # skip symbolic links
#  -not -exec cmp --silent "$sourcedir"/"{}" "$destdir"/"{}" \;  \                # skip anything identical
#  -exec echo cp --preserve=timestamp "$sourcedir"/"{}"     "$destdir"/"{}" \; \
#  -exec      cp --preserve=timestamp "$sourcedir"/"{}"     "$destdir"/"{}" \; \

cd $sourcedir; find * -type f                                   # skip symbolic links\
  -not -exec test -L "$destdir"/"{}" \;                         # skip anything identical\
  -not -wholename 'designs/*'                                   # DO NOT overwrite existing design dirs\
  -not -wholename 'configs/designs*'                            # DO NOT overwrite existing design list(s)\
  #\
  -not -wholename 'archives/*' -not -wholename '*/archives/*'   # skip archives\
  -not -wholename 'save/*'     -not -wholename '*/save/*'       # skip save directories\
  -not -wholename 'old/*'     -not -wholename '*/old/*'         # skip "old" directories\
  -not -wholename 'designs.old/*'\
  -not -wholename 'scratch/*'\
  #\
  -not -exec cmp --silent "$sourcedir"/"{}" "$destdir"/"{}" \;  \
  -exec echo cp --preserve=timestamp "$sourcedir"/"{}"     "$destdir"/"{}" \; \
  -exec      cp --preserve=timestamp "$sourcedir"/"{}"     "$destdir"/"{}" \; \

echo

########################################################################
# Site-specific configuration

#ln -s CONFIG_stanford.txt CONFIG.TXT
#ln -s index_stanford.htm  index.htm

cd $destdir
echo "Configuring for Stanford site."
configs/config.csh stanford

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
