#!/usr/bin/perl
use strict;

if ($#ARGV < 0) {
    print STDERR "Usage: $0 <php-file>\n\n"; exit(-1);
}
my $phpfile = $ARGV[0];
open PHPFILE, "<$phpfile" or
    die "ERROR: Cannot open php file \"$phpfile\"; $!\n\n";

my @lines = <PHPFILE>;

while (my $line = shift(@lines)) {
#  my $line = $_;
  # The syntax below is a bargain I will keep w/myself:
  # Look for string: <?php include "filename"
  # Where filename is surrounded by quotes of any type (single or double).
  # Note, oddly, that a single-quote will match a double-quote.
  if ($line =~
      /^(.*)[<][\?]php\s+include\s+[\'\"]([^\'\"]*)[\'\"][^\?]*[\?][\>](.*)$/) {
      # E.g. (foo)<?php include "(Button_2.js)";   ?>(<!-- expand subparm list -->)

      #print "$line    .$1.\n    .$2.\n    .$3.\n\n";
      my ($prefix,$incfile,$suffix) = ($1,$2,$3);
      print "$prefix";
      system("cat", "$incfile") == 0 
          or die "ERROR: Can't cat '$incfile'; errcode= $?.\n";
      if ($suffix ne "") { print "$suffix\n"; }
  }
  elsif ($line =~
         /^(.*)[<][\?]php\s+include\s+[\'\"]([^\'\"]*)[\'\"]/) {
      # E.g. (foo)<?php include "(Button_2.js)";

      # Stupid continuation line.
      my ($prefix,$incfile) = ($1,$2);
      print "$prefix";
      system("cat", "$incfile") == 0 
          or die "ERROR: Can't cat '$incfile'; errcode= $?.\n";

      # Look for end of continuation line
      my $begin = $line;
      while (! ($lines[0] =~ /^(.*[\?][\>])(.*)$/)) {
          # If we wind up here we're probably lost; i.e.
          # continuation line should've been right after begin line.
#          print "BAZ $lines[0]\n";
          if ($#lines <= 0) {
              chomp($begin);
              print STDERR "ERROR: Could not find end of continuation line\n".
                  "'$begin'\n";
              exit(-1);
          }
          shift @lines;
      }
      $lines[0] =~ /^([^?]*[\?][\>])(.*)$/; # Not sure why, but this was necessary...
      my $suffix = $2; print "$suffix\n";
      shift @lines;
  }
  else { print $line; }
}
close PHPFILE;
