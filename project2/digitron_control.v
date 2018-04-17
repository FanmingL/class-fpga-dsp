module digitron_control(clk,
								KEY_STATE,
								point_position, 
								shank_position,
								number_to_show);
input clk;
input wire[9:0] KEY_STATE;
output reg[5:0]point_position, shank_position;
output reg[19:0]number_to_show;
reg[4:0] FSM;
reg[3:0] set_number_index;
reg[3:0] key_used; 
reg[19:0] start_time;
reg[19:0] exp_number [0:5];
reg[3:0] lf_count;
/*
*0: Start & Setting Mode
*1: Counting Mode
*2: Pausing & KeyEnter Mode
*3: Nearly to end 
*4: End 
*/
initial begin
	point_position <= 6'b000000;    //point position
	shank_position <= 6'b000000;    //to select which to shank
	start_time <= 0;
	number_to_show <= 0;
	FSM <= 0;
	set_number_index <= 5;
	key_used <= 4'b0000;
	exp_number[5] <= 1;
	exp_number[4] <= 10;
	exp_number[3] <= 100;
	exp_number[2] <= 1000;
	exp_number[1] <= 10000;
	exp_number[0] <= 100000;
	
end
//FSM control
always @ (posedge clk) begin
	case(FSM)
	0:begin
//		if (KEY_STATE[4]==1&&!KEY_STATE[9])begin
//			FSM = 2;
//		end
	end
	
	1:begin
		if (KEY_STATE[4]==1)begin
			FSM = 2;
		end else if (number_to_show <= 300)begin
			FSM = 3;
		end else if (number_to_show == 0) begin
			FSM = 4;
		end
	end
	
	2:begin
		if (KEY_STATE[9]==1)begin
			FSM = 0;
		end else if (KEY_STATE[4]==0)begin
			FSM = 1;
		end
	end
	
	3:begin
		if (KEY_STATE[4]==1)begin
			FSM = 2;
		end else if (number_to_show == 0) begin
			FSM = 4;
		end
	end
	
	4:begin
		if (KEY_STATE[4]==1)begin
			FSM = 2;
		end
	end
	
	endcase
end



always @ (posedge clk) begin
	if (FSM == 0)begin
		number_to_show = start_time;
		shank_position = (1<<set_number_index);
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
				if (start_time + exp_number[set_number_index]<=999999)begin
					start_time = start_time + exp_number[set_number_index];
				end //<999999
			end //if !key_used[0]
		end else begin
			key_used[0] = 0;
		end //if KEY_STATE[0]
		
		if (KEY_STATE[1])begin
			if (!key_used[1])begin
				key_used[1] = 1;
				if (start_time >= exp_number[set_number_index])begin
					start_time = start_time - exp_number[set_number_index];
				end //>exp_number[set_number_index]
			end //if !key_used[1]
		end else begin
			key_used[1] = 0;
		end //if KEY_STATE[1]
		
	end//if FSM==0
	else if (FSM == 1||FSM == 3)begin
		shank_position  = 0;
		if (lf_count==9)begin
			lf_count = 0;
			if (number_to_show != 0)begin
				number_to_show = number_to_show - 1;
			end//number_to_show != 1
		end else begin
			lf_count = lf_count + 1;
		end //lf_count==9
	end//if FSM==1
	else if (FSM==3)begin
		shank_position  = 0;
		if (lf_count==9)begin
			lf_count = 0;
			if (number_to_show != 0)begin
				number_to_show = number_to_show - 1;
			end//number_to_show != 1
		end else begin
			lf_count = lf_count + 1;
		end //lf_count==9
	end//if FSM==3
	else if (FSM == 4)begin
		shank_position  = 6'b111111;
	end//if FSM==4
end


endmodule
