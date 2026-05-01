# Standalone Makefile for the gvp2 demo / smoke test.
# Resolves both tools relative to this directory; no env vars required.

HERE  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
GVP2  ?= $(abspath $(HERE)/../../bin/gvp2.pl)

ARGS  := --incdirs . --defparam WIDTH=16 example.vp

.PHONY: all run rawperl test clean

all: run

run: example.v

example.v: example.vp example_inc.vph example_lib.pl $(GVP2)
	$(GVP2) $(ARGS) > $@

rawperl: example.rawperl.pl

example.rawperl.pl: example.vp example_inc.vph example_lib.pl $(GVP2)
	$(GVP2) --rawperl $(ARGS) > $@

# Smoke test: run gvp2.pl on example.vp and verify the output contains every
# feature the template exercises. Strict diff against gvp.pl is not used
# because gvp2.pl inherits Genesis2's parser, which has known cosmetic
# differences (Start/End Include markers, `timescale spacing, no pinclude
# markers) — see the gvp2 design notes.
test: example.v
	@ok=1; \
	for pat in \
	    'parameter WIDTH => 16 (command line)' \
	    'module example_demo' \
	    'wire \[15:0\] inc_signal' \
	    'wire \[15:0\] tap_00' \
	    'wire \[15:0\] tap_03' \
	    'Sub /\*PARAMS: WIDTH=>16' \
	    'doubled WIDTH = 32' \
	    'endmodule'; \
	do \
	    if grep -q -- "$$pat" example.v; then \
	        echo "  OK   : $$pat"; \
	    else \
	        echo "  MISS : $$pat"; ok=0; \
	    fi; \
	done; \
	if [ $$ok -eq 1 ]; then \
	    echo "PASS: gvp2.pl smoke test"; \
	else \
	    echo "FAIL: gvp2.pl smoke test"; exit 1; \
	fi

clean:
	rm -f example.v example.rawperl.pl
	rm -f /tmp/example.vp.*.pl
