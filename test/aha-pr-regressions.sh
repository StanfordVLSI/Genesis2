#!/bin/bash

# IMAGE=stanfordaha/garnet@sha256:030a2eb933513cd67e467eee1b0d934c4124e7ce49fe1e6d322435923d0c2125
# echo "WARNING using last known good docker image $image"

HELP='
DESCRIPTION:
  Extensive regression tests based on StanfordAHA/garnet project.
  If you do all three suites aha[123], runs 78 apps and takes ten hours.
  Requires VCS and, as a related note, only works on machines that mount /cad e.g. kiwi.stanford.edu.

EXAMPLE:
  # Launch all three regression tests in the background
  % alias apr=aha-pr-regressions.sh
  % (apr pr_aha1 >& pr-aha1.log; apr pr_aha2 >& pr-aha2.log; apr pr_aha3 >& pr-aha3.log ) &

  # Monitor the progress
  % jobs
  % tail -f pr-aha1.log

  # Summarize results so far e.g.
  % sedscript="s/.APP0.//;s/..Init.*//;s/_seed.*//;s/_combined.*//"
  % log=pr-aha1.log; egrep "APP0.*Init" $log | sed "$sedscript" | cat -n; ls -l pr-aha*log; date
     9  vec_elemmul
    10  mat_vecmul_ij
    11  mat_elemadd_leakyrelu_exp
    12  matmul_ikj
    13  tensor3_mttkrp
    14  pointwise
'
[ "$1" == "--help" ] && echo "$HELP" && exit
# ------------------------------------------------------------------------
set -x
# Only works on machines that mount /cad e.g. kiwi.stanford.edu

# By default, run...I dunno...pr-aha3 because it's the fastest?
CONFIG=pr_aha3
[ "$1" ] && CONFIG=$1

# One thing to do maybe
# alias apr=aha-pr-regressions.sh
# (apr pr_aha3 >& pr-aha3.log; apr pr_aha2 >& pr-aha2.log; apr pr_aha1 >& pr-aha1.log) &

# Setup
image=stanfordaha/garnet:latest
[ "$IMAGE" ] && image=$IMAGE
echo "Using docker image $image"

container=deleteme-aha-pr-regressions-$$
docker pull $image
docker run -id --name $container --rm -v /cad:/cad $image bash

# Trap and kill docker container on exit
function cleanup { set -x; docker kill $container; }
trap cleanup EXIT

# Create a clean Genesis2 repo 'tmpdir'
tmpdir=/tmp/deleteme-update-Genesis2-$$
/bin/rm -rf $tmpdir; mkdir -p $tmpdir
here=$(git rev-parse --show-toplevel)  # E.g. /nobackup/steveri/github/Genesis2
(cd $here; git ls-files | xargs -I{} cp -r --parents {} $tmpdir)

# Replace container repo with clean copy of local repo
there=/aha/lib/python3.8/site-packages/Genesis2-src
docker exec $container /bin/bash -c "rm -rf $there"  # Remove old repo 'Genesis2-src'
docker cp $tmpdir $container:$there                  # Insert new repo

# Verify the update (ish)
# docker exec $container /bin/bash -c "cat $there/Info/Genesis2.info"

# What th'...? SIXTY-NINE MEGABYTES???
# % lsl -h /nobackup/zircon/MatrixUnit_sim_sram.v /nobackup/zircon/MatrixUnitWrapper_sim.v
# -rw-r--r-- 1 mcoduoza users  69M May 27 17:32 /nobackup/zircon/MatrixUnit_sim_sram.v
# -rw-r--r-- 1 mcoduoza users 409K May 27 17:33 /nobackup/zircon/MatrixUnitWrapper_sim.v
for f in MatrixUnit_sim_sram.v MatrixUnitWrapper_sim.v; do
    if ! test -e /nobackup/zircon/$f; then
        for i in {1..100}; do echo ERROR; done
        echo 'ERROR cannot find $f in dir /nobackup/zircon/'
        echo 'ERROR test will probably FAIL!'
        echo 'Continuing on anyway...'
    else
        docker cp /nobackup/zircon/$f $container:/aha/garnet/$f
    fi
done

# Do it, man
# Emulate the behavior of aha's buildkite/pipeline.yml => regress-metahooks.sh
# You know this is gonna take 12 hours, right...
  docker exec $container /bin/bash -c "
      source /aha/bin/activate;
      source /cad/modules/tcl/init/sh;
      module load base incisive xcelium/19.03.003 vcs/Q-2020.03-SP2;
      aha regress $CONFIG --include-no-zircon-tests;
  "

#   aha regress pr-aha1 --include-no-zircon-tests;
#   aha regress pr-aha2 --include-no-zircon-tests;
#   aha regress pr-aha3 --include-no-zircon-tests;
