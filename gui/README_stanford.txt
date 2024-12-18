12/2014 update:

***NOTE publish.csh DOES NOT EXIST AS OF 12/2014 MAYBE THIS IS OLD.***

------------------------------------------------------------------------------
To publish from steveri dev directory to official stanford version:

% ssh vlsiweb
% cd ~steveri/gui
% sudo cgi/publish.csh |& tee publish.log

------------------------------------------------------------------------------

To remove dead/zombie files from the pub directory:

% ssh vlsiweb
% cd ~steveri/gui
% sudo cgi/publish.csh -clean |& tee cleanup.log

or, more drastically,

% ssh vlsiweb
% /bin/rm -rf /var/www/homepage/genesis/*
% cd ~steveri/gui
% sudo cgi/publish.csh |& tee publish.log


or, less drastically

% ssh vlsiweb
% cd /var/www/homepage; mv genesis gensis-deleteme
% cd ~steveri/gui
% sudo cgi/publish.csh |& tee publish.log
