#!/usr/bin/perl
use POSIX;
use strict;
package GenExt;
sub AddPort {
  my $self = shift;
  my $port_str = shift;
  my $qualifier = shift;
  my $def_format = shift;
  my $port_size=0;
  my $port_dir="";
  my $port_name = "";
  my $work_str = $port_str;
  ##Parse the port_str for port size
  if ($work_str=~s/\[(\d+):(\d+)\]//g){
     $port_size = $1-$2+1;
  } else {
     $port_size = 1;
  }
  
  ##Parse the port_dir
  if ($work_str=~s/^\s*(input|output|inout) //i){
    $port_dir = lc($1);
  if (!$port_dir) { die ("ERROR '$port_dir' for $port_str\n");}
  } elsif($work_str=~s/^\s*([A-Za-z0-9\._]+)\s+//g) {
    $port_dir=$1;
  } else {
    die ("ERROR::: '$work_str' does not match, called from $self\n");
   }

  ##remove 'logic'
  $work_str=~s/^\s*logic //ig;
  
  ##strip away everything else for name
  $work_str=~s/;//g;
  $work_str=~s/,//g;

  if (scalar(split(" ",$work_str))!=1){
    die ($self->get_module_name()."-- Unable to decipher $port_str -- Ended up with '$work_str' as name\n");
  } else {
    $work_str=~s/\s*//g;
    $port_name = $work_str;
  }

  $self->{FEATURE}->{$port_name}->{SIZE} = $port_size;
  $self->{FEATURE}->{$port_name}->{DIR} = $port_dir;
  $self->{FEATURE}->{$port_name}->{TYPE} = "PORT";
  if ($qualifier eq "MON"){
    $self->{MONITOR}->{$port_name}->{DISP_FORMAT}=$def_format;
  }
  if ($qualifier eq "DRV"){
    $self->{DRIVER}->{$port_name}->{DISP_FORMAT}=$def_format;
  }
  if ($qualifier eq "CLK"){
    $self->{CLK}->{$port_name}->{DISP_FORMAT}=$def_format;
    
  }

  return $port_str;
}

sub GetClk {
  my $self = shift;
  my @temp = keys %{$self->{CLK}};
  return shift (@temp);
}

sub nb_get_subinst_array{
  my $self = shift;
  my $inst_pattern = shift;
  my $name = $self->get_module_name()."->get_subinst_array";
  my @inst_array=();
  foreach my $inst_name (keys  %{$self->{SubInstance_InstanceObj}}){
     if ($inst_name=~/$inst_pattern/g){
        push (@inst_array, $self->get_subinst($inst_name));
     }
  }
  return \@inst_array;
}

sub GetPortDir {
  my $self = shift;
  my $port_name = shift;
  if (exists $self->{FEATURE}->{$port_name}){
    return $self->{FEATURE}->{$port_name}->{DIR};
  }
  return;
}
sub GetPortDisp {
  my $self = shift;
  my $port_name = shift;
  if (exists $self->{MONITOR}->{$port_name}){
    return $self->{MONITOR}->{$port_name}->{DISP_FORMAT};
  }
  return;
}

sub GetFeatureSize {
  my $self = shift;
  my $port_name = shift;
  if (exists $self->{FEATURE}->{$port_name}){
    return $self->{FEATURE}->{$port_name}->{SIZE};
  }
  return;
}

sub GetMonitorPorts{
  my $top = shift;
  return GenExt::GetGroupPorts($top,"MONITOR");
}

sub GetDriverPorts{
  my $top = shift;
  return GenExt::GetGroupPorts($top,"DRIVER");
}

sub GetGroupPorts {
  my $top=shift;
  my $group = shift;
  my $parent_obj = $top;
  my %Modules=();
  my @arrTileSubInst = @{$parent_obj->GenExt::nb_get_subinst_array(".*")};
  foreach my $subInstRef (@arrTileSubInst){
    my $identifier = $subInstRef->get_module_name();
    if (exists %$subInstRef->{$group}){
      my %temp = (%{$subInstRef->{$group}}, %{$subInstRef->{CLK}});
      %Modules->{$identifier}->{PORTS} = \%temp;
      %Modules->{$identifier}->{TYPE} = $group;
      push (@{%Modules->{$identifier}->{INSTS}}, $subInstRef);
    }
    %Modules = (%Modules, %{GenExt::GetGroupPorts ($subInstRef,$group)});

  }
  return \%Modules;
}

sub CalcWidth {
  my $width = shift;
  my $format = shift;
    if ($format eq "H"){
      return ($width == 1)? 1:POSIX::ceil(log(2**($width-1))/log(16));
     }
    elsif ($format eq "D"){
      return ($width == 1) ? 1:POSIX::ceil(log(2**($width-1))/log(10));
    }
    else {
      return $width;
    }
}
sub translateDispCode{
  my $code = shift;
  if ($code eq 'H'){
    return "X";
  } elsif ($code eq 'D'){
    return "d";
  } elsif ($code eq 'B'){
    return "b";
  }
}

sub MAX {
   my $val1 = shift;
   my $val2 = shift;
   return $val1 > $val2 ? $val1 : $val2;
}
sub MIN {
   my $val1 = shift;
   my $val2 = shift;
   return $val1 < $val2 ? $val1 : $val2;
}

##Zero Extend with Truncation
sub ZET {
    my $name = shift;
    my $width = shift;
    my $newwidth = shift;
    if (!$newwidth || !$width){
      die ("Error, GenExt::ZET called with $name, $width, $newwidth");
    }
    if ($newwidth == $width){
      return $name;
    } elsif ($newwidth < $width){
      return $name."[".($newwidth-1).":0]";
    } else {
      return "{".($newwidth-$width)."'b0,".$name."}";
    } 

}
1;
