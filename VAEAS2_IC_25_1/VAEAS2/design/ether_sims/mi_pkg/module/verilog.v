//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
// Title   :  mi_pkg
// Project :  umc18a01
// Author  :  dshelton
// Notes   :  this is the bus-functional of the two-wire MI serial 
//            interface. The syncronous interface may be driven at the 
//            specified 2.5MHz or, in the interest of reducing simulation
//            times, it may be driven at 25MHz.
//            
//            the clock task both enables/disables the MDC clock and  
//            selects the interface rate:
// 
//            clock(mode, go)  where: mode is an input from the 
//                                      testbench selecting the rate
//                                      mode = 1'b0  => MDC = sim_clk2p5
//                                      mode = 1'b1  => MDC = sim_clk25
//
//                                    go is an input from the 
//                                      testbench enabling the clock 
//                                      go = 1'b0  => MDC = low
//                                      go = 1'b1  => MDC = sim_clk
//
//
//            the read_only task drives the MDDIS pin synchonously with 
//            timing parameters equivalent to the MDIO specification.
//
//            read_only(port_num, active) 
//                              where: port_num port_num is a single bit from
//                                       the testbench selecting 
//                                       which bus to drive
//                                     active is an input from the 
//                                       testbench enabling read-only mode 
//                                       active = 1'b0  => MDDIS = low
//                                       active = 1'b1  => MDDIS = high
//
//
//
//            the read task drives MDIO three-wire implementation of the 
//            IEEE specified inout port per the umc18a01 specification.
//            It drives the output port per the specified setup/hold time,
//            and samples the respons at the earliest required time:
//
//            read(phy_addr, pre_suppress, reg_addr, data)  
//                              where: phy_addr is 5 bits supplied from
//                                       testbench
//                                     pre_suppress is a bit supplied from
//                                       testbench indicating no preamble
//                                       to be sent
//                                     reg_addr is 5 bits supplied from 
//                                       testbench
//                                     data is 16 bits recieved from the 
//                                       dut and returned to the testbench
//
//
//            the write task drives MDIO three-wire implementation of the
//            IEEE specified inout port per the umc18a01 specification.
//            It drives the output port per the specified setup/hold time,
//            and samples the response at earliest required time:
//
//            write(phy_addr, pre_suppress, reg_addr, data)  
//                              where: phy_addr is 5 bits supplied from
//                                       testbench
//                                     pre_suppress is a bit supplied from
//                                       testbench indicating no preamble
//                                       to be sent
//                                     reg_addr is 5 bits supplied from 
//                                       testbench
//                                     data is 16 bits supplied from the 
//                                       testbench to the dut
//                                     
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
`timescale 1ns/100ps

//`define OLD_NL
//-----------------------------------------------------------------------
// mi frame record
//-----------------------------------------------------------------------
`define MI_FRAME_TYP [ 63:  0]
`define DATA         [ 15:  0]
`define TA           [ 17: 16]
`define REGAD        [ 22: 18]
`define PHYAD        [ 27: 23]
`define OP           [ 29: 28]
`define SFD          [ 31: 30]
`define PRE          [ 63: 32]

