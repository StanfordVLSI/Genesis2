#!/usr/bin/env perl
use strict;
use XML::Simple qw(:strict);                      # use XML::Simple;



xml_merge($ARGV[0], $ARGV[1]);
exit(0);

# http://search.cpan.org/~dmuey/Hash-Merge-0.12/Merge.pm

sub xml_merge {

    my $xmlfile_orig = shift(@_);   # E.g. "samples/merge-1.xml"
    my $xmlfile_new  = shift(@_);   # E.g. "samples/merge-2.xml"

    my $xml_orig = XMLin($xmlfile_orig, 
                        KeepRoot => 1, # Don't throw away "HierarchyTop"
                        NoAttr => 1,
                        KeyAttr => [],
                        ForceArray => ['ArrayItem', 'HashItem', 'ParameterItem', 'SubInstanceItem']
                        );

    my $xml_new = XMLin($xmlfile_new, 
                        KeepRoot => 1, # Don't throw away "HierarchyTop"
                        NoAttr => 1,
                        KeyAttr => [],
                        ForceArray => ['ArrayItem', 'HashItem', 'ParameterItem', 'SubInstanceItem']
                        );



#    use Hash::Merge qw( merge );
#    #my %c = %{ merge( \%a, \%b ) };
#    my $xml_merged = merge( $xml_orig, $xml_new);

    my $xml_merged = $xml_orig;

    print
    XMLout($xml_merged,
	   NoAttr => 1, 
	   KeyAttr => [],
	   RootName => 'HierarchyTop',   # Add root "HierarchyTop"
           KeepRoot => 1,                # Don't throw away "HierarchyTop"
#	   OutputFile => $new_fname
#	   OutputFile => "tmpfoo"
           );
}

