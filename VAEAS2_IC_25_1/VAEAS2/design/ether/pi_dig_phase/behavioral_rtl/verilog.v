// Verilog HDL for "shawnee_ms", "pi_dig_phase" "behavioral"

module pi_dig_phase (RCLK125, ADC_TEST_MODE, CLK250_TAPS, PHASE_DN, 
           PHASE_UP, RCLK125_TEST, RESET);
    output RCLK125;
    input ADC_TEST_MODE;
    input [21:0] CLK250_TAPS;
    input PHASE_DN;
    input PHASE_UP;
    input RCLK125_TEST;
    input RESET;

   
   reg		RCLK125;
   reg		rclk250;
   reg          rclk250_div2;

   reg [4:0] 	curr_tap;
   reg [4:0]    new_tap;
   reg		prev1_reset;
   reg          prev2_reset;
/* -----\/----- EXCLUDED -----\/-----
   reg          prev1_resetn;
   reg          prev2_resetn;   
   reg          prev3_resetn;
   reg          prev4_resetn;   
 -----/\----- EXCLUDED -----/\----- */
   reg          mux_reset;
/* -----\/----- EXCLUDED -----\/-----
   reg          div2_reset;
 -----/\----- EXCLUDED -----/\----- */
   reg		prev_phase_up;
   reg          prev_phase_down;

   wire		upd_enab;
   wire		upd_clk = !CLK250_TAPS[new_tap];

   wire         compare;
   assign compare = CLK250_TAPS[0] ^ rclk250;

   // metastability chain for resets
   always @(posedge rclk250 or posedge RESET)
      if (RESET)
         prev1_reset <= 1'b1;
      else
         prev1_reset <= 1'b0;

   always @(posedge rclk250 or posedge RESET)
      if (RESET)
         prev2_reset <= 1'b1;
      else
         prev2_reset <= prev1_reset;

   always @(posedge rclk250 or posedge RESET)
      if (RESET)
         mux_reset <= 1'b1;
      else
         mux_reset <= prev2_reset;  


// can't be done unless can gurantee rising edge of reset at powerup   
/* -----\/----- EXCLUDED -----\/-----
   // reset for single-cycle div2 register occurrs @ initiation 
   // of RESET sequence
   
   always @(posedge rclk250 or negedge RESET)
      if (!RESET)
         prev1_resetn <= 1'b0;
      else
         prev1_resetn <= 1'b1;

   always @(posedge rclk250 or negedge RESET)
      if (!RESET)
         prev2_resetn <= 1'b0;
      else
         prev2_resetn <= prev1_resetn;
   
   always @(posedge rclk250 or negedge RESET)
      if (!RESET)
         prev3_resetn <= 1'b0;
      else
         prev3_resetn <= prev2_resetn; 

   always @(posedge rclk250 or negedge RESET)
      if (!RESET)
         prev4_resetn <= 1'b0;
      else
         prev4_resetn <= prev3_resetn;   

   
   always @(posedge rclk250 or negedge RESET)
      if (!RESET)
         div2_reset <= 1'b0;
      else
         div2_reset <= prev3_resetn ^ prev4_resetn;	  
 -----/\----- EXCLUDED -----/\----- */

   // clock muxing
   always @(posedge rclk250 or posedge mux_reset)
      if (mux_reset) begin
         prev_phase_up   <= 1'b0;
         prev_phase_down <= 1'b0;
      end
   
      else begin
         prev_phase_up   <= PHASE_UP;
         prev_phase_down <= PHASE_DN;
      end

   always	@(posedge rclk250 or posedge mux_reset) begin
      if (mux_reset) begin
	 new_tap <= 5'd0;
      end
      
      else begin
         if (PHASE_UP & !prev_phase_up)
	    if (curr_tap == 5'd21)
	       new_tap <= 5'd0;
	    else
	       new_tap <= curr_tap + 5'd1;
	 else
	    if (PHASE_DN & !prev_phase_down)
	       if (curr_tap == 5'd0)
		  new_tap <= 5'd21;
	       else
		  new_tap <= curr_tap - 5'd1;
      end
   end

   assign upd_enab = (curr_tap != new_tap); 

   always	@(posedge upd_clk or posedge mux_reset) begin
      if (mux_reset)
	 curr_tap <= 5'd0;
      else
	 if (upd_enab)
	    curr_tap <= new_tap;
   end


   always @(curr_tap or CLK250_TAPS) begin
      case (curr_tap)
	5'd0:   rclk250 = CLK250_TAPS[0];
	5'd1:   rclk250 = CLK250_TAPS[1];
	5'd2:   rclk250 = CLK250_TAPS[2];
	5'd3:   rclk250 = CLK250_TAPS[3];
	5'd4:   rclk250 = CLK250_TAPS[4];
	5'd5:   rclk250 = CLK250_TAPS[5];
	5'd6:   rclk250 = CLK250_TAPS[6];
	5'd7:   rclk250 = CLK250_TAPS[7];
	5'd8:   rclk250 = CLK250_TAPS[8];
	5'd9:   rclk250 = CLK250_TAPS[9];
	5'd10:  rclk250 = CLK250_TAPS[10];
	5'd11:  rclk250 = CLK250_TAPS[11];
	5'd12:  rclk250 = CLK250_TAPS[12];
	5'd13:  rclk250 = CLK250_TAPS[13];
	5'd14:  rclk250 = CLK250_TAPS[14];
	5'd15:  rclk250 = CLK250_TAPS[15];
	5'd16:  rclk250 = CLK250_TAPS[16];
	5'd17:  rclk250 = CLK250_TAPS[17];
	5'd18:  rclk250 = CLK250_TAPS[18];
	5'd19:  rclk250 = CLK250_TAPS[19];
	5'd20:  rclk250 = CLK250_TAPS[20];
	5'd21:  rclk250 = CLK250_TAPS[21];

	default:rclk250 = CLK250_TAPS[0];
      endcase
   end

   // 250->125MHz divider
/* -----\/----- EXCLUDED -----\/-----
   always @(posedge rclk250 or posedge div2_reset) begin
      if (div2_reset)
         rclk250_div2 <= 1'b1;
      else
	 rclk250_div2 <= ~rclk250_div2;
   end
 -----/\----- EXCLUDED -----/\----- */
   // divider can startup either state
   initial
     rclk250_div2 = $random;
   
   always @(posedge rclk250) begin
	 rclk250_div2 <= ~rclk250_div2;
   end

   always @(rclk250_div2 or ADC_TEST_MODE or RCLK125_TEST) begin
      if (ADC_TEST_MODE)
	 RCLK125 = RCLK125_TEST;
      else
	 RCLK125 = rclk250_div2;
   end
 
//   always @(posedge RCLK125)
//    begin
//     $write("curr_tap = %d \n", curr_tap);
//    end
endmodule
