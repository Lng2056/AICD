// Verilog HDL for "drouillard_ms", "or4_1x_hv" "verilog"
`timescale 1ps/10fs

module or4_1x_hv (Y, A, B, C, D);
    output Y;
    input A;
    input B;
    input C;
    input D;

  or #(130) (Y,A,B,C,D);

endmodule
