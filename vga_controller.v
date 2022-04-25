/*module vga_controller(
input clk,resetn,
output reg [8:0]pixel_row,
output reg [9:0]pixel_col,
output reg VGA_VS,VGA_HS,colour_enable
);

parameter
		HORIZ_PIXELS = 640,  HCNT_MAX  = 800, 		
		HSYNC_START  = 656,  HSYNC_END = 752,

		VERT_PIXELS  = 480,  VCNT_MAX  = 525,
		VSYNC_START  = 490,  VSYNC_END = 492;

always@(posedge clk)
begin
		if(!resetn)begin
			pixel_col<=0;
			pixel_row<=0;
			colour_enable<=0;
			VGA_VS<=0;
			VGA_HS<=0;
		end else begin
			if(pixel_col==HCNT_MAX)
				pixel_col<=10'd0;
			else pixel_col<=pixel_col+1'd1;
			
			if((pixel_col>=HCNT_MAX)&&(pixel_row>=VCNT_MAX))
				pixel_row<=9'd0;
			else if (pixel_col==HCNT_MAX)
				pixel_row<=pixel_row+1'd1;
		
			VGA_HS <= ~((pixel_col >= HSYNC_START) && (pixel_col <= HSYNC_END));
			VGA_VS <= ~((pixel_row >= VSYNC_START) && (pixel_row <= VSYNC_END));	
			colour_enable <= ((pixel_col < HORIZ_PIXELS) && (pixel_row < VERT_PIXELS));
		end
end

endmodule*/

module vga_controller(clk25,reset,hcs,vcs,vsync,hsync,disp_ena,n_blank,n_sync);
input clk25,reset;
output hsync,vsync,disp_ena;
output reg [9:0] hcs,vcs;
output wire n_blank,n_sync;
//wire [9:0] h_period,v_period;

localparam h_period =10'b1100100000; //h_period = hpixels + hfp + hpulse + hbp = 640+16+96+48=800
localparam v_period =10'b1000001101; //v_period = hpixels + hfp + hpulse + hbp = 480+10+2+33 = 525

assign n_blank = 1'b1;  //no direct blanking
assign n_sync = 1'b0;   //no sync on green
//counter
always @(posedge clk25)
begin
	if (reset == 1)
	begin
		hcs <= 10'd0;
		vcs <= 10'd0;
	end
	else 
		if(hcs == h_period - 1)
			begin
				hcs <= 10'd0;
				if(vcs == v_period - 10'd1)
					vcs <= 10'd0;
				else
					vcs <= vcs + 10'd1;
			end
		else
			begin
			hcs <= hcs + 10'd1;
			end
end
//horizontal sync
assign hsync = ((hcs < 656)||(hcs >= 752))?1:0;//hsync = ((hcs < hpixels + hfp)||(hcs >= hpixels + hfp + hpulse))?1:0
//vertical sync
assign vsync = ((vcs < 490)||(vcs >= 492))?1:0;//vsync = ((vcs < vpixels + hfp)||(vcs >= vpixels + vfp + vpulse))?1:0
//set display
assign disp_ena = (hcs < 640)&&(vcs < 480)?1:0;//disp_ena = (hcs < hpixels)&&(vcs < vpixels)?1:0
endmodule
		

