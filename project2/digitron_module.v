module digitron_module(
								high_clk,			//100kHz clk
								clk,					//1kHz clk
								shank_position,   //indecate which bit number should spangle
								point_position,	//indecate which bit point should be lighted on
								DIG,					//8 DIGs
								SEL,					//6 SELs
								number_input		//a number 20 bits (0-999999)
								);
	input wire clk, high_clk;				
	input wire[19:0] number_input;
	input wire[5:0] point_position, shank_position;
	output reg[7:0] DIG;
	output reg[5:0] SEL;			
	
	reg [3:0]number_to_show_reg [0:5];
	reg [3:0]index_number;
	reg [7:0]dig_tmp;
	reg [15:0]shank_period;
	reg [15:0]shank_count;
	/**try the binary to bcd***/
	reg [19:0]count_ms10, count_ms10_old;
	reg [47:0]count_dec;
	reg [5:0] binary_bcd_count;
	/**************************/
	//reg [32:0]
	reg shank_flag;
	initial begin
		index_number <= 0;
		dig_tmp <= 8'b00000000;
		shank_period <= 300;
		shank_count <= 0;
		count_ms10 <= 0;
		count_dec <= 0;
		binary_bcd_count <= 0;
		count_ms10_old <= 0;
	end
	
	always @ (posedge clk)begin
		shank_count <= shank_count + 1;
		if (shank_count == shank_period)begin
			shank_count <= 0;
			shank_flag <= ~shank_flag;
		end
	end
	
	/*************try the binary to bcd*****************/
	always @ (posedge high_clk)begin
		if (count_ms10_old!= count_ms10)begin
			if (binary_bcd_count == 0)begin
				count_dec[47:20] = 0;
				count_dec[19:0]  = count_ms10;
			end
			if (binary_bcd_count<20)begin
				
				if (count_dec[23:20]>=5)begin
					count_dec[23:20] = count_dec[23:20] + 3;
				end
				if (count_dec[27:24]>=5)begin
					count_dec[27:24] = count_dec[27:24] + 3;
				end
				if (count_dec[31:28]>=5)begin
					count_dec[31:28] = count_dec[31:28] + 3;
				end
				if (count_dec[35:32]>=5)begin
					count_dec[35:32] = count_dec[35:32] + 3;
				end
				if (count_dec[39:36]>=5)begin
					count_dec[39:36] = count_dec[39:36] + 3;
				end
				if (count_dec[43:40]>=5)begin
					count_dec[43:40] = count_dec[43:40] + 3;
				end
				if (count_dec[47:44]>=5)begin
					count_dec[47:44] = count_dec[47:44] + 3;
				end
				count_dec = count_dec << 1;
				binary_bcd_count = binary_bcd_count + 1;
			end else begin
				number_to_show_reg[5] = count_dec[43:40];
				number_to_show_reg[4] = count_dec[39:36];
				number_to_show_reg[3] = count_dec[35:32];
				number_to_show_reg[2] = count_dec[31:28];
				number_to_show_reg[1] = count_dec[27:24];
				number_to_show_reg[0] = count_dec[23:20];
			count_ms10_old = count_ms10;
			end
		end else begin
			binary_bcd_count = 0;
		end
	end
	
	
	always @ (posedge clk) begin
		count_ms10 = number_input;
	end
	
	always @ (posedge clk) begin
		if (index_number == 5) begin
			index_number = 0;
		end
		else begin
			index_number = index_number + 1;
		end
		SEL = ~(6'b000001 << (index_number));	
		if (((6'b000001 << (index_number))&shank_position)&&shank_flag)begin
			SEL = ~(6'b000000);	
		end
		
		
		case(number_to_show_reg[5-index_number])
		4'b0000:begin					//0
			dig_tmp = 8'b00111111;
		end
		4'b0001:begin					//1
			dig_tmp = 8'b00000110;
		end
		4'b0010:begin					//2
			dig_tmp = 8'b01011011;
		end
		4'b0011:begin					//3
			dig_tmp = 8'b01001111;
		end
		4'b0100:begin					//4
			dig_tmp = 8'b01100110;
		end
		4'b0101:begin					//5
			dig_tmp = 8'b01101101;
		end
		4'b0110:begin					//6
			dig_tmp = 8'b01111101;
		end
		4'b0111:begin					//7
			dig_tmp = 8'b00000111;
		end
		4'b1000:begin					//8
			dig_tmp = 8'b01111111;
		end
		4'b1001:begin					//9
			dig_tmp = 8'b01101111;
		end
		endcase
		if ((6'b000001 << (5-index_number))&(point_position))begin
			dig_tmp = dig_tmp| 8'b10000000;
		end
		DIG = ~dig_tmp;
	end

	
endmodule
								