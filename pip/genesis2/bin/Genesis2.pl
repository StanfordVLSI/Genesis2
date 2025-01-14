#!/usr/bin/env python

import platform
import sys
import os
import genesis2

PERL_LIB_VAR = "PERL5LIB"

# PERL5LIB=$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions:$PERL5LIB

GENESIS_HOME = os.path.join(os.path.abspath(os.path.dirname(os.path.dirname(genesis2.__file__))),
                            "Genesis2-src", "Genesis2Tools")
os.environ["GENESIS_HOME"] = GENESIS_HOME
genesis_path = os.path.join(GENESIS_HOME, "bin", "Genesis2.pl")
perl_path = os.path.join(GENESIS_HOME, "PerlLibs", "ExtrasForOldPerlDistributions")
args = " ".join(sys.argv[1:])
r = os.system(PERL_LIB_VAR + "=" + perl_path + ":${" + PERL_LIB_VAR + "} " + genesis_path + " " + args)
if r != 0:
    sys.exit(1)
