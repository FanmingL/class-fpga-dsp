module lcd_control(clk,
						ram_write_data,
						ram_write_addr,
						ram_write_en,
						KEY_STATE,
						ram_write_data_tmp,
						ram_read_addr_tmp,
						ram_write_addr_tmp,
						wren_tmp,
						ram_read_data_tmp
						);
input clk;
input wire[14:0] KEY_STATE;
input wire[7:0] ram_read_data_tmp;
output reg[7:0] ram_write_data, ram_write_data_tmp;
output reg ram_write_en, wren_tmp;
output reg[9:0]ram_write_addr, ram_read_addr_tmp, ram_write_addr_tmp;
reg[7:0]data_temp;
reg[15:0] page, column;
reg clear_flag, key_active;
reg[15:0] position_head_x, position_head_y, position_tail_x, position_tail_y;
reg[15:0] step_head, step_tail, counter;
reg[15:0] position_x[0:15];
reg[15:0] position_y[0:15];
reg[3:0] head_index, index_tail;

initial begin
	page <= 0;
	column <= 0;
	clear_flag <= 1;
	ram_write_en <= 1;
	wren_tmp <= 1;
	counter <= 1;
end

always @ (posedge clk )begin
	key_active = (KEY_STATE[14] | KEY_STATE[13] | KEY_STATE[12] | KEY_STATE[11] | KEY_STATE[10]);
end

always @ (posedge key_active)begin
	if (KEY_STATE[4])begin
		clear_flag = ~clear_flag;
	end 
	
	if (KEY_STATE[0])begin					//up
		if (~clear_flag)begin
			if (position_head_y == 0)begin
				position_head_y = 63;
			end else begin
				position_head_y = position_head_y - 1;
			end
		end
	end
	
	if (KEY_STATE[1])begin					//down
		if (~clear_flag)begin
			if (position_head_y == 63)begin
				position_head_y = 0;
			end else begin
				position_head_y = position_head_y + 1;
			end
		end
	end
	
	if (KEY_STATE[2])begin					//left
		if (~clear_flag)begin
			if (position_head_x == 0)begin
				position_head_x = 127;
			end else begin
				position_head_x = position_head_x - 1;
			end
		end
	end
	if (KEY_STATE[3])begin					//right
		if (~clear_flag)begin
			if (position_head_x == 127)begin
				position_head_x = 0;
			end else begin
				position_head_x = position_head_x + 1;
			end
		end
	end
	if (KEY_STATE[0]|KEY_STATE[1]|KEY_STATE[2]|KEY_STATE[3])begin
		head_index = head_index + 1;
		position_x[head_index] = position_head_x;
		position_y[head_index] = position_head_y;
		index_tail = head_index + 1;
		position_tail_x = position_x[index_tail];
		position_tail_y = position_y[index_tail];
	end
end



always @ (negedge clk) begin
	
	if ((position_head_x == column) && (page*8 <= position_head_y) && ((page+1)*8 > position_head_y))begin
		case(step_head)
			0:begin
				ram_read_addr_tmp = column + page * 128;
				step_head = 1;
			end
			1:begin
				ram_read_addr_tmp = column + page * 128;
				step_head = 2;
			end
			2:begin
				data_temp =ram_read_data_tmp;
				data_temp = data_temp | (1<<(position_head_y - page*8));
				ram_write_data = data_temp;
				ram_write_data_tmp = data_temp;
				ram_write_addr = column + page * 128 ;
				ram_write_addr_tmp = ram_write_addr;
				step_head = 0;
			end
		endcase
	end
	if ((position_tail_x == column) && (page*8 <= position_tail_y) && ((page+1)*8 > position_tail_y)&&(step_head == 0))begin
		case(step_tail)
			0:begin
				ram_read_addr_tmp = column + page * 128;
				step_tail = 1;
			end
			1:begin
				ram_read_addr_tmp = column + page * 128;
				step_tail = 2;
			end
			2:begin
				data_temp =ram_read_data_tmp;
				data_temp = data_temp & (~(1<<(position_tail_y - page*8)));
				ram_write_data = data_temp;
				ram_write_data_tmp = data_temp;
				ram_write_addr = column + page * 128 ;
				ram_write_addr_tmp = ram_write_addr;
				step_tail = 0;
			end
		endcase
	end
	if (step_head == 0 && step_tail==0) begin
		column = column + 1;
		if (column == 128)begin
			column = 0;
			page = page + 1;
			if (page == 8)begin
				page = 0;
			end
		end
	end
end



endmodule
