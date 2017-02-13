package interface;

use signal;
use Clone::Fast qw(clone);

#Constructor for the interface class
sub new
{
    #Check to make sure that no arguments are being fed.
    die "Error, interface takes 1 argument, ifc_name. Use method add_<param>".
	."to populate the interface class." unless scalar(@_) == 2;

    my $interface = shift;
    my $ifc_name = shift;
    my $self = { _ifc_name => $ifc_name, _signals => {}, _ifc_type => 'svi', 
    _ifc_ptr => ''};
     
    bless $self, $interface;
    return $self;
}

sub add_signal
{
    my $self = shift;
    my $signal = shift;
    my $sig_name = $signal->name();

    if	(exists($self->{$sig_name})){
	die "Signal ".$sig_name." already exists in interface.";
    }

    $self->{signals}->{$sig_name} = $signal;

    return 1;
}

sub set_ifc{
    my $self = shift;
    my $ifc_type = shift;

    $self->{_ifc_type} = $ifc_type;
}
    
#Returns a hash of all signals in the interface
sub signals
{
    my $self = shift;
    return $self->{_signals};
}

sub signal2v
{
    my $self = shift;
    my $signal_name = shift;
    if (!exists($self->{_signals}->{$signal_name})){
	die "signal ${signal_name} does not exist in interface";
    }
    if ($self->{_ifc_type} eq "svi"){
	return $self->{_ifc_name}.".".$signal_name;
    } else {
	return $self->{_ifc_name}."_".$signal_name;
    }
}

sub instantiate
{
    my $self = shift;

    if ($self->{_ifc_type} eq 'svi'){
	return $self->inst_svi();
    } elsif ($self->{_ifc_type} eq 'ports'){
	return $self->inst_ports();
    } elsif ($self->{_ifc_type} eq 'axi'){
	return $self->inst_axi();
    }
    
    return 0;
}

sub top
{
    my $self = shift;

    if ($self->{_ifc_type} eq 'svi'){
	return $self->top_svi();
    } elsif ($self->{_ifc_type} eq 'ports'){
	return $self->top_ports();
    } elsif ($self->{_ifc_type} eq 'axi'){
	return $self->top_axi();
    }

    return 0;
}

