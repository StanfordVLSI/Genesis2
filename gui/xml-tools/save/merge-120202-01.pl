#!/usr/bin/env perl
use strict;


# http://search.cpan.org/~dmuey/Hash-Merge-0.12/Merge.pm



use XML::Merge;

# create new    XML::Merge object from         MainFile.xml
my $merge_obj = XML::Merge->new('samples/merge-test1.xml');

# Merge File2Add.xml              into         MainFile.xml
$merge_obj->merge('samples/merge-test2.xml');

## Tidy up the indenting that resulted from the merge
#$merge_obj->tidy();

# Write out changes back            to         MainFile.xml
$merge_obj->write("foo.xml");

