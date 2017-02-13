##############################
# This package has function "new" which takes in any number of keys, and 
# creates an enumerated hash with encoding starting value of 1.
# Constructor:
## new(<key1>, <key2>, <key3>, ...):
### Object variables (to be accessed through getters or not at all):
### _width: width of signal needed to pass encoding. Use width() to get
### _enum: hash containing enum keys and encodings. Use keys() for a list of
###        enum keys, or use "gen(<key>)" to get a Verilog friendly version of 
###        the encoding to print
### _param: Internally generated variable to keep track of whether the enum
###         is being generated as Verilog parameters, or if it's just being
###         generated as a numerical encoding value (e.g. 3'd0). This variable
###         is not directly settable or readable.
# Getters and setters:
## <Key_name>: returns the encoding of a specified key_name.
## set_<key_name>: changes the encoding for a given key with all the errors and
##   warnings described in change_enc().
# Helper functions:
## e2v(<key>): Returns either the Verilog parameter name, or verilog number 
##             encoding (e.g. 3'd3) value for a given enum key.
## pretty_print(): Prints out enum key/encodes in a Perl hash format (good for 
##               leaving in comments to help with debugging)
##
## add_key(<key>): Adds a new enum key. Computes key's encoding, and updates
##                 _width.
## gen_params(): When invoked, prints out key/encode pairs as Verilog parameters
##           in generated code. Sets _param to 1, causing "gen" function to
##           return parameter name rather than encoding.
# Private functions:
## update_width(): Computes a new _width value based on number of enum keys
#
## change_enc: Takes in a key and new encoding value. If gen_params has 
##           already been called, a warning is thrown and the value is not 
##           changed. If the new encoding is already in use by another key
##           a warning is thrown. Returns 1 on success, 0 on failure.
#
# Author: Andrew Danowitz (danowitz@stanford.edu
# Copyright 2013
###########################

package enum;
use strict;
use warnings;
use POSIX;

#Constructor. Each input argument is a text enum key.
sub new
{
    my $args = scalar(@_);

    my $enum = shift;

    #initialize with an empty hash for enum key/encoding pairs
    #Also, set internal _param value to 0.
    my $self = {_enum => {}, _param => 0, _width => 0};
    
    #Take in each key and assign an encoding
    for ( my $count = 0; $count < $args-1; $count++) {
	my $key = shift;

	if (exists($self->{_enum}->{$key})){
	    die "Error, key ".$key." already defined in enum.";
	} else {
	    $self->{_enum}->{$key} = $count;
	}
    }

    #Bless into an object
    bless $self, $enum;

    #Assign the _width parameter
    $self->update_width();

    #Generate getters for direct encoding
    $self->make_enum();
    #Return the Object
    return $self;
}

sub make_enum{
    my $self = shift;
    
    foreach my $key (@{$self->keys()}){
	eval("sub ${key}{my \$self = shift; ".
	     "return \$self->{_enum}->{\$key};};");
    }
    foreach my $key (@{$self->keys()}){
	eval(qq(sub set_${key}{
             my \$self = shift;
             my \$enc = shift;
             return \$self->change_enc(\$key, \$enc);};));
    }
}

#Returns a list of enum keys
sub keys
{
    my $self = shift;
    my @keys = keys %{$self->{_enum}};
    return \@keys;
}

#Returns a string to be printed in Verilog with the appropriate enum encoding
sub e2v
{
    my $self = shift;
    my $key = shift;
    if ($self->{'_param'} == 0){
	return $self->{_width}."'d".$self->{_enum}->{$key};
    } else{
	#If we're generating Verilog parameters, the key is the parameter name
	return $key;
    }
}

#Print keys/encoding in hash format
sub pretty_print
{
    my $self = shift;

    print "{";
    while ((my $enum, my $encode) = each(%{$self->{enum}}))
    {
	print $enum."<=".$encode.",";
    }
    print "}";
    return 1;
}

#Computes the width of the signal needed to represent this enum
sub update_width
{
    my $self = shift;
    my $nKeys = scalar(@{$self->keys()});
    
    if ($nKeys == 0){
	$self->{'_width'} = 0;
    } else {
	$self->{'_width'} = ceil(log($nKeys)/log(2));
    }
    return $self->{'_width'};
}

#Add a key to the enum
sub add_key
{
    my $self = shift;
    my $new_key = shift;
    my $new_encode = scalar(@{$self->keys()});
    
    if (!exists($self->{_enum}->{$new_key})) {
	$self->{_enum}->{$new_key} = $new_encode;
	$self->update_width();
	return 1;
    } else {
	return 0;
    }
}    

sub change_enc
{
    my $self = shift;
    my $key = shift;
    my $enc = shift;

    my %enc_hash = reverse %{$self->{_enum}};

    if ($self->{_param} == 1) {
	warn "Enum encodings already printed as parameters in generated".
	    "Verilog.";
	return 0;
    }
    if (exists($enc_hash{$enc})){
	warn "Encoding ${enc} already in use for ${enc_hash{$enc}}.";
	return 0;
    } else {
	$self->{_enum}->{$key} = $enc;
	return 1;
    }
}

#Return _width
sub width
{
    my $self = shift;
    return $self->{'_width'};
}

#Prints key/encode pairs as verilog parameters. Sets _param to 1.
sub gen_params
{
    my $self = shift;
    
    $self->{_param} = 1;

    #Make a comment for the generated Verilog
    print "//Parameters generated by Genesis enum type\n";
    while((my $enum, my $encode) = each(%{$self->{_enum}}))
    {
	print "localparam ".$enum." = ".$self->{_width}."'d".$encode.";\n";
    }
    return 1;
}

sub deep_copy
{
    my $self = shift;
    my $copy = new enum();
    
    my $keys = $self->keys();

    $copy->{_param} = $self->{_param};
    while ((my $key, my $value) = each($self->{_enum})){
	$copy->{_enum}->{$key} = $value;
    }
    $copy->update_width();
    return $copy;
}

1;
