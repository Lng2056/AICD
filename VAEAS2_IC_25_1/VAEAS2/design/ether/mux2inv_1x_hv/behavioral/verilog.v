// Verilog HDL for "drouillard_ms", "mux2inv_1x_hv" "verilog"
`timescale 1ps/10fs

module mux2inv_1x_hv (Y, A, B, S0);
    output Y;
    input A;
    input B;
    input S0;

    reg Y;

initial
 begin 
  Y = 0;
 end

always @(A or B or S0)
   begin
    if (S0)
      Y <= #(100) !B;
    else
      Y <= #(100) !A;
   end
 
endmodule
