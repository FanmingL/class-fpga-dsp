module dac_module(clk,
						dac_val,
						dac_clk,
						dac_pin
						);
input clk;
input wire[7:0] dac_val;
output wire dac_clk;
output reg [7:0] dac_pin;
assign dac_clk = clk;

always @ (negedge clk)begin
	//dac_clk <= ~dac_clk;
	dac_pin <= dac_val;
end				
					
endmodule
					