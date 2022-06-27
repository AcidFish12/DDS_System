module Sxy_sin
(
	input clk,
	input rst_n,
	input [23:0]fin,
	output[13:0] Sin
);

	reg[33:0]phase;
	wire[47:0]temp=fin*24'd11258999;
	wire[33:0]K_12_20=temp[47:16];
	
	//相位累加器
	always@(posedge clk or negedge rst_n)
		if(!rst_n)
			phase<=34'd0;
		else 
			phase<=phase+K_12_20;
ROM_Sin	ROM_Sin_inst 
(
	.address ( phase[33:23] ),
	.clock ( clk ),
	.q ( Sin )
);

endmodule
