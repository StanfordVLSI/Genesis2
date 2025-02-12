# HOW TO update the pypi package for pip install

1. Update `setup.py` with new version number e.g. "0.0.7" => "0.0.8"

2. Use the `make-pip` script to install the new package. `make-pip` is
completely non-destructive, all it does is print out the instructions
for each step.
```
  % make-pip.sh --help
```
Optionally, can do it all manually:
```
  # BUILD AND INSTALL
  version=0.0.9
  ls dist
  mv dist/* archives
  python3 setup.py sdist |& tee sdist-$version.log
  ls dist
  twine upload dist/* |& tee twine-$version.log

  # CLEANUP
  d=old/pipfiles-`date +%y%m%d.%H%M`; echo mkdir -p $d; mkdir -p $d
  for p in Genesis2/ build/ genesis2.egg-info/ dist/; do test -e $p && echo mv $p $d; done
  # (cut'n'paste commands resulting from above)
```

Try it out:
  source /nobackup/steveri/garnet_venv/bin/activate
  pip uninstall genesis2
  pip install genesis2 |& tee tmp.log
