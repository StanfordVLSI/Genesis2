#!/bin/bash

# Uncomment to test failure path
TEST_FAILURE_PATH=true

USAGE="
  $0 <commit>

  DESCRIPTION: Builds garnet <commit> build vs. a master build, verifies both get same answer.

  EXAMPLES:
    $0 pull/9/head  # Test pull-request #9
    $0 fixbugs      # Test branch 'fixbugs'
    $0 59a8c39a4    # fails maybe?
    $0 7c941e7c1    # good maybe?
"
if [ "$1" == "--help" ]; then echo "$USAGE"; exit; fi

# What does this script do?
# - verifies that compare-dirs tmp-garnet.d[01] do not exist already
# - launches a container based on garnet:latest
# -- pip-installs latest genesis2 (maybe not necessary no more?)
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
# set -x

# Unpack the arg
if ! [ "$1" ]; then echo oops you forgot to specify a commit hash; exit 13; fi
commit=$1

# Debugging
# function GROUP    { set +x; sleep 1; printf "%s%s[group]%s\n"  "#" "#" "$*"; sleep 1; set -x; }
# function ENDGROUP { set +x; sleep 1; printf "%s%s[endgroup]\n" "#" "#";      sleep 1; set -x; }

# Not debugging
function GROUP    { sleep 1; printf "%s%s[group]%s\n"  "#" "#" "$*"; sleep 1; }
function ENDGROUP { sleep 1; printf "%s%s[endgroup]\n" "#" "#";      sleep 1; }

##############################################################################
GROUP Docker image and container
image=stanfordaha/garnet:latest
docker pull $image
container=DELETEME-$USER-genci$$
docker run -id --name $container --rm $image bash
ENDGROUP

# Setup
function dexec { docker exec $container /bin/bash -c "$*"; }
aha_garnet_cmd="aha garnet --width 4 --height 2 --verilog --use_sim_sram"
build_garnet="source /aha/bin/activate && $aha_garnet_cmd"

# TRAPPER KILLER: Trap and kill docker container on exit
function cleanup { set -x; docker kill $container; }
trap cleanup EXIT

GROUP UPDATE PIP package for latest version of Genesis2
dexec "source /aha/bin/activate && pip uninstall -y genesis2 && pip install genesis2"
ENDGROUP

##############################################################################
GROUP 'GOLD-BUILD (master) > tmp-garnet.v0'
printf "\nINFO Build gold-model verilog using Genesis2 branch 'master'"
dexec "$build_garnet"
docker cp ${container}:/aha/garnet/garnet.v tmp-garnet.v0
dexec 'cd /aha/garnet; make clean' >& /dev/null  # Clean up your mess, ignore errors :(
ENDGROUP

# Can do this if want to accommodate commits like e.g. 'pull/9/head'
# if $commit ~ '^pull/'; then git fetch origin $commit:TEST; commit=TEST; fi

##############################################################################
GROUP "TEST-BUILD ($commit) > tmp-garnet.v1"
printf "\nINFO Build test-model verilog using Genesis2 branch '$commit'\n"
REPO=/aha/lib/python3.8/site-packages/Genesis2-src
dexec "set -x; cd $REPO; git pull; git checkout -fq $commit" || exit 13
if [ "$TEST_FAILURE_PATH" ]; then
    # Inject a fault in Genesis2.pl
    # FAULT INJECTION 
    # FAULT INJECTION print("FOO Attempting fault injection")
    # FAULT INJECTION if os.path.isfile("/aha/garnet/genesis_verif/jtag.sv"):
    # FAULT INJECTION   print("FOO injecting error in /aha/garnet/genesis_verif/jtag.sv")
    # FAULT INJECTION   r2 = os.system("set -x; bsed -i.bak 's/addr = 0/addr = 13/' /aha/garnet/genesis_verif/jtag.sv")
    # FAULT INJECTION   print("FOO r2 = "); print (r2)
    # FAULT INJECTION   if r2 != 0: sys.exit(13)
    # FAULT INJECTION   print("FOO injection SUCCESSFULL...???")
    # FAULT INJECTION 
    fault=$(egrep '^    # FAULT INJECTION' $0 | sed 's/.*INJECTION //' > /tmp/tmp$$)
    dexec "cp /aha/bin/Genesis2.pl /aha/bin/Genesis2.pl0"
    docker cp /tmp/tmp$$ $container:/tmp; # /bin/rm /tmp/tmp$$
    dexec "cat /tmp/tmp$$ >> /aha/bin/Genesis2.pl"
    dexec "diff /aha/bin/Genesis2.pl0 /aha/bin/Genesis2.pl"
fi
dexec "$build_garnet"
if [ "$TEST_FAILURE_PATH" ]; then
    set -x  # Show injected fault
    dexec 'set -x; ls -l /aha/garnet/genesis_verif/'
    dexec 'set -x; diff /aha/garnet/genesis_verif/jtag.{sv.bak,sv}'
    set +x
fi
docker cp ${container}:/aha/garnet/garnet.v tmp-garnet.v1
dexec 'cd /aha/garnet; make clean' >& /dev/null  # Clean up your mess, ignore errors :(
ENDGROUP

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
diff $f1 $f2




ndiffs=`vcompare $f1 $f2 | wc -l`

if [ "$ndiffs" != "0" ]; then
    # ------------------------------------------------------------------------
    # TEST FAILED
    printf ".\n.\n  Test FAILED\n  Test FAILED\n  Test FAILED\n.\n"
    printf "Test FAILED with $ndiffs diffs\n"
    printf '(To update gold verilog, see $GARNET_REPO/bin/rtl-goldfetch.sh --help)'
    printf "\n"
    printf "Top 40 diffs:"
    vcompare $f1 $f2 | head -40
    printf ".\n.\n  Test FAILED\n  Test FAILED\n  Test FAILED\n.\n"
    exit 13
else
    # ------------------------------------------------------------------------
    # TEST PASSED
    printf ".\n.\n  Test PASSED\n  Test PASSED\n  Test PASSED\n.\n"
fi

# ...but what if master got corrupted and test-branch preserves that?
# ...test will pass but answer is wrong??
# ...need a functional test?
# TODO functional test i.e. maybe like 'aha regress fast' or some such...?
# NOTE once we have a functional test...probably don't need comparison test no more...?
