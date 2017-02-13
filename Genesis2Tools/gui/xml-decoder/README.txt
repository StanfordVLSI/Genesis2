To use xml decoder, see xml2js.csh

========================================================================
To test (new format):

  test/regression.csh
  test/testall.csh
  test/test-big.csh

========================================================================
From Ofer (see below):

I also created a description of the XML fields (kind of a schema in
English words). For input xml files:

https://www-vlsi.stanford.edu/mediawiki/index.php/CG/Genesis2#Program.xml_File,

and for output xml files:

https://www-vlsi.stanford.edu/mediawiki/index.php/CG/Genesis2#Hierarchy_Out

========================================================================
Subject: XML description of the chip
Date:	 Tuesday, May 25, 2010 3:58 PM
From:	 "Ofer Shacham" <shacham@stanford.edu>
To:	 "'Stephen Richardson'" <steveri@stanford.edu>

Message contains attachments: 1 File (60KB): program.xml

Hi Steve,

Here is the XML description of the ee272 chip (which is badly named
.template.). I forgot to mention that the output file from genesis
actually have more information than required for the input file (that
is, any genesis output file is valid genesis input file, but if you
just modify an output file and feed back as input, some fields are
probably going to be ignored)

I also created a description of the XML fields (kind of a schema in
English words). For input xml files:
https://www-vlsi.stanford.edu/mediawiki/index.php/CG/Genesis2#Program.xml_File,
and for output xml files:
https://www-vlsi.stanford.edu/mediawiki/index.php/CG/Genesis2#Hierarchy_Out

Let me know if there is any information missing.

Ofer.
