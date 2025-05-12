#!/bin/bash

# Uncomment to test failure path
# TEST_FAILURE_PATH=true

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
if [ "$1" == "--fail" ]; then TEST_FAILURE_PATH=true; shift; fi

# What does this script do?
# - verifies that compare-dirs tmp-gverif.d[01] do not exist already
# - launches a container based on garnet:latest
# -- pip-installs latest genesis2 (maybe not necessary no more?)
# -- builds gold verilog files tmp-gverif.d0/*.sv using master branch
# -- builds target verilog tmp-gverif.d1/*.sv using target branch
# -- compares each target file *.sv against gold

# How to use it?
# - I mean, it's container based...I think you just run
#   the script from any machine that has docker installed
# - AND. This script takes care of launching the image/container
# - SO. Maybe it's just like...run the script I dunno, like maybe
#      genesis-ci.sh origin/`git branch --show-current` |& tee genesis-ci.log | less -r

# Make sure the coast is clear
d1=tmp-gverif.d0; if test -e $d1; then echo ERROR $d1 exists already; exit 13; fi
d2=tmp-gverif.d1; if test -e $d2; then echo ERROR $d2 exists already; exit 13; fi

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
GROUP $0 $* BEGIN
# Skip test when/if merge is SUPPOSED to change master-branch behavior...
skip="grg_param_uniquify"
curbranch=`git branch --show-current`
echo "Current branch name is '$curbranch'"
for b in $skip; do
  if [ "$curbranch" == "$b" ]; then
    echo "------------------------------------------------------------------------"
    echo "WARNING skipping this test because branch name = '$b'"
    echo "------------------------------------------------------------------------"
    [ "$TEST_FAILURE_PATH" ] && exit 13  # Failure path "fails" to succeed, see?
    exit 0  # Mst specify exit code PASS else will inherit FAIL from prev cmd :(
  fi
done
ENDGROUP

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
GROUP 'GOLD-BUILD (master) > tmp-gverif.d0/*.sv'
printf "\nINFO Build gold-model verilog using Genesis2 branch 'master'"
dexec "$build_garnet" || exit 13
docker cp ${container}:/aha/garnet/genesis_verif tmp-gverif.d0/
dexec 'cd /aha/garnet; make clean' >& /dev/null  # Clean up your mess, ignore errors :(
ENDGROUP

# Can do this if want to accommodate commits like e.g. 'pull/9/head'
# if $commit ~ '^pull/'; then git fetch origin $commit:TEST; commit=TEST; fi

##############################################################################
GROUP "TEST-BUILD ($commit) > tmp-gverif.d1/*.sv"
printf "\nINFO Build test-model verilog using Genesis2 branch '$commit'\n"
REPO=/aha/lib/python3.8/site-packages/Genesis2-src
dexec "set -x; cd $REPO; git pull; git checkout -fq $commit" || exit 13
if [ "$TEST_FAILURE_PATH" ]; then
    # Inject a fault in Genesis2.pl
    # FAULT INJECTION 
    # FAULT INJECTION print("FOO Attempting fault injection")
    # FAULT INJECTION if os.path.isfile("/aha/garnet/genesis_verif/jtag.sv"):
    # FAULT INJECTION   from datetime import datetime
    # FAULT INJECTION   HMS = datetime.now().strftime('%H%M%S')  # E.g. '125959'
    # FAULT INJECTION   sedscript = "s/addr = 0/addr = 13/"
    # FAULT INJECTION   failfile  = "/aha/garnet/genesis_verif/jtag.sv"
    # FAULT INJECTION   print(f"FOO injecting error in {failfile}")
    # FAULT INJECTION   r2 = os.system(f"set -x; sed -i.{HMS} '{sedscript}' {failfile}")
    # FAULT INJECTION   print("FOO r2 = "); print (r2)
    # FAULT INJECTION   if r2 != 0: sys.exit(13)
    # FAULT INJECTION   print("FOO injection SUCCESSFULL...???")
    # FAULT INJECTION   exit()  # END AFTER FIRST INJECTION!!! (In case of attempted reuse.)
    # FAULT INJECTION 
    fault=$(egrep '^    # FAULT INJECTION' $0 | sed 's/.*INJECTION //' > /tmp/tmp$$)
    dexec "cp /aha/bin/Genesis2.pl /aha/bin/Genesis2.pl0"
    docker cp /tmp/tmp$$ $container:/tmp; # /bin/rm /tmp/tmp$$
    dexec "cat /tmp/tmp$$ >> /aha/bin/Genesis2.pl"
    dexec "diff /aha/bin/Genesis2.pl0 /aha/bin/Genesis2.pl"
fi
dexec "$build_garnet" || exit 13
if [ "$TEST_FAILURE_PATH" ]; then
    set -x  # Show injected fault
    dexec 'set -x; ls -l /aha/garnet/genesis_verif/'
    dexec 'set -x; files=`ls /aha/garnet/genesis_verif/jtag.sv* | head -2`; diff $files'
    set +x
fi
docker cp ${container}:/aha/garnet/genesis_verif tmp-gverif.d1/
dexec 'cd /aha/garnet; make clean' >& /dev/null  # Clean up your mess, ignore errors :(
ENDGROUP


##############################################################################
# COMPARE "gold" and "test"; use vcompare utility from aha repo
GROUP COMPARE gold and test models
printf ".\nCOMPARE gold and test models\n.\n"
echo .; ls -l tmp-gverif.d0/ | sed 's/^/  /'
if ! test -e tmp-vcompare.sh; then
    docker cp ${container}:/aha/.buildkite/bin/vcompare.sh tmp-vcompare.sh
fi

# Enhance vcompare with a prefilter to ignore comment lines :(
function delcomms { egrep -v '^//' $1; }
function vcompare { ./tmp-vcompare.sh <(delcomms $1) <(delcomms $2); }

# docker kill $container  # Don't need this anymore because of TRAP

set +x
d1=tmp-gverif.d0
d2=tmp-gverif.d1

echo .
files=$(cd $d1; echo *.sv)
for f in $files; do
    # E.g. f1=tmp-gverif.d0/jtag.sv, f2=tmp-gverif.d1/jtag.sv
    f1=$d1/$f; f2=$d2/$f
    echo "  $f..."
    ndiffs=`vcompare $f1 $f2 | wc -l`
    if [ "$ndiffs" != "0" ]; then
        ENDGROUP
        # ------------------------------------------------------------------------
        # TEST FAILED
        printf ".\nTest of $f FAILED with $ndiffs diff lines\n"
        printf "\n"
        printf "Top 40 diff lines:"
        vcompare $f1 $f2 | head -40
        printf ".\n.\n  Test FAILED\n  Test FAILED\n  Test FAILED\n.\n"
        exit 13
    fi
done
ENDGROUP
# ------------------------------------------------------------------------
# TEST PASSED
printf ".\n  Test PASSED\n  Test PASSED\n  Test PASSED\n.\n"


# ...but what if master got corrupted and test-branch preserves that?
# ...test will pass but answer is wrong??
# ...need a functional test?
# TODO functional test i.e. maybe like 'aha regress fast' or some such...?
# NOTE once we have a functional test...probably don't need comparison test no more...?
