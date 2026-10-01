`timescale 1ns/1ns
module test_xtal25 (XTAL25);

parameter Clk25Period         = 40;             // 25Mhz Clock
output          XTAL25;
wire       XTAL25;


// Simulation Clocks and Controls
reg        sim_clk25;

xtal_pkg xtal ( .sim_clk25(sim_clk25), .XTAL25(XTAL25));

initial begin
     sim_clk25     = 1'b0;
end

always begin
          #(Clk25Period/2.0) sim_clk25 = 1'b0;
          #(Clk25Period/2.0) sim_clk25 = 1'b1;
end

endmodule
