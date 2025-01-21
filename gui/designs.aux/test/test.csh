#!/bin/csh -f

#set DL = ../design_list.txt
set DL = `awk '$1=="DESIGN_LIST"{print $2}' ../../CONFIG.TXT`

cat $DL
echo ------------------------------------------------------------------------
sed 's/^#.*//g' $DL
echo ------------------------------------------------------------------------
sed 's/^#.*//g' $DL | egrep ...
echo ------------------------------------------------------------------------

########################################################################
# Make a list of directories and targets

set designs = `sed 's/^#.*//g' $DL | egrep ... | awk '{print $1}'`
set sources = `sed 's/^#.*//g' $DL | egrep ... | awk '{print $2}'`

########################################################################
# Check for existing test subdirs that shouldn't be here.

set needclean = ();

foreach d ($designs) 
  echo $d
  if (-e $d) then
    set needclean = ($needclean $d); break;
  endif
end

if ($#needclean) then
  echo "One or more test directories exists; recommend:"
  echo "/bin/rm -rf $needclean"
  exit
endif

echo ------------------------------------------------------------------------


########################################################################
# Okay, let's do it.

if ($USER == "steveri") then
  setenv SMASH /home/steveri/smart_memories/Smart_design/ChipGen
endif

setenv GENESIS_CFG_XML /dev/null

while ($#designs)
  set d = $designs[1];  set s = $sources[1]
  echo "Checking $d => $s"

  echo "mkdir $d"
  mkdir $d

  echo "cd $d; make gen -f $s/Makefile"
  pushd $d;
    foreach f ($s/*.{vp,pm})
      ln -s $f
    end
    make gen -f $s/Makefile
  popd

exit;

  shift designs; shift sources
  echo;
end



