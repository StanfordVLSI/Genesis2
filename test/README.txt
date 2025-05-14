Also see $GENESIS/.github/workflows/gold.yml

All tests run in docker containers and so should not affect your machine's state...

=== Table of Contents

==== copy_of_garnet_tests_test_app.sh
```
  DESCRIPTION:
    Quick functional test, builds and tests RTL for a Genesis-based IC.

  EXAMPLEs: Build a 4x2 CGRA and use verilator to run the 'pointwise' app.
    % ./copy_of_garnet_tests_test_app.sh master      4x2 apps/pointwise
    % ./copy_of_garnet_tests_test_app.sh 59a8c39     4x2 apps/pointwise
    % ./copy_of_garnet_tests_test_app.sh pull/9/head 4x2 apps/pointwise
```

==== genesis-ci.sh
```
  DESCRIPTION:
    This is a gold test of Genesis2, to see if a given change gives the
    same result as the existing master branch.
    Builds a Genesis-based IC using specified commit and compares to a
    master-branch build. Success if the results are equal.

  EXAMPLES:
      genesis-ci.sh master      # This should always succeed!
      genesis-ci.sh 59a8c39
      genesis-ci.sh pull/8/head

==== install-verilator.sh

Helper file for `test_app.sh` installs verilator if it does not yet exist on your machine.

==== glctest/

Local non-docker test builds a memory controller and compares to previously-built gold verilog.

See glctest/README.txt


=== CI

Genesis2/.github/workflows/gold.yml runs five tests on every git push. They run in order of how quickly each one is expected to finish.

  func_fail_1m:
      test/copy_of_garnet_tests_test_app.sh --fail $BRANCH_NAME 4x2 apps/pointwise \
      && exit 13 || echo FAILED SUCCESSFULLY

  gold_fail_2m:
      test/genesis-ci.sh --fail $BRANCH_NAME && exit 13 \
      || echo FAILED SUCCESSFULLY

  gold_pass_3m:
      test/genesis-ci.sh $BRANCH_NAME

  func_pass_6m:
      test/copy_of_garnet_tests_test_app.sh $BRANCH_NAME 4x2 apps/pointwise

