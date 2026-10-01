// Verilog HDL for "drouillard_ms", "clkbuf_16x_hv" "verilog"
`timescale 1ps/10fs

module clkbuf_16x_hv (Y, A);
    output Y;
    input A;

  buf #(70) (Y,A);

endmodule
