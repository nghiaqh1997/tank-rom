module project
	(
		CLOCK_50,						
		
        KEY,
		
		//VGA_CLK,   						
		VGA_HS,							
		VGA_VS,							
		//VGA_BLANK,						
		//VGA_SYNC,						
		VGA_R,   						
		VGA_G,	 						
		VGA_B,   						
		PS2_CLK,                   
		PS2_DAT,                   
		SW,
		LEDR,
		LEDG
		
	);
	output  [9:0]LEDR;
	output  [7:0]LEDG; 
	
	input [1:0] KEY;
	input [2:0] SW;
	input CLOCK_50,PS2_CLK,PS2_DAT;
	//output			VGA_CLK;   				
	output			VGA_HS;					
	output			VGA_VS;					
	//output			VGA_BLANK;				
	//output			VGA_SYNC;				
	output	[3:0]	VGA_R;   				
	output	[3:0]	VGA_G;	 				
	output	[3:0]	VGA_B;   				
	
	
	assign LEDR[4:0]={fire1,left1,up1,right1,down1};
	assign LEDG[4:0]={fire2,left2,up2,right2,down2};
	//assign start = ~SW[2];
	assign mapselect = SW[1:0];
////////////////////////KEYBOARD///////////////////////////////////////////////////////////////	
	wire no,yes,up1, down1, left1, right1, fire1,up2, down2, left2, right2, fire2;
	keyboard(
		CLOCK_50,
		PS2_CLK,
		PS2_DAT,
		no, yes,
		up1, down1, left1, right1, fire1,        // Keyboard for 1st player
		up2, down2, left2, right2, fire2         // Keyboard for 2nd player
    );
//////////////////////PLL/////////////////////////////////////////////////////////////////////////
	wire clk25;
	frequency_divider_by2(CLOCK_50,clk25);
/////////////////////VGA_COLOUR///////////////////////////////////////////////////////////////////
	wire [11:0]colour;
	wire colour_enable;
	wire resetn;
	assign resetn=SW[2];
	vga_colour(VGA_G,VGA_R,VGA_B,12'b1111_1111_1111,colour_enable,clk25,resetn);
///////////////////VGA_CONTROLLER////////////////////////////////////////////////////////////////////
	wire [9:0]pixel_col;
	wire [8:0]pixel_row;
	vga_controller(
		clk25,resetn,
		pixel_row,
		pixel_col,
		VGA_VS,VGA_HS,colour_enable
	);
/////////////////////GAME//////////////////////////////////////////////////////////////////////////
wire [4:0]player1,player2; 
assign player1={fire1,left1,up1,right1,down1};
assign player2={fire2,left2,up2,right2,down2};
//	game (first_screen,pixel_col,pixel_row,CLOCK_50,clk25,resetn,player1,player2,player_screen,red_score,green_score);
//	wire [11:0]first_screen;
//	wire [1:0] red_score,green_score;
//	wire [1:0]player_screen;
//////////////////////DRAW/////////////////////////////////////////////////////////////////////////
//////////////////////CONTROLLER///////////////////////////////////////////////////////////////////
controller (clk25,resetn,bullet_y1,bullet_x1,bullet_x2,bullet_y2,x_tank1,x_tank2,y_tank2,y_tank1,x,y,player_screen,reset_plyrScrn,direction1,direction2,first_screen_out,direction_bullet1,direction_bullet2,explosion_ack1,explosion_ack2,explosion_flag,bullet_act1,bullet_act2,des_bullet1,des_bullet2);
wire [1:0]player_screen;
wire reset_plyrScrn;
wire [11:0]first_screen_out;
assign x=pixel_col;
assign y=pixel_row;
wire [9:0]x;
wire [8:0]y;
wire des_bullet1,des_bullet2;
//////////////////////TANK/////////////////////////////////////////////////////////////////////////
tank tank1(clk25,resetn,9'd60,8'd60,player1,x_tank1,y_tank1,direction1,explosion_flag,explosion_ack1);
wire [9:0]xpos1,x_tank1;
wire [8:0]ypos1,y_tank1;
wire moving1;
wire start1;
wire [1:0]direction1;

wire explosion_flag;

wire explosion_ack1;
wire explosion_ack2;
//wire stop1,stop2;
//wire stop_flag1,stop_flag2;
tank tank2(clk25,resetn,9'd500,8'd500,player2,x_tank2,y_tank2,direction2,explosion_flag,explosion_ack2);
wire [9:0]xpos2,x_tank2;
wire [8:0]ypos2,y_tank2;
wire moving2;
wire start2;
wire [1:0]direction2;

//////////////////////BULLET///////////////////////////////////////////////////////////////////////
bullet bullet1(clk25,resetn,player1,direction1,direction_bullet1,bullet_x1,bullet_y1,x_tank1,y_tank1,explosion_flag,bullet_act1,des_bullet1);//red
wire [1:0]direction_bullet1;
wire [9:0]bullet_x1;
wire [8:0]bullet_y1;
bullet bullet2(clk25,resetn,player2,direction2,direction_bullet2,bullet_x2,bullet_y2,x_tank2,y_tank2,explosion_flag,bullet_act2,des_bullet2);//blue
wire [1:0]direction_bullet2;
wire [9:0]bullet_x2;
wire [8:0]bullet_y2;
wire bullet_act1,bullet_act2;



		
endmodule