#!/usr/bin/perl -w

# IN:
# //; $flop_inst =  genify('
# //;     flop #(
# //;             .FLOP_WIDTH(1),
# //;             .FLOP_TYPE("rflop"),
# //;             .FLOP_DEFAULT(0)
# //;     )
# //;      Stall_flop(.Clk(Clk), .Reset(Reset), .Enable(/*not used*/),
# //;                 .data_in(Stall),           .data_out(procStall));
# //; ');

# OUT:
#   //;#
#   //;#     flop #(
#   //;#             .FLOP_WIDTH(1),
#   //;#             .FLOP_TYPE("rflop"),
#   //;#             .FLOP_DEFAULT(0)
#   //;#     )
#   //;#      Stall_flop(.Clk(Clk), .Reset(Reset), .Enable(/*not used*/),
#   //;#                 .data_in(Stall),           .data_out(procStall));
#   //;#
#   //; $flop_inst =  $self->unique_inst('flop','Stall_flop',
#   //;                                      'FLOP_WIDTH' => 1,
#   //;                                      'FLOP_TYPE' => 'rflop',
#   //;                                     'FLOP_DEFAULT' =>  0);
#   `$flop_inst->get_module_name()`  `$flop_inst->get_instance_name()`
#     (.Clk(Clk),  .Reset(Reset), .Enable(/*not used*/),
#       .data_in(Stall),           .data_out(procStall));


my $line_in = '     Stall_flop/* foo */(.Clk(Clk), .Reset(Reset), .Enable(/*not used*/),
                     foobar  // foobar comment
                     shoobar // comment 2
';

$line_in = '
    flop #(
            .FLOP_WIDTH(1),           // stupid embedded comment 1
            .FLOP_TYPE("rflop"),      // stupid // embedded // comment 2
            .FLOP_DEFAULT(0)
    )
     Stall_flop(.Clk(Clk), .Reset(Reset), .Enable(/*not used*/),
                .data_in(Stall),           .data_out(procStall));
';



print "Original line in:\n";
print $line_in;
print "\n------------------------------------------------------------------------\n";

# Remove star comments.

my $line_out = remove_star_comment($line_in);
while ($line_in ne $line_out) {
    $line_in = $line_out;
    $line_out = remove_star_comment($line_in);
}
print "After remove_star_comment:\n$line_out\n";
print "------------------------------------------------------------------------\n";

# Remove slash-slash comments.

$line_out = remove_slash_slash_comment($line_in);
while ($line_in ne $line_out) {
    $line_in = $line_out;
    $line_out = remove_slash_slash_comment($line_in);
}
print "After remove_slash_slash:\n$line_out\n";

# Find params

my ($parms,$remainder) = find_params($line_out);

print "Found parms:\n$parms\n\n";
print "Found remainder:\n$remainder\n\n";

my ($module,$instance,$rem2) = parse_instantiation($remainder);

print "\n------------------------------------------------------------------------\n";
print "Found module name: $module\n";
print "Found instance name: $instance\n";
print "Found parms: $parms\n\n";
print "Found remainder: $rem2\n\n";
exit;


my $foo = find_params("a #  ( .bc(bc), .bc(xy), .slam(bam))  b ( .foo(bar), .bax (mumble))");

exit;



my $flop_inst =  genify('
    flop #(
            .FLOP_WIDTH(1),
            .FLOP_TYPE("rflop"),
            .FLOP_DEFAULT(0)
    )
     Stall_flop(.Clk(Clk), .Reset(Reset), .Enable(/*not used*/),
                .data_in(Stall),           .data_out(procStall));
');

sub remove_slash_slash_comment {
    # remove "//...eol" style comments

    my $line = shift @_;

    #print "found input line: '$line'\n\n";

    my $comment = qr/\/\/[^\n]*/;

    if ($line =~ /(.*)($comment)(.*)/s) {  # "s" allows string to match embedded newlines.
#   if ($line =~ /(.*)(\/\/[^\n]*)(\n.*)/s) {  # "s" allows string to match embedded newlines.

	#print "Found comment: $2\n\n";
	#print "Line w/comment removed: $1$3\n\n";
	return("$1$3");
    }
    else {
	return $line;
    }
}

sub remove_star_comment {
    # remove "/* ... */" style comments

    my $line = shift(@_);

    #print "found input line: '$line'\n\n";

    #my $comment = qr/[/][*].*[*][/]/x;
    my $comment = qr/\/\*.*\*\//;

    if ($line =~ /(.*)($comment)(.*)/s) {  # "s" allows string to match embedded newlines.
	#print "Found comment: $2\n\n";
	#print "Line w/comment removed: $1$3\n\n";
	return("$1$3");
    }
    else {
	return $line;
    }
}

sub find_params {
    my $line = shift(@_);

    print "found input line: '$line'\n\n";

#    if ($line =~ /a ((bc)*)/) { print "YES $1\n\n"; }

#    my $inner_paren = qr/[^()]*[(][^()][)][^()]*/;
    my $inner_paren = qr/[^()]*[(][^()]*[)][^()]*/;

#    if ($line =~ /(#[^(]*[(])(([^(]*[(][^)]*[)])*)[)]/  ) { print "YES |$1|$2\n\n"; }
#    if ($line =~ /#[^()]*[(](($inner_paren)*)[)]/) { print "Found params: $1\n\n"; }


    if ($line =~ /^(.*)#[^()]*[(](($inner_paren)*)[)](.*)$/s) {
	my $params = $2;
	my $remainder = $1.$4;
	print "Found params: ...$params...\n\n";
	#print "Remainder: ...$1...$2...$3...$4...\n\n";
	print "Remainder: $remainder\n\n";
	return ($params,$remainder);
    }
}

sub parse_instantiation {
    my $line = shift(@_);

    print "line in = $line\n\n";

    if ($line =~ /^\W+(\w+)\W+(\w+)(.*)/s) {
	my $module = $1;
	my $instance = $2;
	my $remainder = $3;
	return ($module,$instance,$remainder);
    }
    return ("error","error","error");
}
