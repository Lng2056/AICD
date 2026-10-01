//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
// Title   :  testharness
//
// Notes   :  this module and it's constituent bus-functional models
//            and packages wrap around the dut, providing all digital 
//            stimulus and monitoring directly, and providing digital 
//            control over mixed signal elements in the top-level schematic 
//            which create the analog stimulus/monitoring functions to 
//            the dut.  
//
//            Included are the basic clock sources, which are muxed 
//            into the design through the appropriate bus-functional 
//            models. This module only contains io directly or indirectly
//            targeting the dut. This module is instantiated by the various 
//            testbench verilog modules which control it's bus-functional
//            tasks through hierarchical task calls, e.g., 
//            'th.mi.read(addr, data);' would be the testbench call to 
//            read an mi register through this testharness (th). Below 
//            is a diagram of the basic teststructure
//
//  +--------------------------------------------------------------------+
//  | top-level schematic                                                |
//  | +----------------------------------------------------------------+ |
//  | | testbench                                                      | |
//  | |                                                                | |
//  | | initial begin           +------------------------------------+ | |
//  | |  th.xtal.enable(1'b1);  | testharness                        | | |
//  | |  th.reset.enable(go);   |                                    | | |
//  | |  th.mi.clock(mode, go); |  +---+  +---+  +----+      +-----+ | | |
//  | |          .              |  |clk|  | mi|  |xtal|  ... |100tx| | | |
//  | |          .              |  |gen|  |pkg|  | pkg|      |  pkg| | | |
//  | |          .              |  +---+  +---+  +----+      +-----+ | | |
//  | | $finish;                +----------+/\------+---------+-/\---+ | |
//  | |                                    | |      |         |  |     | |
//  | +------------------------------------+-+------+---------+--+-----+ |
//  |                                      M M      X         |  |       |
//  |                                      D D      T        \/  |       |
//  |                                      C I      A      +---------+   |
//  |                                      | O      L      | mixed   |   |
//  |                                      | |      2      |  signal |   |
//  |                                      | |      5      +---------+   |
//  |                                      | |      |         | /\       |
//  |                                     \/\/     \/        \/  |       |
//  |                                  +----------------------------+    |
//  |                                  |           dut              |    |
//  |                                  |                            |    |
//  |                                  +----------------------------+    |
//  +--------------------------------------------------------------------+
//
//           Also included are many miscellaneous support tasks 
//           independent  from any particular interface. These include 
//           following, and are documented in comments preceeding each 
//           task:
//                   reset
//                   phy_addr
//
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
`timescale 1ns/100ps
module testharness (ANDIS_0, ANDIS_1, BGTRIM, DISABLE10, DISABLE100, 
           FIBSEL_0, FIBSEL_1, MDC, MDIO_IN, PHY_0, PHY_1, RESETN_0, 
           RESETN_1, SCANCLK_0, SCANCLK_1, SCAN_EN_0, SCAN_EN_1, SIDDQ, 
           SIDDQ_0, SIDDQ_1, TXD_0, TXD_1, TXEN_0, TXEN_1, TXER_0, TXER_1, 
           TX_AMP_TRIM_0, TX_AMP_TRIM_1, TX_SLP_TRIM_0, TX_SLP_TRIM_1, 
           XTAL25, B10_DIS_0, B10_DIS_1, B100_DIS_0, B100_DIS_1, COL_0, 
           COL_1, CRS_0, CRS_1, LEDC_0, LEDC_1, LEDD_0, LEDD_1, LEDL_0, 
           LEDL_1, LEDR_0, LEDR_1, LEDS_0, LEDS_1, LEDT_0, LEDT_1, MDINT_0, 
           MDINT_1, MDIO_OE_0, MDIO_OE_1, MDIO_OUT_0, MDIO_OUT_1, RXC_0, 
           RXC_1, RXDV_0, RXDV_1, RXD_0, RXD_1, RXER_0, RXER_1, TRISTATE_0, 
           TRISTATE_1, TXC_0, TXC_1);

parameter Clk2p5Period        = 400;		// 2.5Mhz Clock for 10BaseT
parameter Clk20Period	      = 50;		// 20Mhz Clock - Scan
parameter Clk25Period	      = 40;		// 25Mhz Clock
parameter ResetClocks	      = 5;		// reset = (5) 25MHz cycles 
parameter ResetRecoverClocks  = 5;		// reset = (5) 25MHz cycles 
parameter LedTimeout	      = 10000;
parameter IntTimeout	      = 10000;
parameter TimebombTimeout     = 2000000;	// 2ms timebomb 

// PLL Reference Crystal
output		XTAL25;				// Reference Crystal
// Programmable Register Ports
output	[4:0]	PHY_0, PHY_1;			// PHY Address
output		MDC;				// Clock
output		MDIO_IN;			// Input Data
input		MDIO_OE_0,  MDIO_OE_1;		// Port Direction Control
input		MDIO_OUT_0, MDIO_OUT_1;		// Output Data
input		MDINT_0, MDINT_1;		// Interrupts   
// Auto-Negotiation Ports
output		ANDIS_0, ANDIS_1;		// Auto-Negotiation Disable
// Enable-Disabling Ports
output		DISABLE10;			// Disable 10BaseT
output		DISABLE100;			// Disable 100Base-X
output		FIBSEL_0, FIBSEL_1;		// Use Fiber Mode
output		SIDDQ, SIDDQ_0, SIDDQ_1;	// IDDQ Mode
input		B10_DIS_0,  B10_DIS_1;		// 10BaseT Disable Indicator
input		B100_DIS_0, B100_DIS_1;		// 100Base-X Disable Indicator
input		TRISTATE_0, TRISTATE_1;		// Driver-Tristate Indicator
// Chip Reset Ports
output		RESETN_0, RESETN_1;		// Resets
input		CRS_0,  CRS_1;			// Carrier Sense
input	[4:0]	RXD_0,  RXD_1;			// Received Data
input		RXDV_0, RXDV_1;			// Data Valid Indicator
input		RXC_0,  RXC_1;			// Received Data Clock
input		RXER_0, RXER_1;			// Error Detected Indicator
output		TXER_0, TXER_1;			// Force Error
input		TXC_0,  TXC_1;			// Transmit Clock
output		TXEN_0, TXEN_1;			// Enable Data Transmission
output	[4:0]	TXD_0,  TXD_1;			// Transmit Data
input		COL_0,  COL_1;			// Colision Detect
// LED Indicator Ports
input		LEDS_0, LEDT_0, LEDL_0, LEDC_0,LEDR_0, LEDD_0;   
input		LEDS_1, LEDT_1, LEDL_1, LEDC_1,LEDR_1, LEDD_1;   
// SCAN Ports
output		SCAN_EN_0, SCAN_EN_1, SCANCLK_0, SCANCLK_1;
// Trim Ports
output	[3:0]	BGTRIM;				// Bandgap Trim
output	[1:0]	TX_AMP_TRIM_0, TX_AMP_TRIM_1;
output	[1:0]	TX_SLP_TRIM_0, TX_SLP_TRIM_1;

//--------------------------------------------------------------------------
// Output Signals
//--------------------------------------------------------------------------
wire       XTAL25;				// Reference Crystal
wire       MDC;					// Clock
wire       MDIO_IN;				// Input Data
wire       TXER_0, TXER_1;			// Force Error
wire       TXEN_0, TXEN_1;			// Enable Data Transmission
wire [4:0] TXD_0,  TXD_1;			// Transmit Data
wire       SCAN_EN_0, SCAN_EN_1, SCANCLK_0, SCANCLK_1;
reg  [4:0] PHY_0, PHY_1;			// PHY Address
reg        ANDIS_0, ANDIS_1;			// Auto-Negotiation Disable
reg        DISABLE10;				// Disable 10BaseT
reg        DISABLE100;				// Disable 100Base-X
reg        FIBSEL_0, FIBSEL_1;			// Use Fiber Mode
reg        SIDDQ, SIDDQ_0, SIDDQ_1;		// IDDQ Mode
reg        RESETN_0, RESETN_1;			// Resets
reg  [3:0] BGTRIM;				// Bandgap Trim
reg  [1:0] TX_AMP_TRIM_0, TX_AMP_TRIM_1;
reg  [1:0] TX_SLP_TRIM_0, TX_SLP_TRIM_1;

// Simulation Clocks and Controls
reg        sim_clk25;
reg        sim_clk20;
reg        sim_clk2p5;
reg  [1:0] DIS10_SEL;
reg  [1:0] DIS100_SEL;

// MDDIS function removed on atlas
wire	    MDDIS_0;
wire	    MDDIS_1;
   
//--------------------------------------------------------------------
// instantiate bus-functional interface packages 
//--------------------------------------------------------------------
xtal_pkg xtal ( .sim_clk25(sim_clk25), .XTAL25(XTAL25));
scan_pkg scan ( .sim_clk20(sim_clk20),
		.SCANCLK_0(SCANCLK_0), .SCAN_EN_0(SCAN_EN_0),
		.SCANCLK_1(SCANCLK_1), .SCAN_EN_1(SCAN_EN_1));
mi_pkg   mi   (	.sim_clk2p5(sim_clk2p5), .sim_clk25(sim_clk25),
		.MDIO_OE_0(MDIO_OE_0), .MDIO_OUT_0(MDIO_OUT_0),
		.MDIO_OE_1(MDIO_OE_1), .MDIO_OUT_1(MDIO_OUT_1), .MDC(MDC),
		.MDDIS_0(MDDIS_0), .MDDIS_1(MDDIS_1),.MDIO_IN(MDIO_IN));
mii_pkg  mii  (	.TXC_0(TXC_0), .TXEN_0(TXEN_0), .TXER_0(TXER_0), .TXD_0(TXD_0),
		.RXC_0(RXC_0), .RXDV_0(RXDV_0), .RXER_0(RXER_0), .RXD_0(RXD_0),
		.CRS_0(CRS_0), .COL_0(COL_0),
		.TXC_1(TXC_1), .TXEN_1(TXEN_1), .TXER_1(TXER_1), .TXD_1(TXD_1),
		.RXC_1(RXC_1), .RXDV_1(RXDV_1), .RXER_1(RXER_1), .RXD_1(RXD_1),
		.CRS_1(CRS_1), .COL_1(COL_1));

//--------------------------------------------------------------------
// initialize all testharness registers
//--------------------------------------------------------------------
initial begin

      // Port Initialization
      PHY_0         = 5'b00000;
      PHY_1         = 5'b00000;
      ANDIS_0       = 1'b0; 
      ANDIS_1       = 1'b0; 
      DISABLE10     = 1'b0;
      DISABLE100    = 1'b0;
      FIBSEL_0      = 1'b0; 
      FIBSEL_1      = 1'b0;
      SIDDQ         = 1'b0;  
      SIDDQ_0       = 1'b0;  
      SIDDQ_1       = 1'b0;  
      RESETN_0      = 1'b1;    
      RESETN_1      = 1'b1;    
      BGTRIM  	    = 4'h0;
      TX_AMP_TRIM_0 = 2'b00;  
      TX_AMP_TRIM_1 = 2'b00;  
      TX_SLP_TRIM_0 = 2'b00;  
      TX_SLP_TRIM_1 = 2'b00;  

      // Internal Clock and Control Initialization
      sim_clk2p5    = 1'b0;
      sim_clk25     = 1'b0;
      sim_clk20     = 1'b0;
      DIS10_SEL     = 2'b00;
      DIS100_SEL    = 2'b00;   

     #100;
     `ifdef SPEEDUP
        $display("Testharness: SPEED UP FLAG asserted");
     `else
        $display("Testharness: SPEED UP FLAG not asserted");
     `endif

