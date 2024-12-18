#!/bin/csh -f

unset n
if ("$1" == "-n") set n

if ($?n) then
  echo '#\!/bin/csh -f'
#  echo; echo 'set echo'
endif

set sourcedir = /home/steveri/gui
set destdir   = /var/www/homepage/genesis

if ($?n) echo "cd $destdir"
cd $destdir

# Could be disastrous if we're not in the right place!!!
if (`pwd` != "$destdir") then
  echo "#CWD NOT $destdir ??"
  exit
endif

# if ($?n) echo "~steveri/bin/dutop $destdir"; echo

if ($?n) then
  echo
  echo 'echo -n "#SIZE NOW: "'
  echo ~steveri/bin/dutop $destdir
else
  echo -n "#SIZE NOW: "
  ~steveri/bin/dutop $destdir
endif
echo

########################################################################

cd $destdir
echo '#CLEANUP: Delete all files in "scratch" directory'

echo /bin/rm -rf $destdir/scratch/\*
if (! $?n) /bin/rm -rf $destdir/scratch/*

if ($?n) then
  echo; echo 'echo -n "#SIZE NOW: "'
  echo ~steveri/bin/dutop $destdir
else
  echo -n "#SIZE NOW: "
  ~steveri/bin/dutop $destdir
endif

########################################################################
echo; echo '#CLEANUP: Find all directories named "old" "save" "archive" and "tmp*" and delete em.'
cd $destdir

echo; find . -name old   >& /tmp/tmp$$
foreach f (`cat /tmp/tmp$$`)
  echo /bin/rm -rf $f; if (! $?n) /bin/rm -rf $f
end

echo; find * -name save  >& /tmp/tmp$$
foreach f (`cat /tmp/tmp$$`)
  echo /bin/rm -rf $f; if (! $?n) /bin/rm -rf $f
end

echo; find * -name tmp\* >& /tmp/tmp$$
foreach f (`cat /tmp/tmp$$`)
  echo /bin/rm -rf $f; if (! $?n) /bin/rm -rf $f
end

echo; find * -name archive -o -name archives >& /tmp/tmp$$
foreach f (`cat /tmp/tmp$$`)
  echo /bin/rm -rf $f; if (! $?n) /bin/rm -rf $f
end

# Pesky emacs backup files
echo; find * -name \*~ >& /tmp/tmp$$
foreach f (`cat /tmp/tmp$$`)
  echo /bin/rm -rf $f; if (! $?n) /bin/rm -rf $f
end

if ($?n) then
  echo; echo 'echo -n "#SIZE NOW: "'
  echo ~steveri/bin/dutop $destdir
else
  echo -n "#SIZE NOW: "
  ~steveri/bin/dutop $destdir
endif
echo

########################################################################
echo; echo '#CLEANUP: Delete contents of all directories named "SysCfgs"'
cd $destdir

echo; find . -path \*/SysCfgs/\* >& /tmp/tmp$$
foreach f (`cat /tmp/tmp$$`)
  echo /bin/rm -rf $f; if (! $?n) /bin/rm -rf $f
end

if ($?n) then
  echo; echo 'echo -n "#SIZE NOW: "'
  echo ~steveri/bin/dutop $destdir
else
  echo -n "#SIZE NOW: "
  ~steveri/bin/dutop $destdir
endif
echo

########################################################################
echo; echo '#CLEANUP: Delete all files *.tar *changes.xml'
cd $destdir

find . -name \*.tar -o -name \*changes.xml >& /tmp/tmp$$
foreach f (`cat /tmp/tmp$$`)
  echo /bin/rm -rf $f; if (! $?n) /bin/rm -rf $f
end

if ($?n) then
  echo; echo 'echo -n "#SIZE NOW: "'
  echo ~steveri/bin/dutop $destdir
else
  echo -n "#SIZE NOW: "
  ~steveri/bin/dutop $destdir
endif
echo

########################################################################
echo; echo '# CLEANUP: Delete all files *.js under designs/'
cd $destdir

find designs -name \*.js >& /tmp/tmp$$
foreach f (`cat /tmp/tmp$$`)
  echo /bin/rm -rf $f; if (! $?n) /bin/rm -rf $f
end

if ($?n) then
  echo; echo 'echo -n "#SIZE NOW: "'
  echo ~steveri/bin/dutop $destdir
else
  echo -n "#SIZE NOW: "
  ~steveri/bin/dutop $destdir
endif
echo

########################################################################
# DONE if -n set
if ($?n) exit

########################################################################
echo; echo "#CLEANUP: Delete plain-file zombies from $destdir EXCEPT ./designs/*/*.xml"
cd $destdir

# find . -type f -exec /bin/csh -c 'cd ~steveri/gui; test \! -e {}' \; -print | tee /tmp/tmp$$

find . -type f -exec /bin/csh -c 'cd ~steveri/gui; test \! -e {}' \; -print \
  | egrep -v '^[.][/]designs[/].*[.]xml$'\
  | tee /tmp/tmp$$

set zombies = (`cat /tmp/tmp$$`)

foreach f ($zombies)
  if (-e $f) then
#    echo Removing zombie file $f
    rm -r $f
  endif
end

if ($?n) then
  echo; echo 'echo -n "#SIZE NOW: "'
  echo ~steveri/bin/dutop $destdir
else
  echo -n "#SIZE NOW: "
  ~steveri/bin/dutop $destdir
endif
echo

########################################################################
echo; echo "#CLEANUP: Delete" zombie directories from $destdir EXCEPT DESIGN DIRECTORIES!
cd $destdir

#find . -type d -exec /bin/csh -c 'cd ~steveri/gui; test \! -e {}' \; -print | tee /tmp/tmp$$

find . -type d -exec /bin/csh -c 'cd ~steveri/gui; test \! -e {}' \; -print \
  | egrep -v '^[.][/]designs[/]'\
  | tee /tmp/tmp$$


set zombies = (`cat /tmp/tmp$$`)
foreach f ($zombies)
  if (-e $f) then
#    echo Removing zombie file $f
    rm -r $f
  endif
end

if ($?n) then
  echo; echo 'echo -n "#SIZE NOW: "'
  echo ~steveri/bin/dutop $destdir
else
  echo -n "#SIZE NOW: "
  ~steveri/bin/dutop $destdir
endif
echo

