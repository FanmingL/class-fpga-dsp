module signal_generation(
					clk,  				//50MHz clock input
					led,					//4 LEDs
					key,					//4 KEYs 
					beep, 				//1 beep
					DIG,					//8 DIGs
					SEL,				   //6 SELs
					LCD,				//CS SCL A0  SI   			
					DAC					//DAC
					);					
	input wire clk;
	input wire[4:0] key;
	
	output wire[3:0] led;
	output wire[7:0] DIG;
	output wire[5:0] SEL;
	output wire[3:0] LCD;
	output wire[8:0] DAC;
	output reg beep;
	wire[31:0] system_time,system_time_10ms;						//time in ms 10ms
	wire clk_out, clk_out_high;          //1kHz clock 100kHz clock
	wire [14:0]KEY_STATE;
	wire [5:0]point_position_wire, shank_position_wire;
	wire [19:0] number_on_digitron;
	wire [7:0] dac_value;
	wire [10:0]address_a, address_b;
	wire [7:0]q_a,q_b,q;
	wire [12:0]address;
	wire [7:0]ram_write_data,ram_read_data;
	wire [9:0]ram_write_addr, ram_read_addr;
	wire wren;
	
	wire [7:0]ram_write_data_tmp,ram_read_data_tmp;
	wire [9:0]ram_write_addr_tmp, ram_read_addr_tmp;
	wire wren_tmp;
	initial begin
		beep <= 1;
	end
	//instantation of  modules
	decrease_clock decrease_clock_instance(clk, clk_out, clk_out_high, system_time,system_time_10ms); //50MHz, 1kHz 100kHz
	key_module key_module_instance(clk_out, key, KEY_STATE);//UP,DOWN,LEFT,RIGHT,ENTER
	
	led_module led_module_instance(clk_out, KEY_STATE[9:0], led);
	lcd_module lcd_module_instance(clk_out_high, clk_out, KEY_STATE, LCD, address, q, ram_read_addr, ram_read_data);

	digitron_module digitron_module_instance(clk_out_high, clk_out, shank_position_wire, point_position_wire, DIG, SEL, number_on_digitron);
	//digitron_control digitron_control_instance(clk_out,KEY_STATE[9:0], point_position_wire, shank_position_wire, number_on_digitron);
	dac_module(clk, dac_value, DAC[0], DAC[8:1] );
	dac_control(clk, clk_out_high, KEY_STATE[9:0], q_a, dac_value, number_on_digitron, shank_position_wire, point_position_wire, address_a);
	
	sin sin_module(address_a,address_b,clk,q_a,q_b);
	img img_instance(address, clk, q);
	img_ram img_ram_instance(clk,ram_write_data,ram_read_addr,ram_write_addr,wren,ram_read_data);
	img_buffer img_buffer_instance_tmp(clk,ram_write_data_tmp,ram_read_addr_tmp,ram_write_addr_tmp,wren_tmp,ram_read_data_tmp);
	lcd_control lcd_control_instance(clk,ram_write_data,ram_write_addr,wren,KEY_STATE,
	ram_write_data_tmp,ram_read_addr_tmp,ram_write_addr_tmp,wren_tmp,ram_read_data_tmp);










endmodule
