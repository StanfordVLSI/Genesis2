package signal;

sub new
{
    my $signal = shift;
    my $self = {_name => shift,	_type => shift,	_encode => shift};
    bless $signal $self;
    return $self;
}

sub width
{
    return $self->{$encode}->width();
}

sub type
{
    return $self->{_type};
}

sub encode
{
    return $self->{_encode};
}
