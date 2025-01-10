#!/bin/csh -f

# COMPLETELY EMPTIES OUT the deisgn dir and rebuilds a bare-bones version

set curdir = `pwd`
set curdir = $curdir:t

set date = `date +%y%m%d`

set cleanup_dir = ../$curdir.old.$date

while (-e $cleanup_dir)
  set cleanup_dir = ${cleanup_dir}_
end

echo 
echo "  sudo mkdir $cleanup_dir"
echo "  sudo mv \* $cleanup_dir"
echo "  sudo cp $cleanup_dir/__SOURCEDIR__ ."
echo "  sudo mkdir SysCfgs"
echo '  sudo chown www-data *; sudo chgrp www-data *'
