// Verilog HDL for "drouillard_ms", "dffr_2x_hv" "verilog"
`timescale 1ps/1ps

module dffr_2x_hv (Q, QN, D, CK, RN);
    output Q;
    output QN;
    input D;
    input CK;
    input RN;

    reg qreg;

    specify
	(CK*>Q) = (250,250); // specify rise/fall prop delays
	(CK*>QN) = (250,250);
	(RN*>Q) = (20,20);
	(RN*>QN) = (20,20);
    endspecify
   
    always @(posedge CK or negedge RN) 
	if (RN) qreg <= D;
	else qreg <= 1'b0;
    buf ibuf(Q,qreg); // must use primitive for output;
    not inot(QN,qreg);

endmodule
