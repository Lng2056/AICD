// Verilog HDL for "drouillard_ms", "nand2_2x_hv" "verilog"
`timescale 1ps/10fs

module nand2_2x_hv (Y, A, B);
    output Y;
    input A;
    input B;

  nand #(50) (Y,A,B);

endmodule
