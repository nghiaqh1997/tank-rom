module frequency_divider_by2(clk,out_clk);
output reg out_clk;
input clk ;
initial
begin
out_clk <= 0;
end
always @(posedge clk)
begin
     out_clk <= ~out_clk;	
end
endmodule
