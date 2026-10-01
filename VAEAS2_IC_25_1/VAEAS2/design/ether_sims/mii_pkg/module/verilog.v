//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
// Title   :  mii_pkg
// Project :  umc18a01
// Author  :  dshelton
// Notes   :  this is the media indepedent interface (MII) bus functional
//            model. Data may be transmitted on either port at a specified 
//            rate using the transmit task. Data may be all ones or 
//            randomly generated. Data is stored in 4wide x 20 fifo to 
//            allow self-checking upon receive. Receive task reads either
//            port and compares fifo contents with received data. Task to 
//            be called from testbenches are :
//
//
//
//            get_clock_period 
//                           simply measures each of the clock periods for
//                              RXC_0, TXC_0, RXC_1, and TXC_1. If a clock
//                              is static a watchdog times out to allow
//                              the simulation to proceed   
//
//            check_fifo
//                           checks the fifo in/out pointers. If they are
//                           out of sync it returns a 1'b0, and reset both 
//                           pointers to zero. Otherwise it returns 1'b1.    
//     
//            receive(port_num, rate_10bt, symbol_mode, rcv_w_error,
//                     rcv_w_col, rcv_w_crs) 
//
//                           where port_num port_num is a single bit from
//                                    the testbench selecting 
//                                    which bus to drive
//                                 rate_10bt is a single bit from the 
//                                    testbench indicating rate:
//                                    rate_10bt = 1'b0  => 100base-x 
//                                    rate_10bt = 1'b1  => 10base-t 
//                                 symbol_mode is two bits from testbench
//                                    indicating:
//                                    symbol_mode = 2'bX0  => 4-bit mode
//                                    symbol_mode = 2'b01  => 5-bit, bypassing
//                                                            4b5b enc/dec
//                                                          possibly scr/descr
//                                    symbol_mode = 2'b11  => 5-bit, bypassing
//                                                            4b5b enc/dec, 
//                                                          scr/descr, and
//                                                          alignment
//                                 rcv_w_error is an active high bit to the 
//                                    testbench indicating a RXER was activated
//                                 rcv_w_col is an active high bit to the 
//                                    testbench indicating a collesion occurred
//                                 rcv_w_crs is an active high bit to the 
//                                    testbench indicating carrier sense
//                                    rcv_w_crs = 1'b0 => no CRS detected from  
//                                                        RXDV
//                                    rcv_w_crs = 1'b1 => CRS detected
//
//
//
//
//            transmit(port_num, rate_10bt, num_nibble, random_Nones,
//                     error_mode, symbol_mode, tx_w_crs) 
//
//                           where port_num port_num is a single bit from
//                                    the testbench selecting 
//                                    which bus to drive
//                                 rate_10bt is a single bit from the 
//                                    testbench indicating rate:
//                                    rate_10bt = 1'b0  => 100base-x 
//                                    rate_10bt = 1'b1  => 10base-t 
//                                 num_nibble is an input from the 
//                                    testbench indicating how many nibbles 
//                                    to transmit. This is payload only; it
//                                    excludes preamble and sfd which are
//                                    added by this task
//                                 random_Nones is a single bit from the 
//                                    testbench indicating random or all 
//                                    ones data:
//                                    random_Nones = 1'b0  => all ones
//                                    random_Nones = 1'b1  => random
//                                 error_mode is a single bit from the 
//                                    testbench indicating TXER active
//                                    for one cycle of transmission: 
//                                    error_mode = 1'b0  => TXER_x inactive
//                                    error_mode = 1'b1  => TXER_x active
//                                 symbol_mode is two bits from testbench
//                                    indicating:
//                                    symbol_mode = 2'bX0  => 4-bit mode
//                                    symbol_mode = 2'bX1  => 5-bit, bypassing
//                                                            4b5b enc/dec
//                                                            possibly scr/des
//                                 tx_w_crs is an active high bit to the
//                                    testbench indicating carrier sense
//                                    tx_w_crs = 1'b0 => no CRS in time or
//                                                       deactivated too soon
//                                    tx_w_crs = 1'bZ => CRS in time and
//                                                       active to EOF, but
//                                                       no deassrt in spec'd
//                                                       time (full duplex w/
//                                                       recv)
//                                    tx_w_crs = 1'b1 => CRS in time and
//                                                       deassert in time
//                                                       (half duplex)
//
//            transmit_link_pulse(port_num, num_pulses) 
//
//                           where port_num port_num is a single bit from
//                                    the testbench selecting 
//                                    which bus to drive
//                                  num_pulses is an integer from the 
//                                    testbench indicating how many 
//                                    successive pulses to send
//
//
//            transmit_col(port_num, rate_10bt, num_nibble, random_Nones,
//                     error_mode, symbol_mode, tx_w_crs)
//                      
//                           where all the parameters are as in the 
//                                    standard transmit task, BUT
//                                    this task does not add items
//                                    to the fifo. It is used to force
//                                    collesions
//
//            transmit_false_carrier(port_num, num_nibble)                      
// 
//                           where port_num port_num is a single bit from
//                                    the testbench selecting 
//                                    which bus to drive
//                                 num_nibble is an input from the 
//                                    testbench indicating how many nibbles 
//                                    to transmit. This is payload only; it
//                                    excludes preamble and sfd which are
//                                    added by this task
//                            assumes symbol mode and transmits idle after
//                               J-symbol
//                            no transmit data is put into the fifo
//
//            receive_false_carrier(port_num) 
//
//                           where port_num port_num is a single bit from
//                                    the testbench selecting 
//                                    which bus to drive
//
//            transmit_blw(port_num, polarity) 
//
//                           where port_num port_num is a single bit from
//                                    the testbench selecting 
//                                    which bus to drive
//                                 polarity indicates whether string of
//                                    pos. or neg. mlt3 marks are 
//                                    transmitted 
//
//  Note that ones transmission does not support symbol-mode at this time
//
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
`timescale 1ns/100ps
//`define ALIGN_MASK

//-----------------------------------------------------------------------
// mii frame header record 
//-----------------------------------------------------------------------
`define MII_FRAME_TYP [ 63:  0]
`define MII_PRE       [ 55:  0]
`define MII_SFD       [ 63: 56]
`define SYMBOL_10_TYP [  9:  0]

