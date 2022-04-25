module tank(clk25,reset,xpos,ypos,player,x_tank,y_tank,direction,explosion_flag,red_explosion_ack);
input clk25,reset;                                                                 
input [9:0]xpos;
input [8:0]ypos;
input [4:0]player;
output reg [9:0]x_tank;
output reg [8:0]y_tank;
//output moving;
//input start;
output reg [1:0]direction;
//output reg fire;


wire [4:0] DOWN,RIGHT,UP,LEFT,FIRE;

assign  DOWN    = 5'b00001;                 
assign  RIGHT   = 5'b00010;
assign  UP      = 5'b00100;
assign  LEFT    = 5'b01000;
assign  FIRE  = 5'b10000;
wire [1:0] ICON_DOWN,ICON_LEFT,ICON_RIGHT,ICON_UP;
assign  ICON_UP     = 2'b00;                
assign  ICON_DOWN   = 2'b01;
assign  ICON_LEFT   = 2'b10;
assign  ICON_RIGHT  = 2'b11;

//////////toc do xe tank//////////
reg flag;
reg [20:0]flag_count;
parameter FLAG_CNT=500000;
always@(posedge clk25) begin
	if (reset)
		begin
			flag_count <= 0;
			flag <= 1'd0;
		end
	else if (flag_count == FLAG_CNT)
		begin
			flag <= 1'd1;
			flag_count <= 0;
		end
	else 
		begin
			flag_count <= flag_count + 1'd1;
			flag <= 1'd0;
		end
end
/////////huong xe tank//////////////////////

always@(posedge clk25)begin
	if(reset)
		direction<=ICON_UP;
	else 
		begin
			case(player)
				DOWN: direction <= ICON_DOWN;
				RIGHT:  direction <= ICON_RIGHT;
				UP:     direction <= ICON_UP;
				LEFT:   direction <= ICON_LEFT;
				default: direction <= direction ;
			endcase
		end
end
////////////////toa do xe tank/////////////////////////

always@(posedge clk25) begin
	if (reset)
		begin
			y_tank <= ypos;                   // reset red tank location  
			x_tank <= xpos;

		end
	
	else if ( explosion_flag >= 1'd1)                  // if explosion set, reset red tank location
	   begin
	       red_explosion_ack <= 1'd1;                  // used to reset explosion flag
	       y_tank <= ypos;                  // reset red tank location  
           x_tank <= xpos;
           
	   end
	/*else if ( rDout_first != 12'd4095 && (pPixel_row >= tank_start_locY ) && ( pPixel_row <= (tank_start_locY + 10'd31)) && (pPixel_column >= tank_start_locX ) && ( pPixel_column <= (tank_start_locX + 10'd31)))
                     begin
                          red_stop <= 1'd1;             // if at wall stop the movement of tank
                      end*/
	else if ((flag > 0) )          // changing red tank location when button pushed and flag is set high
		begin
			if (red_stop == 1'd0)                    
                begin
                    case (player)         // change tank location if buttons pressed
                        UP:		y_tank <= y_tank - 1'd1;             
                        DOWN:	y_tank <= y_tank + 1'd1;
                        LEFT:	x_tank <= x_tank - 1'd1;
                        RIGHT:	x_tank <= x_tank + 1'd1;
                        default:	begin
                                        x_tank <= x_tank;
                                        y_tank <= y_tank;
                                    end
			         endcase
			    end
			else if (red_stop >= 1'd1)       // stop is set high, reverse 1 location and clear the stop
			     begin
			     red_stop <= 1'd0;           // clear the stop flag
			         case (player)
                         UP:        y_tank <= y_tank + 1'd1;             
                         DOWN:      y_tank <= y_tank - 1'd1;
                         LEFT:      x_tank <= x_tank + 1'd1;
                         RIGHT:     x_tank <= x_tank - 1'd1;
                         default:    begin
                                         x_tank <= x_tank;
                                         y_tank <= y_tank;
                                     end
                      endcase
			     end
			else begin
			         y_tank <= y_tank;
                     x_tank <= x_tank;
                     red_stop <= 1'd0;
			     end
		
	   end
	                    
	else
		begin
			y_tank <= y_tank;
			x_tank <= x_tank;
			red_explosion_ack <= 1'd0;                   // clear acknowledge flag
		end
end
input explosion_flag;
output reg red_explosion_ack;
reg red_stop=1'b0;

endmodule