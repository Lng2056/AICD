// Verilog HDL for "drouillard_ms", "dly1_1x_hv" "verilog"
`timescale 1ps/10fs

module dly1_1x_hv (Y, A);
    output Y;
    input A;

  buf #(300) (Y,A);
endmodule
