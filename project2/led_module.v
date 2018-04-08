module led_module(clk, key_state, led);
	input clk;
	input wire[9:0] key_state;
   output reg[3:0] led;
	
	initial begin
		led <= 4'b0000;
	end
	
	always @ (posedge clk)begin
		if (~key_state[9])begin
			led <= key_state[3:0];
		end else begin
			led <= 4'b1111;
		end
	end
endmodule
