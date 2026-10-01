// Verilog HDL for "drouillard_ms", "and4_1x_hv" "verilog"
`timescale 1ps/10fs

module and4_1x_hv (Y, A, B, C, D);
    output Y;
    input A;
    input B;
    input C;
    input D;

  and #(70) (Y,A,B,C,D);

endmodule
