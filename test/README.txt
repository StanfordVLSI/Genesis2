=== NOTES
* Also see `$GENESIS/.github/workflows/gold.yml`
* All tests run in docker containers and so should not affect your machine's state...
* `garnet.sh` comes from $GARNET_REPO/tests/test_app/test_app.sh 
* Misnamed 'genesis-ci.sh' is useful when making changes that are supposed to preserve existing functionality
* TODO consider renaming `genesis-ci.sh` => `compare-to-master.sh` ish

=== Testing scripts: for details try doing `<script> --help`
* `aha-pr-regressions.sh` -- full garnet regressions: 78 apps, 10 hours
* `garnet.sh`             -- quick garnet test; builds and runs 4x2 pointwise
* `genesis-ci.sh`         -- compare this-branch results to master-branch results
* `install-verilator.sh`  -- helper script used by `garnet.sh`

=== Gold test in `glctest/` subdirectory
* `glctest/` -- local gold test, see `glctests/README.txt`

=== To run all tests
```
  # Quick local test
  cd glctest; ./test.sh -debug 15 |& tee tmp.log | less

