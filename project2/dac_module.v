module dac_module(clk,
						dac_val,
						dac_clk,
						dac_pin
						);
input clk;
input wire[7:0] dac_val;
output reg dac_clk;
output reg [7:0] dac_pin;

always @ (posedge clk)begin
	dac_clk <= ~dac_clk;
	dac_pin <= dac_val;
end				
					
endmodule
					