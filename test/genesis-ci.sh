#!/bin/bash

USAGE="
  $0 <commit>

  EXAMPLES:
    $0 master
    $0 pull/9/head  # Test pull-request #9
    $0 59a8c39a4    # fails maybe?
    $0 7c941e7c1    # good maybe?
"
if [ "$1" == "--help" ]; then echo "$USAGE"; exit; fi

# What does this script do?
# - verifies that tmp-garnet.v[01] does not exist already
# - builds a garnet:latest docker container
# -- installs latest genesis2 (maybe not necessary no more?)
# -- builds gold verilog tmp-garnet.v0 using master branch
# -- builds target verilog tmp-garnet.v1 using target branch
# -- compares the two

# How to use it?
# - I mean, it's container based...I think you just run
#   the script from any machine that has docker installed
# - AND. This script takes care of launching the image/container
# - SO. Maybe it's just like...run the script I dunno, like maybe
#      genesis-ci.sh origin/`git branch --show-current` |& tee genesis-ci.log | less -r

# Make sure the coast is clear
f1=tmp-garnet.v0
f2=tmp-garnet.v1
if test -f $f1; then echo ERROR $f1 exists already; exit 13; fi
if test -f $f2; then echo ERROR $f2 exists already; exit 13; fi

# Debugging
set -x

# Unpack the arg
# broken maybe: 59a8c39a464ce29fa9313ba6b892482fdcd62dca
# good maybe:   7c941e7c1da5195178016ff0afec402650819702
if ! [ "$1" ]; then echo oops you forgot to specify a commit hash; exit 13; fi
commit=$1

# Docker image and container
echo '##[group]Docker image and container'
image=stanfordaha/garnet:latest
docker pull $image
container=DELETEME-$USER-genci$$
docker run -id --name $container --rm $image bash
echo '##[endgroup]'

# Setup
function dexec { docker exec $container /bin/bash -c "$*"; }
aha_garnet_cmd="aha garnet --width 4 --height 2 --verilog --use_sim_sram"
build_garnet="source /aha/bin/activate && $aha_garnet_cmd"

# TRAPPER KILLER: Trap and kill docker container on exit
function cleanup { set -x; docker kill $container; }
trap cleanup EXIT

# UPDATE PIP package for latest version of Genesis2
dexec "source /aha/bin/activate && pip uninstall -y genesis2 && pip install genesis2"

##############################################################################
# GOLD-BUILD (master)
printf "\nINFO Build gold-model verilog using Genesis2 branch 'master'"
dexec "$build_garnet"
docker cp ${container}:/aha/garnet/garnet.v tmp-garnet.v0
dexec 'cd /aha/garnet; make clean' >& /dev/null  # Clean up your mess, ignore errors :(

# Can do this if want to accommodate commits like e.g. 'pull/9/head'
# if $commit ~ '^pull/'; then git fetch origin $commit:TEST; commit=TEST; fi

##############################################################################
# TEST-BUILD ($commit)
printf "\nINFO Build test-model verilog using Genesis2 branch '$commit'\n"
REPO=/aha/lib/python3.8/site-packages/Genesis2-src
dexec "cd $REPO; git pull; git checkout -q $commit" || exit 13
dexec "$build_garnet"
docker cp ${container}:/aha/garnet/garnet.v tmp-garnet.v1
dexec 'cd /aha/garnet; make clean' >& /dev/null  # Clean up your mess, ignore errors :(

##############################################################################
# COMPARE "gold" and "test"; use vcompare utility from aha repo
ls -l tmp-garnet.v[01]
if ! test -e tmp-vcompare.sh; then
    docker cp ${container}:/aha/.buildkite/bin/vcompare.sh tmp-vcompare.sh
fi
function vcompare { ./tmp-vcompare.sh $*; }

# docker kill $container  # Don't need this anymore because of TRAP

set +x
f1=tmp-garnet.v0
f2=tmp-garnet.v1

# Copied from aha/.buildkite/bin/rtl-goldcheck.sh
printf "\n"
echo "Comparing `vcompare $f1 | wc -l` lines of $f1"
echo "versus    `vcompare $f2 | wc -l` lines of $f2"
printf "\n"

echo "diff $f1 $f2"
ndiffs=`vcompare $f1 $f2 | wc -l`

if [ "$ndiffs" != "0" ]; then
    # ------------------------------------------------------------------------
    # TEST FAILED
    printf "Test FAILED with $ndiffs diffs\n"
    printf '(To update gold verilog, see $GARNET_REPO/bin/rtl-goldfetch.sh --help)'
    printf "\n"
    printf "Top 40 diffs:"
    vcompare $f1 $f2 | head -40
    echo; echo "Test FAILED"
    exit 13
else
    # ------------------------------------------------------------------------
    # TEST PASSED
    echo "Test PASSED"
fi

# ...but what if master got corrupted and test-branch preserves that?
# ...test will pass but answer is wrong??
# ...need a functional test?
# TODO functional test i.e. maybe like 'aha regress fast' or some such...?
# NOTE once we have a functional test...probably don't need comparison test no more...?


# THE TRASH

# dexec "cd /aha/lib/python3.8/site-packages/Genesis2-src; git fetch origin" || exit 13
# dexec "cd /aha/lib/python3.8/site-packages/Genesis2-src; git checkout -q $commit" || exit 13
# dexec "cd /aha/lib/python3.8/site-packages/Genesis2-src; git branch -v"

# dexec "cd $REPO; git branch -v"
