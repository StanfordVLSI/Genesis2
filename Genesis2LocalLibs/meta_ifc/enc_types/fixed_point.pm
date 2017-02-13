package fixed_point;
use encoding;
use strict;
our @ISA = qw(encoding);

sub new
{
    my $class = @_;
    my $construct_hash = $_[1];
    my $width = $contruct_hash->{'int_bits'} + $contruct_hash->{'fract_bits'};
    my $self = $class->SUPER::new($width);

    my $self->{_int_bits} = $construct_hash->{'int_bits'};
    my $self->{_fract_bits} = $construct_hash->{'fract_bits'};
}

sub int_bits
{
    return $self->{_int_bits};
}
sub fract_bits
{
    return $self->{fract_bits};
}

sub compat_check {
    my ($self, $comp_encode) = @_;
    
    return 1 if ($self->SUPER::compat_check($comp_encode) and 
		 ($self->{_int_bits} eq $comp_encode->int_bits() and
		  $self->{_fract_bits} eq $comp_encode->fract_bits()))
	else return 0;
}
