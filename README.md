Genesis2
========

The Genesis2 Chip Generator (CG) is a Perl-based design system and
meta-programming language for automatically producing custom hardware.
There is also a Python version, see [farther below](#also-see).

Genesis2 is free software as governed by a BSD-style license,
see LICENSE.txt for specific terms and conditions.

To install in e.g. /tmp/Genesis2
```
  export GENESIS_HOME=/tmp/Genesis2
  mkdir -p $GENESIS_HOME
  git clone https://github.com/StanfordVLSI/Genesis2.git $GENESIS_HOME
  export PATH=".:$GENESIS_HOME/bin:$GENESIS_HOME/gui/bin:$PATH"
  export PERL5LIB=$GENESIS_HOME/PerlLibs:/$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions:$PERL5LIB
```

Alternatively, if you have PIP installed on your machine, you can simply do
```
python3 -m pip install Genesis2
```

Also see [Genesis2 installation instructions](https://github.com/StanfordVLSI/Genesis2/wiki/Genesis2#Installing_Genesis2).

For extensive documentation about Genesis2, what it is and how to use it,
[go to the wiki](https://github.com/StanfordVLSI/Genesis2/wiki).


## Contributing

Perl code must be formatted according to the perltidy rules. Please use perltidy v20260204.

To reformat with perltidy, run this command from the root of the repository:
```
make format
```

## Also see

* [genesispy:](https://github.com/stfns-s/genesispy) Genesis2 except uses Python instead of Perl
* [genesis-editors:](https://github.com/stfns-s/genesis-editors) Editor support (vim, emacs, vscode) for genesis2 and genesispy
