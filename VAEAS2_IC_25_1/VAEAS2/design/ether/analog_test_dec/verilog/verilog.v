// Verilog HDL for "ether", "analog_test_dec_lvshift" "verilog"
// 2004-10-29: RayV created this Verilog view for demonstrate the inhConn
//             on digital sandwitch module (verilog view in between the
//             upper schematic and the lower schematic).
// ---------------------------------------------------------------------------

module analog_test_dec ( ADC_DIS, ADC_TEST, AEQ_DIS, BLW_DIS, FX_DIS,
     X10_DIS, TX100_DIS, RCLK125_TST_SEL, SIDDQ, TEST_MODE, BASEFX_DIS,
     BASE10X_DIS, BASE100X_DIS );
 
output  ADC_DIS, ADC_TEST, AEQ_DIS, BLW_DIS, FX_DIS, RCLK125_TST_SEL,
        TX100_DIS, X10_DIS;
 
input  BASE10X_DIS, BASE100X_DIS, BASEFX_DIS, SIDDQ;
 
input [2:0]  TEST_MODE;
 
 
CLKINVX1  i_92 ( .Y(n_56), .A(TEST_MODE[1]));
OAI21XL  i_39 ( .B0(n_37), .Y(n_36), .A0(TEST_MODE[1]), .A1(n_46));
OAI21XL  i_18 ( .B0(TEST_MODE[2]), .Y(n_42), .A0(TEST_MODE[0]),
     .A1(n_56));
OAI21XL  i_21 ( .B0(n_18), .Y(RCLK125_TST_SEL), .A0(TEST_MODE[1]),
     .A1(n_45));
OAI31XL  i_63 ( .A2(n_52), .B0(n_49), .Y(ADC_DIS),
     .A0(RCLK125_TST_SEL), .A1(n_44));
OAI211X1  i_14 ( .Y(n_26), .A0(n_44), .A1(TEST_MODE[1]), .C0(n_33),
     .B0(n_45));
AO22X1  i_36 ( .B1(n_44), .Y(n_32), .A0(n_48), .B0(TEST_MODE[1]),
     .A1(n_52));
OAI2BB1X1  i_20 ( .B0(TEST_MODE[1]), .Y(n_18), .A0N(n_46),
     .A1N(TEST_MODE[0]));
OAI2BB1X1  i_71 ( .B0(n_49), .Y(TX100_DIS), .A0N(n_30), .A1N(n_29));
OAI2BB1X1  i_67 ( .B0(n_49), .Y(AEQ_DIS), .A0N(n_26), .A1N(n_29));
OAI2BB1X1  i_83 ( .B0(n_49), .Y(BLW_DIS), .A0N(n_42), .A1N(n_55));
AOI211X1  i_3 ( .Y(n_52), .A0(BASE100X_DIS), .A1(BASEFX_DIS),
     .C0(n_50), .B0(TEST_MODE[1]));
OR2X1  i_24 ( .B(TEST_MODE[0]), .Y(n_50), .A(TEST_MODE[2]));
NOR2X1  i_1 ( .B(n_45), .Y(ADC_TEST), .A(TEST_MODE[1]));
NOR2X1  i_0 ( .B(n_50), .Y(n_51), .A(TEST_MODE[1]));
NAND2BX1  i_15 ( .B(TEST_MODE[1]), .Y(n_30), .AN(n_45));
NAND2BX1  i_7 ( .B(n_48), .Y(n_37), .AN(n_55));
NAND2BX1  i_9 ( .B(TEST_MODE[0]), .Y(n_45), .AN(TEST_MODE[2]));
NOR2BX1  i_6 ( .B(TEST_MODE[0]), .Y(n_44), .AN(TEST_MODE[2]));
AOI31X1  i_2 ( .A2(BASE100X_DIS), .B0(SIDDQ), .Y(n_49),
     .A0(BASEFX_DIS), .A1(BASE10X_DIS));
NAND2X1  i_4 ( .B(n_52), .Y(n_29), .A(n_23));
NAND2X1  i_12 ( .B(BASE10X_DIS), .Y(n_48), .A(BASEFX_DIS));
NAND2X1  i_29 ( .B(BASE10X_DIS), .Y(n_23), .A(BASE100X_DIS));
NAND2X1  i_79 ( .B(n_49), .Y(X10_DIS), .A(n_36));
NAND2X1  i_8 ( .B(n_44), .Y(n_33), .A(TEST_MODE[1]));
NAND2X1  i_5 ( .B(n_51), .Y(n_55), .A(n_23));
NAND2X1  i_11 ( .B(TEST_MODE[0]), .Y(n_46), .A(TEST_MODE[2]));
NAND2X1  i_75 ( .B(n_32), .Y(FX_DIS), .A(n_49));
 
endmodule
// ------------------- End of file ------------------------
