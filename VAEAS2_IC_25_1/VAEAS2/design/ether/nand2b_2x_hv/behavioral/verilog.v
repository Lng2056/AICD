// Verilog HDL for "drouillard_ms", "nand2b_2x_hv" "verilog"

module nand2b_2x_hv (Y, AN, B);
    output Y;
    input AN;
    input B;

   wire  A;

   assign #(30) A=!AN;
   nand #(50) (Y,A,B);

endmodule
