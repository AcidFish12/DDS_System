module Sxy_DDS
(
	input wire clk,  				//50MHz
	output wire clk_10k,
	output wire clk_100M,
	output wire clk_out,
	input wire rst_n, 			//复位
	output wire[13:0]sig_out,	//输出		/输出			/输出		/
	input [11:0]ADDR,
	input RD,WR,
	inout [15:0]DATA,
	inout [3:0]KEY_H,KEY_V
);
	reg	[23:0]fc;				//频率		/载波频率		/载波频率	/
	reg 	[23:0]fc_reg;
	reg	[23:0]fs;				//无		/调制频率		/调制频率	/
	reg	[23:0]fs_reg;
	reg	[1:0]mode;				//0Sin	/1AM	/2FM	/3输出AM解调
	reg 	[1:0]mode_reg;
	reg	[14:0]fd;				//无		/无				/最大频偏	/
	reg	[14:0]fd_reg;
	reg	[3:0]ma;					//无		/调制度		/无			/
	reg	[3:0]ma_reg;
	
	wire 	[13:0] modulated;		//调制波
	wire 	[13:0] carrier;		//载波
	wire 	[13:0] FM_out;			
	wire 	[13:0] AM_out;			
	wire 	[13:0] sin_out;	
	
	wire clk_5Hz;						//0.5s周期时钟
	//(*preserve*)wire clk_100M;
	
	
	assign sig_out = mode[1]?(mode[0]?1:FM_out[13:0]):(mode[0]?AM_out[13:0]:sin_out[13:0]);//输出信道选择
	//100Mhz
	clk_100M	clk_100M_inst 
	(
	.areset ( ~rst_n ),
	.inclk0 ( clk),
	.c0 ( clk_100M ),
	.locked ()
	);
assign clk_out=~clk_100M;
	//分频2hz
Sxy_046_div_even Sxy_046_div_even_inst
(
	.clk(clk) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.clk_div(clk_5Hz) 	// output  clk_div_sig
);

defparam Sxy_046_div_even_inst.NUM_DIV = 5_000_000;
	//分频10K
Sxy_046_div_even Sxy_046_div_even_inst_1
(
	.clk(clk) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.clk_div(clk_10k) 	// output  clk_div_sig
);

defparam Sxy_046_div_even_inst_1.NUM_DIV = 5000;
	
	//触发器_步进
always@(posedge clk_5Hz or negedge rst_n)
if(!rst_n)
	begin 
	fs<=0;
	fc<=0;
	ma<=0;
	mode<=0;
	end
else 
	begin
	fs<=fs_reg;
	fc<=fc_reg;
	fd<=fd_reg;
	ma<=ma_reg;
	mode<=mode_reg;
	end

	//步进
always@(*)
begin
		//模式控制
		if(mode>=2'b0&&mode<=2'b10)
				case(DATA)
					16'h11:mode_reg<=2'b00; 
					16'h12:mode_reg<=2'b01;
					16'h14:mode_reg<=2'b10;
					default:mode_reg<=mode;
				endcase
		else mode_reg<=0;
		//fs控制
		if(mode==2'b00)
			if(fs>=24'd1000&&fs<=24'd10_000_000)
				case(DATA)
					16'h21:begin fs_reg<=fs+24'd10;end
					16'h41:begin fs_reg<=fs-24'd10;end
					16'h22:begin fs_reg<=fs+24'd1000;end
					16'h42:begin fs_reg<=fs-24'd1000;end
					16'h24:begin fs_reg<=fs+24'd100_000;end
					16'h44:begin fs_reg<=fs-24'd100_000;end
					default:fs_reg<=fs;
				endcase
			else fs_reg<=24'd1_000;
		else if(mode==2'b01)
			if(fs>=1_000&&fs<=50_000)
				case(DATA)
					16'h21:begin fs_reg<=fs+24'd10;end
					16'h41:begin fs_reg<=fs-24'd10;end
					default:fs_reg<=fs;
				endcase
			else fs_reg<=24'd50_000;
		else fs_reg<=24'd1000;
		//ma控制
		if(ma>=1&&ma<=10)
				case(DATA)
					16'h48:begin ma_reg<=ma+4'd1;end
					16'h88:begin ma_reg<=ma-4'd1;end
					default:ma_reg<=ma;
				endcase
		else ma_reg<=4'd10;
		//fc控制
		if(fc>=24'd500_000&&fc<=24'd10_000_000)
				case(DATA)	
					16'h18:begin fc_reg<=fc+24'd10;end
					16'h28:begin fc_reg<=fc-24'd10;end
					default:fc_reg<=fc;
				endcase
		else
		fc_reg<=24'd10_000_000;
		//fd控制
		/*if(fd>=15'd5000&&fd<=15'd20_000)
			case(DATA)
				16'h81:fd_reg<=fd+15'd1000;
				16'h82:fd_reg<=fd-15'd1000;
				default:fd_reg<=fd;
			endcase
		else fd_reg<=15'd5000;*/		
end

Sxy_sin Sxy_sin_inst
(
	.clk(clk_100M) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.fin(fc) ,	// input [23:0] fin_sig
	.Sin(carrier) 	// output [15:0] Sin_sig
);
Sxy_sin Sxy_sin_inst_2
(
	.clk(clk_100M) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.fin(fs) ,	// input [23:0] fin_sig
	.Sin(modulated) 	// output [15:0] Sin_sig
);

assign sin_out=modulated;
AM AM_inst
(
	.clk_100M(clk_100M) ,	// input  clk_100M_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.ma(ma) ,	// input [3:0] ma_sig
	.carrier(carrier) ,	// input [15:0] carrier_sig
	.modulated(modulated) ,	// input [15:0] modulated_sig
	.AM_Sig(AM_out) 	// output [15:0] AM_Sig_sig
);

/*FM FM_inst
(
	.clk(clk) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.modulated(modulated) ,	// input [15:0] modulated_sig
	.fd(fd) ,	// input [15:0] fd_sig
	.fc(fc) ,	// input [23:0] fc_sig
	.FM_Sig(FM_out) 	// output [15:0] FM_Sig_sig
);*/
TriPhase TriPhase_inst
(
	.CLK_50M(clk) ,	// input  CLK_50M_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.ADDR(ADDR) ,	// input [11:0] ADDR_sig
	.RD(RD) ,	// input  RD_sig
	.WR(WR) ,	// input  WR_sig
	.DATA(DATA) ,	// inout [15:0] DATA_sig
	.KEY_H(KEY_H) ,	// inout [3:0] KEY_H_sig
	.KEY_V(KEY_V) 	// inout [3:0] KEY_V_sig
);



endmodule
