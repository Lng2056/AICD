// Verilog HDL for "drouillard_ms", "inv_1x_hv" "verilog"
`timescale 1ps/10fs

module inv_1x_hv (Y, A);
    output Y;
    input A;

  not #(30) (Y,A);

endmodule
