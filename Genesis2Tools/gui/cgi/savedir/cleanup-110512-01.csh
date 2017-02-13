#!/bin/csh -f

set sourcedir = /home/steveri/gui
set destdir   = /var/www/homepage/genesis

cd $destdir

unset doit

if ($#argv > 0) then
  if ("$1" == "-doit") set doit
endif

if (! $?doit) then
    echo; echo "CLEANUP: DRY RUN.  For real run use '-doit' switch."; echo
endif

  ########################################################################
  # Make a place to put all the crap

  set crap = crapdir

if (! $?doit) goto NEXT1

  unset exists; (ls -d $crap >& /dev/null) && set exists
  if ($?exists) then
    echo "CLEANUP: Recommend you examine and delete directory $crap"
    exit
  endif
  mkdir $crap

NEXT1:
  ########################################################################
  echo; echo "CLEANUP: Establish a baseline and get ready."
  dutop $destdir

  ########################################################################
  echo; echo 'CLEANUP: Delete all files in "scratch" directory'

  if (! $?doit) goto NEXT2
  unset exists; (ls -d $crap/scratch >& /dev/null) && set exists
  if (! $?exists) mkdir $crap/scratch

  NEXT2:
  echo mv $destdir/scratch/\* $crap/scratch
  if ($?doit) mv $destdir/scratch/* $crap/scratch
  dutop $destdir

  ########################################################################
  echo; echo 'CLEANUP: Find all directories named "old" "save" "archive" "tmp*" and delete em.'

  set i = 0
  find * -name old   >& /tmp/tmp$$
  find * -name save  >>& /tmp/tmp$$
  find * -name tmp\*  >>& /tmp/tmp$$
  find * -name archive >>& /tmp/tmp$$

  foreach d (`cat /tmp/tmp$$`)
    echo "mv $d    $crap/$d:t.$i"
    if ($?doit) mv $destdir/$d $crap/$d:t.$i
    @ i= $i + 1
  end
  dutop $destdir

  ########################################################################
  echo; echo 'CLEANUP: Delete contents of all directories named "SysCfgs"'

  set i = 0
  find . -name SysCfgs >& /tmp/tmp$$
  foreach d (`cat /tmp/tmp$$`)
    echo "mkdir $crap/$d.$i; mv $d/* $crap/$d:t.$i"
    if ($?doit) then
      mkdir $crap/$d.$i; mv $d/* $crap/$d:t.$i
    endif
    @ i= $i + 1
  end
  dutop $destdir

  ########################################################################
  echo; echo 'CLEANUP: Delete all files *.tar *changes.xml *.js'

  if ($?doit) mkdir $crap/tar_js_and_change_files
  set i = 0
  find . -name \*.tar -o -name \*changes.xml -o -name \*.js >& /tmp/tmp$$
  foreach f (`cat /tmp/tmp$$`)
    echo "mv $f $crap/tar_js_and_change_files"
    if ($?doit) mv $f $crap/tar_and_change_files
    @ i= $i + 1
  end
  dutop $destdir

  echo; echo "CLEANUP: Delete" plain-file zombies from $destdir
  find . -type f -exec /bin/csh -c 'cd ~steveri/gui; test \! -e {}' \; -print | tee /tmp/tmp$$
  set zombies = (`cat /tmp/tmp$$`)
  foreach f ($zombies)
    if (-e $f) then
      echo Removing zombie file $f
      if ($?doit) rm -r $f
    endif
  end

  echo; echo "CLEANUP: Delete" zombie directories from $destdir
  find . -type d -exec /bin/csh -c 'cd ~steveri/gui; test \! -e {}' \; -print | tee /tmp/tmp$$

  set zombies = (`cat /tmp/tmp$$`)
  foreach f ($zombies)
    if (-e $f) then
      echo Removing zombie file $f
      if ($?doit) rm -r $f
    endif
  end



if (! $?doit) then
    echo; echo "CLEANUP: DRY RUN.  For real run use '-doit' switch."; echo
endif

