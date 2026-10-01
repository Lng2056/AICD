//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
// Title   :  testcase
// Project :  umc18a01
// Author  :  dshelton
//
// Notes   :  this module is the top-level simulation driver.
//
//            This module instantiates the testharness module and controls
//            it's bus-functional tasks through hierarchical task calls, 
//            e.g., 'th.mi.read(addr, data);' would be the call to 
//            read an mi register through the testharness (th). Below 
//            is a diagram of the basic teststructure
//
//
//  +--------------------------------------------------------------------+
//  | top-level schematic                                                |
//  |                                                                    |
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
//  |                                  |        (umc18a01)          |    |
//  |                                  +----------------------------+    |
//  |                                                                    |
//  |                                                                    |
//  +--------------------------------------------------------------------+
//
//
//
// 
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
`timescale 1ns/10ps

module testcase (
   BGTRIM,
   SIDDQ,
   XTAL25,
   DISABLE10,
   DISABLE100,
   SCANCLK_0,
   SCAN_EN_0,
   TX_AMP_TRIM_0,
   TX_SLP_TRIM_0,
   B10_DIS_0,
   B100_DIS_0,
   TRISTATE_0,		 
   CRS_0,
   RXD_0,
   RXDV_0,
   RXC_0,
   RXER_0,
   TXER_0,
   TXC_0,
   TXEN_0,
   TXD_0,
   COL_0,
   FIBSEL_0,
   ANDIS_0,
   MDIO_IN,
   MDIO_OE_0,
   MDIO_OUT_0,	 
   MDC,
   MDINT_0,
   PHY_0,
   RESETN_0,
   SIDDQ_0,
   LEDS_0,
   LEDT_0,
   LEDL_0,
   LEDC_0,
   LEDR_0,
   LEDD_0,		 
   SCANCLK_1,
   SCAN_EN_1,
   TX_AMP_TRIM_1,
   TX_SLP_TRIM_1,
   B10_DIS_1,
   B100_DIS_1,
   TRISTATE_1,			 
   CRS_1,
   RXD_1,
   RXDV_1,
   RXC_1,
   RXER_1,
   TXER_1,
   TXC_1,
   TXEN_1,
   TXD_1,
   COL_1,
   FIBSEL_1,
   ANDIS_1,
   MDIO_OE_1,
   MDIO_OUT_1,
   MDINT_1,
   PHY_1,
   RESETN_1,
   SIDDQ_1,
   LEDS_1,
   LEDT_1,
   LEDL_1,
   LEDC_1,
   LEDR_1,
   LEDD_1);

   output [3:0]   BGTRIM;
   output         SIDDQ;
   output         XTAL25;
   output         DISABLE10;
   output         DISABLE100;
   output         SCANCLK_0;
   output         SCAN_EN_0;
   output [1:0]   TX_AMP_TRIM_0;
   output [1:0]   TX_SLP_TRIM_0;
   input          B10_DIS_0;
   input          B100_DIS_0;
   input          TRISTATE_0;
   input          CRS_0;
   input  [4:0]   RXD_0;
   input          RXDV_0;
   input          RXC_0;
   input          RXER_0;
   output         TXER_0;
   input          TXC_0;
   output         TXEN_0;
   output [4:0]   TXD_0;
   input          COL_0;
   output         FIBSEL_0;
   output         ANDIS_0;
   output         MDIO_IN;
   input          MDIO_OE_0;
   input          MDIO_OUT_0;
   output         MDC;
   input          MDINT_0;   
   output [4:0]   PHY_0;
   output         RESETN_0;
   output         SIDDQ_0;
   input          LEDS_0;
   input          LEDT_0;
   input          LEDL_0;
   input          LEDC_0;
   input          LEDR_0;
   input          LEDD_0;   
   output         SCANCLK_1;
   output         SCAN_EN_1;
   output [1:0]   TX_AMP_TRIM_1;
   output [1:0]   TX_SLP_TRIM_1;
   input          B10_DIS_1;
   input          B100_DIS_1;
   input          TRISTATE_1;   
   input          CRS_1;
   input  [4:0]   RXD_1;
   input          RXDV_1;
   input          RXC_1;
   input          RXER_1;
   output         TXER_1;
   input          TXC_1;
   output         TXEN_1;
   output [4:0]   TXD_1;
   input          COL_1;
   output         FIBSEL_1;
   output         ANDIS_1;
   input          MDIO_OE_1;
   input          MDIO_OUT_1;
   input          MDINT_1;
   output [4:0]   PHY_1;
   output         RESETN_1;
   output         SIDDQ_1;
   input          LEDS_1;
   input          LEDT_1;
   input          LEDL_1;
   input          LEDC_1;
   input          LEDR_1;
   input          LEDD_1;   

   //--------------------------------------------------------------------
   // testharness instantiation
   //--------------------------------------------------------------------
   testharness th ( 
      .BGTRIM(BGTRIM),
      .SIDDQ(SIDDQ),
      .XTAL25(XTAL25),
      .DISABLE10(DISABLE10),
      .DISABLE100(DISABLE100),
      .SCANCLK_0(SCANCLK_0),
      .SCAN_EN_0(SCAN_EN_0),
      .TX_AMP_TRIM_0(TX_AMP_TRIM_0),
      .TX_SLP_TRIM_0(TX_SLP_TRIM_0),
      .B10_DIS_0(B10_DIS_0),
      .B100_DIS_0(B100_DIS_0),
      .TRISTATE_0(TRISTATE_0),
      .CRS_0(CRS_0),
      .RXD_0(RXD_0),
      .RXDV_0(RXDV_0),
      .RXC_0(RXC_0),
      .RXER_0(RXER_0),
      .TXER_0(TXER_0),
      .TXC_0(TXC_0),
      .TXEN_0(TXEN_0),
      .TXD_0(TXD_0),
      .COL_0(COL_0),
      .FIBSEL_0(FIBSEL_0),
      .ANDIS_0(ANDIS_0),
      .MDIO_IN(MDIO_IN),
      .MDIO_OE_0(MDIO_OE_0),
      .MDIO_OUT_0(MDIO_OUT_0),
      .MDC(MDC),
      .MDINT_0(MDINT_0),
      .PHY_0(PHY_0),
      .RESETN_0(RESETN_0),
      .SIDDQ_0(SIDDQ_0),
      .LEDS_0(LEDS_0),
      .LEDT_0(LEDT_0),
      .LEDL_0(LEDL_0),
      .LEDC_0(LEDC_0),
      .LEDR_0(LEDR_0),
      .LEDD_0(LEDD_0),		    
      .SCANCLK_1(SCANCLK_1),
      .SCAN_EN_1(SCAN_EN_1),
      .TX_AMP_TRIM_1(TX_AMP_TRIM_1),
      .TX_SLP_TRIM_1(TX_SLP_TRIM_1),
      .B10_DIS_1(B10_DIS_1),
      .B100_DIS_1(B100_DIS_1),
      .TRISTATE_1(TRISTATE_1),		    
      .CRS_1(CRS_1),
      .RXD_1(RXD_1),
      .RXDV_1(RXDV_1),
      .RXC_1(RXC_1),
      .RXER_1(RXER_1),
      .TXER_1(TXER_1),
      .TXC_1(TXC_1),
      .TXEN_1(TXEN_1),
      .TXD_1(TXD_1),
      .COL_1(COL_1),
      .FIBSEL_1(FIBSEL_1),
      .ANDIS_1(ANDIS_1),
      .MDIO_OE_1(MDIO_OE_1),
      .MDIO_OUT_1(MDIO_OUT_1),
      .MDINT_1(MDINT_1),
      .PHY_1(PHY_1),
      .RESETN_1(RESETN_1),
      .SIDDQ_1(SIDDQ_1),
      .LEDS_1(LEDS_1),
      .LEDT_1(LEDT_1),
      .LEDL_1(LEDL_1),
      .LEDC_1(LEDC_1),
      .LEDR_1(LEDR_1),
      .LEDD_1(LEDD_1));

   //--------------------------------------------------------------------
   // task calls forming particular testcase
   //--------------------------------------------------------------------
   initial begin : test_procedure

      reg [15:0] val;
      reg [15:0] val2;
      reg        bit_val0;
      reg        bit_val1;
      reg        bit_val2;
      reg        bit_val3;      
      
      //
      //
      // initial testharness task tests
      //
      //
      force test.top.RESETN_0 = 1'b0;             // force resets form getgo
      force test.top.RESETN_1 = 1'b0;                   
      th.condition_ffs;                         // condition top_buf rst ffs
      fork
         th.phy_addr(1'b0, 5'b01010);             // set port 0 physical addr
         th.disable_an(1'b0,1'b1);                // diasable port 0 autoneg	 
      join
      fork
         th.phy_addr(1'b1, 5'b11111);             // set port 1 physical addr
         th.disable_an(1'b1,1'b1);                // diasable port 1 autoneg  
      join   
      
      #2000;                                      // wait for powerup
      fork
         th.xtal.enable(1'b1);                    // enable crystal clock

	 begin
	    #40;
            release test.top.RESETN_0;
	    release test.top.RESETN_1; 
         end
      join
      #300;
      $write("Simulation concluded\n");
      $finish;

  end

endmodule
