module decrease_clock(clk_in, 
							clk_out, //1kHz
							clk_out_high,//100kHz
							system_time_ms,//system time in ms
							system_time_ms10, //system time in 10 ms
							clk_1M,
							clk_5M);
input clk_in;
output reg clk_out, clk_out_high, clk_1M, clk_5M;
output reg[31:0] system_time_ms, system_time_ms10;
reg [31:0] clk_count, clk_count2,clk_count_high,clk_1M_counter,clk_5M_counter;
initial begin	
	clk_count <= 0;
	clk_count_high <= 0;
	system_time_ms <= 0;
	system_time_ms10 <= 0;
	clk_count2 <= 0;
	clk_1M_counter <= 0;
	clk_5M_counter <= 0;
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

always @ (posedge clk_in)begin
	clk_1M_counter = clk_1M_counter + 1;
	if (clk_1M_counter == 25) begin
		clk_1M_counter = 0;
		clk_1M = ~clk_1M;
	end
end

always @ (posedge clk_in)begin
	clk_5M_counter = clk_5M_counter + 1;
	if (clk_5M_counter == 5) begin
		clk_5M_counter = 0;
		clk_5M = ~clk_5M;
	end
end
endmodule
