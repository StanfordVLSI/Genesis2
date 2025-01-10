  echo "Do this:"
  echo
  echo "  mv ~/gui/designs ~/gui/designs.deleteme"
  echo
  echo "THEN"
  echo
  echo "  sudo mv ~/gui/designs_dev_sr_prev ~/gui/designs"
  echo "OR"
  echo "  sudo cp -pr ~/gui/designs_dev_sr_clean ~/gui/designs"
  echo
  echo "  pushd ~/gui"
  echo "  unlink index.htm;  ln -s configs/index_dev_sr.htm index.htm"
  echo "  unlink CONFIG.TXT; ln -s configs/CONFIG_dev_sr.txt CONFIG.TXT"
  echo "  popd"
  echo
  echo "To check:"
  echo
  echo "  ls -ld ~/gui/{CONFIG.TXT,index.htm}; echo; ls -ld ~/gui/designs*"
  echo
