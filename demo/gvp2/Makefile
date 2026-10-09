# Standalone Makefile for the gvp2 demo.
# Resolves the tool relative to this directory; no env vars required.
# Regression test lives in test/gvp2test/.

HERE  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
GVP2  ?= $(abspath $(HERE)/../../bin/gvp2.pl)

ARGS  := --incdirs . --defparam WIDTH=16 example.vp

.PHONY: all run rawperl clean

all: run

run: example.v

example.v: example.vp example_inc.vph example_lib.pl $(GVP2)
	$(GVP2) $(ARGS) > $@

rawperl: example.rawperl.pl

example.rawperl.pl: example.vp example_inc.vph example_lib.pl $(GVP2)
	$(GVP2) --rawperl $(ARGS) > $@

clean:
	rm -f example.v example.rawperl.pl
	rm -f /tmp/example.vp.*.pl
