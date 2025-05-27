#!/bin/bash

USAGE="
  DESCRIPTION:
    Builds a memory controller and compares to previously-built gold verilog.
    Generates a 'genesis_clean.cmd' you can use to clean up the mess that it makes.

  USAGE:
    $0 <flags>

  EXAMPLES:
    $0 -debug 15
    $0 -debug 15 |& tee test.log | less
"
if [ "$1" == "--help" ]; then echo "$USAGE"; exit; fi

# Clean up from any prior runs.
test -f genesis_clean.cmd && genesis_clean.cmd || echo okay

# We should be here: Genesis2/test/glctest/
export GENESIS_HOME=$(cd ../..; pwd)
export PATH=$GENESIS_HOME/bin:$GENESIS_HOME/gui/bin:$PATH
export PERL5LIB=$GENESIS_HOME/PerlLibs:/$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions:$PERL5LIB

# Build systemverilog *.sv files and put them in dir genesis_verif/
printf '\n\nBUILD\n'
Genesis2.pl -parse -generate -top global_controller -input \
    global_controller/rtl/genesis/global_controller.svp \
    global_controller/rtl/genesis/jtag.svp \
    global_controller/rtl/genesis/glc_axi_ctrl.svp \
    global_controller/rtl/genesis/glc_axi_addrmap.svp \
    global_controller/rtl/genesis/glc_jtag_ctrl.svp \
    global_controller/rtl/genesis/tap.svp \
    global_controller/rtl/genesis/flop.svp \
    global_controller/rtl/genesis/cfg_and_dbg.svp \
  -parameter global_controller.cfg_data_width=32 \
  -parameter global_controller.cfg_addr_width=32 \
  -parameter global_controller.cfg_op_width=5 \
  -parameter global_controller.axi_addr_width=13 \
  -parameter global_controller.axi_data_width=32 \
  -parameter global_controller.block_axi_addr_width=12 \
  -parameter global_controller.num_glb_tiles=2 \
  -parameter global_controller.cgra_width=4 \
  -parameter global_controller.cgra_width_including_io=4 \
  -parameter global_controller.glb_tile_mem_size=128 \
  $* || exit 13
  
# Wait for genesis to finish writing stderr i guess
sleep 1

# Compare results to gold model
echo COMPARE diff -r genesis_verif_gold/ genesis_verif/

# Ignore comment lines...
diff -r -I '^//' genesis_verif_gold/ genesis_verif/ && result=PASS || result=FAIL

echo ''
echo '------------------------------------------------------------------------'
echo Test result: $result
echo '------------------------------------------------------------------------'
echo ''

[ "$result" == "PASS" ] || exit 13
exit 0  # success (0=no errors)
