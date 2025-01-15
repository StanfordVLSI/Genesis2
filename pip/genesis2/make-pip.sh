#!/bin/bash

# After building pip, will have these new dirs/files:
#   % ls dist/*
#   dist/genesis2-0.0.6-cp38-cp38-linux_x86_64.whl
# 
#   % ls genesis2.egg-info/
#   dependency_links.txt  PKG-INFO  SOURCES.txt  top_level.txt

# This *could* be a Makefile, you know...just sayin'...

HELP="
  DESCRIPTION
    Non-destructively emits commands necessary to complete the given action

  OPTIONS
    $0 --help
    $0 --build   # How-to: Build a pip distribution including 'dist/*' and 'genesis2.egg-info/*'
    $0 --upload  # How-to: Use twine to upload the distribution
    $0 --clean   # How-to: Cleanup from make-pip
"

if [ "$1" == "" ];       then echo "$HELP"; exit; fi
if [ "$1" == "--help" ]; then echo "$HELP"; exit; fi

if [ "$1" == "--build" ]; then
    cat <<'    EOF'
    # Build a pip distribution; creates dirs 'dist' and 'genesis2.egg-info'
    # First, should edit 'setup.py' to update version number. Then:

    # Produces a *.whl, but maybe I want *.tar.gz
    # python3 setup.py bdist_wheel |& tee bdist_wheel.log | less
    
    # Creates e.g. "dist/genesis2-0.0.7.tar.gz"
    python3 setup.py sdist |& tee sdist.log | less


    # Optional cleanup (only need 'dist' dir for upload maybe)
    d=deleteme/pipfiles-`date +%y%m%d.%H%M`; echo mkdir -p $d
    mkdir -p $d; mv Genesis2/ build/ genesis2.egg-info/ $d; ls -l $d
    EOF
    exit
fi

if [ "$1" == "--upload" ]; then
    echo 'twine upload dist/* |& tee twine.log'
    exit
fi

if [ "$1" == "--clean" ]; then
    echo 'd=old/pipfiles-`date +%y%m%d.%H%M`; echo mkdir -p $d'
    echo 'for p in Genesis2/ build/ genesis2.egg-info/ dist/; do test -e $p && echo mv $p $d; done'
    exit
fi

echo "$HELP"
exit

########################################################################
# NOTES

########################################################################
# Not sure if setup.cfg is used for anything...?
# It has info for bdist_wheel but we are maybe using sdist..?


########################################################################
# The twine command requires a pypi API; e.g. something like this (below)
# in a file ~/.pypirc
# 
# [distutils]
#   index-servers =
#     pypi
#     genesis2
# 
# [pypi]
#   username = __token__
#   password = # either a user-scoped token or a project-scoped token you want to set as the default
# [genesis2]
#   repository = https://upload.pypi.org/legacy/
#   username = __token__
#   password = # a project token 

