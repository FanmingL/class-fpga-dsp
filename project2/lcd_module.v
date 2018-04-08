module lcd_module(
						clk,
						lcd);
						
						
	input clk;
	output wire[3:0]lcd;
	reg LCD_CS, LCD_A0, LCD_SCL, LCD_SI;
	assign lcd[0] = LCD_CS;
	assign lcd[1] = LCD_SCL;
	assign lcd[2] = LCD_A0;
	assign lcd[3] = LCD_SI;
	reg [15:0]command, data;
	reg [15:0]col,page;
	reg [15:0] data_to_write;
	reg [7:0]step;
	initial begin
		LCD_CS <= 1;
		LCD_SCL <= 1;
		LCD_A0 <= 1;
		LCD_SI <= 1;
		col = 0;
		page = 0;
		command <= 130;
		data <= 10;
	end
	
	always @ (posedge clk)begin
		data_to_write <= (16'h01);
	end
	
	always @ (posedge clk)begin		//100kHz 
		LCD_SCL <= ~LCD_SCL;
	end
	
	always @ (negedge clk)begin
		if (step ==16)begin
			LCD_CS = 0;
			
		end else begin
			step = 0;
		end
	end
						
						
endmodule

				