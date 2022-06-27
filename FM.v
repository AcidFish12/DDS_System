module FM(
	input clk,
	input rst_n,
	input [13:0] modulated,	
	input [15:0] fd,
	input [23:0] fc,
	output [13:0] FM_Sig
);
	
	wire [23:0] f_fm;
	wire[13:0] modulated_s={!modulated[13],modulated[12:0]};// modulated to signed
	wire[13:0] fd_s={1'b0,fd[12:0]};								  // fd to signed

	wire signed [27:0] s; 
	
	assign f_fm= {1'b0,fc} + {{9{s[27]}},s[26:11]};				
mult_16_16	mult_16_16_inst1
(
	.dataa ( fd_s ),
	.datab ( modulated_s),
	.result ( s )
	);
	
Sxy_sin Sxy_sin_inst2
(
	.clk(clk) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.fin(f_fm) ,	// input [23:0] fin_sig
	.Sin(FM_Sig) 	// output [15:0] Sin_sig
);



endmodule