// Verilog HDL for "blw_dac_bin2therm" "behavioral"
// 7 bit binary to thermometer code
// If input is all zeros, up and down is all one's; common mode state
// If input goes positive, decrement down, which increases DAC output volt  
// If input goes negative, decrement up, which decreases DAC output volt 

module blw_dac_bin2therm (bin_in, reset, down, up);

input 	[6:0]	bin_in;		//input is 2's complement
input		reset;
	
output [62:0] down, up;
reg    [62:0] down, up;

always @(reset or bin_in) begin
    if (reset) begin
	up   = 63'h 7FFF_FFFF_FFFF_FFFF; //initial value, common mode 
	down = 63'h 7FFF_FFFF_FFFF_FFFF; //initial value, common mode 
    end
    else

	//check MSB, which indicates sign
	case(bin_in[6])		//synopsys parallel_case full_case

        //if bin_in[6] = 0, then pos number
	1'd0: begin
	   up = 63'h 7FFF_FFFF_FFFF_FFFF; //initial value, common mode 
	   case(bin_in[5:0])	//synopsys parallel_case full_case
	   6'd0:  down = 63'h 7FFF_FFFF_FFFF_FFFF; //initial value, common mode
	   6'd1:  down = 63'h 7FFF_FFFF_FFFF_FFFE; //(1) if bin_in[5:0] = 1dec  
	   6'd2:  down = 63'h 7FFF_FFFF_FFFF_FFFC; //2 
	   6'd3:  down = 63'h 7FFF_FFFF_FFFF_FFF8; //3 
	   6'd4:  down = 63'h 7FFF_FFFF_FFFF_FFF0; // 
	   6'd5:  down = 63'h 7FFF_FFFF_FFFF_FFE0; // 
	   6'd6:  down = 63'h 7FFF_FFFF_FFFF_FFC0; // 
	   6'd7:  down = 63'h 7FFF_FFFF_FFFF_FF80; // 
	   6'd8:  down = 63'h 7FFF_FFFF_FFFF_FF00; // 
	   6'd9:  down = 63'h 7FFF_FFFF_FFFF_FE00; // 
	   6'd10: down = 63'h 7FFF_FFFF_FFFF_FC00; //
	   6'd11: down = 63'h 7FFF_FFFF_FFFF_F800; // 
	   6'd12: down = 63'h 7FFF_FFFF_FFFF_F000; // 
	   6'd13: down = 63'h 7FFF_FFFF_FFFF_E000; // 
	   6'd14: down = 63'h 7FFF_FFFF_FFFF_C000; // 
	   6'd15: down = 63'h 7FFF_FFFF_FFFF_8000; // 
	   6'd16: down = 63'h 7FFF_FFFF_FFFF_0000; // 
	   6'd17: down = 63'h 7FFF_FFFF_FFFE_0000; // 
           6'd18: down = 63'h 7FFF_FFFF_FFFC_0000; // 
           6'd19: down = 63'h 7FFF_FFFF_FFF8_0000; // 
           6'd20: down = 63'h 7FFF_FFFF_FFF0_0000; // 
           6'd21: down = 63'h 7FFF_FFFF_FFE0_0000; // 
           6'd22: down = 63'h 7FFF_FFFF_FFC0_0000; // 
           6'd23: down = 63'h 7FFF_FFFF_FF80_0000; // 
           6'd24: down = 63'h 7FFF_FFFF_FF00_0000; // 
           6'd25: down = 63'h 7FFF_FFFF_FE00_0000; // 
           6'd26: down = 63'h 7FFF_FFFF_FC00_0000; // 
           6'd27: down = 63'h 7FFF_FFFF_F800_0000; // 
           6'd28: down = 63'h 7FFF_FFFF_F000_0000; // 
           6'd29: down = 63'h 7FFF_FFFF_E000_0000; // 
           6'd30: down = 63'h 7FFF_FFFF_C000_0000; // 
           6'd31: down = 63'h 7FFF_FFFF_8000_0000; // 
           6'd32: down = 63'h 7FFF_FFFF_0000_0000; // 
	   6'd33: down = 63'h 7FFF_FFFE_0000_0000; // 
           6'd34: down = 63'h 7FFF_FFFC_0000_0000; // 
           6'd35: down = 63'h 7FFF_FFF8_0000_0000; // 
           6'd36: down = 63'h 7FFF_FFF0_0000_0000; // 
           6'd37: down = 63'h 7FFF_FFE0_0000_0000; // 
           6'd38: down = 63'h 7FFF_FFC0_0000_0000; // 
           6'd39: down = 63'h 7FFF_FF80_0000_0000; // 
           6'd40: down = 63'h 7FFF_FF00_0000_0000; // 
           6'd41: down = 63'h 7FFF_FE00_0000_0000; // 
           6'd42: down = 63'h 7FFF_FC00_0000_0000; // 
           6'd43: down = 63'h 7FFF_F800_0000_0000; // 
           6'd44: down = 63'h 7FFF_F000_0000_0000; // 
           6'd45: down = 63'h 7FFF_E000_0000_0000; // 
           6'd46: down = 63'h 7FFF_C000_0000_0000; // 
           6'd47: down = 63'h 7FFF_8000_0000_0000; // 
           6'd48: down = 63'h 7FFF_0000_0000_0000; // 
	   6'd49: down = 63'h 7FFE_0000_0000_0000; // 
           6'd50: down = 63'h 7FFC_0000_0000_0000; // 
           6'd51: down = 63'h 7FF8_0000_0000_0000; // 
           6'd52: down = 63'h 7FF0_0000_0000_0000; // 
           6'd53: down = 63'h 7FE0_0000_0000_0000; // 
           6'd54: down = 63'h 7FC0_0000_0000_0000; // 
           6'd55: down = 63'h 7F80_0000_0000_0000; // 
           6'd56: down = 63'h 7F00_0000_0000_0000; // 
           6'd57: down = 63'h 7E00_0000_0000_0000; // 
           6'd58: down = 63'h 7C00_0000_0000_0000; // 
           6'd59: down = 63'h 7800_0000_0000_0000; // 
           6'd60: down = 63'h 7000_0000_0000_0000; // 
           6'd61: down = 63'h 6000_0000_0000_0000; // 
           6'd62: down = 63'h 4000_0000_0000_0000; // 
           6'd63: down = 63'h 0000_0000_0000_0000; // 
           endcase
	end

	//if bin_[6] = 1, then neg number
	1'd1: begin
	   down = 63'h 7FFF_FFFF_FFFF_FFFF; //initial value, common mode 
	   case(bin_in[5:0]) //synopsys parallel_case full_case
           6'd63: up = 63'h 7FFF_FFFF_FFFF_FFFE; // (-1) if bin_in[5:0]=63dec 
           6'd62: up = 63'h 7FFF_FFFF_FFFF_FFFC; //-2 
           6'd61: up = 63'h 7FFF_FFFF_FFFF_FFF8; //-3 
           6'd60: up = 63'h 7FFF_FFFF_FFFF_FFF0; // 
           6'd59: up = 63'h 7FFF_FFFF_FFFF_FFE0; // 
           6'd58: up = 63'h 7FFF_FFFF_FFFF_FFC0; // 
           6'd57: up = 63'h 7FFF_FFFF_FFFF_FF80; //
           6'd56: up = 63'h 7FFF_FFFF_FFFF_FF00; //
           6'd55: up = 63'h 7FFF_FFFF_FFFF_FE00; // 
           6'd54: up = 63'h 7FFF_FFFF_FFFF_FC00; //
           6'd53: up = 63'h 7FFF_FFFF_FFFF_F800; //
           6'd52: up = 63'h 7FFF_FFFF_FFFF_F000; //
           6'd51: up = 63'h 7FFF_FFFF_FFFF_E000; //
           6'd50: up = 63'h 7FFF_FFFF_FFFF_C000; //
           6'd49: up = 63'h 7FFF_FFFF_FFFF_8000; //
           6'd48: up = 63'h 7FFF_FFFF_FFFF_0000; //
           6'd47: up = 63'h 7FFF_FFFF_FFFE_0000; //
           6'd46: up = 63'h 7FFF_FFFF_FFFC_0000; //
           6'd45: up = 63'h 7FFF_FFFF_FFF8_0000; //
           6'd44: up = 63'h 7FFF_FFFF_FFF0_0000; //
           6'd43: up = 63'h 7FFF_FFFF_FFE0_0000; //
           6'd42: up = 63'h 7FFF_FFFF_FFC0_0000; // 
           6'd41: up = 63'h 7FFF_FFFF_FF80_0000; // 
           6'd40: up = 63'h 7FFF_FFFF_FF00_0000; // 
           6'd39: up = 63'h 7FFF_FFFF_FE00_0000; // 
           6'd38: up = 63'h 7FFF_FFFF_FC00_0000; // 
           6'd37: up = 63'h 7FFF_FFFF_F800_0000; // 
           6'd36: up = 63'h 7FFF_FFFF_F000_0000; // 
           6'd35: up = 63'h 7FFF_FFFF_E000_0000; // 
           6'd34: up = 63'h 7FFF_FFFF_C000_0000; // 
           6'd33: up = 63'h 7FFF_FFFF_8000_0000; // 
           6'd32: up = 63'h 7FFF_FFFF_0000_0000; // 
           6'd31: up = 63'h 7FFF_FFFE_0000_0000; // 
           6'd30: up = 63'h 7FFF_FFFC_0000_0000; // 
	   6'd29: up = 63'h 7FFF_FFF8_0000_0000; // 
           6'd28: up = 63'h 7FFF_FFF0_0000_0000; // 
           6'd27: up = 63'h 7FFF_FFE0_0000_0000; // 
           6'd26: up = 63'h 7FFF_FFC0_0000_0000; // 
           6'd25: up = 63'h 7FFF_FF80_0000_0000; // 
           6'd24: up = 63'h 7FFF_FF00_0000_0000; // 
           6'd23: up = 63'h 7FFF_FE00_0000_0000; // 
           6'd22: up = 63'h 7FFF_FC00_0000_0000; // 
           6'd21: up = 63'h 7FFF_F800_0000_0000; // 
           6'd20: up = 63'h 7FFF_F000_0000_0000; //
           6'd19: up = 63'h 7FFF_E000_0000_0000; // 
           6'd18: up = 63'h 7FFF_C000_0000_0000; // 
           6'd17: up = 63'h 7FFF_8000_0000_0000; //
           6'd16: up = 63'h 7FFF_0000_0000_0000; // 
           6'd15: up = 63'h 7FFE_0000_0000_0000; // 
           6'd14: up = 63'h 7FFC_0000_0000_0000; // 
           6'd13: up = 63'h 7FF8_0000_0000_0000; // 
           6'd12: up = 63'h 7FF0_0000_0000_0000; // 
           6'd11: up = 63'h 7FE0_0000_0000_0000; // 
           6'd10: up = 63'h 7FC0_0000_0000_0000; // 
           6'd9:  up = 63'h 7F80_0000_0000_0000; // 
           6'd8:  up = 63'h 7F00_0000_0000_0000; // 
           6'd7:  up = 63'h 7E00_0000_0000_0000; // 
           6'd6:  up = 63'h 7C00_0000_0000_0000; // 
           6'd5:  up = 63'h 7800_0000_0000_0000; // 
           6'd4:  up = 63'h 7000_0000_0000_0000; // 
           6'd3:  up = 63'h 6000_0000_0000_0000; // 
           6'd2:  up = 63'h 4000_0000_0000_0000; // 
	   6'd1:  up = 63'h 0000_0000_0000_0000; // 
	   6'd0:  up = 63'h 0000_0000_0000_0000; // same output as 6'd1
           endcase              
	end
	endcase	
end
endmodule
