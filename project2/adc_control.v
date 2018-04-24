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
	fir_filter[0] <= 10;fir_filter[1] <= 16;fir_filter[2] <= 22;fir_filter[3] <= 29;
	fir_filter[4] <= 35;fir_filter[5] <= 42;fir_filter[6] <= 50;fir_filter[7] <= 58;
	fir_filter[8] <= 65;fir_filter[9] <= 73;fir_filter[10] <= 79;fir_filter[11] <= 85;
	fir_filter[12] <= 89;fir_filter[13] <= 91;fir_filter[14] <= 90;fir_filter[15] <= 86;
	fir_filter[16] <= 78;fir_filter[17] <= 65;fir_filter[18] <= 48;fir_filter[19] <= 25;
	fir_filter[20] <= -3;fir_filter[21] <= -36;fir_filter[22] <= -75;fir_filter[23] <= -118;
	fir_filter[24] <= -165;fir_filter[25] <= -216;fir_filter[26] <= -269;fir_filter[27] <= -323;
	fir_filter[28] <= -376;fir_filter[29] <= -427;fir_filter[30] <= -473;fir_filter[31] <= -513;
	fir_filter[32] <= -545;fir_filter[33] <= -565;fir_filter[34] <= -573;fir_filter[35] <= -566;
	fir_filter[36] <= -541;fir_filter[37] <= -498;fir_filter[38] <= -434;fir_filter[39] <= -348;
	fir_filter[40] <= -240;fir_filter[41] <= -108;fir_filter[42] <= 46;fir_filter[43] <= 224;
	fir_filter[44] <= 424;fir_filter[45] <= 644;fir_filter[46] <= 883;fir_filter[47] <= 1139;
	fir_filter[48] <= 1409;fir_filter[49] <= 1689;fir_filter[50] <= 1977;fir_filter[51] <= 2267;
	fir_filter[52] <= 2558;fir_filter[53] <= 2843;fir_filter[54] <= 3119;fir_filter[55] <= 3383;
	fir_filter[56] <= 3629;fir_filter[57] <= 3853;fir_filter[58] <= 4054;fir_filter[59] <= 4226;
	fir_filter[60] <= 4367;fir_filter[61] <= 4475;fir_filter[62] <= 4548;fir_filter[63] <= 4585;
	fir_filter[64] <= 4585;fir_filter[65] <= 4548;fir_filter[66] <= 4475;fir_filter[67] <= 4367;
	fir_filter[68] <= 4226;fir_filter[69] <= 4054;fir_filter[70] <= 3853;fir_filter[71] <= 3629;
	fir_filter[72] <= 3383;fir_filter[73] <= 3119;fir_filter[74] <= 2843;fir_filter[75] <= 2558;
	fir_filter[76] <= 2267;fir_filter[77] <= 1977;fir_filter[78] <= 1689;fir_filter[79] <= 1409;
	fir_filter[80] <= 1139;fir_filter[81] <= 883;fir_filter[82] <= 644;fir_filter[83] <= 424;
	fir_filter[84] <= 224;fir_filter[85] <= 46;fir_filter[86] <= -108;fir_filter[87] <= -240;
	fir_filter[88] <= -348;fir_filter[89] <= -434;fir_filter[90] <= -498;fir_filter[91] <= -541;
	fir_filter[92] <= -566;fir_filter[93] <= -573;fir_filter[94] <= -565;fir_filter[95] <= -545;
	fir_filter[96] <= -513;fir_filter[97] <= -473;fir_filter[98] <= -427;fir_filter[99] <= -376;
	fir_filter[100] <= -323;fir_filter[101] <= -269;fir_filter[102] <= -216;fir_filter[103] <= -165;
	fir_filter[104] <= -118;fir_filter[105] <= -75;fir_filter[106] <= -36;fir_filter[107] <= -3;
	fir_filter[108] <= 25;fir_filter[109] <= 48;fir_filter[110] <= 65;fir_filter[111] <= 78;
	fir_filter[112] <= 86;fir_filter[113] <= 90;fir_filter[114] <= 91;fir_filter[115] <= 89;
	fir_filter[116] <= 85;fir_filter[117] <= 79;fir_filter[118] <= 73;fir_filter[119] <= 65;
	fir_filter[120] <= 58;fir_filter[121] <= 50;fir_filter[122] <= 42;fir_filter[123] <= 35;
	fir_filter[124] <= 29;fir_filter[125] <= 22;fir_filter[126] <= 16;fir_filter[127] <= 10;


end

always @ (posedge clk)begin

	data_buffer[0] <= adc_in * ratio;
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
		step = 0;
	end
	endcase
end


							
endmodule

