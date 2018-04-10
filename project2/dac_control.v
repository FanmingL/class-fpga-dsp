module dac_control(clk,
							clk_high,
							KEY_STATE,
							q_a,
							dac_value,
							number_on_digitron,
							address_a);
								
input clk, clk_high;
output reg[7:0] dac_value;
input wire[9:0] KEY_STATE;
input wire[7:0] q_a;
output reg[10:0] address_a;
output reg [19:0] number_on_digitron;
reg[7:0] dcrease_count;
reg[7:0] out_reg;
reg[7:0] FSM;
reg[7:0] step;
reg clk_out;
reg out_dir;
reg[15:0] fixed_point_number;
initial begin
	out_reg <= 1;
	address_a <= 0;
	step <= 2;
end
always @ (posedge clk_high)begin
	dcrease_count <= dcrease_count + 1;
	if (dcrease_count == 10)begin
		dcrease_count <= 0;
		clk_out <= ~clk_out;
	end
end

always @ (posedge clk) begin
	if (address_a >= 2000-step)begin
		address_a = 0;
	end else begin
		address_a = address_a + step;
	end
	dac_value = q_a;
end							
							
always @ (posedge clk_out )begin
	number_on_digitron[7:0] = q_a;
	fixed_point_number = fixed_point_number/10;
end
					
							
endmodule							
