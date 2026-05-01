#!/bin/bash

USAGE="
  DESCRIPTION:
    Smoke test for bin/gvp2.pl: regenerates demo/gvp2/example.v from the
    fixtures and diffs against expected_output.v in this directory.

  USAGE:    $0
"
if [ "$1" == "--help" ]; then echo "$USAGE"; exit; fi

# We should be here: Genesis2/test/gvp2test/
export GENESIS_HOME=$(cd ../..; pwd)
export PATH=$GENESIS_HOME/bin:$PATH
export PERL5LIB=$GENESIS_HOME/PerlLibs:$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions:$PERL5LIB

printf '\n\nBUILD\n'
make -C "$GENESIS_HOME/demo/gvp2" clean example.v || exit 13

# Strip the absolute GENESIS_HOME prefix so the diff is portable.
actual=$(mktemp)
sed "s|$GENESIS_HOME|GENESIS_HOME|g" "$GENESIS_HOME/demo/gvp2/example.v" > "$actual"

printf '\n\nCOMPARE diff -u expected_output.v actual\n'
if diff -u expected_output.v "$actual"; then
    result=PASS
else
    result=FAIL
fi
rm -f "$actual"

echo ''
echo '------------------------------------------------------------------------'
echo Test result: $result
echo '------------------------------------------------------------------------'
echo ''

[ "$result" == "PASS" ] || exit 13
exit 0
