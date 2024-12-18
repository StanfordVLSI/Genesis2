==============================================================================
Note developers may want to check their generator design directory to
make sure it's going to work with the Genesis and the GUI.  To do
that, see DESIGN PRE-TEST far below.

==============================================================================
Information for users:

Home base for GUI information is here:
    http://genesis2.stanford.edu/mediawiki/index.php/Interactive_Genesis2_GUI

==============================================================================
Information for developers:

To prepare an official release, see
    configs/install/README-packing.txt
and/or
    http://genesis2.stanford.edu/mediawiki/index.php/Interactive_Genesis2_GUI#Preparing_an_official_release

The rest of this file deals with how to update Stanford's
vlsiweb-based version of Original GUI without going through an
official release. Also see:
    http://genesis2.stanford.edu/mediawiki/index.php/Interactive_Genesis2_GUI#Installing_Original_GUI_on_vlsiweb_directly_from_the_development_directory

------------------------------------------------------------------------------
HOW TO UPDATE VLSIWEB DIRECTLY FROM THE DEVELOPMENT DIRECTORY

The easiest thing is to upgrade the existing installation directly
from the development directory.  The instructions below come from the
link

    http://genesis2.stanford.edu/mediawiki/index.php/Original_GUI_Installation_Details#Upgrade_existing_install_OR

, which should always have the latest procedure.

To install gui from scratch on vlsiweb, see "HOW TO UPDATE VLSIWEB AS
A NEW INSTALL," below


The sequence below simply copies the new files in place of the
old. For paranoia's sake, it's probably good to preserve a copy of the
existing installation before overwriting it with the new update. For
instance, at Stanford we would do:

 % source ~/gui/configs/setup_stanford.cshrc  (I think) (to get $GENESIS_HOME etc.)
 % cp -r /var/www/homepage/genesis ~/genesis.old
 % cd $GENESIS_HOME
 % cp -r gui/* /var/www/homepage/genesis

or maybe just

 % cp -rf gui/* /var/www/homepage/genesis

If updating, YOU ARE DONE, DO NOT PROCEED.

--------------------------------------------------------------------------------
HOW TO UPDATE VLSIWEB AS A NEW INSTALL

Latest/greatest information will always be found here (I hope):

    http://genesis2.stanford.edu/mediawiki/index.php/Original_GUI_Installation_Details#New_install

For a vlsiweb install, you'll first need to ssh to vlsiweb:

  % ssh vlsiweb



(had to do this:
  mkdir /var/www/homepage
  mkdir /usr/lib/cgi_bin






For a new install, cd to the install directory
$GENESIS_HOME/gui/configs/install. Run the install script INSTALL.sh
and follow the directions. Note that you'll probably need to have full
root privilege (e.g. sudo) for everything to work properly.

Okay, so here we go:

 % source ~/gui/configs/setup_stanford.cshrc  (I think) (to get $GENESIS_HOME etc.)
 % cd $GENESIS_HOME
 % cd gui/configs/install
 % sudo ./INSTALL.sh

of course, if you don't have access to sudo, you'll instead be doing
something like

 % su root
 # ./INSTALL.sh

Note: By default the installation will create a website called
"genesis," e.g. its URL will be "http://your-site.com/genesis" and the
cgi files will live in e.g. "http://your-site.com/cgi/genesis". If for
some reason you cannot use the default install name "genesis", and/or
if you want to make a separate test installation with a different name
you can do that by answering "yes" when prompt for changing the server
subdirectory. Only do that if you really know what you are doing. You
can also use the "-test" option for INSTALL.sh, e.g.

 % cd $GENESIS_HOME
 % cd gui/configs/install
 % sudo ./INSTALL.sh -test genesis_test_install

Either way, these (above) would create a web site

   http://your-site.com/genesis_test_install

...instead of the default

   http://your-site.com/genesis

INSTALL.sh will want to know and/or will try to guess the following information (examples are from Stanford's installation at http://www-vlsi.stanford.edu/genesis - feel free to visit there for reference purposes):

what is your web-server URL (e.g. "http://www-vlsi.stanford.edu")
where do cgi files live on your server (e.g. "/usr/lib/cgi_bin")
what pathname does your server use to access cgi files (e.g. "/cgi-bin")
where do "/" level html files live on your server (e.g. "/var/www/homepage")
what is the username of the web server (e.g. "www-data")
what group name (for chgrp) can the web server access(e.g. "www-data")

Note the instructions at the end of the INSTALL script, which will
tell you how to set correct permissions such that the web server can
use the new installation. You'll be doing something like this:

 % chown -R www-data /var/www/homepage/genesis
 % chgrp -R www-data /var/www/homepage/genesis

 % chown -R www-data /usr/lib/cgi-bin/genesis
 % chgrp -R www-data /usr/lib/cgi-bin/genesis


==============================================================================
DESIGN PRE-TEST

Pre-test to see if design directories work with Genesis.  Example
below is for design directory "CMP."  Easiest to try on kiwi first
maybe, and then vlsiweb.

  # For a clean environment do a new ssh
  ssh kiwi
  source ~/gui/configs/setup_stanford.cshrc

  # It's supposed to work from anywhere, so let's use /tmp
  set tmpdir = /tmp/deleteme-gui-test
  mkdir $tmpdir; cd $tmpdir

  # Bug: CMP Makefile dependence on SysCfgs; how/why?
  mkdir $tmpdir/SysCfgs; touch $tmpdir/SysCfgs/config.xml

  # optional?
  touch empty.xml

  set ddir = `cat ~/gui/designs/FFTGenerator/__SOURCEDIR__`
  make -n -f $ddir/Makefile gen


Bug: CMP Makefile dependence on SysCfgs; how/why?
If do above test sequence w/ddir=designs/CMP, complains about
missing SysCfgs/config.xml...??

Note: Makefile should be doing this, basically:
  make -f $ddir/Makefile gen GENESIS_HIERARCHY=$xml_out GENESIS_CFG_XML=$changefile >& $makefile_log

==============================================================================
