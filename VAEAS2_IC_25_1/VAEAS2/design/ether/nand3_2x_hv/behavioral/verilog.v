// Verilog HDL for "drouillard_ms", "nand3_2x_hv" "verilog"
`timescale 1ps/10fs

module nand3_2x_hv (Y, A, B, C);
    output Y;
    input A;
    input B;
    input C;

  nand #(50) (Y,A,B,C);

endmodule
