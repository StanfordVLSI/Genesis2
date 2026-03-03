#!/bin/bash

USAGE="
  DESCRIPTION:
    Builds a trivial design with parameter overriding. May show issues
    with the module cache if it's incorrectly blocking generation.

  USAGE:
    $0 <flags>

  EXAMPLES:
    $0 -debug 15
    $0 -debug 15 |& tee test.log | less
"
if [ "$1" == "--help" ]; then echo "$USAGE"; exit; fi

# Clean up from any prior runs.
test -f genesis_clean.cmd && ./genesis_clean.cmd || echo okay

# We should be here: Genesis2/test/glctest/
export GENESIS_HOME=$(cd ../..; pwd)
export PATH=$GENESIS_HOME/bin:$GENESIS_HOME/gui/bin:$PATH
export PERL5LIB=$GENESIS_HOME/PerlLibs:/$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions:$PERL5LIB

# Build systemverilog *.sv files and put them in dir genesis_verif/
#
# Params:
#  -unqstyle: Switch to numeric as param doesn't correctly handle parameters
#             passed on the command line.
#  -no_module_cache: Disable the module cache, as the module cache doesn't yet
#                    handle parameters passed on the command line.
printf '\n\nBUILD\n'
Genesis2.pl -parse -generate -top top -input \
    src/top.svp \
    src/child.svp \
  -unqstyle=numeric \
  -no_module_cache \
  -parameter top.child2.out_val=2 \
  $* || exit 13
  
# Compare results to gold model
echo COMPARE diff -ru genesis_verif_gold/ genesis_verif/

# Ignore comment lines...
diff -ru -I '^//' genesis_verif_gold/ genesis_verif/ && result=PASS || result=FAIL

echo ''
echo '------------------------------------------------------------------------'
echo Test result: $result
echo '------------------------------------------------------------------------'
echo ''

[ "$result" == "PASS" ] || exit 13
exit 0  # success (0=no errors)
