# To test, try something like: perl -f <thisfile>
use strict;

  my $DBG9 = 0; # DBG9 = xtreme debug
#    $DBG9 = 1;

sub getparms {

    ##############################################################################
    # Given pointer to %INPUT hash, and a query string ENV variable e.g.
    #
    #    $ENV{QUERY_STRING} = 
    #   "newdesign=clyde".
    #	"&curdesign=..%2Fdesigns%2Ftmp.tgt0%2Ftgt0-baseline.js".
    #	"&modpath=top&DBG=1".
    #	"&ASSERTION=OFF&MODE=VERIF&NUM_MEM_MATS=1&NUM_PROCESSOR=2&QUAD_ID=1&TILE_ID=1".
    #	"d1=1&d2=2&d3=3&d4=4&p1=v1&p2=v2&".
    #	"SPECIAL.2.name=SYNCLOAD&SPECIAL.2.tiecode=foo2&SPECIAL.3=bar3";
    #
    # Unpack the parms and set $INPUT{newdesign}="clyde",
    # $INPUT{curdesign}="../designs/tmp.tgt0/tgt0-baseline.js" etc.

    my $INPUTref    = shift @_;

    my $parms = $ENV{QUERY_STRING};

    # Go lookin' for trouble.  (Just might find it!)

    debug9("getparms.pl sees parms:\n$parms\n\n");

    my @fv_pairs = split /\&/ , $parms;
    foreach my $pair (@fv_pairs) {          # E.g. "foo=bar" is a pair
	if($pair=~m/([^=]+)=(.*)/) {
	    my $field = $1; my $value = $2;
	    $value =~ s/\+/ /g;
	    $value =~ s/%([\dA-Fa-f]{2})/pack("C", hex($1))/eg;
	    $INPUTref->{$field}=$value;
	}
    }
    debug9("\n");
}

sub debug9 { my $msg = shift @_; if ($DBG9) {print $msg; }}

1;
