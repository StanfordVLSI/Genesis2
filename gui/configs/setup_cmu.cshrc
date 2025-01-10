# Set up CMU-specific environment (because chipgen makefile not robust...?)
setenv GENESIS_INSTALL /afs/ece/project/genesis/GENESIS
setenv GENESIS_LIBS $GENESIS_INSTALL/PerlLibs
setenv PATH         $GENESIS_LIBS/Genesis2:/usr/local/bin/:${PATH}
setenv decodedir    $GENESIS_INSTALL/gui/xml-decoder