sub meta2topInst{
    my $self = shift;
    my $con_hash = shift;

    if ($self->{_ifc_type} eq 'svi'){
	return $self->m2t_svi();
    } elsif ($self->{_ifc_type} eq 'ports'){
	return $self->m2t_ports();
    } elsif ($self->{_ifc_type} eq 'axi'){
	return $self->m2t_axi();
    }

    return 0;
sub internal2ifc
{
    my $self = shift;
    my $con_hash = shift;
    
    if ($self->{_ifc_type} eq 'svi'){
	return $self->i2m_svi($con_hash);
    } elsif ($self->{_ifc_type} eq 'ports'){
	return $self->i2m_ports($con_hash);
    } elsif ($self->{_ifc_type} eq 'axi'){
	return $self->i2m_axi($con_hash);
    }

    return '';
}

sub i2m_ports
{
    return '';
}

sub i2m_axi
{
    return '';
}
sub i2m_svi
{

}

sub m2t_svi{
        #takes in a hash with keys ifc_name, and connections. Connections is a 
    #hash where each key is a signal in $self and value is the name
    #of the interface signal it connects to. Only needed for interfaces
    my $self = shift;
    my $master_ifc = shift;

    my $conn_map = $self->comp_ifcs($master_ifc);

    my $return_string =$self->inst_svi()."\n".$master_ifc->inst_svi()."\n";

    foreach my $sig (keys %{$conn_map->{connections}}){
	my $width = $self->{_signals}->{$sig}->width();
	my $dir = $self->{_signals}->{$sig}->direction();
	my $ifc = $conn_map->{ifc_name};
	my $conn_sig = $conn_map->{connections}->{$sig};

	if ($self->{_signals}->{$sig}->direction() eq "input"){
	    $return_string .= 
		"${self->{_ifc}}.${sig} = ${ifc}.${conn_sig};\n";
	} elsif ($self->{_signals}->{$sig}->direction() eq "output"){
	    $return_string .="${ifc}.${conn_sig} = ${self->{_ifc}}.$sig;\n";
	} elsif ($self->{_signals}->{$sig}->direction() eq "inout"){ 
	    # *** Fix ***
	    die "Error, inout connections not yet implemented";
	}
    }
    return $return_string;
}

sub m2t_ports{
    my $self = shift;
    my $master_ifc = shift;

    my $conn_hash = $self->comp_ifcs($master_ifc);
    my @port_list = ();
    while ((my $port, my $signal) = each(%{$conn_hash})){
	append(@port_list, ".${port}(${signal})");
    }

    my $port_string = join(',', @port_list);

    return $port_string;
}


#Prints standard Verilog port instantiation
sub inst_ports
{
    my $self = shift;
    
    my $sig_hash = $self->signals();
    my @signals = keys(%{$sig_hash});
    my $numSigs = scalar(@signals);

    my @print_list = ();

    foreach my $signal (@signals) {
	my $direction = $sig_hash{$signal}->direction();
	my $width = $sig_hash{$signal}->width();
	append (@print_list, "${direction} logic [${width}-1:0] ${signal}");
    }

    return join(',', @print_list);


}

sub inst_svi
{
    my $self = shift;

    if ($self->{_ifc_ptr} eq ''){
	$self->{_ifc_ptr} = generate(generic_ifc, $self->{_ifc_name},
				 SIGNALS => $self->signals(), FORCE => 1);
    }
    ${self->{_ifc_ptr}->instantiate()};
    #Implements System Verilog interface

    return 1;
}

sub inst_axi
{
    #Implements AXI taps
    die "Error: AXI is not yet supported";
}

sub top_svi
{
    my $self = shift;
    $self->inst_svi();
}

sub top_ports
{
    my $self = shift;

    while ((my $signame, my $signal) = each(%{$self->signals()})){
	print "logic [${signal->{width}}-1:0] $signame";
    }
}
	   
sub comp_ifcs
{
    #Compares two interfaces and matches signals

    my $self = shift;
    my $comp = shift;

    my $signals = $self->signals();
    my $comp_signals = $comp->signals();

    my $signal_hash = {'ifc_name' => $comp->ifc_name(), 'connections' => {}};

    foreach my $signal ($comp_signals){
	if (!exist($signals->{$signal})){
	    $self->add_signal($comp_signals->{$signal});
	}
    }

    while ((my $signame, my $signal) = each %$signals){
	my $found = 0;
	while ((my $compname, my $compsig) = each %$comp_signals){
	    my $match = $signal->equals($compsig);
	    
	    if ($match & !$found){
		$signal_haash->{connections}->{$signame} = $compsig;
		$found = 1;
	    } elsif ($match & $found} {
		die "Error, found two mappings for signal ${signame} in ".
		    $comp->ifc_name();
	    }
	}
	if (!$found){
	    die "Error, no match for ${signame} in ${comp->ifc_name()";
	}
    }

    return $signal_hash;
	    
}

sub deep_copy
{
    my $self = shift;

    my $ifc_name = $self->{_ifc_name};
    my $signals = copy($self->{_signals});
    my $ifc_type = $self->{_ifc_type};
    my $ifc_ptr = '';
    
    if ( $ifc_ptr neq ''){
	my $ifc_ptr = $self{_ifc_ptr}->clone_inst();
    }

    my $copy = new interface($ifc_name);
    $copy->{_signals} = $signals;
    $copy->{_ifc_type} = $ifc_type;
    $copy->{_ifc_ptr} = $ifc_ptr;

    return $copy;
}
	    

1;
