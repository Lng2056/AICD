// Verilog HDL for "drouillard_ms", "or2_4x_hv" "verilog"
`timescale 1ps/10fs

module or2_4x_hv (Y, A, B);
    output Y;
    input A;
    input B;

  or #(90) (Y,A,B);

endmodule
