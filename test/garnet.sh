#!/bin/bash
# Copied from / compare to $GARNET_REPO/tests/test_app/test_app.sh

# Use '--fail' test failure path (for debugging)
[ "$1" == "--fail" ] && TEST_FAILURE_PATH=true
[ "$1" == "--fail" ] && shift

# Uncomment for reusable container (for debugging)
# REUSE_CONTAINER=True

HELP="
  DESCRIPTION:
    Launch a docker container and run the indicated app using the indicated Genesis2 commit.

  USAGE:
    $0 <commit> [ --vcs ] [ --fp ] <width>x<height> <app>

  EXAMPLE(S):
    $0 fixbugs 4x2 apps/pointwise      # Test branch 'fixbugs'
    $0 59a8c39 4x2 apps/pointwise      # Test commit 59a8c39
    $0 pull/9/head 4x2 apps/pointwise  # Test pull-request #9
    $0 mybranch --fp  4x2 tests/fp_pointwise  # Do a floating-point test (relaxed gold-compare)
    $0 --vcs 4x2 apps/pointwise        # Use vcs for sim (default is verilator)
"
if [ "$1" == "--help" ]; then echo "$HELP"; exit; fi

# Unpack the args
commit=$1; shift

# More args e.g. '4x2' => '--width 4 --height 2'
DO_FP=;  if [ "$1" == "--fp"  ]; then shift; DO_FP="--dense-fp"; fi
DO_VCS=; if [ "$1" == "--vcs" ]; then shift; DO_VCS=True; fi
size=`echo $1 | awk -Fx '{printf("--width %s --height %s", $1, $2)}'`
app=$2

# FOR VERILATOR
CAD=
TOOL='export TOOL=VERILATOR'

# FOR VCS
if [ "$DO_VCS" ]; then
    CAD='-v /cad:/cad'
    TOOL='. /cad/modules/tcl/init/bash; module load base; module load vcs'
fi

########################################################################
# Two ways to form groups in github workflow action logs:
#   echo "::group::Colon group"; echo "foo"; echo "::endgroup::"
#   echo "##[group]Hash group";  echo "bar"; echo "##[endgroup]"
#
# But unless you use subterfuge (below), the echo command itself can trigger a group :(

function GROUP    { sleep 1; printf "%s%s[group]%s\n"  "#" "#" "$1"; sleep 1; }
function ENDGROUP { sleep 1; printf "%s%s[endgroup]\n" "#" "#";      sleep 1; }

##############################################################################
GROUP $0 $* BEGIN
ENDGROUP


########################################################################
# DOCKER image and container
GROUP "DOCKER image and container"
image=stanfordaha/garnet:latest
docker pull $image
container=DELETEME-$USER-apptest-$$
[ "$REUSE_CONTAINER" ] && container=deleteme-steveri-testapp-dev
# Note for verilator CAD="" else CAD="-v /cad:/cad"
# Note this will err if reusing container, but that's okay maybe.
docker run -id --name $container --rm $CAD $image bash || echo okay


########################################################################
# TRAPPER KILLER: Trap and kill docker container on exit ('--rm' no workee, but why?)
function cleanup { set -x; docker kill $container; }
[ "$REUSE_CONTAINER" ] || trap cleanup EXIT
# echo "##[endgroup]"
# set +x; sleep 1; echo "##[endgroup]"; sleep 1; set -x
set +x; ENDGROUP

########################################################################
GROUP "UPDATE docker w local Genesis2"
printf "Build test-model verilog using Genesis2 branch '$commit'\n"
REPO=/aha/lib/python3.8/site-packages/Genesis2-src
function dexec { docker exec $container /bin/bash -c "$*"; }
dexec "set -x; cd $REPO; git remote add grg https://github.com/grg/Genesis2; git fetch grg"
dexec "set -x; cd $REPO; git pull; git checkout -fq $commit" || exit 13
ENDGROUP