//-----------------------------------------------------------------------
// mi bus bus functional models
//-----------------------------------------------------------------------
module mi_pkg (
  sim_clk2p5,
  sim_clk25,
  MDIO_OE_0,
  MDIO_OUT_0,
  MDIO_OE_1,
  MDIO_OUT_1,
	       
  MDC,
  MDDIS_0,
  MDDIS_1,
  MDIO_IN);

   input  sim_clk2p5;
   input  sim_clk25;
   input  MDIO_OE_0;   
   input  MDIO_OUT_0;
   input  MDIO_OE_1;
   input  MDIO_OUT_1;
   
   output MDC;
   output MDDIS_0;
   output MDDIS_1;
   output MDIO_IN;

   reg    MDC;
   reg    MDDIS_0;
   reg    MDDIS_1;
   reg    MDIO_IN;
   reg    `MI_FRAME_TYP sta;
   reg    mdc_go;
   reg 	  mdc_fast;

   tri    MDIO_OUT;
   
   // sum multiple PHYs output and condition if both tristated
   assign MDIO_OUT = (MDIO_OE_0 == 1) ? MDIO_OUT_0 : 1'bZ;
   assign MDIO_OUT = (MDIO_OE_1 == 1) ? MDIO_OUT_1 : 1'bZ;   
   pullup (weak1) cond (MDIO_OUT); 

   // timing parameters
   parameter SpecPeriod  = 400,
             SpecThold   = 10,
             SpecTsetup  = 10,
             FastPeriod  = 40,
             FastThold   = 10,
             FastTsetup  = 10;

   initial begin
      // intialize static bits of MI frame
      sta`PRE <= 32'hFFFFFFFF;
      sta`SFD <= 2'b01;
      
      //initalize MDIO_IN, MDDIS, and MDC
      MDC      <= 1'b0;
      MDDIS_0  <= 1'b0;
      MDDIS_1  <= 1'b0;
      MDIO_IN  <= 1'b1;

      // initialize mdc_go and mdc_fast signals
      mdc_go   <= 1'b0;
      mdc_fast <= 1'b0;
      
   end 

   //--------------------------------------------------------------------   
   // combinatorial mux to select MDC driver
   //--------------------------------------------------------------------
   always @(sim_clk2p5 or sim_clk25 or mdc_go or mdc_fast)
      if (!mdc_go)
         MDC <= 1'b0;
      else if (mdc_fast)
         MDC <= sim_clk25;
      else 
         MDC <= sim_clk2p5;


   //--------------------------------------------------------------------
   // clock enabling task      mode = 1'b0  => MDC = sim_clk2p5
   //                          mode = 1'b1  => MDC = sim_clk25
   //                          go = 1'b0    => MDC = low
   //                          go = 1'b1    => MDC = sim_clk
   //--------------------------------------------------------------------
   task clock;
      input mode;
      input go;

      reg   in_use;

      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mi.clock was reentrant\n");
	    $finish;
	 end 
	 in_use = 1'b1;

	 @ (negedge sim_clk25);
         // set go register
         if (!go)
            mdc_go <= 1'b0;
         else
            mdc_go <= 1'b1;
 
         // set speed control register
         if (!mode)
            mdc_fast <= 1'b0;
         else
            mdc_fast <= 1'b1;
	 @ (negedge sim_clk25);         

	 in_use = 1'b0;
      end
         
   endtask // clock

   //--------------------------------------------------------------------   
   //  read_only (MDDIS) task    active = 1'b0  => MDDIS = low
   //                            active = 1'b1  => MDDIS = high
   //--------------------------------------------------------------------
   task read_only;
      input  port_num;
      input  active;

      reg    in_use;
   
      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to miread_only was reentrant\n");
	    $finish;
	 end 
	 in_use = 1'b1;
         
	 // sync to next clock
	 @ (posedge MDC);

         // fastmode timing
	 if (mdc_fast)

            // send bit to specified port
            if (!port_num) begin
	       #(FastPeriod - FastTsetup);
               MDDIS_0 <= active;
	       #(FastThold + FastTsetup);
            end

            else begin
	       #(FastPeriod - FastTsetup);
               MDDIS_1 <= active;
	       #(FastThold + FastTsetup);
            end

         // spec timing
         else 
            // send bit to specified port
            if (!port_num) begin
	       #(SpecPeriod - SpecTsetup);
               MDDIS_0 <= active;
	       #(SpecThold + SpecTsetup);
            end

            else begin
	       #(SpecPeriod - SpecTsetup);
               MDDIS_1 <= active;
	       #(SpecThold + SpecTsetup);
            end

	 @ (negedge MDC);	 
	 in_use = 1'b0;
      end
   endtask // read_only


   //--------------------------------------------------------------------
   // read task
   //--------------------------------------------------------------------
   task read;
      input  [4:0]   phy_addr;
      input          pre_suppress;
      input  [4:0]   reg_addr;
      output [15:0]  data;

      integer 	     i;

      reg 	     in_use;      

      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mi.read was reentrant\n");
	    $finish;
	 end 
	 in_use = 1'b1;
	 
         // setup MI frame for read
	 sta`PHYAD <= phy_addr;
	 sta`REGAD <= reg_addr;
	 sta`OP    <= 2'b10;
	 sta`TA    <= 2'bZZ;

	 // sync to next clock
	 @ (posedge MDC);
	 if (mdc_fast) begin

	    // send first sta`PRE bit
            // if pre_suppress set this is only bit sent
	    #(FastPeriod - FastTsetup);
	    MDIO_IN <= sta[63];
	    #(FastThold + FastTsetup);

            if (!pre_suppress) begin
	       // send remaining preamble bits
	       for (i=62; i>=32; i=i-1) begin
	          MDIO_IN <= 1'bX;
	          #(FastPeriod - FastThold - FastTsetup);	
	          MDIO_IN <= sta[i];
	          #(FastThold + FastTsetup);  
	       end 
            end

	    // send next sta bits up to high-Z PHY
	    for (i=31; i>=18; i=i-1) begin
	       MDIO_IN <= 1'bX;
	       #(FastPeriod - FastThold - FastTsetup);	
	       MDIO_IN <= sta[i];
	       #(FastThold + FastTsetup);  
	    end 

	    // would drive high-Z for a bit with MDIO implemented as inout
	    MDIO_IN <= 1'bX;
            #(FastPeriod);

	    // receive and check PHY TA bit
	    //
            // note that MDIO_IN would see reflection of MDIO_OUT if
	    // MDIO is implemented as inout.
	    //	    
            // note that spec has Thold in and max MDC to MDIO out of dut
            // the same, thus this is correct. If the timing changes
            // such that these two requirements differ, a new parameter
            // will need to be introduced
            sta[16] <= MDIO_OUT;
            if (!MDIO_OUT)
               $write("");
            else 
	       $write("W: PHY failed to issue TA low bit during MI read at %0d ns\n", $time);

            // receive PHY data
	    for (i=15; i>=0; i=i-1) begin
	       #(FastPeriod);
	       sta[i] <= MDIO_OUT;
	    end

	    // condition MDIO_IN to preamble
	    #(FastPeriod - FastThold - FastTsetup);
	    MDIO_IN <= 1'b1;
	    #(FastThold + FastTsetup);
	    
            // go idle for 35 clocks
	    for (i=1; i<=35; i=i+1)
	       #(FastPeriod);

	    @(negedge MDC);

            data = sta`DATA;
	    
	 end

	 else begin

	    // send first sta`PRE bit
            // if pre_suppress set this is only bit sent
	    #(SpecPeriod - SpecTsetup);
	    MDIO_IN <= sta[63];
	    #(SpecThold + SpecTsetup);

            if (!pre_suppress) begin
	       // send remaining preamble bits
	       for (i=62; i>=32; i=i-1) begin
	          MDIO_IN <= 1'bX;
	          #(SpecPeriod - SpecThold - SpecTsetup);	
	          MDIO_IN <= sta[i];
	          #(SpecThold + SpecTsetup);  
	       end 
            end

	    // send next sta bits up to high-Z 
	    for (i=31; i>=18; i=i-1) begin
	       MDIO_IN <= 1'bX;
	       #(SpecPeriod - SpecThold - SpecTsetup);	
	       MDIO_IN <= sta[i];
	       #(SpecThold + SpecTsetup);  
	    end 

	    // would drive high-Z for a bit with MDIO implemented as inout
	    MDIO_IN <= 1'bX;
            #(SpecPeriod);


	    // receive and check PHY TA bit
	    //
            // note that MDIO_IN would see reflection of MDIO_OUT if
	    // MDIO is implemented as inout.
	    //
            // also note that spec has Thold in and max MDC to MDIO out 
            // of dut the same, thus this is correct. If the timing changes
            // such that these two requirements differ, a new parameter
            // will need to be introduced	    
            sta[16] <= MDIO_OUT;
            if (!MDIO_OUT)
               $write("");
            else 
	       $write("W: PHY failed to issue TA low bit during MI read at %0d ns\n", $time);
            
            // receive PHY data
	    for (i=15; i>=0; i=i-1) begin
	       #(SpecPeriod);       
	       sta[i]  <= MDIO_OUT;
	    end

	    // condition MDIO_IN to preamble	    
	    #(SpecPeriod - SpecThold - SpecTsetup);	
	    MDIO_IN <= 1'b1;
	    #(SpecThold + SpecTsetup);	    

            // go idle for 3 clocks
	    #(SpecPeriod);

	    repeat (3) @(negedge MDC);

            data = sta`DATA;
	    
	 end
	 
	 in_use = 1'b0;
      end
   endtask // read


   //--------------------------------------------------------------------
   // write task
   //--------------------------------------------------------------------
   task write;
      input  [4:0]   phy_addr;
      input          pre_suppress;
      input  [4:0]   reg_addr;
      input [15:0]   data;

      integer 	     i;

      reg 	     in_use;    
  
      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mi.write was reentrant\n");
	    $finish;
	 end 
	 in_use = 1'b1;
	 
         // setup MI frame for write
	 sta`PHYAD <= phy_addr;
	 sta`REGAD <= reg_addr;
	 sta`DATA  <= data;
	 sta`OP    <= 2'b01;
	 sta`TA    <= 2'b10;

	 // sync to next clock
	 @ (posedge MDC);
	 if (mdc_fast) begin

	    // send first sta`PRE bit
            // if pre_suppress set this is only bit sent
	    #(FastPeriod - FastTsetup);
	    MDIO_IN <= sta[63];
	    #(FastThold + FastTsetup);

            if (!pre_suppress) begin
	       // send remaining preamble bits
	       for (i=62; i>=32; i=i-1) begin
	          MDIO_IN <= 1'bX;
	          #(FastPeriod - FastThold - FastTsetup);	
	          MDIO_IN <= sta[i];
	          #(FastThold + FastTsetup);  
	       end 
            end

	    // send remaining sta bits up 
	    for (i=31; i>=0; i=i-1) begin
	       MDIO_IN <= 1'bX;
	       #(FastPeriod - FastThold - FastTsetup);	
	       MDIO_IN <= sta[i];
	       #(FastThold + FastTsetup);  
	    end 

            MDIO_IN <= 1'b1;

            // go idle for 36 clocks
	    for (i=1; i<=36; i=i+1)
	       #(FastPeriod);

	    @(negedge MDC);

         end

         else begin

	    // send first sta`PRE bit
            // if pre_suppress set this is only bit sent
	    #(SpecPeriod - SpecTsetup);
	    MDIO_IN <= sta[63];
	    #(SpecThold + SpecTsetup);

            if (!pre_suppress) begin
	       // send remaining preamble bits
	       for (i=62; i>=32; i=i-1) begin
	          MDIO_IN <= 1'bX;
	          #(SpecPeriod - SpecThold - SpecTsetup);	
	          MDIO_IN <= sta[i];
	          #(SpecThold + SpecTsetup);  
	       end 
            end

	    // send remaining sta bits up 
	    for (i=31; i>=0; i=i-1) begin
	       MDIO_IN <= 1'bX;
	       #(SpecPeriod - SpecThold - SpecTsetup);	
	       MDIO_IN <= sta[i];
	       #(SpecThold + SpecTsetup);  
	    end 

            MDIO_IN <= 1'b1;

            // go idle for 3 clocks
	    #(SpecPeriod);

	    repeat (3) @(negedge MDC);

	 end

	 in_use = 1'b0;
      end

   endtask // write
 
endmodule


