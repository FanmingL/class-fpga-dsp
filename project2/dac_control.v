module dac_control(clk,
							clk_high,
							KEY_STATE,
							q_a,
							dac_value,
							number_on_digitron,
							shank_position,
							point_position,
							address_a);
								
input clk, clk_high;
output reg[7:0] dac_value;
input wire[9:0] KEY_STATE;
input wire[7:0] q_a;
output reg[5:0] shank_position, point_position;
output reg[10:0] address_a;
output reg [19:0] number_on_digitron;
reg[7:0] dcrease_count;
reg[7:0] out_reg;
reg[7:0] FSM;
reg[7:0] step;
reg clk_out;
reg out_dir;
reg[15:0] fixed_point_number, real_frequency, step_add_high, step_add_low, step_test;
reg[4:0] key_used;
reg[19:0] exp_number [0:5];
reg[19:0] exp_number2 [0:5];
reg[3:0] set_number_index;
reg[31:0] step_counter;
reg show_flag;


initial begin
	out_reg <= 1;
	address_a <= 0;
	step <= 2;
	step_test <= 100;
	real_frequency <= 50;
	exp_number[5] <= 1;
	exp_number[4] <= 10;
	exp_number[3] <= 100;
	exp_number[2] <= 1000;
	exp_number[1] <= 10000;
	exp_number[0] <= 100000;
	exp_number2[5] <= 2;
	exp_number2[4] <= 20;
	exp_number2[3] <= 200;
	exp_number2[2] <= 2000;
	exp_number2[1] <= 20000;
	exp_number2[0] <= 200000;
	point_position <= 6'b000000;
	set_number_index <= 5;
	show_flag <= 1;
end
always @ (posedge clk_high)begin
	dcrease_count <= dcrease_count + 1;
	if (dcrease_count == 10)begin
		dcrease_count <= 0;
		clk_out <= ~clk_out;
	end
end

always @ (posedge clk_high) begin
	dac_value = q_a;
end							
							
	
always @ (posedge clk_high)begin
	if (show_flag)begin
		number_on_digitron[15:0] = real_frequency;
		point_position = 6'b000000;
	end 
end

always @ (negedge clk_high)begin
	if (step_counter < 200000 - step_test)begin
		step_counter = step_counter + step_test;
	end else begin
		step_counter = step_counter + step_test ;
		step_counter = step_counter - 200000 ;
	end
	address_a = (step_counter / 100);
end


always @ (posedge clk_high) begin
	//number_on_digitron = real_frequency;
	shank_position = (1<<set_number_index);
	if (show_flag)begin
		if (KEY_STATE[3])begin
			if (!key_used[3])begin
				key_used[3] = 1;
				if (set_number_index == 5)begin
					set_number_index = 0;
				end else begin
					set_number_index = set_number_index + 1;
				end//if set_number_index == 5
			end //if !key_used[3]
		end else begin
			key_used[3] = 0;
		end //if KEY_STATE[3]
		
		if (KEY_STATE[2])begin
			if (!key_used[2])begin
				key_used[2] = 1;
				if (set_number_index == 0)begin
					set_number_index = 5;
				end else begin
					set_number_index = set_number_index - 1;
				end//if set_number_index == 0
			end //if !key_used[2]
		end else begin
			key_used[2] = 0;
		end //if KEY_STATE[2]
		
		
		if (KEY_STATE[0])begin
			if (!key_used[0])begin
				key_used[0] = 1;
				if (real_frequency + exp_number[set_number_index]<=25000)begin
					real_frequency = real_frequency + exp_number[set_number_index];
					step_test = step_test + exp_number2[set_number_index];
				end //<25000
			end //if !key_used[0]
		end else begin
			key_used[0] = 0;
		end //if KEY_STATE[0]
		
		if (KEY_STATE[1])begin
			if (!key_used[1])begin
				key_used[1] = 1;
				if (real_frequency >= exp_number[set_number_index] && real_frequency > 50)begin
					real_frequency = real_frequency - exp_number[set_number_index];
					step_test = step_test - exp_number2[set_number_index];
				end //>exp_number[set_number_index]
			end //if !key_used[1]
		end else begin
			key_used[1] = 0;
		end //if KEY_STATE[1]
	end
	if (KEY_STATE[4])begin
		if (!key_used[4])begin
			key_used[4] = 1;
			show_flag = ~show_flag;
		end //if !key_used[4]
	end else begin
		key_used[4] = 0;
	end //if KEY_STATE[4]
	
	
end
							
endmodule							
