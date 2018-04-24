module adc_module(clk,
						ADC_clk,
						ADC,
						ADC_out
						);

input clk;
output wire ADC_clk;
input wire[7:0] ADC;
output reg[7:0] ADC_out;
assign ADC_clk = clk;
always @ (negedge clk)begin
	ADC_out <= ADC;

end
						
						
						
						
						
						
endmodule						
						
						