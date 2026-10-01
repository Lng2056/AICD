// Verilog HDL for "drouillard_ms", "pi_lvshift" "behavioral"

module pi_lvshift (phase_1p0v, AGND, AVDD_2p5V, DVDD, phase_2p5v);

output [21:0] phase_1p0v;
input AGND;
input AVDD_2p5V;
input DVDD;
input [21:0] phase_2p5v;

wire [21:0] phase_1p0v = phase_2p5v;

endmodule
