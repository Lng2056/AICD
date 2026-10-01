//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
// Title   :	testcase
//
// Notes   :	This module tests the 10/100 PHY.
//		Tests:
//		1. Read/Write MI Interface Registers
//		2. Transmit without Errors (loop data back externally).
//		3. Transmit for long time = FIFO check.
//		4. Transmit with error
//
// Make sure to use the -define SPEEDUP (or +define+SPEEDUP) to limit the
// simulation time.
//
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
`timescale 1ns/1ns
module testcase (BGTRIM, SIDDQ, XTAL25, DISABLE10, DISABLE100, SCANCLK_0, 
           SCAN_EN_0, TX_AMP_TRIM_0, TX_SLP_TRIM_0, B10_DIS_0, B100_DIS_0, 
           TRISTATE_0, CRS_0, RXD_0, RXDV_0, RXC_0, RXER_0, TXER_0, TXC_0, 
           TXEN_0, TXD_0, COL_0, FIBSEL_0, ANDIS_0, MDIO_IN, MDIO_OE_0, 
           MDIO_OUT_0, MDC, MDINT_0, PHY_0, RESETN_0, SIDDQ_0, LEDS_0, 
           LEDT_0, LEDL_0, LEDC_0, LEDR_0, LEDD_0, SCANCLK_1, SCAN_EN_1, 
           TX_AMP_TRIM_1, TX_SLP_TRIM_1, B10_DIS_1, B100_DIS_1, TRISTATE_1, 
           CRS_1, RXD_1, RXDV_1, RXC_1, RXER_1, TXER_1, TXC_1, TXEN_1, 
           TXD_1, COL_1, FIBSEL_1, ANDIS_1, MDIO_OE_1, MDIO_OUT_1, MDINT_1, 
           PHY_1, RESETN_1, SIDDQ_1, LEDS_1, LEDT_1, LEDL_1, LEDC_1, 
           LEDR_1, LEDD_1);

// Port Control Signals
output		XTAL25;				// PLL External Reference Clock
output		DISABLE10, DISABLE100;		// 10BaseT and 100BaseX Disable
output		SCANCLK_0, SCANCLK_1;		// Scan Test Clock
output		SCAN_EN_0, SCAN_EN_1;		// Scan Test Enable
output		TXER_0, TXER_1;			// Transmit Error Indicator
output		TXEN_0, TXEN_1;			// Transmit Data Indicator
output	[4:0]	TXD_0, TXD_1;			// Transmit Data
output		FIBSEL_0, FIBSEL_1;		// Fiber Select
output		ANDIS_0, ANDIS_1;		// Auto-Negotiation Disable
output		MDIO_IN;			// MI Input Data
output		MDC;				// MI Serial Interface Clock
output	[4:0]	PHY_0, PHY_1;			// PHY Address
output		RESETN_0, RESETN_1;		// Reset 
output		SIDDQ, SIDDQ_0, SIDDQ_1;	// IDDQ Test Indicators
output	[3:0]	BGTRIM;				// Bandgap Trim
output	[1:0]	TX_AMP_TRIM_0, TX_AMP_TRIM_1;	// Drive Amplitude Trim
output	[1:0]	TX_SLP_TRIM_0, TX_SLP_TRIM_1;	// Drive Slope Trim

// Output from Each port
input [4:0] RXD_0;
input B10_DIS_0, B100_DIS_0, TRISTATE_0, CRS_0, RXDV_0, RXC_0, RXER_0,
      TXC_0, COL_0, MDIO_OE_0, MDIO_OUT_0, MDINT_0,
      LEDS_0, LEDT_0, LEDL_0, LEDC_0, LEDR_0, LEDD_0;
input [4:0] RXD_1;
input B10_DIS_1, B100_DIS_1, TRISTATE_1, CRS_1, RXDV_1, RXC_1, RXER_1,
      TXC_1, COL_1, MDIO_OE_1, MDIO_OUT_1, MDINT_1,
      LEDS_1, LEDT_1, LEDL_1, LEDC_1, LEDR_1, LEDD_1;

//--------------------------------------------------------------------
// testharness instantiation
//--------------------------------------------------------------------
testharness th ( .ANDIS_0(ANDIS_0), .ANDIS_1(ANDIS_1), .BGTRIM(BGTRIM),
		.DISABLE10(DISABLE10), .DISABLE100(DISABLE100),
		.FIBSEL_0(FIBSEL_0), .FIBSEL_1(FIBSEL_1),
		.MDC(MDC), .MDIO_IN(MDIO_IN), .PHY_0(PHY_0), .PHY_1(PHY_1),
		.RESETN_0(RESETN_0), .RESETN_1(RESETN_1),
		.SCANCLK_0(SCANCLK_0), .SCANCLK_1(SCANCLK_1),
		.SCAN_EN_0(SCAN_EN_0), .SCAN_EN_1(SCAN_EN_1),
		.SIDDQ(SIDDQ), .SIDDQ_0(SIDDQ_0), .SIDDQ_1(SIDDQ_1),
		.TXD_0(TXD_0), .TXD_1(TXD_1), .TXEN_0(TXEN_0), .TXEN_1(TXEN_1),
		.TXER_0(TXER_0), .TXER_1(TXER_1),
		.TX_AMP_TRIM_0(TX_AMP_TRIM_0), .TX_AMP_TRIM_1(TX_AMP_TRIM_1),
		.TX_SLP_TRIM_0(TX_SLP_TRIM_0), .TX_SLP_TRIM_1(TX_SLP_TRIM_1),
		.XTAL25(XTAL25), .B10_DIS_0(B10_DIS_0), .B10_DIS_1(B10_DIS_1),
		.B100_DIS_0(B100_DIS_0), .B100_DIS_1(B100_DIS_1),
		.COL_0(COL_0), .COL_1(COL_1), .CRS_0(CRS_0), .CRS_1(CRS_1),
		.LEDC_0(LEDC_0), .LEDC_1(LEDC_1),
		.LEDD_0(LEDD_0), .LEDD_1(LEDD_1),
		.LEDL_0(LEDL_0), .LEDL_1(LEDL_1),
		.LEDR_0(LEDR_0), .LEDR_1(LEDR_1),
		.LEDS_0(LEDS_0), .LEDS_1(LEDS_1),
		.LEDT_0(LEDT_0), .LEDT_1(LEDT_1),
		.MDINT_0(MDINT_0), .MDINT_1(MDINT_1),
		.MDIO_OE_0(MDIO_OE_0), .MDIO_OE_1(MDIO_OE_1),
		.MDIO_OUT_0(MDIO_OUT_0), .MDIO_OUT_1(MDIO_OUT_1),
		.RXC_0(RXC_0), .RXC_1(RXC_1), .RXDV_0(RXDV_0), .RXDV_1(RXDV_1),
		.RXD_0(RXD_0), .RXD_1(RXD_1), .RXER_0(RXER_0), .RXER_1(RXER_1),
		.TRISTATE_0(TRISTATE_0), .TRISTATE_1(TRISTATE_1),
		.TXC_0(TXC_0), .TXC_1(TXC_1) );

//--------------------------------------------------------------------
// Internal registers
//--------------------------------------------------------------------
reg	   mdcfast;			// Use Fast clock (25MHz) for MDC
reg	   go_clk;			// Start stop clock indicator
reg [15:0] mi_reg;			// register data from MI interface
reg	   tx_crs;			// TX CRS
reg	   rcv_rxer;			// Received RX_ER
reg	   rcv_col;			// Received COL
reg	   rcv_crs;			// Received COL
reg	   fifo_ok;			// Fifo Status Indicator
reg  [4:0] phy0_addr;			// PHY 0 address
reg  [4:0] phy1_addr;			// PHY 1 address
reg  [4:0] reg_addr;			// register address
reg	   pre_sup;			// Suppress Preamble in MI 
//--------------------------------------------------------------------
// Run Testbench
//--------------------------------------------------------------------
initial begin : test_procedure
  phy0_addr = 5'b01010;
  phy1_addr = 5'b11111;
  $display("Testcase: Setting PHY Address \n");
  th.phy_addr(1'b0, phy0_addr);  	     // set port 0 physical addr
  $display("Testcase: Enable The Macro \n");
  th.xtal.enable(1'b1); 		     // enable crystal clock 
  $display("Testcase: Reset the Macro \n");
  th.reset(1'bZ);			     // perform port 0 and 1 reset

  //--------------------------------------------------------------------
  // Wait for Hard Reset to complete 
  //--------------------------------------------------------------------
  `ifdef SPEEDUP
	$display("Testcase: Waiting 500ns for hard reset to complete \n");
	#500;				// Wait for SPEEDUP timer to complete
  `else
	$display("Testcase: Waiting 320us for hard reset to complete \n");
	#320000;
  `endif
  $display("Testcase: Hard Reset Complete \n");

  //--------------------------------------------------------------------------
  // checking initial conditions: LED's
  //--------------------------------------------------------------------------
  $display("Testcase: Checking LED's \n");
  if (LEDS_0)  $write("E: Expected LEDS_0 initially active: %0d ns\n", $time);
  if (!LEDT_0) $write("E: Expected LEDT_0 initially inactive: %0d ns\n", $time);
  if (!LEDL_0) $write("E: Expected LEDL_0 initially inactive: %0d ns\n", $time);
  if (!LEDC_0) $write("E: Expected LEDC_0 initially inactive: %0d ns\n", $time);
  if (LEDD_0)  $write("E: Expected LEDD_0 initially active: %0d ns\n", $time);
  if (!LEDR_0) $write("E: Expected LEDR_0 initially inactive: %0d ns\n", $time);
  $display("Testcase: Done Checking LED's \n");

  //--------------------------------------------------------------------------
  // a. checking initial conditions: MI Registers
  //--------------------------------------------------------------------------
  $display("Testcase: Checking the MI Registers \n");
  pre_sup  = 1'b1;				// Supress Preamble

  // Start the MI clock (MDC)
  mdcfast = 1'b1;				// Use 25MHz Clock
  go_clk  = 1'b1;				// Start the clock
  th.mi.clock(mdcfast, go_clk);			// start MDC      

  //--------------------------------------------------------------------------
  // Check Control Register 0
  // Reg0[15:12] = {!RESET_DONE, DIG_LOOP_BACK_ENAB, 100MBS, AN_ENAB}
  // Reg0[11:8]  = {POWER_DOWN, ISOLATE_TX, AN_RESTART, FULL_DUPLEX}
  // Reg0[ 7:0]  = { COL_TEST, 7'b0}
  //--------------------------------------------------------------------------
  $display("Testcase: Checking Register 0 \n");
  reg_addr = 5'd00;				// Register 0 = Control Register
  th.mi.read(phy0_addr, pre_sup, reg_addr, mi_reg); // read control register
 
  if (mi_reg != 16'h2100)  
    $write("E: Expecting Reg0 = 16'h2100; Actual Value = %h \n", mi_reg);

  //--------------------------------------------------------------------------
  // Check Status Register 1
  // Reg1[15:4] = {10'b0111_1000_01,AN_COMPLETE,Remote_Fault}
  // Reg1[3:0]  = {1'b1, Link_Status, Jabber_Status, 1'b1}
  //--------------------------------------------------------------------------
  $display("Testcase: Checking Register 1 \n");
  reg_addr = 5'd01;				// Register 1 = Status Register
  th.mi.read(phy0_addr, pre_sup, reg_addr, mi_reg); // read status register

  if (mi_reg != 16'h7849)  
    $write("E: Expecting Reg1 = 16'h7849; Actual Value = %h \n", mi_reg);

  //--------------------------------------------------------------------------
  // Check Proprietary Status Register 17
  // Reg17[15:12] = {1'b0,link_down,Full Duplex,100MBS}
  // Reg17[11:8]  = {1'b0,AN_COMPLETE, AN_EXP[1],int_no_common_mode}
  // Reg17[7:0]   = {1'b0, MDIX, POL_REVERSED, 5'b0}
  //--------------------------------------------------------------------------
  $display("Testcase: Checking Register 17 \n");
  reg_addr = 5'd17;				// Register 17= Proprietary
  th.mi.read(phy0_addr, pre_sup, reg_addr, mi_reg); // read proprietary status
  if (mi_reg != 16'h7100)  
    $write("E: Expecting Reg17 = 16'h7100; Actual Value = %h \n", mi_reg);

  //--------------------------------------------------------------------------
  // Disable unneeded clocks
  //--------------------------------------------------------------------------
  th.pll_disable(1'b1,1'b1);			// no longer require pll160 

  //--------------------------------------------------------------------------
  // Write To Proprietary Control Register 18
  // Reg18[15:12] = {1'b0,FarEndFault Disable, MII_LoopBack_DISB,MDIX_DISB}
  // Reg18[11:8]  = {MDIX_FORCE, JABBER_EN, LINK_TEST_DISB, POL_CORR_DISB}
  // Reg18[7:4]   = {ALIGN_DISB,SYMBOL_MODE,BYPASS_SCRAM, TP_DISC}
  // Reg18[3:0]   = {RXTX_TEST, 3'b000}
  //--------------------------------------------------------------------------
  $display("Testcase: Writing Register 18 \n");
  reg_addr = 5'd18;				// Register 18= Proprietary
  mi_reg = 16'h2208;				//  
  th.mi.write(phy0_addr, pre_sup, reg_addr, mi_reg);//write proprietary control

  //--------------------------------------------------------------------------
  // Write Register 23 to Avoid Receive Channel Error Reset
  // Reg23[15:11] = MR_ERR_THRESH
  // Reg23[10:1]  = MR_ERR_TIMER
  // Reg23[0]     = MR_MSE_NORESET
  //--------------------------------------------------------------------------
  $display("Testcase: Writing Register 23 \n");
  reg_addr = 5'd23;				// Register 23= Proprietary
  mi_reg = 16'h0001;				//  
  th.mi.write(phy0_addr, pre_sup, reg_addr, mi_reg);//write proprietary control

  //--------------------------------------------------------------------------
  // Write To  Register 29
  //--------------------------------------------------------------------------
  $display("Testcase: Writing Register 29 \n");
  reg_addr = 5'd29;				// Register 16= Proprietary
  mi_reg = 16'h7240;				//  
  th.mi.write(phy0_addr, pre_sup, reg_addr, mi_reg);//write proprietary control

  //--------------------------------------------------------------------------
  // Set Mode = 100TX Full Duplex by writing Control Register 0
  //--------------------------------------------------------------------------
  $display("Testcase: Setting 100Base-TX Full Duplex Mode \n");
  reg_addr = 5'b00000;				// Register 0 = Control Register
  mi_reg = 16'h2100;				// 100MBS Full Duplex
  th.mi.write(phy0_addr, pre_sup, reg_addr, mi_reg); // write control register

  //--------------------------------------------------------------------------
  // Done with MI Interface - Stop the clock
  //--------------------------------------------------------------------------
  go_clk  = 1'b0;				// Start the clock
  th.mi.clock(mdcfast, go_clk);			// Stop MDC      
  $display("Testcase: Done with MI Registers \n");
  
  //--------------------------------------------------------------------------
  // Wait for Data to be stable before TX to RX tests
  //--------------------------------------------------------------------------
  `ifdef SPEEDUP
     $display("Testcase: SPEEDUP Wait = 20us \n");
     #20000;  // Wait 1us
     $display("Testcase: Completed SPEEDUP Wait = 20us \n");
  `else 
     $display("Testcase: Start First Long Wait = 63us \n");
     #(1050*60);
     $display("Testcase: Completed First Long Wait = 63us \n");

    $display("Testcase: Start Second Long Wait = 300us \n");
    #(300000);
    $display("Testcase: Completed Second Long Wait = 300us \n");
  `endif  

  //--------------------------------------------------------------------------
  // Test a. Start Transmitting data
  //--------------------------------------------------------------------------
  $write("Testcase: Starting Data Transmission at time:  %0d ns\n",$time);
  $write("Testcase: Test a:  %0d ns\n",$time);

  th.mii.check_fifo(fifo_ok);			// flush fifo  	     
  th.mii.get_clock_period;			// sample clock periods

  $display("Testcase: Starting first Transmission \n");
  fork
        	       // port0, tx100, nibbles, random, w/o error insertion
    th.mii.transmit(1'b0, 1'b0, 128, 1'b1, 1'b0, 2'b00, tx_crs); 
    th.mii.receive(1'b0, 1'b0, 2'b00, rcv_rxer, rcv_col, rcv_crs);
  join 

  $display("Testcase: Completed first Transmission - Verifying results \n");
  if (!rcv_crs)
      $write("E: Expected CRS_0 activation/deactivation: %0d ns\n", $time);
  if (rcv_rxer) $write("E: Unexpected RXER_0: %0d ns\n", $time);
  if (rcv_col) $write("E: Unexpected COL_0 : %0d ns\n", $time);

  th.mii.check_fifo(fifo_ok);
  if (!fifo_ok)      
   $write("E: Mii_pkg fifo was unexpectedly out of sync: %0d ns\n", $time);
  `ifdef SPEEDUP
	#(3000);			// Wait 3us
  `else
	#(30000);			//wait 30us
  `endif
  //---------------------------------------------------------------------------
  // Test a1, long transmission, 4-bit, w/o errors
  //---------------------------------------------------------------------------
  $write("Testcase: Starting EXT_LPBK :  %0d ns\n",$time);
  $write("Testcase: Test a1:  %0d ns\n",$time);

  th.mii.check_fifo(fifo_ok);  	      // flush fifo		  
  th.mii.get_clock_period;		      // sample clock periods

  $display("Testcase: Starting Long Transmission \n");
  fork
    //  th.check_RXDV(1'b0);
    th.check_ledt(1'b0);
    th.check_ledr(1'b0);	    
    th.mii.transmit(1'b0, 1'b0, 1518, 1'b1, 1'b0, 2'b00, tx_crs); 
    		   // port0, tx100, random, w/o error insertion
    th.mii.receive(1'b0, 1'b0, 2'b00, rcv_rxer, rcv_col, rcv_crs);
  join 

  $display("Testcase: Completed Long Transmission - Verifying results\n");
  if (!rcv_crs)
     $write("E: Expected CRS_0 activation/deactivation : %0d ns\n", $time);
  if (rcv_rxer) $write("E: Unexpected RXER_0 :  %0d ns\n", $time);
  if (rcv_col) $write("E: Unexpected COL_0 : %0d ns\n", $time); 

  th.mii.check_fifo(fifo_ok);
  if (!fifo_ok)      
     $write("E: Mii_pkg fifo was unexpectedly out of sync :  %0d ns\n", $time);
  `ifdef SPEEDUP
	#(3000);			// Wait 3us
  `else
	#(30000);			//wait 30us
  `endif
  //--------------------------------------------------------------------------
  // Test b, 4-bit with error
  //--------------------------------------------------------------------------
  $write("Testcase: Test b:  %0d ns\n",$time);

  $display("Testcase: Starting Transmission with Error\n");
  fork
    // th.check_RXDV(1'b0);
    th.check_ledt(1'b0);
    th.check_ledr(1'b0);
    th.mii.transmit(1'b0, 1'b0, 15, 1'b1, 1'b1, 2'b00, tx_crs); 
    		       // port0, tx100, random, w/error insertion
    th.mii.receive(1'b0, 1'b0, 2'b00, rcv_rxer, rcv_col, rcv_crs); 
  join
  
  $display("Testcase: Completed Transmission with Error - Verifying results\n");
  if (!rcv_crs)
     $write("E: Expected CRS_0 activation/deactivation : %0d ns\n", $time);
  if (!rcv_rxer) $write("E: Expected RXER_0 : %0d ns\n", $time);	 
  if (rcv_col) $write("E: Unexpected COL_0 : %0d ns\n", $time);   

  th.mii.check_fifo(fifo_ok);
  if (!fifo_ok)      
     $write("E: Mii_pkg fifo was unexpectedly out of sync :  %0d ns\n", $time);
  `ifdef SPEEDUP
	#(3000);			// Wait 3us
  `else
	#(30000);			//wait 30us
  `endif
  //--------------------------------------------------------------------------
  // Shutting down
  //--------------------------------------------------------------------------
  th.xtal.enable(1'b0); 		     // stop crystal clock
  #10;
  $write("Simulation concluded\n");
  $finish;

end

endmodule
