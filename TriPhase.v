module TriPhase(
input CLK_50M,
input rst_n,
input [11:0]ADDR,
input RD,WR,
inout [15:0]DATA,
inout [3:0]KEY_H,KEY_V
);
wire cs0,cs1;//keyboard and 8688
wire [7:0] rddat0;
wire [15:0] data7,data6,data5,data0,data4,data3;




BUS BUS_inst
(
	.clk(CLK_50M) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.ADDR(ADDR) ,	// input [11:0] ADDR_sig
	.RD(RD) ,	// input  RD_sig
	.WR(WR) ,	// input  WR_sig
	.DATA(DATA) ,	// inout [15:0] DATA_sig
	.cs0(cs0) ,	// output  cs0_sig
	.cs1(cs1),
	.rddat0(rddat0) ,	// input [15:0] rddat0_sig

	.otdata0(Tri_KW) ,	// output [15:0] otdata0_sig

);
KEY KEY_inst
(
	.clk(CLK_50M) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.rddat(rddat0) ,	// output [7:0] rddat_sig
	.irq() ,	// output  irq_sig
	.cs(cs0) ,	// input  cs_sig
	.KEY_H(KEY_H) ,	// inout [3:0] KEY_H_sig
	.KEY_V(KEY_V) 	// inout [3:0] KEY_V_sig
);

endmodule