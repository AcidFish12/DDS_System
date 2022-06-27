module Sxy_046_div_even(clk,rst_n,clk_div);
      input clk;
      input rst_n;
      output clk_div;
      reg clk_div;
     
     parameter NUM_DIV=50_000_000;
      reg    [31:0] cnt;
     
 always @(posedge clk or negedge rst_n)
     if(!rst_n) begin
         cnt     <= 32'd0;
         clk_div    <= 1'b0;
     end
     else if(cnt < NUM_DIV / 2 - 1) begin
         cnt     <= cnt + 1'b1;
         clk_div    <= clk_div;
     end
     else begin
           cnt     <= 32'd0;
        clk_div    <= ~clk_div;
     end
  endmodule