end 

//--------------------------------------------------------------------
// timebomb to kill runaway simulations
//--------------------------------------------------------------------   
initial begin	  
      #(TimebombTimeout);
      $write("E: Timebomb - Runaway simulation\n");
      $finish;     
end

//--------------------------------------------------------------------
// simulation clock sources 
//--------------------------------------------------------------------
always begin
      #(Clk2p5Period/2.0) sim_clk2p5 = 1'b0;
      #(Clk2p5Period/2.0) sim_clk2p5 = 1'b1;
end

always begin
      #(Clk25Period/2.0) sim_clk25 = 1'b0;
      #(Clk25Period/2.0) sim_clk25 = 1'b1;
end

always begin
      #(Clk20Period/2.0) sim_clk20 = 1'b0;
      #(Clk20Period/2.0) sim_clk20 = 1'b1;
end

//--------------------------------------------------------------------
// global reset task
//
//     reset(port_num)  	   
//				 where  port_num is a single bit from
//					  the testbench selecting 
//					  which bus to drive
//
// reset duration ResetClocks*XTAL25 periods (40ns) 
// recovery duration ResetRecoverClocks*XTAL25 periods
//--------------------------------------------------------------------
task reset;
   input port_num;
   reg   in_use;
   integer i;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to reset was reentrant\n");
     	 $finish;
      end 
      in_use = 1'b1;

      // initiate on falling edge of sim_clk25
      @(negedge sim_clk25);
      $display("Testharness: Start Reset Sequence\n");
      RESETN_1 = 1'b0;
      RESETN_0 = 1'b0;

      // count ResetClocks cycles and disable
      repeat (ResetClocks) @(negedge sim_clk25);
      RESETN_1 = 1'b1; 
      RESETN_0 = 1'b1;
      $display("Testharness: End Reset Sequence: RESET = ",RESETN_1,"\n");

      // count ResetRecoverClocks cycles and exit
      repeat (ResetRecoverClocks) @(negedge sim_clk25);

      in_use = 1'b0;

   end
      
