#!/bin/sh -f

# EVERYTHING breaks if there's no /usr/bin/perl...!

perl="/usr/bin/perl"
if test ! -f $perl
then
  echo "ERROR could not find $perl"
  echo "    Please install and/or create a symbolic link in order to proceed, e.g."
  echo '    "cd /usr/bin; ln -s /bin/perl"'
  exit -1
fi

installscript="./INSTALL.pl"
if test -f $installscript
then
  exec $installscript
  exit 0;
fi

# If we made it this far, that means we didn't find the install script
# Maybe we're in the wrong place?
# E.g. if this script was called using "/foo/bar/gui/configs/install/INSTALL.sh"
# we'll cd to "/foo/bar/gui/configs/install/" and try again
installdir=${0%*/*}
cd $installdir
if test -f $installscript
then
  pwd
  exec $installscript
  exit 0;
else
  echo "ERROR could not find INSTALL.pl"
  echo "  To fix: find INSTALL.pl in gui/configs/install"
  echo "  Cd to its directory and run it.  Example:"
  echo "    % cd /home/mydir/gui/configs/install"
  echo "    % ./INSTALL.pl"
  exit -1
fi
