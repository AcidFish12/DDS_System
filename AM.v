module AM
(
	input	clk_100M,
	input rst_n,
	input wire [3:0]ma,
	input [13:0] carrier,
	input [13:0] modulated,
	output[13:0] AM_Sig
);
	
	//无符号转为有符号
	wire[13:0] carrier_s={!carrier[13],carrier[12:0]};
	wire[13:0] modulated_s={!modulated[13],modulated[12:0]};
	
	wire[13:0]ma_16;
	assign ma_16=ma*10'd819;	
	wire[27:0] result_m;
	wire[14:0]Sum;

mult_16_16	mult_16_16_inst_1 
(
	.dataa ( modulated_s),
	.datab (ma_16),
	.result ( result_m )
);	

	assign Sum=result_m[27:13]+14'd8191;

	wire[27:0]result;
	wire[13:0]temp;
	assign temp={result[27:13]};
	assign AM_Sig={~temp[13],temp[12:0]};
	
mult_16_16	mult_16_16_inst_2 
(
	.dataa ( Sum[14:1] ),
	.datab ( carrier_s),
	.result ( result )
);

endmodule
