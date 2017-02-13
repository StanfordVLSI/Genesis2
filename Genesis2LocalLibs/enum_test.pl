#!/usr/bin/perl

use enum;
use strict;

#Create an enum.
my $enum = new enum('dog','cat','moose','banana');

#Get the keys
my $keys = $enum->keys();

#Print the Verilog encoding for a key
print "\nhere 1 ".$enum->e2v('dog')."\n";

#Add a key
$enum->add_key('bear');

#Turn the hash into Verilog parameters. Note that since adding a 5th key,
#the signal width used to encode the verilog signal has increased!
$enum->gen_params();

my $enum_copy = $enum->deep_copy();

$enum_copy->gen_params();
#Print the verilog encoding for key "dog"
print "\nhere 1 ".$enum_copy->e2v('dog')."\n";

#Print out all of the keys and their encoding
foreach my $key (@{$keys}) {
    print $key."\n";
    print $enum->e2v($key)."\n";
    print "here again ".$enum->e2v($key)."\n";
    print "here aa ".$enum->dog();
}

my $enum2 = new enum('dog','cat','moose','banana');
print "\nfailed change: ".$enum2->change_enc('dog', 2)."\n";
#print "succ change: ".$enum2->change_enc('dog', 8)."\n";
print "succ2: ".$enum2->set_dog(10)."\n";
print "new dog new trick: ".$enum2->dog()."\n";
print $enum->width();
