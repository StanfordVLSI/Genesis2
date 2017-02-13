To add a new Genesis2 design to the gui:

Assuming you're currently in the "designs" subdirectory of the genesis 
gui (i.e. where this README file lives):

  1. Link your new design ("mydesign in the example below) to the gui's design directory:
     % ln -s $MYPATH/mydesign mydesign
     % ls $GUI_PATH/designs/mydesign (check---should be there)

  2. Make sure the new design has a SysCfgs subdirectory where the
     gui can write temporary change files:
     % mkdir mydesign/SysCfgs

  3. Make sure the makefile in "mydesign" supports the following syntax
     (needed when gui calls "updatedesign.csh" in this directory)

     % cd $MYPATH/mydesign
     % make gen GENESIS_HIERARCHY=new.xml GENESIS_CFG_XML=SysCfgs/changefile.xml

  4. Make sure the gui has read/write permissions for the design directory
     and change subdirectory (MAY NEED TO BE ROOT for this to work).  In
     the following example, the web server is a member of group "33":

     % chgrp 33 $MYPATH/mydesign $MYPATH/mydesign/SysCfgs
     % chmod g+w $MYPATH/mydesign
     % chmod g+w $MYPATH/mydesign/SysCfgs

  5. make sure "mydesign" contains at least one seed hierarchy file e.g. "baseline.xml"

  6. That's it!  The new design (i.e. "mydesign/baseline") should now magically appear in the gui.
