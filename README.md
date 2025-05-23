Genesis2
========

The Genesis2 Chip Generator (CG) is a design system and meta-programming language for automatically producing custom hardware.

Genesis2 is free software as governed by a BSD-style license, see LICENSE.txt for specific terms and conditions.

To install in e.g. `/home/mydir/Genesis2`:

C shell:
```
setenv GENESIS_HOME /home/mydir/Genesis2
git clone https://github.com/StanfordVLSI/Genesis2.git $GENESIS_HOME
 
set path=(. $GENESIS_HOME/bin $GENESIS_HOME/gui/bin $path)
setenv PERL5LIB $GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions
```

Bourne shell:
```
export GENESIS_HOME=/home/mydir/Genesis2
git clone https://github.com/StanfordVLSI/Genesis2.git $GENESIS_HOME

export PATH=$GENESIS_HOME/bin:$GENESIS_HOME/gui/bin:$PATH
export PERL5LIB=$GENESIS_HOME/PerlLibs:/$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions:$PERL5LIB
```

If you get an error like this:

```
# Compress::Raw::Zlib object version 2.060 does not match bootstrap parameter...
```

You might need to do this:

```
/bin/rm -rf $GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions/Compress
```

Also see Genesis2 installation instructions here:
https://github.com/StanfordVLSI/Genesis2/wiki#user-content-Download_and_Install_Genesis2
