#!/bin/csh -f

# csh works as a cgi executable, right...?
# and/or could call it from a perl file...

# For this to work, we must be "www-data" (preferably)
# or "root" (ick) and we must be on vlsiweb

set whoami = `/usr/bin/whoami`
if ( ("$whoami" != "root") && ("$whoami" != "www-data")) then
  echo; echo "ERROR: Must be 'root' or 'www-data' (preferably 'www-data')."; echo;
  exit
endif

#echo "Okay here we go."

set sourcedir = /home/steveri/gui
set destdir   = /var/www/homepage/genesis

set awfulhack = $sourcedir/cgi/publish.csh      # Hey that's me!!!

if ($#argv > 0) goto COPY

# If source has any files/dirs that don't exist in dest, copy them in

if (! -e $destdir) mkdir $destdir

echo; echo cp -RLn $sourcedir $destdir; echo
cp -RLn $sourcedir/* $destdir

# Copy anything that's changed

cd $sourcedir


find -L . -type f -newer "$destdir"/{} -exec $awfulhack {} \;
echo

if ("$whoami" == "root") then
  echo chown -R www-data "$destdir"; echo
  chown -R www-data "$destdir"
endif



exit


#find -L . -type d -exec $awfulhack {} \;
#find -L . -type f -newer "$destdir"/{} -print
#find -L . -type f -newer "$destdir"/{} -exec echo -n cp {} "$destdir" \; -exec echo {} \;
# echo
# find -L . -type f -newer "$destdir"/{} -exec echo cp {} "$destdir" {} \;

exit

COPY:

echo cp "$sourcedir/$1" "$destdir/$1"
cp "$sourcedir/$1" "$destdir/$1"






##############################################################################
### 
### 
### 
### #echo $0
### 
### 
### find -L . -type d -print
### 
### exit
### 
### 
### 
### 
### exit
### 
### 
### 
### find -L $sourcedir -exec $0 {} \;
### #find -L $sourcedir -exec echo {} \;
### 
### 
### #  find . -exec echo cmp $sourcedir/{} $destdir/{} \;
### 
### 
### exit
### ########################################################################
### 
### set i = 0;
### while (-e "$destdir.save.$i") @ i = $i + 1
### 
### cp -p -R -L $sourcedir $destdir
### chown -R www-data $destdir
### 
### 
### exit
### ########################################################################
### 
### COPY_IF_DIFFERENT:
### 
### set tail = `echo $1 | sed "s|$sourcedir||"`
### 
### #echo
### #echo "and here we are with $1"
### #echo "aka $tail"
### #echo
### 
### set src = "$sourcedir$tail"
### set dest = "$destdir$tail"
### 
### unset copy
### if (! -e "$dest") then
###   set copy
### else
###   if (-d "$src") exit
###   cmp "$src" "$dest" || set copy
### endif
### 
### if (! $?copy) exit
### 
### if (-d "$src") then
###   echo mkdir "$dest"
### else
###   echo cp "$src" "$dest"
### endif
### 
