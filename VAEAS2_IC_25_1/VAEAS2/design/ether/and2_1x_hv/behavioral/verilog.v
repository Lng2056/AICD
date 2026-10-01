// Verilog HDL for "drouillard_ms", "and2_1x_hv" "verilog"
`timescale 1ps/10fs

module and2_1x_hv (Y, A, B);
    output Y;
    input A;
    input B;

  and #(70) (Y,A,B);

endmodule
