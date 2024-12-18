#!/usr/bin/perl -w

while (<STDIN>) {
#    print $_;
    my $line = $_;

    #if ($line =~ /print { \$self->{OutfileHandle} }/) {
    #if ($line =~ /print . \$self->.OutfileHandle. ./) {

    if ($line =~ /^print { \$self->{OutfileHandle} }/) {
#	print "FOO $line\n";
	$line =~ s/;\s*/;\n/g;
	$line = "\n$line\n";
#	print "FOO2 $line\n\n";
    }
    print "$line";

    if ($line =~ /^my \$self = shift;/) {
	print "\n#new func goes here\n\n";
	print "  sub printout {\n";
	print "    ";
    }



}
