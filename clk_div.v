module clk_div
(
	input clk,
	input div_num,
	input rst_n,
	output reg clk_o
);
reg [23:0]div_cnt;
always@(posedge clk or negedge rst_n)
if(!rst_n)
begin
	div_cnt<=23'd0;
	clk_o<=0;
end
else if(div_cnt<(div_num/2)-1)
		begin
			div_cnt<=div_cnt+23'd1;
			clk_o<=clk_o;
		end
		else
		begin
			clk_o<=~clk_o;
			div_cnt<=0;
		end
endmodule

