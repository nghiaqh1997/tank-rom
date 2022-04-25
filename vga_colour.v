module vga_colour(vga_g,vga_r,vga_b,colour,colour_enable,clk,resetn);
output reg [3:0]vga_g,vga_r,vga_b;
input colour_enable,clk,resetn;
input [11:0]colour;

always@(posedge clk)
begin	if(!resetn)
			begin
				vga_b<=4'b0000;
				vga_r<=4'b0000;
				vga_g<=4'b0000;

			end
		else if(colour_enable)
			begin
				vga_b<=colour[3:0];
				vga_r<=colour[11:8];
				vga_g<=colour[7:4];
			end
		else
			begin
				vga_b<=4'b0000;
				vga_r<=4'b0000;
				vga_g<=4'b0000;
			end
end

endmodule
		