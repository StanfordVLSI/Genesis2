Genesis2
========

The Genesis2 Chip Generator (CG) is a design system and meta-programming language for automatically producing custom hardware.

Genesis2 is free software as governed by a BSD-style license, see LICENSE.txt for specific terms and conditions.

To install in e.g. /home/mydir/Genesis2:

<pre>
 set destdir = /home/mydir/Genesis2
 git clone https://github.com/StanfordVLSI/Genesis2.git $destdir
 
 setenv GENESIS_HOME $destdir/Genesis2Tools
 set path=(. $GENESIS_HOME/bin $GENESIS_HOME/gui/bin $path)
 setenv PERL5LIB $GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions
</pre>

If you get an error like this:

<pre>
 # Compress::Raw::Zlib object version 2.060 does not match bootstrap parameter...
</pre>

You might need to do this:

<pre>
 /bin/rm -rf $destdir/Genesis2Tools/PerlLibs/ExtrasForOldPerlDistributions/Compress
</pre>

Also see Genesis2 installation instructions here:
http://genesis2.stanford.edu/mediawiki/index.php/Genesis2#Installing_Genesis2