package wallace;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

use Exporter;
use FileHandle;
use Env; # Make environment variables available


use Genesis2::Manager 1.00;
use Genesis2::UniqueModule 1.00;

@ISA = qw(Exporter Genesis2::UniqueModule);
@EXPORT = qw();
@EXPORT_OK = qw();

$VERSION = '1.0';

############################### Module Starts Here ###########################


sub to_verilog{
my $self = shift;
local $Genesis2::UniqueModule::src_inline;local $Genesis2::UniqueModule::src_infile;$self->SUPER::to_verilog;
$Genesis2::UniqueModule::src_infile = "/home/steveri/genesis2-experiments/wallace/wallace.vp";

print { $self->{OutfileHandle} } '// returns the depth of a tree of m->n compressors for t numbers';
print { $self->{OutfileHandle} } "\n";$Genesis2::UniqueModule::src_inline = 2;

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";$Genesis2::UniqueModule::src_inline = 3;

 sub treedepth {
   my ($m,$n,$t) = @_;
   if ($t > $m) { return (1 + treedepth($m, $n, $n*int($t/$m) + $t%$m)); }
   else         { return  1; }
 }

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 9;

 my $module_name = $self->get_module_name();
 my $n = $self->define_param(op_width => 4);

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 12;

print { $self->{OutfileHandle} } 'module '; 
print { $self->{OutfileHandle} } $module_name; 
print { $self->{OutfileHandle} } ' (';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 13;

print { $self->{OutfileHandle} } '   input  ['; 
print { $self->{OutfileHandle} } $n-1; 
print { $self->{OutfileHandle} } ':0] pp ['; 
print { $self->{OutfileHandle} } $n-1; 
print { $self->{OutfileHandle} } ':0],';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 14;

print { $self->{OutfileHandle} } '   output ['; 
print { $self->{OutfileHandle} } 2*$n-1; 
print { $self->{OutfileHandle} } ':0] s,';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 15;

print { $self->{OutfileHandle} } '   output ['; 
print { $self->{OutfileHandle} } 2*$n-1; 
print { $self->{OutfileHandle} } ':0] c';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 16;

print { $self->{OutfileHandle} } ');';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 17;

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 18;

print { $self->{OutfileHandle} } '   logic ['; 
print { $self->{OutfileHandle} } 2*$n-1; 
print { $self->{OutfileHandle} } ':0]   pp_wide ['; 
print { $self->{OutfileHandle} } $n-1; 
print { $self->{OutfileHandle} } ':0];';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 19;

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 20;

print { $self->{OutfileHandle} } '   // make pps rectangular (insert 0s!)';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 21;

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 22;
 for (my $i=0; $i<$n; $i++) {

print { $self->{OutfileHandle} } '    assign pp_wide['; 
print { $self->{OutfileHandle} } $i; 
print { $self->{OutfileHandle} } '] = {{('; 
print { $self->{OutfileHandle} } $n-$i; 
print { $self->{OutfileHandle} } '){1\'b0}}, pp['; 
print { $self->{OutfileHandle} } $i; 
print { $self->{OutfileHandle} } '], {'; 
print { $self->{OutfileHandle} } $i; 
print { $self->{OutfileHandle} } '{1\'b0}}};';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 24;
 }

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 26;

print { $self->{OutfileHandle} } '   // long tmp variables to hold the redundant sums';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 27;

print { $self->{OutfileHandle} } '   logic ['; 
print { $self->{OutfileHandle} } (2*$n+treedepth(3,2,$n)-1)-1; 
print { $self->{OutfileHandle} } ':0] stmp;';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 28;

print { $self->{OutfileHandle} } '   logic ['; 
print { $self->{OutfileHandle} } (2*$n+treedepth(3,2,$n)-1)-1; 
print { $self->{OutfileHandle} } ':0] ctmp;';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 29;

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 30;

print { $self->{OutfileHandle} } '   // adder tree to add n (2*n) bit numbers in parallel (using 3-2 CSAs)';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 31;

print { $self->{OutfileHandle} } '//   adder_tree #(.w(2*4), .n(4)) addtree (.in(pp_wide), .c(ctmp), .s(stmp));';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 32;

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 33;

 my $addtree = $self->unique_inst('adder_tree', 'addtree', w => 2*4, n => 4);

print { $self->{OutfileHandle} } '   '; 
print { $self->{OutfileHandle} } $addtree->get_module_name(); 
print { $self->{OutfileHandle} } ' '; 
print { $self->{OutfileHandle} } $addtree->get_instance_name(); 
print { $self->{OutfileHandle} } '(.in(pp_wide), .c(ctmp), .s(stmp));';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 35;

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 36;

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 37;
# my $addtree = $self->unique_inst('adder_tree', 'addtree',
#                                                           w => 2*4,
#                                                           n => 4);
#   `$addtree->get_module_name()` `$addtree->get_instance_name()`(.in(pp_wide), .c(ctmp), .s(stmp));

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 42;

print { $self->{OutfileHandle} } '   assign s = stmp['; 
print { $self->{OutfileHandle} } 2*$n-1; 
print { $self->{OutfileHandle} } ':0];';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 43;

print { $self->{OutfileHandle} } '   assign c = ctmp['; 
print { $self->{OutfileHandle} } 2*$n-1; 
print { $self->{OutfileHandle} } ':0];';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 44;

print { $self->{OutfileHandle} } '';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 45;

print { $self->{OutfileHandle} } 'endmodule // wallace';
print { $self->{OutfileHandle} } "\n";
$Genesis2::UniqueModule::src_inline = 46;
}
