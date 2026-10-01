// Verilog HDL for "drouillard_ms", "dffnr_2x_hv" "verilog"
`timescale 1ps/1ps

module dffnr_2x_hv (Q, QN, D, CKN, RN);
    output Q;
    output QN;
    input D;
    input CKN;
    input RN;

    reg qreg;

    specify
	(CKN*>Q) = (300,300); // specify rise/fall prop delays
	(CKN*>QN) = (300,300);
	(RN*>Q) = (20,20);
	(RN*>QN) = (20,20);
    endspecify

  always @(negedge CKN or negedge RN)
	if (RN) qreg <= D;
	else qreg <= 1'b0;
  buf ibuf(Q,qreg); // must use primitive for outputs
  not inot(QN,qreg);
endmodule
