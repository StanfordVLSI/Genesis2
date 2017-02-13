= How do I build a new GUI release? (DEVELOPERS ONLY) =

* Short answer: "./build_release.sh"
* Long answer: see below.

<small><i>
Note: This information exists in two places:
* http://genesis2.stanford.edu/mediawiki/index.php/Original_GUI_Installation_Details#How_do_I_build_a_new_GUI_release.3F_.28DEVELOPERS_ONLY.29
* $GENESIS_HOME/README-packing.txt
</i></small>

== Build the release ==

If you just want the latest source tarball, there should be one in the development path at this location:

  $CHIPGEN/bin/Genesis2Tools/gui/configs/install/latest-release/gui.tar.bz2
  gui/configs/install/latest-release/gui.tar.bz2

To build a new tarball and/or a complete new release, do this:

  cd $CHIPGEN/bin/Genesis2Tools/gui/configs/install
  ./build_tarfile.sh
  ssh neva
  ./build_release.sh

Note that "build_release" only works on neva, because of permission
problems with respect to final install location "/cad".

== Test the release ==

To be safe, we'll use a test location "homepage/genesis_text_install" to test
the release, instead of the official final home "homepage/genesis".

=== Out with the old ===

To test the installation-package process, login to vlsiweb and erase 
the old installation (if one exists), as shown below.  This does some scary stuff
(like "sudo /bin/rm -rf"), so please make sure you know what you're doing!

  ssh vlsiweb
  sudo /bin/rm -rf /var/www/homepage/genesis_test_install /usr/lib/cgi-bin/genesis_test_install

=== In with the new ===

At Stanford:

  ssh vlsiweb
  sudo /bin/rm -rf /tmp/unpackgui
  mkdir /tmp/unpackgui

  cd /tmp/unpackgui
  cp ~/gui/configs/install/*/gui.tar.bz2 .
  tar xjf gui.tar.bz2

  cd /tmp/unpackgui/gui/configs/install
  sudo ./INSTALL.sh -test

=== Verify the test install ===

Go to "http://www-vlsi.stanford.edu/genesis_test_install";
click on "Choose a design" and then "edit the design database";
enter design name "tgt0_example" and design location 
"/var/www/homepage/genesis_test_install/examples/tgt0"
and then click "Submit" and then click "return to choose..."
