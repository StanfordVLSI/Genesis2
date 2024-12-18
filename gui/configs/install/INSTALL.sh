#!/bin/sh -f

##############################################################################
# EVERYTHING breaks if there's no /usr/bin/perl...!

perl="/usr/bin/perl"
if test ! -f $perl
then
  echo "ERROR could not find $perl"
  echo "    Please install and/or create a symbolic link in order to proceed, e.g."
  echo '    "cd /usr/bin; ln -s /bin/perl"'
  exit -1
fi

##############################################################################
# If args say "-test" or "-test <testname>", then do a test install;
# any other args (e.g. "--help") result in a help message and exit.

if test $# -gt 0;
then
  # echo found args

  if test "$1" = "-test"; # E.g. "INSTALL.sh -test"
  then
    GENESIS_DIR=genesis_test_install; export GENESIS_DIR
    #echo A TEST
    #echo GENESIS_DIR = $GENESIS_DIR
  else
    echo "Usage: INSTALL.sh <-test>";
    echo ""
    echo "By default, builds and installs a gui with the default name 'genesis'."
    echo "With env var GENESIS_DIR set to e.g. 'mygenesis', will use that name instead."
    echo
    echo "With '-test', builds a test-install version 'genesis_test_install'"
    echo "(i.e. sets GENESIS_DIR = 'genesis_test_install')."
    echo

    exit -1;
  fi

  if test $# -gt 1 # E.g. "INSTALL.sh -test genesis_test_install
  then
    GENESIS_DIR="$2"; export GENESIS_DIR
  fi

fi

######################################################################
# Execute the install script, else error if no install script (below).

installscript="./INSTALL.pl"
if test -f $installscript
then
  exec $installscript
  exit 0;
fi

# (else...see below)

###############################################################################
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
