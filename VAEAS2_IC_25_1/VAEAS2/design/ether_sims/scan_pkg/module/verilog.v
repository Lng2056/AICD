//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
// Title   :  scan_pkg
// Project :  umc18a01
// Author  :  dshelton
// Notes   :  this is the scan bus functional model. The 20MHz sim_clk
//            is passed to SCANCLK_x when enabled; otherwise clocks is low.
//            Tasks include:
//     
//            clock(port_num, go) 
//                           where port_num port_num is a single bit from
//                                    the testbench selecting 
//                                    which bus to drive
//                                 go is an input from the testbench
//                                    go = 1'b0  => SCANCLK = low
//                                    go = 1'b1  => SCANCLK = sim_clk20
//
//
//
//            enable(port_num, go) 
//                           where port_num port_num is a single bit from
//                                    the testbench selecting 
//                                    which bus to drive
//                                 go is an input from the testbench
//                                    go = 1'b0  => SCAN_EN = low
//                                    go = 1'b1  => SCAN_EN = high
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
`timescale 1ns/10ps

module scan_pkg (
   sim_clk20,
   SCANCLK_0,
   SCAN_EN_0,
   SCANCLK_1,
   SCAN_EN_1,);

   input   sim_clk20;
   output  SCANCLK_0;
   output  SCAN_EN_0;
   output  SCANCLK_1;
   output  SCAN_EN_1;

   reg     SCANCLK_0;
   reg     SCAN_EN_0;
   reg     SCANCLK_1;
   reg     SCAN_EN_1;
   reg     clk0_go;
   reg     clk1_go;

   initial begin
      SCANCLK_0  <= 1'b0;
      SCANCLK_1  <= 1'b0;
      SCAN_EN_0  <= 1'b0;
      SCAN_EN_1  <= 1'b0;
      clk0_go    <= 1'b0;
      clk1_go    <= 1'b0;
   end

   // combinatorial mux selecting SCANCLK_0 driver 
   always @(sim_clk20 or clk0_go)
      if (!clk0_go)
         SCANCLK_0 <= 1'b0;
      else
         SCANCLK_0 <= sim_clk20;

   // combinatorial mux selecting SCANCLK_1 driver 
   always @(sim_clk20 or clk1_go)
      if (!clk1_go)
         SCANCLK_1 <= 1'b0;
      else
         SCANCLK_1 <= sim_clk20;

   // clock enabling task; go = 1'b0  => SCANCLK = low   
   //                      go = 1'b1  => SCANCLK = high
   task clock;
      input port_num;
      input go;

      reg   in_use;

      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to scan.clock was reentrant\n");
	    $finish;
	 end 
	 in_use = 1'b1;
  
         @(negedge sim_clk20);

         if (port_num)
            clk1_go <= go;

         else
            clk0_go <= go;

         @(negedge sim_clk20);

	 in_use = 1'b0;

      end

   endtask // clock

   // scan enabling task;  go = 1'b0  => SCAN_EN = low   
   //                      go = 1'b1  => SCAN_EN = high
   task enable;
      input port_num;
      input go;

      reg   in_use;

      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to scan.enable was reentrant\n");
	    $finish;
	 end 
	 in_use = 1'b1;
  
         @(negedge sim_clk20);

         if (port_num)
            SCAN_EN_1 <= go;

         else
            SCAN_EN_0 <= go;

         @(negedge sim_clk20);

	 in_use = 1'b0;

      end

   endtask // enable

endmodule

