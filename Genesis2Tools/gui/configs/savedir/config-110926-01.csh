#!/bin/csh -f

set dir = $0:h
if ($dir == $0) then
  set dir = .
endif

# This should take us to the gui home directory.
cd $dir/..
#echo Now I am here: `pwd`

if (! -d configs) then
  echo "Could not find config directory"
  exit
endif

echo

if ($#argv == 0) then
  echo; echo "Config choices:"; echo
  foreach f (`ls -1 configs/CONFIG_*`)
    echo -n "    $0 "; echo $f | sed 's/[^_]*_//' | sed 's/.txt$//'
  end
  echo
  exit
endif

set site = $1
set config = configs/CONFIG_$site.txt
set index  = configs/index_$site.htm

###########################################################################
# Link to site-appropriate config file.
if (! -e $config) then
  echo; echo "Could not find site-specific config file $config"; echo; exit
else
  ln -sf $config CONFIG.TXT
  ls -l CONFIG.TXT         # Confirm successful link
endif


###########################################################################
# Link to site-appropriate index file.
if (! -e $index) then
  echo; echo "Could not find site-specific index file $index"; echo; exit
else
  ln -sf $index index.htm
  ls -l index.htm         # Confirm successful link
endif



echo;

exit

# Find $server/$cgi e.g. "http://www-vlsi.stanford.edu//cgi-bin/genesis"

set server = `awk '$1 == "SERVER_URL" {print $2}' $config`
set cgi    = `awk '$1 == "CGI_URL"    {print $2}' $config`

echo found $server$cgi


cat index.htm \
  | sed "s|YOUR_SITE_HERE|$site|" \
  | sed "s|YOUR_CGI_URL_HERE|$server$cgi|" \
  > /tmp/index.htm.$$

diff index.htm /tmp/index.htm.$$
exit

