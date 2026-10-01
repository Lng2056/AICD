// Verilog HDL for "drouillard_ms", "dff_1x_hv" "verilog"
`timescale 1ps/1ps

module dff_1x_hv (Q, QN, D, CK);
    output Q;
    output QN;
    input D;
    input CK;

    reg qreg;

    always @(posedge CK) qreg <= D;
    wire #(250) Q = qreg;
    wire #(250)  QN = !qreg;
endmodule
