#!/bin/bash

########################################################################
# Usage:
# build_release.sh          (only works on neva when new_release_num > cur_release_num)
# build_release.sh -f       (works anywhere but may have wrong cur_release_num)
# build_release.sh -f <cur_release_num>     (artificially sets cur_release_num)
#
# Example:
#   build_release.sh -f 11359

########################################################################
# This prog is very safe; it doesn't really do anything except echo
# commands that you then have to cut n paste to do the actual release.
#
# The release can only be built on neva.
#
# If you're not on neva and you still want to see the commands,
# use the "-f" flag.

if [ "$1" != "-f" ]; then

    echo 'Remember to first do a build_tarfile.sh!'
    echo
    echo

    # MUST BE ON NEVA
    if [ ! `hostname` = "neva.stanford.edu" ] ; then
      echo 'Must be on neva for this to work:'
      echo '  ssh neva'
      echo
      echo '...or you could use the -f flag...'
      echo "  $0 -f"
      echo
      exit;
    fi
fi

# Find latest gui release
gui_ver=`cat /home/steveri/gui/configs/install/version_number.txt`; #echo $gui_ver

# Find latest genesis release
gen_ver=`cd /cad/genesis2; ls -d r????? | tail -1`; #echo $gen_ver
gen_ver=`expr substr  $gen_ver 2 5`;                #echo $gen_ver

if [ "$1" == "-f" ]; then
  shift;
  if [  $# -ge 0 ]; then
    gen_ver=$1;
  fi
fi

# Make sure they're not the same
echo "Genesis2 version gen_ver = $gen_ver;"
echo "Stewie   version gui_ver = $gui_ver;"
echo 'Make sure gui_ver > gen_ver'
echo

if [ "$1" != "-f" ]; then
    test $gui_ver -gt $gen_ver || echo -n 'Looks to me like no.  '
    test $gui_ver -gt $gen_ver || echo 'Maybe you need to do a "build_tarfile.sh".'
    test $gui_ver -gt $gen_ver || echo '(Or use -f to force a release).'
    test $gui_ver -gt $gen_ver || echo 'Bye!'
    test $gui_ver -gt $gen_ver || echo
    test $gui_ver -gt $gen_ver || exit -1
fi

## copy release to gui--r$gui_ver (should have already been done)
#echo
#echo "    cd /home/steveri/gui/configs/install/latest-release"
#echo "    cp gui.tar.bz2 gui--r$gui_ver.tar.bz2"

echo "    ########################################################################"
echo "    ### Copy new release $gui_ver to /cad/genesis2/r$gui_ver/gui ###"
echo
echo "    cd /cad/genesis2; sudo mkdir r$gui_ver; cd r$gui_ver"
echo "    sudo tar xjf ~/gui/configs/install/latest-release/gui.tar.bz2"
echo "    sudo echo $gui_ver > gui/configs/install/version_number.txt"
echo
echo "    ########################################################################"
echo "    ### Better make sure the stupid "designs" directory is clean ###"
echo
echo "    unlink gui/designs; mkdir gui/designs"
echo

old=0
new=1

if (( $old )); then
echo "    ###"
echo "    ### (old) Copy PerlLibs from most recent gen_ver ###"
echo "    sudo cp -pr ../r$gen_ver/PerlLibs ."
echo "    ls -lt"
echo
fi

if (( $new )); then
echo "    ########################################################################"
echo "    ### Begin by making a complete copy of the previous version, ###"
echo "    ### then delete the old gui and copy in the new one.         ###"
echo
echo OKAY WELL THIS HAS ALL CHANGED NOW HADNT IT
echo DONT BUILD RELEASE UNTIL YOUVE REVIEWED THE NEW PROCEDURE
echo AND UPDATED THIS SCRIPT (build_release.sh)
echo
echo "    sudo cp -pr ../r$gen_ver/* ."                "OOPS CHANGED RIGHT"
echo "    sudo mv Genesis2Tools/gui /tmp/gui-save.$$"  "OOPS CHANGED RIGHT"
echo "    sudo mv gui Genesis2Tools/"                  "OOPS CHANGED RIGHT"
echo "    ls -lt Genesis2Tools"                        "OOPS CHANGED RIGHT"
echo
fi

echo "    ########################################################################"
echo '    ### Update "latest" in /cad/genesis2 ###'
echo
echo "    cd /cad/genesis2"
echo "    ls -l latest"
echo "    sudo unlink latest; sudo ln -s r$gui_ver latest; ls -l latest"
echo

echo "    #####################################################################"
echo "    ### Update modulefiles (/cad/modules/modulefiles/tools/genesis2/) ###"
echo
echo "    cd /cad/modules/modulefiles/tools/genesis2/"
echo "    cat r$gen_ver | sed 's/GENESIS_VER r.*/GENESIS_VER r$gui_ver/' | sudo tee r$gui_ver"
echo "    diff r$gen_ver r$gui_ver"
echo

echo "    #####################################################################"
echo "    ### Update "latest" in modulefiles ###"
echo
echo "    cd /cad/modules/modulefiles/tools/genesis2/"
echo "    ls -l latest"
echo "    sudo unlink latest; sudo ln -s r$gui_ver latest; ls -l latest"
echo

date=`date +%y%m%d`;

echo "    #####################################################################"
echo "    ### Update vlsiweb ###"
echo
echo "    UPDATE VLSIWEB"
echo "    ssh vlsiweb -p 22222"
echo "    ~/gui/bin/find-updates.csh | tee /tmp/before"
echo "    cd /var/www/homepage"
echo "    cp -r /var/www/homepage/genesis ~/genesis.save/$date"
echo
echo "    /bin/rm -rf /tmp/unpackgui; mkdir /tmp/unpackgui"
echo "    cd /tmp/unpackgui; tar xjf ~/gui/configs/install/latest-release/gui.tar.bz2"
echo "    sudo cp -r gui/* /var/www/homepage/genesis"
echo "    sudo ~steveri/bin/chgor /var/www/homepage/genesis www-data www-data"
echo "    ~/gui/bin/find-updates.csh | tee /tmp/after"
echo
echo "    CLEAN UP and compress ~/genesis.save/$date"
echo
