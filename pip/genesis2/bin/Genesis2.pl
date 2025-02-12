#!/usr/bin/env python

import platform
import sys
import os
import genesis2

PERL_LIB_VAR = "PERL5LIB"

# OLD: PERL5LIB=$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions:$PERL5LIB
# NEW: PERL5LIB=$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions:$GENESIS_HOME/PerlLibs:$PERL5LIB

# GENESIS_HOME = os.path.join(os.path.abspath(os.path.dirname(os.path.dirname(genesis2.__file__))),
#                             "Genesis2-src", "Genesis2Tools")
#
# Guess what things are about to change maybe

DOT = os.path.abspath(os.path.dirname(os.path.dirname(genesis2.__file__)))

OLD_SCRIPTPATH = os.path.join(DOT, "Genesis2-src", "Genesis2Tools", "bin", "Genesis2.pl")
NEW_SCRIPTPATH = os.path.join(DOT, "Genesis2-src", "bin", "Genesis2.pl")

if os.path.isfile(NEW_SCRIPTPATH):
    GENESIS_HOME = os.path.join(DOT, "Genesis2-src")
else:
    GENESIS_HOME = os.path.join(DOT, "Genesis2-src", "Genesis2Tools")

os.environ["GENESIS_HOME"] = GENESIS_HOME
genesis_path = os.path.join(GENESIS_HOME, "bin", "Genesis2.pl")

# @grg is changing Genesis2.pl to use libs in top-level "PerlLibs" directory
perl_path1 = os.path.join(GENESIS_HOME, "PerlLibs", "ExtrasForOldPerlDistributions")
perl_path2 = os.path.join(GENESIS_HOME, "PerlLibs")
perl_path = perl_path1 + ":" + perl_path2

args = " ".join(sys.argv[1:])
r = os.system(PERL_LIB_VAR + "=" + perl_path + ":${" + PERL_LIB_VAR + "} " + genesis_path + " " + args)
if r != 0:
    sys.exit(1)
