`timescale 1ns / 1ps 

module adcflash_latches ( out, CLK, in );

input  CLK;
input [2:0]  in;
output [2:0]  out;

reg [2:0] out;

always @(posedge CLK) begin
   out <= in;
end

endmodule


module adc_decode ( adc_flash, adc_out, ph1, ph1b, 
                    adcflash, adc, FX_BIT, BASEFX_DIS,
                    adc_latch_clk);

input  BASEFX_DIS, FX_BIT, ph1, ph1b;
input [62:0]  adc;
input [5:0]  adcflash;
output [5:0]  adc_out;
output [2:0]  adc_flash;
output adc_latch_clk;

wire  [0:2]  net024;


adcflash_latches flash_lat ( .out(adc_flash[2:0]), .CLK(ph1b),
     .in(net024[0:2]));
adc_therm2bin adc_t2b ( .CLK125(ph1b), .BIN(adc_out[5:0]),
     .THERM(adc[62:0]));
adcflash_therm2bin flash_t2b ( .FX_BIT(FX_BIT),
     .BASEFX_DIS(BASEFX_DIS), .BIN(net024[0:2]), .THERM(adcflash[5:0]),
     .CLK125(ph1));


assign adc_latch_clk = ~ph1b;

endmodule

module adc_therm2bin ( CLK125, THERM, BIN );

input 		CLK125;
input 	[62:0] 	THERM;

output	[5:0]	BIN;

reg	[5:0]	BIN;
wire	[5:0]	next_bin;
reg	[62:0]  stage1_corr;
reg	[62:0]  stage2_corr;
reg	[62:0]	value_bit;

reg	[5:0]	i,j,k;

// Bit pattern inputs and their associated output
// Therm[1:0]  stage1_corr[0]
// ----------  --------------
//     00            0       (default condition)
//     01            1
//     10            1
//     11            1
//
// Therm[n+1:n-1]  stage1_corr[n] for n = 1 to 61
// --------------  --------------
//    000            0       (default condition)
//    001            0
//    010            0
//    011            1
//    100            0  
//    101            1
//    110            1
//    111            1
//
// Therm[62:61]  stage1_corr[62]
// ------------  --------------
//     00            0       (default condition)
//     01            0
//     10            0
//     11            1

always @(THERM) begin
    stage1_corr[62:0] = 63'd0;

    if (THERM[1:0] != 2'b00)   stage1_corr[0] = 1'b1;

    for (i=1; i<=61; i=i+1) begin
	casex ({THERM[i+1],THERM[i],THERM[i-1]}) //synopsys parallel_case
	3'bx11,3'b1x1,3'b11x: stage1_corr[i] = 1'b1;
	endcase
    end

    if (THERM[62:61] == 2'b11) stage1_corr[62] = 1'b1;
end
   
always @(stage1_corr) begin
    stage2_corr[62:0] = 63'd0;

    if (stage1_corr[1:0] != 2'b00)   stage2_corr[0] = 1'b1;

    for (j=1; j<=61; j=j+1) begin
	casex ({stage1_corr[j+1],stage1_corr[j],stage1_corr[j-1]}) //synopsys parallel_case
	3'bx11,3'b1x1,3'b11x: stage2_corr[j] = 1'b1;
	endcase
    end

    if (stage1_corr[62:61] == 2'b11) stage2_corr[62] = 1'b1;
end

always @(stage2_corr) begin
    value_bit[62:0] = 63'd0;

    if (stage2_corr[3:0] == 4'b0001) value_bit[0] = 1'b1;
    if (stage2_corr[4:0] == 5'b00011) value_bit[1] = 1'b1;

    for (k = 2; k <= 59; k = k+1) begin
       if ({stage2_corr[k+3],stage2_corr[k+2],stage2_corr[k+1],stage2_corr[k],
	    stage2_corr[k-1],stage2_corr[k-2]} == 6'b000111 |
	    ({stage2_corr[k+2],stage2_corr[k+1],stage2_corr[k],
	      stage2_corr[k-1]} == 4'b1100))
	    value_bit[k] = 1'b1;
    end

    if (stage2_corr[62:58] == 5'b00111) value_bit[60] = 1'b1;
    if (stage2_corr[62:59] == 4'b0111) value_bit[61] = 1'b1;
    if (stage2_corr[62:60] == 3'b111) value_bit[62] = 1'b1;
end
   
assign	next_bin[5] =
	value_bit[62] | value_bit[61] | value_bit[60] | value_bit[59] |
	value_bit[58] | value_bit[57] | value_bit[56] | value_bit[55] |
	value_bit[54] | value_bit[53] | value_bit[52] | value_bit[51] |
	value_bit[50] | value_bit[49] | value_bit[48] | value_bit[47] |
	value_bit[46] | value_bit[45] | value_bit[44] | value_bit[43] |
	value_bit[42] | value_bit[41] | value_bit[40] | value_bit[39] |
	value_bit[38] | value_bit[37] | value_bit[36] | value_bit[35] |
	value_bit[34] | value_bit[33] | value_bit[32] | value_bit[31] ;

assign	next_bin[4] =
	value_bit[62] | value_bit[61] | value_bit[60] | value_bit[59] |
	value_bit[58] | value_bit[57] | value_bit[56] | value_bit[55] |
	value_bit[54] | value_bit[53] | value_bit[52] | value_bit[51] |
	value_bit[50] | value_bit[49] | value_bit[48] | value_bit[47] |

	value_bit[30] | value_bit[29] | value_bit[28] | value_bit[27] |
	value_bit[26] | value_bit[25] | value_bit[24] | value_bit[23] |
	value_bit[22] | value_bit[21] | value_bit[20] | value_bit[19] |
	value_bit[18] | value_bit[17] | value_bit[16] | value_bit[15] ;

assign	next_bin[3] =
	value_bit[62] | value_bit[61] | value_bit[60] | value_bit[59] |
	value_bit[58] | value_bit[57] | value_bit[56] | value_bit[55] |

	value_bit[46] | value_bit[45] | value_bit[44] | value_bit[43] |
	value_bit[42] | value_bit[41] | value_bit[40] | value_bit[39] |

	value_bit[30] | value_bit[29] | value_bit[28] | value_bit[27] |
	value_bit[26] | value_bit[25] | value_bit[24] | value_bit[23] |

	value_bit[14] | value_bit[13] | value_bit[12] | value_bit[11] |
	value_bit[10] | value_bit[9]  | value_bit[8]  | value_bit[7]  ;

assign	next_bin[2] =
	value_bit[62] | value_bit[61] | value_bit[60] | value_bit[59] |
	value_bit[54] | value_bit[53] | value_bit[52] | value_bit[51] |
	value_bit[46] | value_bit[45] | value_bit[44] | value_bit[43] |
	value_bit[38] | value_bit[37] | value_bit[36] | value_bit[35] |
	value_bit[30] | value_bit[29] | value_bit[28] | value_bit[27] |
	value_bit[22] | value_bit[21] | value_bit[20] | value_bit[19] |
	value_bit[14] | value_bit[13] | value_bit[12] | value_bit[11] |
	value_bit[6]  | value_bit[5]  | value_bit[4]  | value_bit[3]  ;

assign	next_bin[1] =
	value_bit[62] | value_bit[61] | value_bit[58] | value_bit[57] |
	value_bit[54] | value_bit[53] | value_bit[50] | value_bit[49] |
	value_bit[46] | value_bit[45] | value_bit[42] | value_bit[41] |
	value_bit[38] | value_bit[37] | value_bit[34] | value_bit[33] |
	value_bit[30] | value_bit[29] | value_bit[26] | value_bit[25] |
	value_bit[22] | value_bit[21] | value_bit[18] | value_bit[17] |
	value_bit[14] | value_bit[13] | value_bit[10] | value_bit[9]  |
	value_bit[6]  | value_bit[5]  | value_bit[2]  | value_bit[1]  ;

assign	next_bin[0] =
	value_bit[62] | value_bit[60] | value_bit[58] | value_bit[56] |
	value_bit[54] | value_bit[52] | value_bit[50] | value_bit[48] |
	value_bit[46] | value_bit[44] | value_bit[42] | value_bit[40] |
	value_bit[38] | value_bit[36] | value_bit[34] | value_bit[32] |
	value_bit[30] | value_bit[28] | value_bit[26] | value_bit[24] |
	value_bit[22] | value_bit[20] | value_bit[18] | value_bit[16] |
	value_bit[14] | value_bit[12] | value_bit[10] | value_bit[8]  |
	value_bit[6]  | value_bit[4]  | value_bit[2]  | value_bit[0]  ;

always @(posedge CLK125) begin
    BIN[4:0] <= next_bin[4:0];
    BIN[5] <= ~next_bin[5];
end

endmodule


// Verilog HDL for "umc05001", "adcflash_therm2bin" "behavioral"

module adcflash_therm2bin (CLK125, THERM, BIN, BASEFX_DIS, FX_BIT);
    input CLK125;
    input [5:0] THERM;
    output [2:0] BIN;
    input BASEFX_DIS;
    input FX_BIT;

// input VDD;
// input VSS;

reg	[2:0]	BIN;
wire	[2:0]	next_bin;
reg	[5:0]   stage1_corr;
reg	[5:0]   stage2_corr;
reg	[5:0]	value_bit;

reg	[5:0]	i,j;

// Bit pattern inputs and their associated output
// Therm[1:0]  stage1_corr[0]
// ----------  --------------
//     00            0       (default condition)
//     01            1
//     10            1
//     11            1
//
// Therm[n+1:n-1]  stage1_corr[n] for n = 1 to 4
// --------------  --------------
//    000            0       (default condition)
//    001            0
//    010            0
//    011            1
//    100            0  
//    101            1
//    110            1
//    111            1
//
// Therm[5:4]  stage1_corr[5]
// ------------  --------------
//     00            0       (default condition)
//     01            0
//     10            0
//     11            1

always @(THERM) begin
    stage1_corr[5:0] = 6'd0;

    if (THERM[1:0] != 2'b00)   stage1_corr[0] = 1'b1;

    for (i=1; i<=4; i=i+1) begin
	casex ({THERM[i+1],THERM[i],THERM[i-1]}) //synopsys parallel_case
	3'bx11,3'b1x1,3'b11x: stage1_corr[i] = 1'b1;
	endcase
    end

    if (THERM[5:4] == 2'b11) stage1_corr[5] = 1'b1;
end
   
always @(stage1_corr) begin
    stage2_corr[5:0] = 6'd0;

    if (stage1_corr[1:0] != 2'b00)   stage2_corr[0] = 1'b1;

    for (j=1; j<=4; j=j+1) begin
	casex ({stage1_corr[j+1],stage1_corr[j],stage1_corr[j-1]}) //synopsys parallel_case
	3'bx11,3'b1x1,3'b11x: stage2_corr[j] = 1'b1;
	endcase
    end

    if (stage1_corr[5:4] == 2'b11) stage2_corr[5] = 1'b1;
end

always @(stage2_corr) begin
    value_bit[5:0] = 6'd0;

    if (stage2_corr[3:0] == 4'b0001) value_bit[0] = 1'b1;
    if (stage2_corr[4:0] == 5'b00011) value_bit[1] = 1'b1;

       if ({stage2_corr[5],stage2_corr[4],stage2_corr[3],stage2_corr[2],
	    stage2_corr[1],stage2_corr[0]} == 6'b000111 |
	    ({stage2_corr[4],stage2_corr[3],stage2_corr[2],
	      stage2_corr[1]} == 4'b1100))
	    value_bit[2] = 1'b1;

    if (stage2_corr[5:1] == 5'b00111) value_bit[3] = 1'b1;
    if (stage2_corr[5:2] == 4'b0111)  value_bit[4] = 1'b1;
    if (stage2_corr[5:3] == 3'b111)   value_bit[5] = 1'b1;
end
   
assign	next_bin[2] = value_bit[5] | value_bit[4] |
		      value_bit[3] | value_bit[2] ;

assign	next_bin[1] = value_bit[5] | value_bit[4] |
		      value_bit[1]  | value_bit[0]  ;

assign	next_bin[0] = !(value_bit[4] | value_bit[2] | value_bit[0])  ;

always @(posedge CLK125) begin
    if (BASEFX_DIS) begin
        BIN[1:0] <=  next_bin[1:0];
        BIN[2]   <= ~next_bin[2];
    end
    else begin
        if (FX_BIT) begin
	    BIN[2:0] <= 3'b001;
	end
	else begin
	    BIN[2:0] <= 3'b111;
	end
    end
end



endmodule
