TO DISABLE WEBSITE (general)

  # Start at the top
  cd $GUI_HOME

  # Move everything into "disabled" directory
  chmod +rw disabled/
  mv * disabled/

  # Install "this site is broken" messages
  cp -rp disabled/disabled_shadow_site/* .

  # Disable all the old pages
  chmod -rw disabled/

TO DISABLE WEBSITE ON VLSIWEB

  # Move everything into "disabled" directory
  mkdir disabled
  mv * disabled/

  # Fetch "this site is broken" messages
  scp -r steveri@kiwi:/nobackup/steveri/github/Genesis2/Genesis2Tools/gui/disabled/disabled_shadow_site disabled
  ls -lR disabled/disabled_shadow_site
  chown -R www-data:www-data disabled/disabled_shadow_site
  chown www-data:www-data disabled

  
  # Verify that we're clean
  ls -la

  # Install "this site is broken" messages
  cp -rp disabled/disabled_shadow_site/* .

  # Disable all the old pages
  chmod -rw disabled/

  # Links to try on browser: New links
  vlsiweb.stanford.edu/genesis/index.htm
  vlsiweb.stanford.edu/genesis/configs/fftgen_gateway.htm
  vlsiweb.stanford.edu/genesis/demo/fpdemo.php
  vlsiweb.stanford.edu/genesis/download.php
  vlsiweb.stanford.edu/genesis/cmpdemo.php
  vlsiweb.stanford.edu/genesis/designs/FFTGenerator/gui_extras.php

  # Links to try on browser: Old links in disabled directory
  vlsiweb.stanford.edu/genesis/disabled/index.htm
  vlsiweb.stanford.edu/genesis/disabled/configs/fftgen_gateway.htm
  vlsiweb.stanford.edu/genesis/disabled/demo/fpdemo.php
  vlsiweb.stanford.edu/genesis/disabled/download.php
  vlsiweb.stanford.edu/genesis/disabled/cmpdemo.php
  vlsiweb.stanford.edu/genesis/disabled/designs/FFTGenerator/gui_extras.php
