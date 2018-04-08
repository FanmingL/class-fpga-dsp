module decrease_clock(clk_in, 
							clk_out, //1kHz
							clk_out_high,//100kHz
							system_time_ms,//system time in ms
							system_time_ms10); //system time in 10 ms
input clk_in;
output reg clk_out, clk_out_high;
output reg[31:0] system_time_ms, system_time_ms10;
reg [31:0] clk_count, clk_count2,clk_count_high;
initial begin	
	clk_count <= 0;
	clk_count_high <= 0;
	system_time_ms <= 0;
	system_time_ms10 <= 0;
	clk_count2 <= 0;
end

always @ (posedge clk_in) begin
	clk_count <= clk_count + 1;
	if (clk_count == 25000) begin
		clk_out = ~clk_out;
	end else if (clk_count == 50000)begin
		clk_count <= 0;
		clk_out = ~clk_out;
		system_time_ms <= system_time_ms + 1;
		
	end
end

always @ (posedge clk_in) begin
	clk_count2 <= clk_count2 + 1;
	if (clk_count2 == 500000)begin
		clk_count2 <= 0;
		system_time_ms10 <= system_time_ms10 + 1;
		
	end
end

always @ (posedge clk_in) begin
	clk_count_high <= clk_count_high + 1;
	if (clk_count_high == 250) begin
		clk_count_high <= 0;
		clk_out_high = ~clk_out_high;
	end
end


endmodule