endtask // reset

//--------------------------------------------------------------------
// bandgap trim task
//
//     bg_trim(data)		 where  data is the 4 bit trim data
//					  from the testbench to be
//					  applied to the BGTRIM<3:0>  
//--------------------------------------------------------------------
task bg_trim;
   input [3:0] data;

   reg in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to bg_trim was reentrant\n");
     	 $finish;
      end 
      in_use = 1'b1;

      // initiate on falling edge of sim_clk25
      @(negedge sim_clk25);
      
      BGTRIM[3:0] <= data;

      @(negedge sim_clk25); 
      in_use = 1'b0;
   end
      
endtask // bg_trim

//--------------------------------------------------------------------
// siddq task
//
//     iddq(port_num, go)	 where  port_num is a single bit from
//					  the testbench selecting 
//					  which SIDDQ to drive
//					  port_num = 1'bX  SIDDQ only
//					  port_num = 1'b0  SIDDQ_0 only
//					  port_num = 1'b1  SIDDQ_1 only 
//					  port_num = 1'bZ  all three
//					go is SIDDQ(_x) enable from the 
//					  testbench 
//					  go = 1'b0  SIDDQ inactive 
//					  go = 1'b1  SIDDQ active  
//--------------------------------------------------------------------
task iddq;
   input port_num;
   input go;

   reg   in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to iddq was reentrant\n");
     	 $finish;
      end 
      in_use = 1'b1;

      // initiate on falling edge of sim_clk25
      @(negedge sim_clk25);
      
      case (port_num)
	 1'bX: SIDDQ   <= go;
	 1'b0: SIDDQ_0 <= go;
	 1'b1: SIDDQ_1 <= go;
	 1'bZ: begin
		  SIDDQ   <= go;
		  SIDDQ_0 <= go;
		  SIDDQ_1 <= go;
	       end
      endcase

      @(negedge sim_clk25); 
      in_use = 1'b0;
   end
      
