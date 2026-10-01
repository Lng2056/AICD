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

