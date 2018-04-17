module lcd_module(
						clk,
						clk_low,
						lcd,
						number_on_digitron,
						address,
						q);
input wire[19:0]number_on_digitron;		
input clk;
input clk_low;
output reg [12:0]address;
input wire [7:0]q;
output wire[3:0]lcd;
reg LCD_CS, LCD_A0, LCD_SCL, LCD_SI;
assign lcd[0] = LCD_CS;
assign lcd[1] = LCD_SCL;
assign lcd[2] = LCD_A0;
assign lcd[3] = LCD_SI;
reg [7:0]command, data, data_ins;
reg [7:0]command_buffer[0:15];
reg [7:0] command_buffer_index;
reg [15:0]col,page;
reg [15:0] data_to_write;
reg [7:0]step;
reg [7:0]state; //send data finite state mechine 
/*	0: IDLE 
 *	1:	Start
 *	2: Send 1 byte data high_half
 *	3: Send 1 byte data low_half
 * 4: Finish sending
 */
reg send_command_flag;
reg new_data_come;
reg initial_flag;
reg[7:0] bit_counter;
reg[31:0] initial_counter;
reg finish_point, pre_clear_flag;
reg[7:0] column_counter, page_counter, set_page_counter;
reg [31:0] data_quantity, data_quantity_old;
reg iic_clk_out;
reg [7:0]buffer_change_page[0:2];
reg [7:0] buffer_change_step;
reg [12:0] address_counter;
initial begin
	col = 0;
	initial_counter <= 0;
	page = 0;
	command <= 8'haf;
	data <= 0;
	state <= 0;
	send_command_flag<= 1;
	initial_flag <= 0;
	new_data_come <= 0;
	command_buffer[0] <= 8'he2; //e2 reset e0 modify ee end e3 nop
	command_buffer[1] <= 8'haf;
	command_buffer[2] <= 8'h40;
	command_buffer[3] <= 8'ha0;
	command_buffer[4] <= 8'ha7;
	command_buffer[5] <= 8'ha4;
	command_buffer[6] <= 8'ha2;
	command_buffer[7] <= 8'hc8;
	command_buffer[8] <= 8'h2f;
	command_buffer[9] <= 8'h24;
	command_buffer[10] <= 8'h81;
	command_buffer[11] <= 8'h24;
	command_buffer[12] <= 8'hb0;
	command_buffer[13] <= 8'h10;
	command_buffer[14] <= 8'h00;
	buffer_change_page[0] <= 8'hb0;
	buffer_change_page[1] <= 8'h10;
	buffer_change_page[2] <= 8'h00;
	address <= 0;
	address_counter<= 0;
end



always @ ( posedge iic_clk_out) begin
	
	if (~initial_flag)begin
		command = command_buffer[command_buffer_index];
		command_buffer_index = command_buffer_index + 1;
		if (command_buffer_index > 14)begin
			command_buffer_index = 0;
			initial_flag = 1;
		end//if command_buffer_index
	data_quantity = data_quantity + 1;
	end//if ~initial_flag
	//else if (~pre_clear_flag)begin
	else if (1)begin
		if (column_counter <128)begin
			send_command_flag = 0;
			data  = q;
			address_counter = address_counter + 1;
			column_counter = column_counter + 1;
			address_counter = 128 * page_counter + column_counter;
			if (address_counter == 8192)begin
				address_counter = 0;
			end
			address = address_counter;
		end else begin //if column_counter<128
			if (page_counter < 7)begin
				send_command_flag = 1;
				case (buffer_change_step)
					0:begin
						command  = 8'h10;
						buffer_change_step = 1;
					end
					1:begin
						command  = 8'h00;
						buffer_change_step = 2;
					end
					2:begin
						command  = 8'hb1 + page_counter;
						page_counter = page_counter + 1;
						column_counter = 0;
						buffer_change_step = 0;
					end				
				endcase
			end else begin
				column_counter = 0;
				initial_counter = initial_counter + 1;
				if (initial_counter > 1000)pre_clear_flag = 1;
				page_counter  = 0;
			end
		end//else 
	data_quantity = data_quantity + 1;
	end//else if ~pre_clear_flag
	
	
end



always @ ( posedge clk) begin
	case (state)
		0:begin
			if (data_quantity != data_quantity_old) begin
				data_quantity_old = data_quantity;
				if (send_command_flag)begin
					data_ins = command;
					LCD_A0 = 0;
				end //if send_command_flag
				else begin
					data_ins = data;
					LCD_A0 = 1;
				end //else
				state = 1;
			end//if new_data_come
			iic_clk_out = 1;
		end//case 0
		1:begin
			iic_clk_out = 0;
			bit_counter = 0;
			LCD_CS = 0;
			LCD_SCL = 0;
			state = 2;
		end//case 1
		2:begin
			if (data_ins & 8'h80)begin
				LCD_SI = 1;
			end //data_ins & 8'h80
			else begin
				LCD_SI = 0;
			end //else
			data_ins = data_ins<<1;
			bit_counter = bit_counter + 1;
			LCD_SCL = 0;
			state = 3;
		end//case 2
		3:begin
			LCD_SCL = 1;
			state = 2;
			if (bit_counter==8)begin
				state = 4;
			end
		end//case 3
	   4:begin
			LCD_CS = 1;
			state = 0;
		end//case 4
	endcase
end


		
						
endmodule

				