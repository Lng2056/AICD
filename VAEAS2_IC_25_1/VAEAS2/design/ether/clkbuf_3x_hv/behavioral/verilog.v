// Verilog HDL for "drouillard_ms", "clkbuf_3x_hv" "verilog"
`timescale 1ps/10fs

module clkbuf_3x_hv (Y, A);
    output Y;
    input A;

  buf #(100) (Y,A);

endmodule
