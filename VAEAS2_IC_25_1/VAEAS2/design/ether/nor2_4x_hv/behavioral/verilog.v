// Verilog HDL for "drouillard_ms", "nor2_4x_hv" "verilog"
`timescale 1ps/10fs

module nor2_4x_hv (Y, A, B);
    output Y;
    input A;
    input B;

  nor #(50) (Y,A,B);

endmodule

