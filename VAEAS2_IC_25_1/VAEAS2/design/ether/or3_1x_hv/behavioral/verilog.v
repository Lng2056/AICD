// Verilog HDL for "drouillard_ms", "or3_1x_hv" "verilog"
`timescale 1ps/10fs

module or3_1x_hv (Y, A, B, C);
    output Y;
    input A;
    input B;
    input C;

  or #(130) (Y,A,B,C);

endmodule
