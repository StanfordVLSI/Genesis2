# HOW TO update the pypi package for pip install

### BUILD DISTRIBUTION FILE e.g. "dist/genesis2-0.0.10.tar.gz"
```
  # First, edit 'setup.py' to update version number e.g.
  old_version=0.0.9; new_version=0.0.10
  sed "s/$old_version/$new_version/" setup.py > tmp
  diff tmp setup.py
  mv tmp setup.py

  # Create tar file  e.g. "dist/genesis2-0.0.10.tar.gz"
  # -- We use "setup.py sdist" (*tar.gz) instead of "setup bdist_wheel" (*.whl) (why?)
  # This creates dirs 'dist' (which we want) and 'genesis2.egg-info' (which we don't need)
  python3 setup.py sdist |& tee sdist.log | less
```

### TEST the new distribution file
```  
  deactivate || echo okay          # (optional) deactivate existing venv
  python3 -m venv /tmp/venv        # Build new venv
  source /tmp/venv/bin/activate
  pip install dist/genesis2-0.0.11.tar.gz  # Install genesis2
  deactivate                               # Clean up

  # AND/OR
  test/docker-test.sh --help
  test/docker-test.sh dist/genesis2-0.0.11.tar.gz
```

### UPLOAD to pypi
```  
  twine upload dist/genesis2-0.0.11.tar.gz |& tee twine-0.0.11.log
```

### TEST uploaded pypi package
```
  test/docker-test.sh --help
  test/docker-test.sh --pypi
```

### OPTIONAL CLEANUP (only need 'dist' dir for upload maybe)
```
  # Unwanted files go to old/ subdirectory
  d=old/pipfiles-`date +%y%m%d.%H%M`; echo mkdir -p $d; mkdir -p $d
  for p in Genesis2/ build/ genesis2.egg-info/ dist/; do test -e $p && echo mv $p $d; done
  # (cut'n'paste commands resulting from above)

```
