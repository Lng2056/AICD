///  

module trans_ld_bin2therm (NEG_EVEN, NEG_ODD, POS_EVEN,POS_ODD, BIN_IN,CLK160,RESET,TRANS_OFF);


input   [4:0]   BIN_IN;
input           CLK160;
input           RESET;
input           TRANS_OFF;

output  [12:0]  POS_EVEN;
output  [12:0]  NEG_EVEN;
output  [12:0]  POS_ODD;
output  [12:0]  NEG_ODD;

trans_ld_b2t_logic logic ( .TRANS_OFF(TRANS_OFF), 
                        .RESET(RESET),
                        .BIN_IN(BIN_IN[4:0]), 
                        .POS_ODD(POS_ODD[12:0]),
                        .POS_EVEN(POS_EVEN[12:0]), 
                        .NEG_ODD(NEG_ODD[12:0]),
                        .NEG_EVEN(NEG_EVEN[12:0]), 
                        .CLK160_NE(CLK160_NE),
                        .CLK160_NO(CLK160_NO), 
                        .CLK160_PO(CLK160_PO),
                        .CLK160_PE(CLK160_PE)
                      );

trans_ld_b2t_clock clock ( .CLK(CLK160), 
                        .CLK_NE(CLK160_NE),
                        .CLK_NO(CLK160_NO), 
                        .CLK_PO(CLK160_PO), 
                        .CLK_PE(CLK160_PE)
                      );

endmodule

