// Verilog HDL for "training", "digStim" "behavioral"
`timescale 1ns / 1ns

module digStim(out1,out2);

	output out1, out2;

	reg out1, out2;

initial

	begin

out1 = 0;
out2 = 1;

#50
out1 = 1 ;
out2 = 0 ;

#50
out1 = 0 ;

#50
out1 = 1 ;
out2 = 1 ;

end

endmodule
