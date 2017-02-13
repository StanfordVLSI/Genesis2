#!/bin/csh -f

set sourcedir = /home/steveri/gui
set destdir   = /var/www/homepage/genesis

echo Listing files in $destdir that do not match $sourcedir

set echo

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
  -print

exit




#  -exec echo cp --preserve=timestamp "$sourcedir"/"{}"     "$destdir"/"{}" \; \
#  -exec      cp --preserve=timestamp "$sourcedir"/"{}"     "$destdir"/"{}" \; \

echo
