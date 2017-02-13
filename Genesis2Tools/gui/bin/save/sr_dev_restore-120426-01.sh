  echo "Do this:"
  echo;
  echo "  pushd ~/gui"
  echo;
  echo "  mv designs designs.deleteme"
  echo "  sudo mv designs_dev_sr designs"
  echo;
  echo "  unlink index.htm;  ln -s configs/index_dev_sr.htm index.htm"
  echo;
  echo "  unlink CONFIG.TXT; ln -s configs/CONFIG_dev_sr.txt CONFIG.TXT"
  echo;
  echo "  popd"
  echo;
  echo "To check:"
  echo
  echo "  ls -ld ~/gui/{CONFIG.TXT,index.htm}; echo; ls -ld ~/gui/designs*"
  echo
