#!/bin/bash

HELP='
DESCRIPTION
  Launches a docker image build that will try to do
  "pip install genesis2" in a clean python virtual environment.
  Test succeeds if no errors occur during this process.

  Can test pypi distribution file or can optionally test a file locally.
  In the latter case, local file must match template "*/genesis2*.gz".

USAGE
  docker-test.sh --pypi      # Launch docker-build that does "pip install genesis2"
  docker-test.sh <filename>  # Launch docker-build that does "pip install <filename>"

EXAMPLE
  docker-test.sh dist/genesis2-0.0.9.tar.gz   # Should FAIL
  docker-test.sh dist/genesis2-0.0.11.tar.gz  # Should PASS
  docker-test.sh --pypi
'

# Function to verify and return wheel filename
function wheel {
    if ! test -f "$1"; then
        echo "ERROR: Cannot find requested wheel '$1'" > /dev/stderr
        echo ERROR
    else
        echo "$1"
    fi
}

# Unpack args
pipfile="genesis2"  # default value
case "$1" in
    -h|--help)    echo "$HELP"; exit   ;;
    --pypi)       pipfile="genesis2"   ;;
    .*)           pipfile=$(wheel "$1" | tail -1)  ;;
esac
[ "$pipfile" == "ERROR" ] && exit 13

# Make a temporary workspace maybe
# Must be lower case to use later as docker image tag (which disallows uppercase!?)
workspace=$(mktemp -u /tmp/docker-test-XXXXX | tr [:upper:] [:lower:])
echo "Building temporary workspace '$workspace'"
mkdir "$workspace"

# Copy relevant files to the workspace and cd
cp $(dirname $0)/Dockerfile.genesis "$workspace"
test -f "$pipfile" && cp "$pipfile" "$workspace"

# Dockerfile will try to do "COPY ./genesis2*.gz", this ensures that don't fail
touch "$workspace"/genesis2-dummy.tar.gz  # Hack so that dockerfile COPY does not fail
ls -l "$workspace"

# Prep for docker image cleanup
function cleanup {
    printf "TEST $1\n\n"  # "TEST PASSED" or "TEST FAILED"
    echo BEFORE: "$(docker images)"
    docker system prune -f || echo okay
    test -e iidfile && docker rmi $(cat iidfile) || echo okay
    cd /tmp && /bin/rm -rf "$workspace" || echo okay
    echo AFTER: "$(docker images)"
    printf "\nTEST $1\n\n"  # "TEST PASSED" or "TEST FAILED"
}

# Try the build
set -x
cd $workspace
if docker build \
          --no-cache \
          --iidfile iidfile \
          --file Dockerfile.genesis \
          --build-arg PIPFILE="$(basename $pipfile)" \
          -t $(basename $workspace) \
          .
then
    set +x; cleanup PASSED
else
    set +x; cleanup FAILED; exit 13
fi
