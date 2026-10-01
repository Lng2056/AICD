// Verilog HDL for "drouillard_ms", "or2_2x_hv" "verilog"
`timescale 1ps/10fs

module or2_2x_hv (Y, A, B);
    output Y;
    input A;
    input B;

  or #(90) (Y,A,B);

endmodule
