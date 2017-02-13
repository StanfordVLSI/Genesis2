#!/bin/csh -f

dutop * | sort -n | tail -40
exit

echo tar files:
ls -lt *.tar

echo xml files:
ls -lt *.xml

