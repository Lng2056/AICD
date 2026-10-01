// Verilog HDL for "drouillard_ms", "xor2_1x_hv" "verilog"
`timescale 1ps/10fs

module xor2_1x_hv (Y, A, B);
    output Y;
    input A;
    input B;

  xor #(130) (Y,A,B);

endmodule