########################################################################
# INJECT a fault for testing, if requested
if [ "$TEST_FAILURE_PATH" ]; then
    GROUP 'INJECT a fault for testing'

    # Prepare a fault to inject in Genesis2.pl
    # FAULT INJECTION 
    # FAULT INJECTION print("FOO Attempting fault injection")
    # FAULT INJECTION if os.path.isfile("/aha/garnet/genesis_verif/global_controller.sv"):
    # FAULT INJECTION   from datetime import datetime
    # FAULT INJECTION   HMS = datetime.now().strftime('%H%M%S')  # E.g. '125959'
    # FAULT INJECTION   failfile  = "/aha/garnet/genesis_verif/global_controller.sv"
    # FAULT INJECTION   if os.system(f'set -x; cp {failfile} {failfile}.{HMS}'): sys.exit(13)
    # FAULT INJECTION   if os.system(f'set -x; echo foo > {failfile}'):          sys.exit(13)
    # FAULT INJECTION   print("FOO injection SUCCESSFUL...???")
    # FAULT INJECTION   exit()  # END AFTER FIRST INJECTION!!! (In case of attempted reuse.)
    # FAULT INJECTION 
    fault=$(egrep '^    # FAULT INJECTION' $0 | sed 's/.*INJECTION //' > /tmp/tmp$$)

    # Remove earlier fault attempts
    dexec "sed -n '1,/Attempting fault/p' /aha/bin/Genesis2.pl > /aha/bin/Genesis2.pl.clean"

    # Insert new fault attempt
    docker cp /tmp/tmp$$ $container:/tmp; # /bin/rm /tmp/tmp$$
    dexec "cat /aha/bin/Genesis2.pl.clean /tmp/tmp$$ > /aha/bin/Genesis2.pl"
    dexec "diff /aha/bin/Genesis2.pl.clean /aha/bin/Genesis2.pl"
    /bin/rm /tmp/tmp$$

    ENDGROUP
fi

# Prepare to install verilator if needed
if [ "$CAD" ]; then
    make_verilator='echo Using vcs, no need for verilator'
else
    REPO=/aha/lib/python3.8/site-packages/Genesis2-src
    make_verilator="(set -x; $REPO/test/install-verilator.sh)"
fi
GROUP "make_verilator=$make_verilator"
ENDGROUP

# This will of course FAIL if target machine does not have vcs in the proper path /cad/...
DO_FULL_PR=
if [ "$DO_FULL_PR" ]; then
  docker exec $container /bin/bash -c "
      source /aha/bin/activate;
      source /cad/modules/tcl/init/sh || exit 13
      module load base incisive xcelium/19.03.003 vcs/Q-2020.03-SP2
      pwd; aha regress pr;
  " || exit 13
  exit
fi

########################################################################
# TEST
# size='--width 4 --height 2'
docker exec $container /bin/bash -c "
  rm -f garnet/garnet.v
  source /aha/bin/activate
  $TOOL

  cd /aha/garnet; make clean

  # Note (echo \#\# ...) gives much better result than (echo '##...') 
  echo \#\#[group]aha garnet $size --verilog --use_sim_sram --glb_tile_mem_size 128
  aha garnet $size --verilog --use_sim_sram --glb_tile_mem_size 128 || exit 13
  echo \#\#[endgroup]

  echo \#\#[group]aha map $app
  aha map $app || exit 13
  echo \#\#[endgroup]

  echo \#\#[group]aha pnr $app $size
  aha pnr $app $size || exit 13
  echo \#\#[endgroup]

  # We need verilator for the final step, if we make it this far...
  echo \#\#[group]install verilator
  $make_verilator || exit 13
  echo \#\#[endgroup]

  # 'aha test' calls 'make sim' and 'make run' etc.
  echo \#\#[group]aha test $app $DO_FP
  aha test $app $DO_FP || exit 13
  echo \#\#[endgroup]
"
