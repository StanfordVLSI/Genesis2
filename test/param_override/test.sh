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


# Perform a series of builds and comparisons against golden results. If any
# build or comparison fails, the test fails.
result=PASS

#####################
# Build 1:
#  - 2 children, each of depth 1
#  - override one parameter

# Build 1a:
#  - uniquification style: numeric
printf '\n\nBUILD\n'
Genesis2.pl -parse -generate -top top_2x1 -input \
    src/top_2x1.svp \
    src/child.svp \
  -unqstyle=numeric \
  -parameter top_2x1.child2.out_val=2 \
  $* || exit 13

# Compare results to gold model
echo COMPARE diff -ru genesis_verif_gold_2x1_numeric/ genesis_verif/

# Ignore comment lines...
diff -ru -I '^//' genesis_verif_gold_2x1_numeric/ genesis_verif/ || result=FAIL

# Clean up
test -f genesis_clean.cmd && ./genesis_clean.cmd || echo okay

# Build 1b:
#  - uniquification style: parameter
printf '\n\nBUILD\n'
Genesis2.pl -parse -generate -top top_2x1 -input \
    src/top_2x1.svp \
    src/child.svp \
  -unqstyle=param \
  -parameter top_2x1.child2.out_val=2 \
  $* || exit 13

# Compare results to gold model
echo COMPARE diff -ru genesis_verif_gold_2x1_param/ genesis_verif/

# Ignore comment lines...
diff -ru -I '^//' genesis_verif_gold_2x1_param/ genesis_verif/ || result=FAIL

# Clean up
test -f genesis_clean.cmd && ./genesis_clean.cmd || echo okay

#####################
# Build 2:
#  - 2 children, each of depth 2
#  - override one parameter

# Build 2a:
#  - uniquification style: numeric
printf '\n\nBUILD\n'
Genesis2.pl -parse -generate -top top_2x2 -input \
    src/top_2x2.svp \
    src/parent_mod.svp \
    src/child.svp \
  -unqstyle=numeric \
  -parameter top_2x2.parent2.child.out_val=2 \
  $* || exit 13

# Compare results to gold model
echo COMPARE diff -ru genesis_verif_gold_2x2_numeric/ genesis_verif/

# Ignore comment lines...
diff -ru -I '^//' genesis_verif_gold_2x2_numeric/ genesis_verif/ || result=FAIL

# Clean up
test -f genesis_clean.cmd && ./genesis_clean.cmd || echo okay

# Build 2b:
#  - uniquification style: param
printf '\n\nBUILD\n'
Genesis2.pl -parse -generate -top top_2x2 -input \
    src/top_2x2.svp \
    src/parent_mod.svp \
    src/child.svp \
  -unqstyle=param \
  -parameter top_2x2.parent2.child.out_val=2 \
  $* || exit 13

# Compare results to gold model
echo COMPARE diff -ru genesis_verif_gold_2x2_param/ genesis_verif/

# Ignore comment lines...
diff -ru -I '^//' genesis_verif_gold_2x2_param/ genesis_verif/ || result=FAIL

# Clean up
test -f genesis_clean.cmd && ./genesis_clean.cmd || echo okay

#####################
# Build 3:
#  - 4 children, each of depth 2
#  - override one parameter

# Build 3a:
#  - uniquification style: numeric
printf '\n\nBUILD\n'
Genesis2.pl -parse -generate -top top_4x2 -input \
    src/top_4x2.svp \
    src/parent_mod.svp \
    src/child.svp \
  -unqstyle=numeric \
  -parameter top_4x2.parent2.child.out_val=2 \
  -parameter top_4x2.parent4.child.out_val=4 \
  $* || exit 13

# Compare results to gold model
echo COMPARE diff -ru genesis_verif_gold_4x2_numeric/ genesis_verif/

# Ignore comment lines...
diff -ru -I '^//' genesis_verif_gold_4x2_numeric/ genesis_verif/ || result=FAIL

# Clean up
test -f genesis_clean.cmd && ./genesis_clean.cmd || echo okay

# Build 4b:
#  - uniquification style: param
printf '\n\nBUILD\n'
Genesis2.pl -parse -generate -top top_4x2 -input \
    src/top_4x2.svp \
    src/parent_mod.svp \
    src/child.svp \
  -unqstyle=param \
  -parameter top_4x2.parent2.child.out_val=2 \
  -parameter top_4x2.parent4.child.out_val=4 \
  $* || exit 13

# Compare results to gold model
echo COMPARE diff -ru genesis_verif_gold_4x2_param/ genesis_verif/

# Ignore comment lines...
diff -ru -I '^//' genesis_verif_gold_4x2_param/ genesis_verif/ || result=FAIL

echo ''
echo '------------------------------------------------------------------------'
echo Test result: $result
echo '------------------------------------------------------------------------'
echo ''

[ "$result" == "PASS" ] || exit 13
exit 0  # success (0=no errors)
