// Verilog HDL for "drouillard_ms", "clkbuf_12x_hv" "verilog"
`timescale 1ps/10fs

module clkbuf_12x_hv (Y, A);
    output Y;
    input A;

  buf #(70) (Y,A);

endmodule