`timescale 1ns / 10ps

module trans_ld_b2t_logic (BIN_IN, CLK160_PE, CLK160_PO, CLK160_NE, CLK160_NO, 
                           RESET, TRANS_OFF, POS_EVEN, NEG_EVEN, POS_ODD, 
                           NEG_ODD);
                      
// POS_EVEN for positive values  1 to  13 on RISING  edge of CLK160
// NEG_EVEN for negative values -1 to -13 on RISING  edge of CLK160

// POS_ODD  for positive values  1 to  13 on FALLING edge of CLK160
// NEG_ODD  for negative values -1 to -13 on FALLING edge of CLK160

// 010307-tomw added TRANS_OFF input (internally or'd with RESET)
// 010309-daw  added separate clocks to minimize skew and define clock trees

input	[4:0]	BIN_IN;
input		CLK160_NE;  // Separate clock input (tree) for NEG_EVEN outputs
input		CLK160_NO;  // Separate clock input (tree) for NEG_ODD  outputs
input		CLK160_PE;  // Separate clock input (tree) for POS_EVEN outputs
input		CLK160_PO;  // Separate clock input (tree) for POS_ODD  outputs
input		RESET;
input		TRANS_OFF;

output  [12:0]  NEG_EVEN;
output  [12:0]  NEG_ODD;
output	[12:0]  POS_EVEN;
output  [12:0]  POS_ODD;

reg     [12:0]  NEG_EVEN;
reg     [12:0]  NEG_ODD;
reg	[12:0]  POS_EVEN;
reg     [12:0]  POS_ODD;

wire   reset_int;

assign reset_int = TRANS_OFF | RESET;


always @(posedge CLK160_PE or posedge reset_int) begin      // POS_EVEN outputs
   if (reset_int)                                           // (CLK160_PE tree)
      POS_EVEN <= 13'h1fff;
   else
      POS_EVEN <= BIN_IN[4] ? 13'h1fff : b2t0(BIN_IN);
end

always @(posedge CLK160_NE or posedge reset_int) begin      // NEG_EVEN outputs
   if (reset_int)                                           // (CLK160_NE tree)
      NEG_EVEN <= 13'h1fff;
   else
      NEG_EVEN <= BIN_IN[4] ? b2t1(BIN_IN) : 13'h1fff;
end


always @(posedge CLK160_PO or posedge reset_int) begin      // POS_ODD  outputs
   if (reset_int)                                           // (CLK160_PO tree)
      POS_ODD  <= 13'h1fff;
   else      
      POS_ODD  <= BIN_IN[4] ? 13'h1fff : b2t0(BIN_IN); 
end

always @(posedge CLK160_NO or posedge reset_int) begin      // NEG_ODD  outputs
   if (reset_int)                                           // (CLK160_NO tree)
      NEG_ODD  <= 13'h1fff;
   else      
      NEG_ODD  <= BIN_IN[4] ? b2t1(BIN_IN) : 13'h1fff;
end


function [12:0] b2t1;                  // bin-to-therm function (w/MSB=1)

   input [4:0] bin;

      case(bin[3:0]) // synopsys parallel_case
         4'd0:  b2t1 = 13'b 0000000000000;
         4'd1:  b2t1 = 13'b 0000000000000;
         4'd2:  b2t1 = 13'b 0000000000000;
         4'd3:  b2t1 = 13'b 0000000000000;
         4'd4:  b2t1 = 13'b 1000000000000;
         4'd5:  b2t1 = 13'b 1100000000000;
         4'd6:  b2t1 = 13'b 1110000000000;
         4'd7:  b2t1 = 13'b 1111000000000;
         4'd8:  b2t1 = 13'b 1111100000000;
         4'd9:  b2t1 = 13'b 1111110000000;
         4'd10: b2t1 = 13'b 1111111000000;
         4'd11: b2t1 = 13'b 1111111100000;
         4'd12: b2t1 = 13'b 1111111110000;
         4'd13: b2t1 = 13'b 1111111111000;
         4'd14: b2t1 = 13'b 1111111111100;
         4'd15: b2t1 = 13'b 1111111111110;
      endcase // case(bin[3:0])

endfunction  // b2t1

function [12:0] b2t0;                  // bin-to-therm function (w/MSB=0)

   input [12:0] bin;

      case(bin[3:0]) // synopsys parallel_case
         4'd0:  b2t0 = 13'b 1111111111111;
         4'd1:  b2t0 = 13'b 1111111111110;
         4'd2:  b2t0 = 13'b 1111111111100;
         4'd3:  b2t0 = 13'b 1111111111000;
         4'd4:  b2t0 = 13'b 1111111110000;
         4'd5:  b2t0 = 13'b 1111111100000;
         4'd6:  b2t0 = 13'b 1111111000000;
         4'd7:  b2t0 = 13'b 1111110000000;
         4'd8:  b2t0 = 13'b 1111100000000;
         4'd9:  b2t0 = 13'b 1111000000000;
         4'd10: b2t0 = 13'b 1110000000000;
         4'd11: b2t0 = 13'b 1100000000000;
         4'd12: b2t0 = 13'b 1000000000000;
         4'd13: b2t0 = 13'b 0000000000000;
         4'd14: b2t0 = 13'b 0000000000000;
         4'd15: b2t0 = 13'b 0000000000000;
      endcase // case(bin[3:0])

endfunction  // b2t0

endmodule

// Verilog HDL for  "trans_ld_b2t_clock" "behavioral"
//   
// output CLK_NE - All NEG_EVEN outputs switch on one clock (CLK_NE clock tree)
// output CLK_NO - All NEG_ODD  outputs switch on one clock (CLK_NO clock tree)

// output CLK_PE - All POS_EVEN outputs switch on one clock (CLK_PE clock tree)
// output CLK_PO - All POS_ODD  outputs switch on one clock (CLK_PO clock tree)

`timescale 1ns / 10ps

module trans_ld_b2t_clock (CLK_NE, CLK_NO, CLK_PE, CLK_PO, CLK);

output CLK_NE;
output CLK_NO;
output CLK_PE;
output CLK_PO;

input  CLK;

wire   CLK_NE;
wire   CLK_NO;
wire   CLK_PE;
wire   CLK_PO;

assign CLK_NE =  CLK;
assign CLK_NO = !CLK;
assign CLK_PE =  CLK;
assign CLK_PO = !CLK;

endmodule
