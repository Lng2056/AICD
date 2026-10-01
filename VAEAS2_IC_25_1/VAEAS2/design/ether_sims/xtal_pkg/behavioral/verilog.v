//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
// Title   :  xtal_pkg
// Project :  umc18a01
// Author  :  dshelton
// Notes   :  this is the crystal bus functional model. The 25MHz sim_clk
//            is passed to XTAL25 when enabled; otherwise XTAL25 is low.
//            There is only one associated task:
//     
//            enable(go)    where    go is an input from the testbench
//                                       go = 1'b0  => XTAL25 = low
//                                       go = 1'b1  => XTAL25 = sim_clk25
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
`timescale 1ns/10ps

module xtal_pkg ( sim_clk25, XTAL25);

output  XTAL25;
input   sim_clk25;

reg	XTAL25;
reg	xtal_go;

initial begin
   XTAL25  = 1'b0;
   xtal_go = 1'b0;
end

// combinatorial mux selecting XTAL25 driver 
always @(sim_clk25 or xtal_go) begin
   if (!xtal_go)
      XTAL25 <= 1'b0;
   else
      XTAL25 <= sim_clk25;
end

//-----------------------------------------------------------------------
// clock enabling task; go = 1'b0  => XTAL25 = low   
//			go = 1'b1  => XTAL25 = sim_clk25
//-----------------------------------------------------------------------
task enable;
   input go;
   reg   in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to xtal.enable was reentrant\n");
     	 $finish;
      end 
      in_use = 1'b1;

      @(negedge sim_clk25);

      if (go == 1'b0)
	 xtal_go <= 1'b0;
      else 
	 xtal_go <= 1'b1;

      @(negedge sim_clk25);

      in_use = 1'b0;

   end

endtask

endmodule

