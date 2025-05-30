==== NOTES
* Also see `$GENESIS/.github/workflows/gold.yml`
* All tests run in docker containers and so should not affect your machine's state...
* TODO rename `copy_of_garnet_tests_test_app.sh` omg


=== Testing scripts: for details try doing `<script> --help`
* `aha-pr-regressions.sh` -- full garnet regressions: 78 apps, 10 hours
* `copy_of_garnet_tests_test_app.sh` -- quick garnet test builds and runs 4x2 pointwise
* `genesis-ci.sh`         -- compare this-branch results to master-branch results
* `install-verilator.sh`  -- helper script used by `copy_of_garnet_tests_test_app.sh`

=== Gold test in `glctest/` subdirectory
* `glctest/` -- local gold test, see `glctests/README.txt`

=== CI

`Genesis2/.github/workflows/gold.yml` runs three tests on every git
push. They run in order of how quickly each is expected to finish.


```
  quick_local_test_5s:
      run: cd test/glctest; ./test.sh -debug 15

  func_fail_1m:
      run: test/copy_of_garnet_tests_test_app.sh \
             --fail $BRANCH_NAME 4x2 apps/pointwise \
           && exit 13 || echo FAILED SUCCESSFULLY

  func_pass_6m:
      run: test/copy_of_garnet_tests_test_app.sh $BRANCH_NAME 4x2 apps/pointwise
```
