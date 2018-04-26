module adc_control(clk,
						clk_high,
							adc_in,
							digitron_number,
							dac_out);
input clk, clk_high;
input wire[7:0] adc_in;
output reg[7:0] digitron_number;
reg signed [15:0] fir_filter[0:127];
reg signed [31:0] data_buffer[0:127], multi_buffer[0:127];
reg signed [31:0] data_cal;
reg[15:0] iter_count;
output reg[7:0]dac_out;
reg[24:0] ratio;
reg [7:0]step;
//these fir parameter is 1e5 more than the original one.
initial begin
	ratio <= 100000;
	fir_filter[0] <= 37;fir_filter[1] <= 39;fir_filter[2] <= 41;fir_filter[3] <= 44;
	fir_filter[4] <= 46;fir_filter[5] <= 48;fir_filter[6] <= 49;fir_filter[7] <= 50;
	fir_filter[8] <= 50;fir_filter[9] <= 48;fir_filter[10] <= 45;fir_filter[11] <= 40;
	fir_filter[12] <= 33;fir_filter[13] <= 23;fir_filter[14] <= 11;fir_filter[15] <= -5;
	fir_filter[16] <= -24;fir_filter[17] <= -46;fir_filter[18] <= -72;fir_filter[19] <= -100;
	fir_filter[20] <= -132;fir_filter[21] <= -165;fir_filter[22] <= -201;fir_filter[23] <= -238;
	fir_filter[24] <= -275;fir_filter[25] <= -311;fir_filter[26] <= -345;fir_filter[27] <= -376;
	fir_filter[28] <= -403;fir_filter[29] <= -424;fir_filter[30] <= -438;fir_filter[31] <= -442;
	fir_filter[32] <= -437;fir_filter[33] <= -420;fir_filter[34] <= -390;fir_filter[35] <= -347;
	fir_filter[36] <= -288;fir_filter[37] <= -213;fir_filter[38] <= -122;fir_filter[39] <= -14;
	fir_filter[40] <= 110;fir_filter[41] <= 251;fir_filter[42] <= 409;fir_filter[43] <= 582;
	fir_filter[44] <= 769;fir_filter[45] <= 969;fir_filter[46] <= 1180;fir_filter[47] <= 1400;
	fir_filter[48] <= 1627;fir_filter[49] <= 1859;fir_filter[50] <= 2093;fir_filter[51] <= 2326;
	fir_filter[52] <= 2556;fir_filter[53] <= 2779;fir_filter[54] <= 2993;fir_filter[55] <= 3195;
	fir_filter[56] <= 3382;fir_filter[57] <= 3552;fir_filter[58] <= 3702;fir_filter[59] <= 3831;
	fir_filter[60] <= 3936;fir_filter[61] <= 4016;fir_filter[62] <= 4070;fir_filter[63] <= 4098;
	fir_filter[64] <= 4098;fir_filter[65] <= 4070;fir_filter[66] <= 4016;fir_filter[67] <= 3936;
	fir_filter[68] <= 3831;fir_filter[69] <= 3702;fir_filter[70] <= 3552;fir_filter[71] <= 3382;
	fir_filter[72] <= 3195;fir_filter[73] <= 2993;fir_filter[74] <= 2779;fir_filter[75] <= 2556;
	fir_filter[76] <= 2326;fir_filter[77] <= 2093;fir_filter[78] <= 1859;fir_filter[79] <= 1627;
	fir_filter[80] <= 1400;fir_filter[81] <= 1180;fir_filter[82] <= 969;fir_filter[83] <= 769;
	fir_filter[84] <= 582;fir_filter[85] <= 409;fir_filter[86] <= 251;fir_filter[87] <= 110;
	fir_filter[88] <= -14;fir_filter[89] <= -122;fir_filter[90] <= -213;fir_filter[91] <= -288;
	fir_filter[92] <= -347;fir_filter[93] <= -390;fir_filter[94] <= -420;fir_filter[95] <= -437;
	fir_filter[96] <= -442;fir_filter[97] <= -438;fir_filter[98] <= -424;fir_filter[99] <= -403;
	fir_filter[100] <= -376;fir_filter[101] <= -345;fir_filter[102] <= -311;fir_filter[103] <= -275;
	fir_filter[104] <= -238;fir_filter[105] <= -201;fir_filter[106] <= -165;fir_filter[107] <= -132;
	fir_filter[108] <= -100;fir_filter[109] <= -72;fir_filter[110] <= -46;fir_filter[111] <= -24;
	fir_filter[112] <= -5;fir_filter[113] <= 11;fir_filter[114] <= 23;fir_filter[115] <= 33;
	fir_filter[116] <= 40;fir_filter[117] <= 45;fir_filter[118] <= 48;fir_filter[119] <= 50;
	fir_filter[120] <= 50;fir_filter[121] <= 49;fir_filter[122] <= 48;fir_filter[123] <= 46;
	fir_filter[124] <= 44;fir_filter[125] <= 41;fir_filter[126] <= 39;fir_filter[127] <= 37;




end

always @ (posedge clk)begin

	data_buffer[0] <= adc_in;
	for (iter_count=1;iter_count<128;iter_count=iter_count + 1)begin
		data_buffer[iter_count] <= data_buffer[iter_count - 1];
	end
	//dac_out <= data_cal / ratio;
end

always @ (negedge clk_high )begin
	case(step)
	0:begin
		digitron_number <= dac_out;
		for (iter_count = 0; iter_count < 128; iter_count = iter_count + 1)begin
			multi_buffer[iter_count] <=  data_buffer[iter_count] * fir_filter[iter_count];
		end
		step = 1;
	end
	1:begin
		for (iter_count = 0; iter_count < 32; iter_count = iter_count + 1)begin
			multi_buffer[iter_count] <= multi_buffer[iter_count]+ multi_buffer[iter_count + 32] + multi_buffer[iter_count + 64]+ multi_buffer[iter_count + 96];
		end
		step = 2;
	end
	2:begin
		for (iter_count = 0; iter_count < 8; iter_count = iter_count + 1)begin
			multi_buffer[iter_count] <= multi_buffer[iter_count] + multi_buffer[iter_count + 8] + multi_buffer[iter_count + 16]+ multi_buffer[iter_count + 24];
		end
		step = 3;
	end
	3:begin
		for (iter_count = 0; iter_count < 2; iter_count = iter_count + 1)begin
			multi_buffer[iter_count] <= multi_buffer[iter_count] + multi_buffer[iter_count + 2] + multi_buffer[iter_count + 4]+ multi_buffer[iter_count + 6];
		end
		step = 4;
	end
	4:begin
		dac_out <= (multi_buffer[0] + multi_buffer[1]) / ratio;
		//dac_out <= adc_in;
		step = 0;
	end
	endcase
end


							
endmodule