//-----------------------------------------------------------------------
// mii bus bus functional models
//-----------------------------------------------------------------------
module mii_pkg(
   TXC_0, 
   TXEN_0, 
   TXER_0,  
   TXD_0,
   RXC_0, 
   RXDV_0,  
   RXER_0, 
   RXD_0,
   CRS_0,
   COL_0,

   TXC_1, 
   TXEN_1, 
   TXER_1,  
   TXD_1,
   RXC_1, 
   RXDV_1,  
   RXER_1, 
   RXD_1,
   CRS_1,
   COL_1);

   input          TXC_0;
   output         TXEN_0;
   output         TXER_0;
   output [4:0]   TXD_0;
   input          RXC_0;
   input          RXDV_0;
   input          RXER_0;
   input  [4:0]   RXD_0;
   input 	  CRS_0;
   input 	  COL_0;

   input          TXC_1;
   output         TXEN_1;
   output         TXER_1;
   output [4:0]   TXD_1;
   input          RXC_1;
   input          RXDV_1;
   input          RXER_1;
   input  [4:0]   RXD_1;
   input 	  CRS_1;
   input 	  COL_1;  

   reg            TXEN_0;
   reg 	          TXER_0;
   reg [4:0] 	  TXD_0;

   reg            TXEN_1;
   reg 	          TXER_1;
   reg [4:0] 	  TXD_1;

   reg `MII_FRAME_TYP header;
   reg `SYMBOL_10_TYP symbol_jk;
   reg `SYMBOL_10_TYP symbol_ji;   
   reg `SYMBOL_10_TYP symbol_tr;  
   reg `SYMBOL_10_TYP symbol_sfd;   

   reg [4:0]      fifo [19:0];

   integer        fifo_in_ptr;
   integer        fifo_out_ptr;

   integer 	  txc_0_stamp;
   integer 	  txc_1_stamp;
   integer 	  rxc_0_stamp;
   integer 	  rxc_1_stamp; 
   integer 	  txc_0_period;
   integer 	  txc_1_period;
   integer 	  rxc_0_period;
   integer 	  rxc_1_period;   

   parameter Tx10Thold    = 5,
             Tx10Tsetup   = 10,
             Rx10Thold    = 30, 
             Rx10Tsetup   = 40, 
	     Tx100Thold   = 5,
             Tx100Tsetup  = 10,
             Rx100Thold   = 10,  
	     Rx100Tsetup  = 10,  
             RxTimeout    = 10000,
            `ifdef DSP_GATES	 
                UnalignedDly = 4;   // latency in unaligned mode 
            `else
                UnalignedDly = 0;   // latency in unaligned mode 
            `endif	 
	 

   
   //-------------------------------------------------------------------
   //initalize all registers
   //------------------------------------------------------------------- 
   initial begin  
      header`MII_PRE <= 56'h55555555555555; 
      header`MII_SFD <= 8'hD5;
      symbol_jk      <= 10'b1000111000;
      symbol_ji      <= 10'b1111111000;       
      symbol_tr      <= 10'b0011101101;      
      symbol_sfd     <= 10'b1101101011;
  
      TXEN_0 <= 1'b0;
      TXER_0 <= 1'b0;
      TXD_0  <= 5'b10000;
      TXEN_1 <= 1'b0;
      TXER_1 <= 1'b0;
      TXD_1  <= 5'b10000;   

      fifo_in_ptr  = 0;
      fifo_out_ptr = 0;   
   end

   //-------------------------------------------------------------------
   // task to sample clock periods
   //-------------------------------------------------------------------
   task get_clock_period;

      reg 	     in_use;

      begin 
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mii.get_clock_period was reentrant\n");
	    $finish;
	 end 
	 in_use = 1'b1;

         fork: txc_0_alive
            begin
               @(posedge TXC_0) txc_0_stamp  = $time;
               @(posedge TXC_0) txc_0_period = $time - txc_0_stamp;
               disable txc_0_alive;
            end

            #(801) disable txc_0_alive;
         join

         fork: txc_1_alive
            begin
               @(posedge TXC_1) txc_1_stamp  = $time;
               @(posedge TXC_1) txc_1_period = $time - txc_1_stamp;     
               disable txc_1_alive;
            end

            #(801) disable txc_1_alive;
         join

         fork: rxc_0_alive
            begin
               @(posedge RXC_0) rxc_0_stamp  = $time;
               @(posedge RXC_0) rxc_0_period = $time - rxc_0_stamp;
               disable rxc_0_alive;
            end

            #(801) disable rxc_0_alive;
         join

         fork: rxc_1_alive
            begin
               @(posedge RXC_1) rxc_1_stamp  = $time;
               @(posedge RXC_1) rxc_1_period = $time - rxc_1_stamp;
               disable rxc_1_alive;
            end

            #(801) disable rxc_1_alive;
         join

	 in_use = 1'b0;
      end
   endtask 
   
   //-------------------------------------------------------------------
   // fifo task for storing transmitted nibbles until checking
   // upon loopback receive
   //-------------------------------------------------------------------
   task put_fifo;
      input [4:0] nibble;

      begin
	 fifo[fifo_in_ptr] = nibble[4:0];
	 if (fifo_in_ptr == 19)
	    fifo_in_ptr = 0;
	 else
	    fifo_in_ptr = fifo_in_ptr + 1;
      end
      
   endtask

   //-------------------------------------------------------------------
   // fifo task for pulling nibble off to check against received data
   //-------------------------------------------------------------------
   task get_fifo;
      output [4:0] nibble;

      begin
	 nibble = fifo[fifo_out_ptr];	 
	 if (fifo_out_ptr == 19)
	    fifo_out_ptr = 0;
	 else
	    fifo_out_ptr = fifo_out_ptr + 1;
      end          
 
   endtask

   //-------------------------------------------------------------------
   // check_fifo task
   //------------------------------------------------------------------- 
   task check_fifo;
      output fifo_ok;

      reg 	     in_use;      
      reg 	     fifo_ok;
      
      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mii.check_fifo was reentrant\n");
	    $finish;
	 end 
	 in_use  = 1'b1;
	 fifo_ok = 1'b0;
	 
	 if (fifo_out_ptr == fifo_in_ptr)
	    fifo_ok = 1'b1;

         else begin
            fifo_out_ptr = 0;
	    fifo_in_ptr  = 0;	    
         end   

	 in_use = 1'b0;	 
      end

   endtask
     
   //-------------------------------------------------------------------
   // receive task
   //------------------------------------------------------------------- 
   task receive;
      input          port_num;
      input 	     rate_10bt;    
      input [ 1: 0]  symbol_mode;

      output 	     rcv_w_error;
      output 	     rcv_w_col;
      output 	     rcv_w_crs;      

      reg 	     in_use;
      reg   [ 4: 0]  data; 
      reg   [ 4 :0]  expected;
      reg   [ 4: 0]  aligned_data;  
      reg   [ 4: 0]  last_data;      
      reg 	     error_flag;
      reg 	     rcv_w_error;
      reg            rcv_w_col;
      reg            sfd_recvd;
      reg            preamble_recvd;
      reg            eof_recvd;      
      reg            rcv_w_crs;
      
      begin: rx_main
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mii.receive was reentrant\n");
	    $finish;
	 end 
	 in_use = 1'b1;
	 rcv_w_error    = 1'b0;
	 rcv_w_col      = 1'b0;
	 rcv_w_crs      = 1'b0;	 
	 sfd_recvd      = 1'b0;
	 preamble_recvd = 1'b0;
	 eof_recvd      = 1'b0;
	 
         // port 1
         if(port_num) begin
	    // watchdog timer looking for at least one RXC_1 rising edge
	    fork: wait_for_rxdv_1_2
               begin
                  @(posedge RXC_1);
	    
	          //select timing to use
                  if (rate_10bt)
	             #(rxc_1_period - Rx10Tsetup);	       
	          else
	             #(rxc_1_period - Rx100Tsetup);
                  disable wait_for_rxdv_1_2;
               end
		  
	       begin
                  #(RxTimeout);
		  $write("E: Wathdog timeout on mii.receive\n");
		  in_use = 1'b0;
		  disable rx_main;
		  // $finish
	       end
	    join

	    
	    // watchdog timer looking for start of data reception
            // resync to RXC each iteration as clock muxing can cause
            // phase error
	    fork: wait_for_rxdv_1
               begin
	          while (!RXDV_1) begin
                     @(posedge RXC_1);
                     if (rate_10bt)
		        // changed to not check RXDV setup to allow reception
		        // of 10base-t frames where the recovered RXC clock 
		        // is muxed out just before the sfd delimiter  
	                // #(rxc_1_period - Rx10Tsetup);		  
		        ;     
       
	             else
	                #(rxc_1_period - Rx100Tsetup);
                  end
                  disable wait_for_rxdv_1;
               end

	       begin
                  #(RxTimeout);
		  $write("E: Wathdog timeout on mii.receive\n");
		  in_use = 1'b0;
		  disable rx_main;
		  // $finish
	       end
	    join

            // receive data while data valid remains active
	    while (RXDV_1 & !eof_recvd) begin
	       // save received data at setup point
	       data[4:0] = RXD_1[4:0];
	       error_flag = RXER_1;
	       rcv_w_error = RXER_1 || rcv_w_error;
	       rcv_w_col = COL_1 || rcv_w_col;	       
	    
	       // delay to hold point unless in 10base-t mode on first
	       // frame bit (no setup check in this case)
               if (rate_10bt & !preamble_recvd)
                 ;
	       else
	          @(posedge RXC_1);

               if (rate_10bt)
	          #(Rx10Thold);	       
	       else
	          #(Rx100Thold);

               // check data remains the same at hold point
	       // (only if past header lock-in period in 10bt)
	       if (((data[4:0] != RXD_1[4:0]) | (error_flag != RXER_1)) &
                   (!rate_10bt | (rate_10bt & sfd_recvd))) begin
		  $write("E: Hold violation in mii.receive at %0d ns\n", $time);
                  $write("data = %b, RXD_1 = %b \n", data[4:0], RXD_1[4:0]);
                  //$finish;
	       end	       

	       // if in unaligned symbol mode shift data to realign using user-selected parameter
               if (symbol_mode === 2'b11) begin
                  `ifdef ALIGN_MASK
		     aligned_data = data;
		  `else
//		  if (UnalignedDly > 0)
//		    aligned_data = {last_data[UnalignedDly-1:0], data[4:UnalignedDly]};
//		  else
//		    aligned_data = data;
		  case (UnalignedDly)
		    0: aligned_data = data ;
		    1: aligned_data = {last_data[0], data[4:1]} ;
		    2: aligned_data = {last_data[1:0], data[4:2]} ;
		    3: aligned_data = {last_data[2:0], data[4:3]} ;
		    4: aligned_data = {last_data[3:0], data[4]} ;
		    default: aligned_data = data ;
		  endcase
		  `endif
		  last_data = data;
               end
	       
	       // check data against expected data in fifo
	       if (sfd_recvd) begin
		  // ignore mismatching TR control nibbles which are
		  // not stripped off in mii loopback		  
	          if (symbol_mode === 2'b01 & 
                      data[4:0] != 5'h0D & 
                      data[4:0] != 5'h07) begin	  

                     get_fifo(expected);	
	             if ((expected[4:0] != data[4:0]) &
                                           !rcv_w_error &
                                           !rcv_w_col) begin
 
	                $write("E: Received/expected mismatch in mii.receive at %0d ns\n", $time);
	                // $finish;
		     end
	          end

                  else if (symbol_mode === 2'b11 &
                      aligned_data[4:0] != 5'h0D & 
                      aligned_data[4:0] != 5'h07) begin	 
		     
                     get_fifo(expected);	
	             if ((expected[4:0] != aligned_data[4:0]) &
                                           !rcv_w_error &
                                           !rcv_w_col) begin
 
	                $write("E: Received/expected mismatch in mii.receive at %0d ns\n", $time);
	                // $finish;
		     end
		  end
		  		  
		  else begin 
                     if (!symbol_mode[0]) begin
		        get_fifo(expected);
		        if ((expected[3:0] != data[3:0]) &
                                              !rcv_w_error &
                                              !rcv_w_col) begin
	                   $write("E: Received/expected mismatch in mii.receive at %0d ns\n", $time);
	                   // $finish;
                        end
	             end 
		  end  
	       end   

	       // check CRS
	       if (CRS_1 === 1'b1) 
                  rcv_w_crs = 1'b1;
	       else
		  rcv_w_crs = 1'b0 | rcv_w_crs;	       
		  
	       // wait for next bit
               if (rate_10bt)
	          #(rxc_1_period - Rx10Tsetup - Rx10Thold);	       
	       else
	          #(rxc_1_period - Rx100Tsetup - Rx100Thold);

	       // update preamble/sfd been received flags?
               if (symbol_mode !== 2'b11) begin
	          if (data[3:0] == 4'h5 & !sfd_recvd)
                     preamble_recvd = 1'b1;

	          if (data[3:0] == 4'hD & preamble_recvd)
		     sfd_recvd = 1'b1;
	       end
               else begin
                  if (aligned_data[3:0] == 4'h5 & !sfd_recvd)
                    preamble_recvd = 1'b1;

	          if (aligned_data[3:0] == 4'hD & preamble_recvd)
		     sfd_recvd = 1'b1;

	          if (aligned_data[4:0] == 5'h07 & sfd_recvd)
		     eof_recvd = 1'b1;
	       end
	       
	    end 

	    // take one extra clock to detect COL after RXDV deassert
	    // such as in jabber detection
	    rcv_w_col = COL_1 || rcv_w_col;

	    // hold in receive task until CRS deactivates or until a
	    // a watchdog times out
            if (rcv_w_crs)
                fork: wait_for_crs_1
                   begin
	              while (CRS_1) #(rxc_1_period);	       
                      disable wait_for_crs_1;
		   end

	           begin
                      #(RxTimeout);
		      $write("E: CRS_1 wathdog timeout on mii.receive at %0d ns\n", $time);
		      in_use = 1'b0;
		      disable rx_main;
		      // $finish
	           end
	        join			 
	 end 

	 // port 0
	 else begin
	    // watchdog timer looking for at least one RXC_0 rising edge
	    fork: wait_for_rxdv_0_2
               begin
                  @(posedge RXC_0);
	    
	          //select timing to use
                  if (rate_10bt)
	             #(rxc_0_period - Rx10Tsetup);     
	          else
	             #(rxc_0_period - Rx100Tsetup);	  
                  disable wait_for_rxdv_0_2;
               end
		  
	       begin
                  #(RxTimeout);
		  $write("E: Wathdog timeout on mii.receive\n");
		  in_use = 1'b0;
		  disable rx_main;
		  // $finish
	       end
	    join
		  
	    // watchdog timer looking for start of data reception
            // resync to RXC each iteration as clock muxing can cause
            // phase error
	    fork: wait_for_rxdv_0
               begin
	          while (!RXDV_0) begin
                     @(posedge RXC_0);
                     if (rate_10bt)
		        // changed to not check RXDV setup to allow reception
		        // of 10base-t frames where the recovered RXC clock 
		        // is muxed out just before the sfd delimiter  
                        // #(rxc_0_period - Rx10Tsetup);	  
		        ;     
	             else
	                #(rxc_0_period - Rx100Tsetup);
                  end
                  disable wait_for_rxdv_0;
               end

	       begin
                  #(RxTimeout);
		  $write("E: Wathdog timeout on mii.receive\n");
		  in_use = 1'b0;
		  disable rx_main;
		  // $finish
	       end
	    join
	       
            // receive data while data valid remains active
	    while (RXDV_0 & !eof_recvd) begin
	       // save received data at setup point
	       data[4:0] = RXD_0[4:0];
	       error_flag = RXER_0;
	       rcv_w_error = RXER_0 || rcv_w_error;
	       rcv_w_col = COL_0 || rcv_w_col;
	    
	       // delay to hold point unless in 10base-t mode on first
	       // frame bit (no setup check in this case)
               if (rate_10bt & !preamble_recvd)
                 ;
	       else
	          @(posedge RXC_0);

               if (rate_10bt)
	          #(Rx10Thold);	       
	       else
	          #(Rx100Thold);
	       
               // check data remains the same at hold point
	       // (only if past header lock-in period in 10bt)
	       if (((data[4:0] != RXD_0[4:0]) | (error_flag != RXER_0)) &
                  (!rate_10bt | (rate_10bt & sfd_recvd))) begin		  
		  $write("E: Hold violation in mii.receive at %0d ns\n", $time);
                  $write("data = %b, RXD_0 = %b \n", data[4:0], RXD_0[4:0]); 
                  //$finish;
	       end 

               // if in unaligned symbol mode shift data to realign using user-selected parameter
               if (symbol_mode === 2'b11) begin
                  `ifdef ALIGN_MASK
		     aligned_data = data;
		  `else
//		     aligned_data = {last_data[UnalignedDly-1:0], data[4:UnalignedDly]};		  
		  case (UnalignedDly)
		    0: aligned_data = data ;
		    1: aligned_data = {last_data[0], data[4:1]} ;
		    2: aligned_data = {last_data[1:0], data[4:2]} ;
		    3: aligned_data = {last_data[2:0], data[4:3]} ;
		    4: aligned_data = {last_data[3:0], data[4]} ;
		    default: aligned_data = data ;
		  endcase
                  `endif
		  last_data = data;
               end                
	       
	       // check data against expected payload data in fifo
	       if (sfd_recvd) begin
		  // ignore mismatching TR control nibbles which are
		  // not stripped off now		  
	          if (symbol_mode === 2'b01 & 
                      data[4:0] != 5'h0D & 
                      data[4:0] != 5'h07) begin	  

                     get_fifo(expected);	
	             if ((expected[4:0] != data[4:0]) &
                                           !rcv_w_error &
                                           !rcv_w_col) begin
 
	                $write("E: Received/expected mismatch in mii.receive at %0d ns\n", $time);
                        $write("expected = %b, RXD_0 = %b \n", expected[4:0], RXD_0[4:0]); 
	                // $finish;
		     end
	          end

                  else if (symbol_mode === 2'b11 & 
                      aligned_data[4:0] != 5'h0D & 
                      aligned_data[4:0] != 5'h07) begin	 
		    
                     get_fifo(expected);	
	             if ((expected[4:0] != aligned_data[4:0]) &
                                           !rcv_w_error &
                                           !rcv_w_col) begin
 
	                $write("E: Mismatch in mii.receive at %0d ns\n", $time);
                        $write("expected = %b, aligned RXD_0 = %b \n", expected[4:0], aligned_data[4:0]); 
	                // $finish;
		     end
		  end
   
		  else begin 	
                     if (!symbol_mode[0]) begin                     
	                get_fifo(expected);
	                if ((expected[3:0] != data[3:0]) &
                                              !rcv_w_error &
                                              !rcv_w_col) begin
	                   $write("E: Received/expected mismatch in mii.receive at %0d ns\n", $time);
                           $write("expected = %b, RXD_0 = %b \n", expected[3:0], RXD_0[3:0]); 
	                   // $finish;
	                end 
                     end
		  end  
	       end       

	       // check CRS
	       if (CRS_0 === 1'b1) 
                  rcv_w_crs = 1'b1;
	       else
		  rcv_w_crs = 1'b0 | rcv_w_crs;	       

	       // wait for next bit
               if (rate_10bt)
	          #(rxc_0_period - Rx10Tsetup - Rx10Thold);	       
	       
	       else
	          #(rxc_0_period - Rx100Tsetup - Rx100Thold);

	       // update preamble/sfd been received flags?
               if (symbol_mode !== 2'b11) begin
	          if (data[3:0] == 4'h5 & !sfd_recvd)
                     preamble_recvd = 1'b1;

	          if (data[3:0] == 4'hD & preamble_recvd)
		     sfd_recvd = 1'b1;
	       end
               else begin
                  if (aligned_data[3:0] == 4'h5 & !sfd_recvd)
                    preamble_recvd = 1'b1;

	          if (aligned_data[3:0] == 4'hD & preamble_recvd)
		     sfd_recvd = 1'b1;

	          if (aligned_data[4:0] == 5'h07 & sfd_recvd)
		     eof_recvd = 1'b1;
	       end
		    		       
	    end 

	    // take one extra clock to detect COL after RXDV deassert
	    // such as in jabber detection
	    rcv_w_col = COL_0 || rcv_w_col;

	    // hold in receive task until CRS deactivates or until a
	    // a watchdog times out
            if (rcv_w_crs)
                fork: wait_for_crs_0
                   begin
	              while (CRS_0) #(rxc_0_period);	       
                      disable wait_for_crs_0;
		   end

	           begin
                      #(RxTimeout);
		      $write("E: CRS_0 wathdog timeout on mii.receive at %0d ns\n", $time);
		      in_use = 1'b0;
		      disable rx_main;
		      // $finish
	           end
	        join			 	    
         end	  
	    
	 in_use = 1'b0;	    
      end
   endtask // receive
   
   //-------------------------------------------------------------------
   // transmit task
   //------------------------------------------------------------------- 
   task transmit;
      input          port_num;
      input 	     rate_10bt;
      input  [31: 0] num_nibble;
      input 	     random_Nones;
      input 	     error_mode;     
      input  [ 1: 0] symbol_mode;
      output         tx_w_crs;
      
      integer 	     i;
      reg 	     in_use;      
      reg    [ 4: 0] data;
      reg            tx_w_crs;
      reg            test_10bt;
      
      
      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mii.transmit was reentrant\n");
	    $finish;
	 end 
	 in_use    = 1'b1;
         tx_w_crs  = 1'b0;
         test_10bt = 1'b0;	 
 

         //
	 // sync to clock and set tx enable
         //
	 if (port_num) begin 
            @(posedge TXC_1);
	 
	    //select transmit timing to use
            if (rate_10bt)
	       #(txc_1_period - Tx10Tsetup);
	    else
	       #(txc_1_period - Tx100Tsetup);

            // activate enable	    
            TXEN_1 <= 1'b1;

         end

	 else begin
	     @(posedge TXC_0);

	    // select transmit timing to use
            if (rate_10bt) 
	       #(txc_0_period - Tx10Tsetup);
  	
	    else 
	       #(txc_0_period - Tx100Tsetup);
	    
            // activate enable	    
            TXEN_0 <= 1'b1;	 

         end	 

         //
         // send header
         //
    	 if (port_num) begin 
            if (test_10bt)
	      // Do nothing
              #0;

            else begin 
              if (rate_10bt)  begin

               for (i=0; i<=13; i=i+1) begin
                  TXD_1[3:0] <= header`MII_PRE >> i*4;
	          #(Tx10Tsetup + Tx10Thold);
	          TXD_1  <= 4'hX;
		  #(0.5*txc_1_period);
		  if (CRS_1 === 1'b1) begin
                     if (i==0) 
                        tx_w_crs = 1'bZ;
                  end

		  else
		     tx_w_crs = 1'b0;
                  #(0.5*txc_1_period - Tx10Tsetup - Tx10Thold);
               end

               for (i=0; i<=1; i=i+1) begin
                  TXD_1[3:0] <= header`MII_SFD >> i*4;
	          #(Tx10Tsetup + Tx10Thold);
	          TXD_1  <= 4'hX;
		  if (CRS_1 === 1'b0) 
		     tx_w_crs = 1'b0;		  
                  #(txc_1_period - Tx10Tsetup - Tx10Thold);
               end

              end
  
	      else begin

               for (i=0; i<=13; i=i+1) begin
		  // if symbol mode, send 5-bit JK in first two nibbles
		  if (symbol_mode[0] && (i<=1)) begin
                     TXD_1[4:0] <= symbol_jk >> i*5;  
		  end

		  // else just send regular 14 nibble preamble 
		  else TXD_1[3:0] <= header`MII_PRE >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_1  <= 4'hX;
		  #(0.5*txc_1_period);
		  if (CRS_1 === 1'b1) begin
                     if (i==0) 
                        tx_w_crs = 1'bZ;
                  end

		  else
		     tx_w_crs = 1'b0;		  		  
                  #(0.5*txc_1_period - Tx100Tsetup - Tx100Thold);
               end

               for (i=0; i<=1; i=i+1) begin
		  // in case in symbol mode make sure not to send 5'h0D (symbol T)
		  TXD_1[4] <= 1'b1;		  
                  TXD_1[3:0] <= header`MII_SFD >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_1  <= 4'hX;
		  if (CRS_1 === 1'b0) 
		     tx_w_crs = 1'b0;			  	  
                  #(txc_1_period - Tx100Tsetup - Tx100Thold); 
               end

              end
            end

         end

         // port 0 header
         else begin

            if (test_10bt)
	      // Do nothing
              #0;

            else begin 
              if (rate_10bt)  begin	    
               for (i=0; i<=13; i=i+1) begin
                  TXD_0[3:0] <= header`MII_PRE >> i*4;
	          #(Tx10Tsetup + Tx10Thold);
	          TXD_0  <= 4'hX;
		  #(0.5*txc_0_period);
		  if (CRS_0 === 1'b1) begin
                     if (i==0)  
                        tx_w_crs = 1'bZ;
		  end

		  else
		     tx_w_crs = 1'b0;			  
                  #(0.5*txc_0_period - Tx10Tsetup - Tx10Thold);
               end

               for (i=0; i<=1; i=i+1) begin
                  TXD_0[3:0] <= header`MII_SFD >> i*4;
	          #(Tx10Tsetup + Tx10Thold);
	          TXD_0  <= 4'hX;
		  if (CRS_0 === 1'b0) 
		     tx_w_crs = 1'b0;			  
                  #(txc_0_period - Tx10Tsetup - Tx10Thold);
               end

              end
  
	      else begin

               for (i=0; i<=13; i=i+1) begin
		  // if symbol mode, send 5-bit JK in first two nibbles
		  if (symbol_mode[0] && (i<=1)) begin
                     TXD_0[4:0] <= symbol_jk >> i*5;  
		  end

		  // else just send regular 14 nibble preamble 
		  else TXD_0[3:0] <= header`MII_PRE >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_0  <= 4'hX;
		  #(0.5*txc_0_period);
		  if (CRS_0 === 1'b1) begin
                     if (i==0)  
                        tx_w_crs = 1'bZ;
		  end

		  else
		     tx_w_crs = 1'b0;		  			  
                  #(0.5*txc_0_period - Tx100Tsetup - Tx100Thold);
               end

               for (i=0; i<=1; i=i+1) begin
		  // in case in symbol mode make sure not to send 5'h0D (symbol T)
		  TXD_0[4] <= 1'b1;
                  TXD_0[3:0] <= header`MII_SFD >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_0  <= 4'hX;
		  if (CRS_0 === 1'b0) 
		     tx_w_crs = 1'b0;			  		  
                  #(txc_0_period - Tx100Tsetup - Tx100Thold); 
               end
              end
            end

         end
	       
         //
         // send payload
         //
	 // loop for specified number of clocks
	 for (i=num_nibble; i>=1; i=i-1) begin

	    // random data
	    if (random_Nones) begin
    	       if (port_num) begin 
	         if (i==num_nibble & error_mode) 
                    TXER_1 <= 1'b1;
		 else
                    TXER_1 <= 1'b0;

		 if (symbol_mode[0]) begin	
                   // if last bit in symbol mode, send TR nibble
		   // and don't put in fifo as it will be stripped off
		   if (i == 2) 
                      TXD_1[4:0] <= symbol_tr >> 0*5;
		    
		   else if (i == 1) 
                      TXD_1[4:0] <= symbol_tr >> 1*5;		    

		   // else pick random data and translate to pcs data code
		   // thus taking care not to send pcs control/invalid codes
		   else begin
		      case({$random} % 16)
			       0 : data[4:0] = 5'b11110;
			       1 : data[4:0] = 5'b01001;
			       2 : data[4:0] = 5'b10100;
			       3 : data[4:0] = 5'b10101;
			       4 : data[4:0] = 5'b01010;
			       5 : data[4:0] = 5'b01011;
			       6 : data[4:0] = 5'b01110;
			       7 : data[4:0] = 5'b01111;
			       8 : data[4:0] = 5'b10010;
			       9 : data[4:0] = 5'b10011;
			      10 : data[4:0] = 5'b10110;
			      11 : data[4:0] = 5'b10111;
			      12 : data[4:0] = 5'b11010;
			      13 : data[4:0] = 5'b11011;
			      14 : data[4:0] = 5'b11100;
			      15 : data[4:0] = 5'b11101;		
                         default : data[4:0] = 5'bXXXXX;
		      endcase

		      put_fifo(data);
		      TXD_1[4:0] <= data;
		   end   
		 end
		  
                 else begin
                    data[3:0] = $random;
		    put_fifo({1'bX, data});
		    TXD_1[3:0] <= data;		    
                 end		 
	       end 

	       else begin
	         if (i==num_nibble & error_mode) 
                    TXER_0 <= 1'b1;
		 else
                    TXER_0 <= 1'b0;	

		 if (symbol_mode[0]) begin	
                   // if last bit in symbol mode, send TR nibble
		   // and don't put in fifo as it will be stripped off
		   if (i == 2) 
                      TXD_0[4:0] <= symbol_tr >> 0*5;
		    
		   else if (i == 1) 
                      TXD_0[4:0] <= symbol_tr >> 1*5;		    

		   // else pick random data and translate to pcs data code
		   // thus taking care not to send pcs control/invalid codes
		   else begin
		      case({$random} % 16)
			       0 : data[4:0] = 5'b11110;
			       1 : data[4:0] = 5'b01001;
			       2 : data[4:0] = 5'b10100;
			       3 : data[4:0] = 5'b10101;
			       4 : data[4:0] = 5'b01010;
			       5 : data[4:0] = 5'b01011;
			       6 : data[4:0] = 5'b01110;
			       7 : data[4:0] = 5'b01111;
			       8 : data[4:0] = 5'b10010;
			       9 : data[4:0] = 5'b10011;
			      10 : data[4:0] = 5'b10110;
			      11 : data[4:0] = 5'b10111;
			      12 : data[4:0] = 5'b11010;
			      13 : data[4:0] = 5'b11011;
			      14 : data[4:0] = 5'b11100;
			      15 : data[4:0] = 5'b11101;		
                         default : data[4:0] = 5'bXXXXX;
		      endcase

		      put_fifo(data); 
	               TXD_0[4:0] <= data; 
                   end     
		 end

		 else begin
                   data[3:0] = $random;
		   put_fifo({1'bX, data}); 
	           TXD_0[3:0] <= data;
		 end

	       end 	  
	    end

	    // all ones data
	    else begin
    	       if (port_num) begin 
	         if (i==num_nibble & error_mode) 
                    TXER_1 <= 1'b1;
		 else
                    TXER_1 <= 1'b0;

		 if (symbol_mode[0]) begin		  
                    data[4:0] = 5'b11111;
		    put_fifo(data);
	            TXD_1[4:0] <= data;
		 end

                 else begin
                    data[3:0] = 4'hF;
		    put_fifo({1'bX, data});
	            TXD_1[3:0] <= data;
		 end 
		  
	       end 

	       else begin
	         if (i==num_nibble & error_mode) 
                    TXER_0 <= 1'b1;
		 else
                    TXER_0 <= 1'b0;

		 if (symbol_mode[0]) begin
                    data[4:0] = 5'b11111;
		    put_fifo(data);
	            TXD_0[4:0] <= data;
		 end

		 else begin
                    data[3:0] = 4'hF;
		    put_fifo({1'bX, data});
	            TXD_0[3:0] <= data;
		 end

	       end 	          
	    end 

	    // select transmit timing to use   
            if (rate_10bt)
	       #(Tx10Tsetup + Tx10Thold);	       
	    else
	       #(Tx100Tsetup + Tx100Thold);	   	       

	    // force unknowns, disable if last nibble
    	    if (port_num) begin

	       if (i==1) 
                  TXEN_1 <= 1'bX;

	       TXER_1 <= 1'bX; 
	       TXD_1  <= 4'hX;

               if (rate_10bt)
	          #(txc_1_period - Tx10Tsetup - Tx10Thold);	       
	       else
	          #(txc_1_period - Tx100Tsetup - Tx100Thold);	

	       if (CRS_1 === 1'b0) 
		  tx_w_crs = 1'b0;	       
	    end 

	    else begin
	       if (i==1) 
                  TXEN_0 <= 1'bX;

	       TXER_0 <= 1'bX; 
	       TXD_0  <= 4'hX;

               if (rate_10bt)
	          #(txc_0_period - Tx10Tsetup - Tx10Thold);	       
	       else
	          #(txc_0_period - Tx100Tsetup - Tx100Thold);	  

	       if (CRS_0 === 1'b0) 
		  tx_w_crs = 1'b0;	     
	    end 
	 end

	 // all outputs low
    	 if (port_num) begin 
            TXEN_1      <= 1'b0;
	    TXER_1      <= 1'b0; 
    	    TXD_1[4:0]  <= 4'h0;
	    if (rate_10bt) begin
	       #(0.5*txc_1_period + Tx10Tsetup + Tx10Thold);
	       if ((CRS_1 === 1'b0) && (tx_w_crs === 1'bZ)) 
		  tx_w_crs = 1'b1;
            end

	    else begin
	       #(0.5*txc_1_period + Tx100Tsetup + Tx100Thold);
	       if ((CRS_1 === 1'b0) && (tx_w_crs === 1'bZ)) 
		  tx_w_crs = 1'b1;
            end	       
	 end 

	 else begin
            TXEN_0      <= 1'b0;
	    TXER_0      <= 1'b0; 
	    TXD_0[4:0]  <= 4'h0;
	    if (rate_10bt) begin
	       #(0.5*txc_0_period + Tx10Tsetup + Tx10Thold);
	       if ((CRS_0 === 1'b0) && (tx_w_crs === 1'bZ)) 
		  tx_w_crs = 1'b1;
            end

	    else begin
	       #(0.5*txc_0_period + Tx100Tsetup + Tx100Thold);
	       if ((CRS_0 === 1'b0) && (tx_w_crs === 1'bZ)) 
		  tx_w_crs = 1'b1;
            end	       
	 end 

	 in_use = 1'b0;
      end
   endtask // transmit

   //-------------------------------------------------------------------
   // transmit_link_pulse task
   //------------------------------------------------------------------- 


   //-------------------------------------------------------------------
   // transmit_col task
   //------------------------------------------------------------------- 
   task transmit_col;
      input          port_num;
      input 	     rate_10bt;
      input  [31: 0] num_nibble;
      input 	     random_Nones;
      input 	     error_mode;     
      input  [ 1: 0] symbol_mode;
      output         tx_w_crs;
      
      integer 	     i;
      reg 	     in_use;      
      reg    [ 4: 0] data;
      reg            tx_w_crs;
      reg            test_10bt;
      
      
      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mii.transmit_col was reentrant\n");
	    $finish;
	 end 
	 in_use    = 1'b1;
         tx_w_crs  = 1'b0;
         test_10bt = 1'b0;	 
 
         //
	 // sync to clock and set tx enable
         //
	 if (port_num) begin 
            @(posedge TXC_1);
	 
	    //select transmit timing to use
            if (rate_10bt)
	       #(txc_1_period - Tx10Tsetup);	       
	    else
	       #(txc_1_period - Tx100Tsetup);

            // activate enable	    
            TXEN_1 <= 1'b1;	 
         end
	 
	 else begin
	     @(posedge TXC_0);

	    // select transmit timing to use
            if (rate_10bt) 
	       #(txc_0_period - Tx10Tsetup);	
	    else 
	       #(txc_0_period - Tx100Tsetup);
 
            // activate enable	    
            TXEN_0 <= 1'b1;	 
         end	 

         //
         // send header
         //
    	 if (port_num) begin 
            if (test_10bt)
	      // Do nothing
              #0;
	    
            else begin 
              if (rate_10bt)  begin

               for (i=0; i<=13; i=i+1) begin
                  TXD_1[3:0] <= header`MII_PRE >> i*4;
	          #(Tx10Tsetup + Tx10Thold);
	          TXD_1  <= 4'hX;
		  #(0.5*txc_1_period);
		  if (CRS_1 === 1'b1) begin
                     if (i==0) 
                        tx_w_crs = 1'bZ;
                  end
		     
		  else
		     tx_w_crs = 1'b0;
                  #(0.5*txc_1_period - Tx10Tsetup - Tx10Thold);
               end

               for (i=0; i<=1; i=i+1) begin
                  TXD_1[3:0] <= header`MII_SFD >> i*4;
	          #(Tx10Tsetup + Tx10Thold);
	          TXD_1  <= 4'hX;
		  if (CRS_1 === 1'b0) 
		     tx_w_crs = 1'b0;		  
                  #(txc_1_period - Tx10Tsetup - Tx10Thold);
               end

              end
  
	      else begin

               for (i=0; i<=13; i=i+1) begin
		  // if symbol mode, send 5-bit JK in first two nibbles
		  if (symbol_mode[0] && (i<=1)) begin
                     TXD_1[4:0] <= symbol_jk >> i*5;  
		  end

		  // else just send regular 14 nibble preamble 
		  else TXD_1[3:0] <= header`MII_PRE >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_1  <= 4'hX;
		  #(0.5*txc_1_period);
		  if (CRS_1 === 1'b1) begin
                     if (i==0) 
                        tx_w_crs = 1'bZ;
                  end
		     
		  else
		     tx_w_crs = 1'b0;		  		  
                  #(0.5*txc_1_period - Tx100Tsetup - Tx100Thold);
               end

               for (i=0; i<=1; i=i+1) begin
		  // in case in symbol mode make sure not to send 5'h0D (symbol T)
		  TXD_1[4] <= 1'b1;		  
                  TXD_1[3:0] <= header`MII_SFD >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_1  <= 4'hX;
		  if (CRS_1 === 1'b0) 
		     tx_w_crs = 1'b0;			  	  
                  #(txc_1_period - Tx100Tsetup - Tx100Thold); 
               end
              end
            end

         end

         // port 0 header
         else begin

            if (test_10bt)
	      // Do nothing
              #0;

            else begin 
              if (rate_10bt)  begin	    
               for (i=0; i<=13; i=i+1) begin
                  TXD_0[3:0] <= header`MII_PRE >> i*4;
	          #(Tx10Tsetup + Tx10Thold);
	          TXD_0  <= 4'hX;
		  #(0.5*txc_0_period);
		  if (CRS_0 === 1'b1) begin
                     if (i==0)  
                        tx_w_crs = 1'bZ;
		  end
		  
		  else
		     tx_w_crs = 1'b0;			  
                  #(0.5*txc_0_period - Tx10Tsetup - Tx10Thold);
               end

               for (i=0; i<=1; i=i+1) begin
                  TXD_0[3:0] <= header`MII_SFD >> i*4;
	          #(Tx10Tsetup + Tx10Thold);
	          TXD_0  <= 4'hX;
		  if (CRS_0 === 1'b0) 
		     tx_w_crs = 1'b0;			  
                  #(txc_0_period - Tx10Tsetup - Tx10Thold);
               end

              end
  
	      else begin

               for (i=0; i<=13; i=i+1) begin
		  // if symbol mode, send 5-bit JK in first two nibbles
		  if (symbol_mode[0] && (i<=1)) begin
                     TXD_0[4:0] <= symbol_jk >> i*5;  
		  end

		  // else just send regular 14 nibble preamble 
		  else TXD_0[3:0] <= header`MII_PRE >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_0  <= 4'hX;
		  #(0.5*txc_0_period);
		  if (CRS_0 === 1'b1) begin
                     if (i==0)  
                        tx_w_crs = 1'bZ;
		  end
		  
		  else
		     tx_w_crs = 1'b0;		  			  
                  #(0.5*txc_0_period - Tx100Tsetup - Tx100Thold);
               end

               for (i=0; i<=1; i=i+1) begin
		  // in case in symbol mode make sure not to send 5'h0D (symbol T)
		  TXD_0[4] <= 1'b1;
                  TXD_0[3:0] <= header`MII_SFD >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_0  <= 4'hX;
		  if (CRS_0 === 1'b0) 
		     tx_w_crs = 1'b0;			  		  
                  #(txc_0_period - Tx100Tsetup - Tx100Thold); 
               end
              end
            end

         end
	       
         //
         // send payload
         //
	 // loop for specified number of clocks
	 for (i=num_nibble; i>=1; i=i-1) begin
	    
	    // random data
	    if (random_Nones) begin
    	       if (port_num) begin 
	         if (i==num_nibble & error_mode) 
                    TXER_1 <= 1'b1;
		 else
                    TXER_1 <= 1'b0;

		 if (symbol_mode[0]) begin	
                   // if last bit in symbol mode, send TR nibble
		   // and don't put in fifo as it will be stripped off
		   if (i == 2) 
                      TXD_1[4:0] <= symbol_tr >> 0*5;
		    
		   else if (i == 1) 
                      TXD_1[4:0] <= symbol_tr >> 1*5;		    

		   // else pick random data and translate to pcs data code
		   // thus taking care not to send pcs control/invalid codes
		   else begin
		      case({$random} % 16)
			       0 : data[4:0] = 5'b11110;
			       1 : data[4:0] = 5'b01001;
			       2 : data[4:0] = 5'b10100;
			       3 : data[4:0] = 5'b10101;
			       4 : data[4:0] = 5'b01010;
			       5 : data[4:0] = 5'b01011;
			       6 : data[4:0] = 5'b01110;
			       7 : data[4:0] = 5'b01111;
			       8 : data[4:0] = 5'b10010;
			       9 : data[4:0] = 5'b10011;
			      10 : data[4:0] = 5'b10110;
			      11 : data[4:0] = 5'b10111;
			      12 : data[4:0] = 5'b11010;
			      13 : data[4:0] = 5'b11011;
			      14 : data[4:0] = 5'b11100;
			      15 : data[4:0] = 5'b11101;		
                         default : data[4:0] = 5'bXXXXX;
		      endcase
	  
		      TXD_1[4:0] <= data;
		   end   
		 end
		  
                 else begin
                    data[3:0] = $random;
		    TXD_1[3:0] <= data;		    
                 end		 
	       end 
	       
	       else begin
	         if (i==num_nibble & error_mode) 
                    TXER_0 <= 1'b1;
		 else
                    TXER_0 <= 1'b0;	

		 if (symbol_mode[0]) begin	
                   // if last bit in symbol mode, send TR nibble
		   // and don't put in fifo as it will be stripped off
		   if (i == 2) 
                      TXD_0[4:0] <= symbol_tr >> 0*5;
		    
		   else if (i == 1) 
                      TXD_0[4:0] <= symbol_tr >> 1*5;		    

		   // else pick random data and translate to pcs data code
		   // thus taking care not to send pcs control/invalid codes
		   else begin
		      case({$random} % 16)
			       0 : data[4:0] = 5'b11110;
			       1 : data[4:0] = 5'b01001;
			       2 : data[4:0] = 5'b10100;
			       3 : data[4:0] = 5'b10101;
			       4 : data[4:0] = 5'b01010;
			       5 : data[4:0] = 5'b01011;
			       6 : data[4:0] = 5'b01110;
			       7 : data[4:0] = 5'b01111;
			       8 : data[4:0] = 5'b10010;
			       9 : data[4:0] = 5'b10011;
			      10 : data[4:0] = 5'b10110;
			      11 : data[4:0] = 5'b10111;
			      12 : data[4:0] = 5'b11010;
			      13 : data[4:0] = 5'b11011;
			      14 : data[4:0] = 5'b11100;
			      15 : data[4:0] = 5'b11101;		
                         default : data[4:0] = 5'bXXXXX;
		      endcase

	               TXD_0[4:0] <= data; 
                   end     
		 end

		 else begin
                   data[3:0] = $random;
	           TXD_0[3:0] <= data;
		 end

	       end 	  
	    end
	    
	    // all ones data
	    else begin
    	       if (port_num) begin 
	         if (i==num_nibble & error_mode) 
                    TXER_1 <= 1'b1;
		 else
                    TXER_1 <= 1'b0;

		 if (symbol_mode[0]) begin		  
                    data[4:0] = 5'b11111;
	            TXD_1[4:0] <= data;
		 end
		  
                 else begin
                    data[3:0] = 4'hF;
	            TXD_1[3:0] <= data;
		 end 
		  
	       end 
	       
	       else begin
	         if (i==num_nibble & error_mode) 
                    TXER_0 <= 1'b1;
		 else
                    TXER_0 <= 1'b0;

		 if (symbol_mode[0]) begin
                    data[4:0] = 5'b11111;
	            TXD_0[4:0] <= data;
		 end

		 else begin
                    data[3:0] = 4'hF;
	            TXD_0[3:0] <= data;
		 end

	       end 	          
	    end 

	    // select transmit timing to use   
            if (rate_10bt)
	       #(Tx10Tsetup + Tx10Thold);	       
	    else
	       #(Tx100Tsetup + Tx100Thold);	   	       
	    
	    // force unknowns, disable if last nibble
    	    if (port_num) begin

	       if (i==1) 
                  TXEN_1 <= 1'bX;

	       TXER_1 <= 1'bX; 
	       TXD_1  <= 4'hX;
	       
               if (rate_10bt)
	          #(txc_1_period - Tx10Tsetup - Tx10Thold);	       
	       else
	          #(txc_1_period - Tx100Tsetup - Tx100Thold);	

	       if (CRS_1 === 1'b0) 
		  tx_w_crs = 1'b0;	       
	    end 
	       
	    else begin
	       if (i==1) 
                  TXEN_0 <= 1'bX;

	       TXER_0 <= 1'bX; 
	       TXD_0  <= 4'hX;

               if (rate_10bt)
	          #(txc_0_period - Tx10Tsetup - Tx10Thold);	       
	       else
	          #(txc_0_period - Tx100Tsetup - Tx100Thold);	  

	       if (CRS_0 === 1'b0) 
		  tx_w_crs = 1'b0;	     
	    end 
	 end

	 // all outputs low
    	 if (port_num) begin 
            TXEN_1      <= 1'b0;
	    TXER_1      <= 1'b0; 
    	    TXD_1[4:0]  <= 4'h0;
	    if (rate_10bt) begin
	       #(0.5*txc_1_period + Tx10Tsetup + Tx10Thold);
	       if ((CRS_1 === 1'b0) && (tx_w_crs === 1'bZ)) 
		  tx_w_crs = 1'b1;
            end

	    else begin
	       #(0.5*txc_1_period + Tx100Tsetup + Tx100Thold);
	       if ((CRS_1 === 1'b0) && (tx_w_crs === 1'bZ)) 
		  tx_w_crs = 1'b1;
            end	       
	 end 
	       
	 else begin
            TXEN_0      <= 1'b0;
	    TXER_0      <= 1'b0; 
	    TXD_0[4:0]  <= 4'h0;
	    if (rate_10bt) begin
	       #(0.5*txc_0_period + Tx10Tsetup + Tx10Thold);
	       if ((CRS_0 === 1'b0)&& (tx_w_crs === 1'bZ)) 
		  tx_w_crs = 1'b1;
            end

	    else begin
	       #(0.5*txc_0_period + Tx100Tsetup + Tx100Thold);
	       if ((CRS_0 === 1'b0) && (tx_w_crs === 1'bZ)) 
		  tx_w_crs = 1'b1;
            end	       
	 end 
	 
	 in_use = 1'b0;
      end
   endtask // transmit_col


   //-------------------------------------------------------------------
   // transmit_false_carrier task
   //------------------------------------------------------------------- 
   task transmit_false_carrier;
      input          port_num;
      input  [31: 0] num_nibble;
      
      integer 	     i;
      reg 	     in_use; 
      reg 	     fc_sent;      
      reg    [ 4: 0] data;
      
      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mii.transmit_false_carrier was reentrant\n");
	    $finish;
	 end 
	 in_use    = 1'b1;
	 fc_sent   = 1'b0;
 
         //
	 // sync to clock and set tx enable
         //
	 if (port_num) begin 
            @(posedge TXC_1);
	    #(txc_1_period - Tx100Tsetup);
            // activate enable	    
            TXEN_1 <= 1'b1;	 
         end
	 
	 else begin
	     @(posedge TXC_0);
	     #(txc_0_period - Tx100Tsetup);
            // activate enable	    
            TXEN_0 <= 1'b1;	 
         end	 

         //
         // send header
         //
    	 if (port_num) begin 
               for (i=0; i<=13; i=i+1) begin
		  // send 5-bit JI in first two nibbles
		  if (i<=1) begin
                     TXD_1[4:0] <= symbol_ji >> i*5;  
		  end

		  // else just send regular 14 nibble preamble 
		  else TXD_1[4:0] <= 5'b01011;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_1  <= 4'hX;	  
                  #(txc_1_period - Tx100Tsetup - Tx100Thold);
               end

               for (i=0; i<=1; i=i+1) begin
                  TXD_1[4:0] <= symbol_sfd >> i*5;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_1  <= 4'hX;		  
                  #(txc_0_period - Tx100Tsetup - Tx100Thold); 
               end    
              
         end

         // port 0 header
         else begin	    
               for (i=0; i<=13; i=i+1) begin
		  // send 5-bit JI in first two nibbles
		  if (i<=1) begin
                     TXD_0[4:0] <= symbol_ji >> i*5;  
		  end

		  // else just send regular 14 nibble preamble 
		  else TXD_0[4:0] <= 5'b01011;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_0  <= 4'hX;		  			  
                  #(txc_0_period - Tx100Tsetup - Tx100Thold);
               end

               for (i=0; i<=1; i=i+1) begin
                  TXD_0[4:0] <= symbol_sfd >> i*5;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_0  <= 4'hX;		  
                  #(txc_0_period - Tx100Tsetup - Tx100Thold); 
               end
	    
         end
	       
         //
         // send payload
         //
	 // loop for specified number of clocks
	 for (i=num_nibble; i>=1; i=i-1) begin
    	       if (port_num) begin 
                   // if last bit in symbol mode, send TR nibble
		   // and don't put in fifo as it will be stripped off
		   if (i == 2) 
                      TXD_1[4:0] <= symbol_tr >> 0*5;
		    
		   else if (i == 1) 
                      TXD_1[4:0] <= symbol_tr >> 1*5;		    
		  
		   // pick random data and translate to pcs data code
		   // thus taking care not to send pcs control/invalid codes
		   else begin
 		         case({$random} % 16)
			          0 : data[4:0] = 5'b11110;
			          1 : data[4:0] = 5'b01001;
			          2 : data[4:0] = 5'b10100;
			          3 : data[4:0] = 5'b10101;
			          4 : data[4:0] = 5'b01010;
			          5 : data[4:0] = 5'b01011;
			          6 : data[4:0] = 5'b01110;
			          7 : data[4:0] = 5'b01111;
			          8 : data[4:0] = 5'b10010;
			          9 : data[4:0] = 5'b10011;
			         10 : data[4:0] = 5'b10110;
			         11 : data[4:0] = 5'b10111;
			         12 : data[4:0] = 5'b11010;
			         13 : data[4:0] = 5'b11011;
			         14 : data[4:0] = 5'b11100;
			         15 : data[4:0] = 5'b11101;		
                            default : data[4:0] = 5'bXXXXX;
		         endcase

		      TXD_1[4:0] <= data;
		   end   		 
	        end 
	       
	        else begin
                   // if last bit in symbol mode, send TR nibble
		   // and don't put in fifo as it will be stripped off
		   if (i == 2) 
                      TXD_0[4:0] <= symbol_tr >> 0*5;
		    
		   else if (i == 1) 
                      TXD_0[4:0] <= symbol_tr >> 1*5;		    

		   // else pick random data and translate to pcs data code
		   // thus taking care not to send pcs control/invalid codes
		   else begin

		         case({$random} % 16)
			          0 : data[4:0] = 5'b11110;
			          1 : data[4:0] = 5'b01001;
			          2 : data[4:0] = 5'b10100;
			          3 : data[4:0] = 5'b10101;
			          4 : data[4:0] = 5'b01010;
			          5 : data[4:0] = 5'b01011;
			          6 : data[4:0] = 5'b01110;
			          7 : data[4:0] = 5'b01111;
			          8 : data[4:0] = 5'b10010;
			          9 : data[4:0] = 5'b10011;
			         10 : data[4:0] = 5'b10110;
			         11 : data[4:0] = 5'b10111;
			         12 : data[4:0] = 5'b11010;
			         13 : data[4:0] = 5'b11011;
			         14 : data[4:0] = 5'b11100;
			         15 : data[4:0] = 5'b11101;		
                            default : data[4:0] = 5'bXXXXX;
		         endcase

	               TXD_0[4:0] <= data; 
                   end     
	        end 	  

	        #(Tx100Tsetup + Tx100Thold);	   	       
	    
	        // force unknowns, disable if last nibble
    	        if (port_num) begin
	           if (i==1) 
                      TXEN_1 <= 1'bX;
 
	           TXD_1  <= 4'hX;
	           #(txc_1_period - Tx100Tsetup - Tx100Thold);	
	       
	        end 
	       
	        else begin
	           if (i==1) 
                      TXEN_0 <= 1'bX;

	           TXD_0  <= 4'hX;
	           #(txc_0_period - Tx100Tsetup - Tx100Thold);	  
	     
	        end 
	 end

	 // all outputs low
    	 if (port_num) begin 
            TXEN_1      <= 1'b0;
	    TXER_1      <= 1'b0; 
    	    TXD_1[4:0]  <= 4'h0;

	    #(0.5*txc_1_period + Tx100Tsetup + Tx100Thold);
	 end 
	       
	 else begin
            TXEN_0      <= 1'b0;
	    TXER_0      <= 1'b0; 
	    TXD_0[4:0]  <= 4'h0;

	    #(0.5*txc_0_period + Tx100Tsetup + Tx100Thold);
	 end 
	 
	 in_use = 1'b0;
      end
   endtask // transmit_false_carrier

   //-------------------------------------------------------------------
   // receive_false_carrier task
   //------------------------------------------------------------------- 
   task receive_false_carrier;
      input          port_num;    

      reg 	     in_use;   
      
      begin: rx_fse_car_main
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mii.receive_false_carrier was reentrant\n");
	    $finish;
	 end 
	 in_use = 1'b1;

	 
         // port 1
         if(port_num) begin
            @(posedge RXC_1);
	    #(rxc_1_period - Rx100Tsetup);

	    // watchdog timer looking for start of false_carrier indication
            // resync to RXC each iteration as clock muxing can cause
            // phase error
	    fork: wait_for_rxer_1
               begin
	          while (!RXER_1) begin
                     @(posedge RXC_1);
 	             #(rxc_1_period - Rx100Tsetup);
                  end
                  disable wait_for_rxer_1;
               end

	       begin
                  #(RxTimeout);
		  $write("E: Wathdog timeout on mii.receive_false_carrier\n");
		  in_use = 1'b0;
		  disable rx_fse_car_main;
		  // $finish
	       end
	    join

	    while (RXER_1) begin
	       // check RXDV deasserted and data is 5'h0E at data setup point
               if (RXDV_1 | (RXD_1[4:0] != 5'h0E))
	          $write("E: Improperly formated false carrier at %0d ns\n", $time);

               @(posedge RXC_1);
               #(Rx100Thold);
	       // check RXDV deasserted and data is 5'h0E at data hold point
               if (RXDV_1 | (RXD_1[4:0] != 5'h0E))
	          $write("E: Improperly formated false carrier at %0d ns\n", $time);
               #(rxc_1_period - Rx100Tsetup - Rx100Thold);
	    end 

         end

	 else begin
            @(posedge RXC_0);
	    #(rxc_0_period - Rx100Tsetup);

	    // watchdog timer looking for start of false_carrier indication
            // resync to RXC each iteration as clock muxing can cause
            // phase error
	    fork: wait_for_rxer_0
               begin
	          while (!RXER_0) begin
                     @(posedge RXC_0);
 	             #(rxc_0_period - Rx100Tsetup);
                  end
                  disable wait_for_rxer_0;
               end

	       begin
                  #(RxTimeout);
		  $write("E: Wathdog timeout on mii.receive_false_carrier\n");
		  in_use = 1'b0;
		  disable rx_fse_car_main;
		  // $finish
	       end
	    join

	    while (RXER_0) begin
	       // check RXDV deasserted and data is 5'h0E at data setup point
               if (RXDV_0 | (RXD_0[4:0] != 5'h0E))
	          $write("E: Improperly formated false carrier at %0d ns\n", $time);

               @(posedge RXC_0);
               #(Rx100Thold);
	       // check RXDV deasserted and data is 5'h0E at data hold point
               if (RXDV_0 | (RXD_0[4:0] != 5'h0E))
	          $write("E: Improperly formated false carrier at %0d ns\n", $time);
               #(rxc_0_period - Rx100Tsetup - Rx100Thold);
            end

	 end
	    
	 in_use = 1'b0;	    
      end
   endtask // receive_false_carrier   



   //-------------------------------------------------------------------
   // transmit_blw task
   //------------------------------------------------------------------- 
`ifdef NOTVAMS
   task transmit_blw;
      input          port_num;
      input          polarity;

      integer 	     i;
      integer 	     j;      
      reg 	     in_use;      
      reg    [ 4: 0] data;      
      
      begin
	 // check non-reentrant task guard semaphore
	 if (in_use === 1'b1) begin
	    $display("E: Call to mii.transmit_blw was reentrant\n");
	    $finish;
	 end 
	 in_use    = 1'b1;	 
 
         //
	 // sync to clock and set tx enable
         //
	 if (port_num) begin 
            @(posedge TXC_1);
	    #(txc_1_period - Tx100Tsetup);   
            TXEN_1 <= 1'b1;	 
         end
	 
	 else begin
	     @(posedge TXC_0);
	     #(txc_0_period - Tx100Tsetup);
            TXEN_0 <= 1'b1;	 
         end	 

         //
         // send header
         //
    	 if (port_num) begin 

               for (i=0; i<=13; i=i+1) begin
		  // send 5-bit JK in first two nibbles
		  if (i<=1) begin
                     TXD_1[4:0] <= symbol_jk >> i*5;  
		  end

		  // else just send regular 14 nibble preamble 
		  else TXD_1[3:0] <= header`MII_PRE >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_1  <= 4'hX;
                  #(txc_1_period - Tx100Tsetup - Tx100Thold);
               end

               for (i=0; i<=1; i=i+1) begin
		  // in case in symbol mode make sure not to send 5'h0D (symbol T)
		  TXD_1[4] <= 1'b1;		  
                  TXD_1[3:0] <= header`MII_SFD >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_1  <= 4'hX;		  	  
                  #(txc_1_period - Tx100Tsetup - Tx100Thold); 
               end

         end

         // port 0 header
         else begin

               for (i=0; i<=13; i=i+1) begin
		  // if symbol mode, send 5-bit JK in first two nibbles
		  if (i<=1) begin
                     TXD_0[4:0] <= symbol_jk >> i*5;  
		  end

		  // else just send regular 14 nibble preamble 
		  else TXD_0[3:0] <= header`MII_PRE >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_0  <= 4'hX;	  			  
                  #(txc_0_period - Tx100Tsetup - Tx100Thold);
               end

               for (i=0; i<=1; i=i+1) begin
		  // in case in symbol mode make sure not to send 5'h0D (symbol T)
		  TXD_0[4] <= 1'b1;
                  TXD_0[3:0] <= header`MII_SFD >> i*4;
	          #(Tx100Tsetup + Tx100Thold);
	          TXD_0  <= 4'hX;		  		  
                  #(txc_0_period - Tx100Tsetup - Tx100Thold); 
               end

         end

	 
         //
         // send payload
         //
	 // loop for specified number of clocks
	 for (i=1; i<=14; i=i+1) begin
            for (j=1; j<=13; j=j+1) begin
    	       if (port_num) begin 

                 // sync up to marks
		 if ((j==1) && (i==1)) begin
                    if (polarity) begin		  
//                       if (test.top.I0.I1.I01.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b00) begin
//                          data[4:0] = 5'b11100;
//		          put_fifo(data);
//	                  TXD_1[4:0] <= data;
//		       end

//		       else if (test.top.I0.I1.I01.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b10) begin
//                          data[4:0] = 5'b00000;
//		          put_fifo(data);
//	                  TXD_1[4:0] <= data;
//		       end

//		       else if (test.top.I0.I1.I01.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b11) begin
//                          data[4:0] = 5'b10000;
//		          put_fifo(data);
//	                  TXD_1[4:0] <= data;
//		       end		       

//		       else  begin
                          data[4:0] = 5'b11000;
		          put_fifo(data);
	                  TXD_1[4:0] <= data;
//		       end
                    end

		    else begin
//                       if (test.top.I0.I1.I01.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b01) begin
//                         data[4:0] = 5'b00000;
//		          put_fifo(data);
//	                  TXD_1[4:0] <= data;
//		       end

//		       else if (test.top.I0.I1.I01.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b00) begin
//                         data[4:0] = 5'b10000;
//		          put_fifo(data);
//	                  TXD_1[4:0] <= data;
//		       end

//		       else if (test.top.I0.I1.I01.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b11) begin
//                          data[4:0] = 5'b11100;
//		          put_fifo(data);
//	                  TXD_1[4:0] <= data;
//		       end		       

//		       else  begin
                          data[4:0] = 5'b11000;
		          put_fifo(data);
	                  TXD_1[4:0] <= data;
//		       end
                    end		      
		 end

                 // send TR nibble
		 // and don't put in fifo as it will be stripped off		  
		 else if ((j==12) && (i==14))
                    TXD_1[4:0] <= symbol_tr >> 0*5;		  

		 else if ((j==13) && (i==14))
                    TXD_1[4:0] <= symbol_tr >> 1*5;
	
                 // insert 4 mlt3 ones	
		 else if (j==13) begin		  
                    data[4:0] = 5'b01111;
		    put_fifo(data);
	            TXD_1[4:0] <= data;
		 end		  

		 // insert string of zeros to force blw event
		 else begin
                    data[4:0] = 5'b00000;
		    put_fifo(data);
	            TXD_1[4:0] <= data;
		 end
		  
	       end 
	       
	       else begin

                 // sync up to marks
		 if ((j==1) && (i==1)) begin
                    if (polarity) begin		  
                       if (test.top.I0.I00.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b00) begin
                          data[4:0] = 5'b11100;
		          put_fifo(data);
	                  TXD_0[4:0] <= data;
		       end

		       else if (test.top.I0.I00.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b10) begin
                          data[4:0] = 5'b00000;
		          put_fifo(data);
	                  TXD_0[4:0] <= data;
		       end

		       else if (test.top.I0.I00.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b11) begin
                          data[4:0] = 5'b10000;
		          put_fifo(data);
	                  TXD_0[4:0] <= data;
		       end		       

		       else  begin
                          data[4:0] = 5'b11000;
		          put_fifo(data);
	                  TXD_0[4:0] <= data;
		       end
                    end

		    else begin
                       if (test.top.I0.I00.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b01) begin
                          data[4:0] = 5'b00000;
		          put_fifo(data);
	                  TXD_0[4:0] <= data;
		       end

		       else if (test.top.I0.I00.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b00) begin
                          data[4:0] = 5'b10000;
		          put_fifo(data);
	                  TXD_0[4:0] <= data;
		       end

		       else if (test.top.I0.I00.I0.i_top_digital.MLT3_TDATA[1:0] === 2'b11) begin
                          data[4:0] = 5'b11100;
		          put_fifo(data);
	                  TXD_0[4:0] <= data;
		       end		       

		       else  begin
                          data[4:0] = 5'b11000;
		          put_fifo(data);
	                  TXD_0[4:0] <= data;
		       end
                    end		      
		 end

                 // send TR nibble
		 // and don't put in fifo as it will be stripped off		  
		 else if ((j==12) && (i==14))
                    TXD_0[4:0] <= symbol_tr >> 0*5;		  

		 else if ((j==13) && (i==14))
                    TXD_0[4:0] <= symbol_tr >> 1*5;
	
                 // insert 4 mlt3 ones			  
		 else if (j==13) begin
                    data[4:0] = 5'b01111;
		    put_fifo(data);
	            TXD_0[4:0] <= data;
		 end

		 // insert string of zeros to force blw event
		 else begin
                    data[4:0] = 5'b00000;
		    put_fifo(data);
	            TXD_0[4:0] <= data;
		 end

               end

	       // select transmit timing to use   
	       #(Tx100Tsetup + Tx100Thold);	   	       
	    
	       // force unknowns, disable if last nibble
    	       if (port_num) begin

	          if ((i==14) && (j==13)) 
                     TXEN_1 <= 1'bX;

	          TXER_1 <= 1'bX; 
	          TXD_1  <= 4'hX;
	       
	          #(txc_1_period - Tx100Tsetup - Tx100Thold);	
	       
               end 
	       
	       else begin
	          if ((i==14) && (j==13)) 
                     TXEN_0 <= 1'bX;

	          TXER_0 <= 1'bX; 
	          TXD_0  <= 4'hX;

 	          #(txc_0_period - Tx100Tsetup - Tx100Thold);	  
	     
	       end 
            end
	 end

	 // all outputs low
    	 if (port_num) begin 
            TXEN_1      <= 1'b0;
	    TXER_1      <= 1'b0; 
    	    TXD_1[4:0]  <= 4'h0;
	    #(0.5*txc_1_period + Tx100Tsetup + Tx100Thold);    
	 end 
	       
	 else begin
            TXEN_0      <= 1'b0;
	    TXER_0      <= 1'b0; 
	    TXD_0[4:0]  <= 4'h0;
	    #(0.5*txc_0_period + Tx100Tsetup + Tx100Thold); 
	 end 
	 
	 in_use = 1'b0;
      end
   endtask // transmit_blw
`else
    initial
     #100 $display("Skipping transmit_blw task \n");
`endif
   
endmodule 
