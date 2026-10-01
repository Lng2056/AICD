// Verilog HDL for "tsmc13fLucy_rt", "PLL_ARST_DIG" "verilog"

module PLL_ARST_DIG (DUMP, COMP, PD, REFCLK, VDD, VSS);
    output DUMP;
    input COMP;
    input PD;
    input REFCLK;
    input VDD;
    input VSS;

    reg DUMP;

    always @(posedge REFCLK)
       DUMP <= COMP;
       

endmodule
