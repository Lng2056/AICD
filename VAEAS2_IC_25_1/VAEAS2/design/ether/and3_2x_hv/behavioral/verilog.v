// Verilog HDL for "drouillard_ms", "and3_2x_hv" "verilog"
`timescale 1ps/10fs

module and3_2x_hv (Y, A, B, C);
    output Y;
    input A;
    input B;
    input C;

  and #(70) (Y,A,B,C);

endmodule
