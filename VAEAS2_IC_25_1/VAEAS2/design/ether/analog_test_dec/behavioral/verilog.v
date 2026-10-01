// Verilog HDL for  "analog_test_dec" "behavioral"

module analog_test_dec (
   ADC_DIS, 
   ADC_TEST, 
   AEQ_DIS, 
   BLW_DIS, 
   FX_DIS,       
   X10_DIS,
   TX100_DIS,
   RCLK125_TST_SEL,  
   SIDDQ, 
   TEST_MODE,     
   BASEFX_DIS, 
   BASE10X_DIS, 
   BASE100X_DIS);
   
   output      ADC_DIS;
   output      ADC_TEST;
   output      AEQ_DIS;
   output      BLW_DIS;
   output      FX_DIS;
   output      X10_DIS;
   output      TX100_DIS;
   output      RCLK125_TST_SEL;   

   input       SIDDQ;
   input [2:0] TEST_MODE;
   input       BASEFX_DIS;
   input       BASE10X_DIS;
   input       BASE100X_DIS;

   reg         NO_TEST;   
   reg 	       ADC_TEST;
   reg 	       AEQ_TEST;   
   reg 	       FX_TEST;
   reg 	       X10_TEST;
   reg 	       TX100_TEST;
   reg 	       PLL_PI_TEST;
   reg 	       BLW_TEST;   


   wire        SOFT_PWDN      =  BASEFX_DIS &  BASE10X_DIS &  BASE100X_DIS;
   wire        B10_RESOLVED   =  BASEFX_DIS & !BASE10X_DIS &  BASE100X_DIS;  
   wire        B100T_RESOLVED =  BASEFX_DIS &  BASE10X_DIS & !BASE100X_DIS;
   wire        B100F_RESOLVED = !BASEFX_DIS &  BASE10X_DIS &  BASE100X_DIS;    
   
   // assignments for creating single disables from
   // siddq mode, test mode, or 10bt-100bt-100bf selection 

   assign FX_DIS   = FX_TEST ? 
                        (SIDDQ | SOFT_PWDN) : 
                        (NO_TEST ? 
                           (SIDDQ | SOFT_PWDN | B10_RESOLVED | B100T_RESOLVED) : 
                           1'b1);

   assign BLW_DIS  = (BLW_TEST | PLL_PI_TEST | X10_TEST) ? 
                        (SIDDQ | SOFT_PWDN) : 
                        (NO_TEST ? 
                           (SIDDQ | SOFT_PWDN | B100F_RESOLVED) : 
                           1'b1);
 
   assign AEQ_DIS  = (AEQ_TEST | PLL_PI_TEST | BLW_TEST) ? 
                        (SIDDQ | SOFT_PWDN) : 
                        (NO_TEST ? 
                           (SIDDQ | SOFT_PWDN | B10_RESOLVED | B100F_RESOLVED) : 
                           1'b1);
   
   assign ADC_DIS  = (ADC_TEST | AEQ_TEST | BLW_TEST | PLL_PI_TEST | FX_TEST) ?
                        (SIDDQ | SOFT_PWDN) :
                        (NO_TEST ?
                           (SIDDQ | SOFT_PWDN | B10_RESOLVED) :
                           1'b1);

   assign X10_DIS  = X10_TEST ? 
                        (SIDDQ | SOFT_PWDN) : 
                        (NO_TEST ? 
                           (SIDDQ | SOFT_PWDN | B100T_RESOLVED | B100F_RESOLVED) : 
                           1'b1);

   assign TX100_DIS = TX100_TEST ?
	               (SIDDQ | SOFT_PWDN) :
                       (NO_TEST ? 
                          (SIDDQ | SOFT_PWDN | B10_RESOLVED | B100F_RESOLVED) : 
                          1'b1);
    
   assign RCLK125_TST_SEL = ADC_TEST | AEQ_TEST | BLW_TEST | FX_TEST;
   
   // analog test mode decoder
   always @(TEST_MODE)
      case(TEST_MODE)
         3'b001: begin
	    NO_TEST    = 1'b0;
	    ADC_TEST   = 1'b1;
            AEQ_TEST   = 1'b0;
            FX_TEST    = 1'b0;
            X10_TEST   = 1'b0;
            TX100_TEST = 1'b0;
	    PLL_PI_TEST= 1'b0;
            BLW_TEST   = 1'b0;	    
         end

         3'b010: begin
	    NO_TEST    = 1'b0;
	    ADC_TEST   = 1'b0;
            AEQ_TEST   = 1'b1;
            FX_TEST    = 1'b0;
            X10_TEST   = 1'b0;
            TX100_TEST = 1'b0;
	    PLL_PI_TEST= 1'b0;	
            BLW_TEST   = 1'b0;	     
         end

         3'b011: begin
	    NO_TEST    = 1'b0;
	    ADC_TEST   = 1'b0;
            AEQ_TEST   = 1'b0;
            FX_TEST    = 1'b0;
            X10_TEST   = 1'b0;
            TX100_TEST = 1'b1;
	    PLL_PI_TEST= 1'b0;
            BLW_TEST   = 1'b0;	 	    
         end

         3'b100: begin
	    NO_TEST    = 1'b0;
	    ADC_TEST   = 1'b0;
            AEQ_TEST   = 1'b0;
            FX_TEST    = 1'b0;
            X10_TEST   = 1'b0;
            TX100_TEST = 1'b0;
	    PLL_PI_TEST= 1'b1;	
            BLW_TEST   = 1'b0;	     
         end   
	
         3'b101: begin
	    NO_TEST    = 1'b0;
	    ADC_TEST   = 1'b0;
            AEQ_TEST   = 1'b0;
            FX_TEST    = 1'b0;
            X10_TEST   = 1'b1;
            TX100_TEST = 1'b0;
	    PLL_PI_TEST= 1'b0;
            BLW_TEST   = 1'b0;	 	    
         end	

         3'b110: begin
	    NO_TEST    = 1'b0;
	    ADC_TEST   = 1'b0;
            AEQ_TEST   = 1'b0;
            FX_TEST    = 1'b1;
            X10_TEST   = 1'b0;
            TX100_TEST = 1'b0;
	    PLL_PI_TEST= 1'b0;	  
            BLW_TEST   = 1'b0;	   
         end

         3'b111: begin
	    NO_TEST    = 1'b0;
	    ADC_TEST   = 1'b0;
            AEQ_TEST   = 1'b0;
            FX_TEST    = 1'b0;
            X10_TEST   = 1'b0;
            TX100_TEST = 1'b0;
	    PLL_PI_TEST= 1'b0;	  
            BLW_TEST   = 1'b1;	   
         end			 

	 default: begin
	    NO_TEST    = 1'b1;
	    ADC_TEST   = 1'b0;
            AEQ_TEST   = 1'b0;
            FX_TEST    = 1'b0;
            X10_TEST   = 1'b0;
            TX100_TEST = 1'b0;
	    PLL_PI_TEST= 1'b0;
            BLW_TEST   = 1'b0;	 	    
         end	   
      endcase 

endmodule

