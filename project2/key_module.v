module key_module(	clk,
								key,
								KEY_STATE);
					
					 
	input wire[4:0] key;
	input clk;
	reg [31:0] system_time;
	reg [31:0] record_time [0:4];
	reg [4:0]active_flag;
	output reg [9:0]KEY_STATE;
	reg [15:0] long_time_length;
	initial begin
		system_time <= 0;
		record_time[0] <= 0;
		record_time[1] <= 0;
		record_time[2] <= 0;
		record_time[3] <= 0;
		record_time[4] <= 0;
		active_flag <= 4'b00000;
		long_time_length <= 2000;		//2000ms to set long flag
	end
	
	
	
	always @ (posedge clk) begin
		system_time <= system_time + 1;
		if (system_time == 32'hFFFFFFFE) begin
			system_time <= 0;
		end
	end

	
	//KEY TASK
	always @ (posedge clk) begin
		if (~key[0]) begin
			if (active_flag[0]) begin
				if (system_time - record_time[0] >= 30) begin
					KEY_STATE[0] <= 1;
					if (system_time - record_time[0] >= long_time_length) begin 
						KEY_STATE[5] <= 1;
					end
				end
			end
			else begin
				active_flag[0] <= 1'b1;
				record_time[0] <= system_time;
			end
		end
		else begin 
			active_flag[0] <= 1'b0;
			KEY_STATE[0] <= 0;
			KEY_STATE[5] <= 0;
		end
		
		if (~key[1]) begin
			if (active_flag[1]) begin
				if (system_time - record_time[1] >= 30) begin
					KEY_STATE[1] <= 1;
					if (system_time - record_time[1]>= long_time_length) begin 
						KEY_STATE[6] <= 1;
					end
				end
			end
			else begin
				active_flag[1] <= 1'b1;
				record_time[1] <= system_time;
			end
		end
		else begin 
			active_flag[1] <= 1'b0;
			KEY_STATE[1] <= 0;
			KEY_STATE[6] <= 0;
		end
		
		if (~key[2]) begin
			if (active_flag[2]) begin
				if (system_time - record_time[2]>= 30) begin
					KEY_STATE[2] <= 1;
					if (system_time - record_time[2]>= long_time_length) begin 
						KEY_STATE[7] <= 1;
					end
				end
			end
			else begin
				active_flag[2] <= 1'b1;
				record_time[2] <= system_time;
				KEY_STATE[2] <= 0;
				KEY_STATE[7] <= 0;
			end
		end
		else begin 
			active_flag[2] <= 1'b0;
			KEY_STATE[2] <= 0;
			KEY_STATE[7] <= 0;
		end
		
		if (~key[3]) begin
			if (active_flag[3]) begin
				if (system_time - record_time[3] >= 30) begin
					KEY_STATE[4] <= 1;
					if (system_time - record_time[3] >= long_time_length) begin 
						KEY_STATE[9] <= 1;
					end
				end
				
			end
			else begin
				active_flag[3] <= 1'b1;
				record_time[3] <= system_time;
			end
		end
		else begin 
			active_flag[3] <= 1'b0;
			KEY_STATE[4] <= 0;
			KEY_STATE[9] <= 0;
		end
		
		if (~key[4]) begin
			
			if (active_flag[4]) begin
				if (system_time - record_time[4]>= 30) begin
					KEY_STATE[3] <= 1;
					if (system_time - record_time[4] >= long_time_length) begin 
						KEY_STATE[8] <= 1;
					end	
				end
			end
			else begin
				active_flag[4] <= 1'b1;
				record_time[4] <= system_time;
			end
		end
		else begin 
			active_flag[4] <= 1'b0;
			KEY_STATE[3] <= 0;
			KEY_STATE[8] <= 0;
		end
	end
endmodule
