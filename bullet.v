module bullet(clk25,reset,player,direction,direction_bullet,bullet_x,bullet_y,x_tank,y_tank,explosion_flag,bullet_act,des_bullet);
input clk25,reset;
input [1:0]direction;
output reg [1:0]direction_bullet;
input [4:0]player;
output reg [9:0]bullet_x;
output reg [8:0]bullet_y;
input [9:0]x_tank;
input [8:0]y_tank;
input des_bullet;
output reg bullet_act;
input explosion_flag;
//wire [4:0] DOWN,RIGHT,UP,LEFT,FIRE;
wire [1:0] ICON_DOWN,ICON_LEFT,ICON_RIGHT,ICON_UP;
//assign  DOWN    = 5'b00001;                 
//assign  RIGHT   = 5'b00010;
//assign  UP      = 5'b00100;
//assign  LEFT    = 5'b01000;
//assign  FIRE  = 5'b10000;

assign  ICON_UP     = 2'b00;                
assign  ICON_DOWN   = 2'b01;
assign  ICON_LEFT   = 2'b10;
assign  ICON_RIGHT  = 2'b11;
/////////////////////////huong vien dan///////////////////////
always@(posedge clk25)begin
	if(reset)
		direction_bullet<=ICON_UP;
	else if (bullet_act&&player[4]==1'd1)
		case(direction)
			ICON_DOWN:	direction_bullet <= ICON_DOWN;	
         ICON_UP:		direction_bullet <= ICON_UP;
         ICON_LEFT:	direction_bullet <= ICON_LEFT;
         ICON_RIGHT:	direction_bullet <= ICON_RIGHT;
            default:direction_bullet <= direction_bullet;
        endcase
end
//////////////////// toc do vien dan//////////////////////
reg [20:0] bullet_count;
reg bullet_flag;
parameter BULLET_CNT=100000;
always@(posedge clk25)begin
	if (reset)
		begin
			bullet_count <= 0;
			bullet_flag <= 1'd0;
		end
	else if (bullet_count == BULLET_CNT)
		begin
			bullet_flag <= 1'd1;
			bullet_count <= 0;
		end
	else 
		begin
			bullet_count <= bullet_count + 1'd1;
			bullet_flag <= 1'd0;
		end
end
////////////////toa do bullet///////////////////////


always@(posedge clk25)begin
if (reset)
		begin
			bullet_act <= 0;
			bullet_x<= 10'd0;                    // reset bullet location
			bullet_y <= 9'd0;
		end
    else if (des_bullet==1'b1)
		  bullet_act<=1'b0;
	 else if (explosion_flag >= 1'd1)                    // if hit opposing player, reset bullet location
        begin 
                               
           bullet_x <= 10'd0;
           bullet_y <= 9'd0;
        end 	
	else if (player[4] == 1'd1)                          // fire button hit
		begin
			bullet_act <= 1'd1;                          //  activate bullet
			bullet_x <= x_tank + 4'd15;      //  assign starting bullet location
			bullet_y <= y_tank + 4'd15;
		end
	else if ((bullet_act == 1'd1) && (bullet_flag > 0))    // only increment bullet location if flag is high and is active
		begin
			case (direction_bullet)         // increment X Y location based on orientation 
				ICON_UP:			bullet_y <= bullet_y - 1'd1;	
				ICON_DOWN:		    bullet_y <= bullet_y + 1'd1;
				ICON_LEFT:		    bullet_x <= bullet_x - 1'd1;
				ICON_RIGHT:		   bullet_x <= bullet_x + 1'd1;
				default:	begin
								    bullet_x <= bullet_x;
								    bullet_y <= bullet_y;
							end
			endcase
		end
	/*else if ((rDout_first != 12'd4095) && ( pPixel_row == (red_bullet_locY + 10'd4)) && // if bullet hits wall
				 ( pPixel_column == (red_bullet_locX + 10'd7)))
			begin
				red_bullet_act <= 1'd0;                     // deactivate bullet and reset location
				red_bullet_locX <= 10'd0;
                red_bullet_locY <= 10'd0;
			end*/
	/*else if ((red_bullet_locY >= green_tank_locY) && ( red_bullet_locY <= (green_tank_locY+ 10'd31)) &&    // if bullet hits opposing player
            (red_bullet_locX >= green_tank_locX) && ( red_bullet_locX <= (green_tank_locX+ 10'd31)))
                 red_bullet_act <= 1'd0; */  		           // deactivate bullet
	else begin
			bullet_x  <= bullet_x ;
			bullet_y  <= bullet_y ;
			
		end
end

endmodule

	



