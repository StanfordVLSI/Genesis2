// gvp2 demo + smoke test: exercises every gvp.pl built-in plus include/pinclude
`timescale 1ns/1ps
// parameter WIDTH => 16 (command line)

module example_demo (
    input  wire             clk,
    input  wire [15:0] din,
    output reg  [15:0] dout
);

// ----- Start Include Of GENESIS_HOME/demo/gvp2/example_inc.vph -----
// included via //;include("example_inc.vph") - exercises Genesis2 include path
// inline backtick: WIDTH parameter is 16
wire [15:0] inc_signal;
// ----- End Include Of GENESIS_HOME/demo/gvp2/example_inc.vph -----

    wire [15:0] tap_00;
    wire [15:0] tap_01;
    wire [15:0] tap_02;
    wire [15:0] tap_03;

    Sub /*PARAMS: WIDTH=>16  */ u_sub1 (.clk(clk), .d(din), .q(dout));

// note: doubled WIDTH = 32
endmodule