endtask // iddq

//--------------------------------------------------------------------
// disable pll task
//
//     pll_disable(tenbt, go)	where  tebt from the testbench selects
//					  which disable to move 
//					  tenbt = 1'b0  move DISABLE100 
//					  tenbt = 1'b1  move DISABLE10 
//				       go is enable from the testbench 
//					  go = 1'b0  disable inactive 
//					  go = 1'b1  disable active
//					  go = 1'bZ  disable follows 
//						     'and' of B10/100_DIS 
//						      signals from phys  
//--------------------------------------------------------------------
task pll_disable;
   input tenbt;
   input go;

   reg   in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to pll_disable was reentrant\n");
     	 $finish;
      end 
      in_use = 1'b1;

      // initiate on falling edge of sim_clk25
      @(negedge sim_clk25);

      // move specified disable signal
      if (tenbt)
	 if (go === 1'b0)
	    DIS10_SEL <= 2'b00;
     	 else if (go === 1'b1)
	    DIS10_SEL <= 2'b01;
     	 else if (go === 1'bZ)
	    DIS10_SEL <= 2'b10; 
	 else DIS10_SEL <= 2'b11;	       
      else 
	 if (go === 1'b0)
	    DIS100_SEL <= 2'b00;
     	 else if (go === 1'b1)
	    DIS100_SEL <= 2'b01;
     	 else if (go === 1'bZ)
	    DIS100_SEL <= 2'b10; 
	 else
	    DIS100_SEL <= 2'b11;       

      @(negedge sim_clk25); 
      in_use = 1'b0;

   end
      
endtask // pll_disable

// B10/100_DIS to disable muxes 
always @(DIS10_SEL or B10_DIS_0 or B10_DIS_1)
   case(DIS10_SEL)
     2'b00 :   DISABLE10 <= 1'b0;
     2'b01 :   DISABLE10 <= 1'b1;
     2'b10 :   DISABLE10 <= B10_DIS_0 & B10_DIS_1;		     
     default : DISABLE10 <= 1'b0;
   endcase 

always @(DIS100_SEL or B100_DIS_0 or B100_DIS_1)
   case(DIS100_SEL)
     2'b00 :   DISABLE100 <= 1'b0;
     2'b01 :   DISABLE100 <= 1'b1;
     2'b10 :   DISABLE100 <= B100_DIS_0 & B100_DIS_1;		
     default : DISABLE100 <= 1'b0;
   endcase   
//   begin 
//                    if (B100_DIS_0 ===  1'bX | B100_DIS_0 ===  1'bZ |
//		        B100_DIS_1 ===  1'bX | B100_DIS_1 ===  1'bZ)
 //                     DISABLE100 <= 1'b0;
//	            else
		   

//--------------------------------------------------------------------
// transmitter trims task
//
//     tx_trim(port_num, amp_trim, data)	     
//				 where  port_num is a single bit from
//					  the testbench selecting 
//					  which bus to drive
//					amp_trim is a single bit from
//					  the testbench selecting 
//					  which trim bus to drive
//					  amp_trim = 1'b0  slope selected 
//					  amp_trim = 1'b1  amp selected  
//					data is the 2 bit trim data
//					  from the testbench to be
//					  applied to PHYs  
//--------------------------------------------------------------------
task tx_trim;
   input       port_num;
   input       amp_trim;
   input [1:0] data;

   reg in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to tx_trim was reentrant\n");
     	 $finish;
      end 
      in_use = 1'b1;

      // initiate on falling edge of sim_clk25
      @(negedge sim_clk25);
      
      if (port_num)
	 if (amp_trim)
	    TX_AMP_TRIM_1[1:0] <= data;
	 else
	    TX_SLP_TRIM_1[1:0] <= data;
      else
	 if (amp_trim)
	    TX_AMP_TRIM_0[1:0] <= data;
	 else
	    TX_SLP_TRIM_0[1:0] <= data;

      @(negedge sim_clk25); 
      in_use = 1'b0;
   end
      
endtask // tx_trim

//--------------------------------------------------------------------
// fiber select task
//
//     fiber(port_num, go)	       
//				 where  port_num is a single bit from
//					  the testbench selecting 
//					  which bus to drive
//					go is enable from the testbench 
//					  go = 1'b0  copper inactive 
//					  go = 1'b1  fiber  active  
//--------------------------------------------------------------------
task fiber;
   input       port_num;
   input       go;

   reg in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to fiber was reentrant\n");
     	 $finish;
      end 
      in_use = 1'b1;

      // initiate on falling edge of sim_clk25
      @(negedge sim_clk25);
      
      if (port_num)
	 FIBSEL_1 <= go;

      else
	 FIBSEL_0 <= go;

      @(negedge sim_clk25); 
      in_use = 1'b0;
   end
      
endtask // fiber

//--------------------------------------------------------------------
//  disable autonegotiate task
//
//     disable_an(port_num, go) 	    
//				 where  port_num is a single bit from
//					  the testbench selecting 
//					  which PHY to disable
//					go is enable from the testbench 
//					  go = 1'b0  autonegotiate on 
//					  go = 1'b1  autonegotiate off  
//--------------------------------------------------------------------
task disable_an;
   input       port_num;
   input       go;

   reg in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to disable_an was reentrant\n");
     	 $finish;
      end 
      in_use = 1'b1;

      // initiate on falling edge of sim_clk25
      @(negedge sim_clk25);
      
      if (port_num)
	 ANDIS_1 <= go;

      else
	 ANDIS_0 <= go;

      @(negedge sim_clk25); 
      in_use = 1'b0;
   end
      
endtask // disable_an	

//--------------------------------------------------------------------
// phyical address task
//
//     phy_addr(port_num, addr)   where port_num is a single bit from
//					  the testbench selecting 
//					  which bus to drive
//					addr is the 5 bit address from
//					  the testbench to be assigned
//					  to the PHY_<port_num> bus  
//--------------------------------------------------------------------
task phy_addr;
   input       port_num;
   input [4:0] addr;

   reg in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to phy_addr was reentrant\n");
     	 $finish;
      end 
      in_use = 1'b1;

      // initiate on falling edge of sim_clk25
      @(negedge sim_clk25);
      
      // load address to specified port
      if (port_num)
	 PHY_1[4:0] <= addr;
      else
	 PHY_0[4:0] <= addr;


      @(negedge sim_clk25); 
      in_use = 1'b0;
   end
      
endtask // phy_addr
	 
//--------------------------------------------------------------------
// LEDT check task
//
//     check_ledt(port_num)		
//				 where  port_num is a single bit from
//					  the testbench selecting 
//
//--------------------------------------------------------------------
task check_ledt;
   input  port_num;

   reg in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to check_ledt was reentrant\n");
     	 $finish;
      end 
      in_use	  = 1'b1;
      
      if (port_num) begin
     	 fork: wait_for_ledt_1
	    begin
	       while (LEDT_1 !== 1'b0) @(negedge TXC_1);
	       @(negedge TXC_1);
	       disable wait_for_ledt_1;
	    end

     	    begin
	       #(LedTimeout);
     	       $write("E: Wathdog timeout on check_ledt: at %0d ns\n", $time);
     	       disable wait_for_ledt_1;
     	    end
     	 join
      end

      else begin
     	 fork: wait_for_ledt_0
	    begin
	       while (LEDT_0 !== 1'b0) @(negedge TXC_0);
	       @(negedge TXC_0);
	       disable wait_for_ledt_0;
	    end

     	    begin
	       #(LedTimeout);
     	       $write("E: Wathdog timeout on check_ledt: at %0d ns\n", $time);
     	       disable wait_for_ledt_0;
     	    end
     	 join
      end

      in_use = 1'b0;
   end
      
endtask // check_ledt


//--------------------------------------------------------------------
// LEDR check task
//
//     check_ledr(port_num)		
//				 where  port_num is a single bit from
//					  the testbench selecting 
//
//--------------------------------------------------------------------
task check_ledr;
   input  port_num;

   reg in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to check_ledr was reentrant\n");
     	 $finish;
      end 
      in_use	  = 1'b1;
      
      if (port_num) begin
     	 fork: wait_for_ledr_1
	    begin
	       while (LEDR_1 !== 1'b0) @(negedge RXC_1);
	       @(negedge RXC_1);
	       disable wait_for_ledr_1;
	    end

     	    begin
	       #(LedTimeout);
     	       $write("E: Wathdog timeout on check_ledr: at %0d ns\n", $time);
     	       disable wait_for_ledr_1;
     	    end
     	 join
      end

      else begin
     	 fork: wait_for_ledr_0
	    begin
	       while (LEDR_0 !== 1'b0) @(negedge RXC_0);
	       @(negedge RXC_0);
	       disable wait_for_ledr_0;
	    end

     	    begin
	       #(LedTimeout);
     	       $write("E: Wathdog timeout on check_ledr: at %0d ns\n", $time);
     	       disable wait_for_ledr_0;
     	    end
     	 join
      end

      in_use = 1'b0;
   end
      
endtask // check_ledr


//--------------------------------------------------------------------
// LEDC check task
//
//     check_ledc(port_num)		
//				 where  port_num is a single bit from
//					  the testbench selecting 
//
//--------------------------------------------------------------------
task check_ledc;
   input  port_num;

   reg in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to check_ledc was reentrant\n");
     	 $finish;
      end 
      in_use	  = 1'b1;
      
      if (port_num) begin
     	 fork: wait_for_ledc_1
	    begin
	       while (LEDC_1 !== 1'b0) @(negedge RXC_1);
	       @(negedge RXC_1);
	       disable wait_for_ledc_1;
	    end

     	    begin
	       #(LedTimeout);
     	       $write("E: Wathdog timeout on check_ledc: at %0d ns\n", $time);
     	       disable wait_for_ledc_1;
     	    end
     	 join
      end

      else begin
     	 fork: wait_for_ledc_0
	    begin
	       while (LEDC_0 !== 1'b0) @(negedge RXC_0);
	       @(negedge RXC_0);
	       disable wait_for_ledc_0;
	    end

     	    begin
	       #(LedTimeout);
     	       $write("E: Wathdog timeout on check_ledc: at %0d ns\n", $time);
     	       disable wait_for_ledc_0;
     	    end
     	 join
      end

      in_use = 1'b0;
   end
      
endtask // check_ledc

//--------------------------------------------------------------------
// LEDC check task
//
//     check_mdint(port_num)		 
//				 where  port_num is a single bit from
//					  the testbench selecting 
//
//--------------------------------------------------------------------
task check_mdint;
   input  port_num;

   reg in_use;

   begin
      // check non-reentrant task guard semaphore
      if (in_use === 1'b1) begin
     	 $display("E: Call to check_mdint was reentrant\n");
     	 $finish;
      end 
      in_use	  = 1'b1;
      
      if (port_num) begin
     	 fork: wait_for_mdint_1
	    begin
	       while (MDINT_1 !== 1'b1) @(negedge sim_clk25);
	       @(negedge sim_clk25);
	       disable wait_for_mdint_1;
	    end

     	    begin
	       #(IntTimeout);
     	       $write("E: Wathdog timeout on check_mdint: at %0d ns\n", $time);
     	       disable wait_for_mdint_1;
     	    end
     	 join
      end

      else begin
     	 fork: wait_for_mdint_0
	    begin
	       while (MDINT_0 !== 1'b1) @(negedge sim_clk25);
	       @(negedge sim_clk25);
	       disable wait_for_mdint_0;
	    end

     	    begin
	       #(IntTimeout);
     	       $write("E: Wathdog timeout on check_mdint: at %0d ns\n", $time);
     	       disable wait_for_mdint_0;
     	    end
     	 join
      end

      in_use = 1'b0;
   end
      
endtask // check_mdint   

endmodule

