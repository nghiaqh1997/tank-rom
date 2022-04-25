module controller(
						//in
						clk25,reset,
						bullet_y1,bullet_x1,bullet_x2,bullet_y2,
						x_tank1,x_tank2,y_tank2,y_tank1,
						x,y,
						direction1,direction2,
						direction_bullet1,direction_bullet2,
						red_explosion_ack,green_explosion_ack,
						red_bullet_act,green_bullet_act,
						reset_plyrScrn,
						
						//out
						player_screen,
						first_screen_out,
						explosion_flag,
						des_bullet1,des_bullet2);


input red_bullet_act,green_bullet_act;
input [9:0]bullet_x1,bullet_x2,x_tank1,x_tank2,x;
input [8:0]bullet_y1,bullet_y2,y_tank1,y_tank2,y;
input clk25,reset;
input [1:0]direction1,direction2,direction_bullet1,direction_bullet2;
input red_explosion_ack,green_explosion_ack;//reset explosion_flag
output reg [1:0]player_screen;
input reset_plyrScrn;
output reg [11:0]first_screen_out;
output reg explosion_flag;
//dia chi vao` rom
reg [9:0]up_addr,left_addr,explosion_addr,greenup_addr,greenleft_addr,green_explosion_addr;
reg [6:0]bullet_up_addr,bullet_left_addr;
reg [6:0]greenbullet_down_addr,bullet_right_addr; 
//data out rom
wire [11:0]up_dataOut,left_dataOut,explosion_dataOut,greenup_dataOut,greenleft_dataOut,green_explosion_dataOut;
wire [11:0]bullet_up_dataOut,bullet_left_dataOut;
wire [11:0]bullet_down_dataOut,bullet_right_dataOut;
//counter
reg [20:0]green_explosion_cnt,explosion_cnt;
//reg explosion_act;


reg [1:0]green_score,red_score;
output reg des_bullet1,des_bullet2;

/*wire [4:0] DOWN,RIGHT,UP,LEFT,FIRE;

assign  DOWN    = 5'b00001;                 
assign  RIGHT   = 5'b00010;
assign  UP      = 5'b00100;
assign  LEFT    = 5'b01000;
assign  FIRE  = 5'b10000;*/
wire [1:0] ICON_DOWN,ICON_LEFT,ICON_RIGHT,ICON_UP;
assign  ICON_UP     = 2'b00;                
assign  ICON_DOWN   = 2'b01;
assign  ICON_LEFT   = 2'b10;
assign  ICON_RIGHT  = 2'b11;
always@(posedge clk25)begin
if (reset) begin
                up_addr <=  10'd0;
                left_addr <= 10'd0;
                end
                
//////////////// If green bullet hits red tank output explosion///////////////////////////////////////                
           else if ((bullet_y2 >= y_tank1) && ( bullet_y2 <= (y_tank1+ 10'd31)) && 
                (bullet_x2 >= x_tank1) && ( bullet_x2 <= (x_tank1+ 10'd31)) &&
                (y >= y_tank1 ) && ( y <= (y_tank1 + 10'd31)) && 
                (x >= x_tank1 ) && ( x <= (x_tank1 + 10'd31)))
                    begin
                               explosion_addr <= explosion_addr + 1'd1;             // address for explosion 
                               first_screen_out <= explosion_dataOut;               // data in explosion 
                               green_explosion_cnt <= green_explosion_cnt + 1'd1;   // counter length of time to display explosion
                               //explosion_act <= 1'd1;                               // explosion active, used to produce sound
										 des_bullet2<=1'b1;
                    end
            
/////////////// when counter reaches 60000, increment score            
           else if (green_explosion_cnt >= 19'd60000)
                begin
                    green_score <= green_score + 1'd1;
                    green_explosion_cnt <= 19'd0;
                    explosion_flag <= 1'd1;                                         // flag used to reset player locations
						  des_bullet2<=1'b0;
                    //explosion_act <= 1'd0;                                          // stop outputting explosion sound
                end
///////////// when green tank reaches 3 hits, output player 1 wins//////////////
           else if (green_score == 2'd3)
                begin
                    player_screen <= 2'b01;
                    green_score <= 1'd0;
                end
        
////////// reset flag when tank locations reset/////////////////////////////////        
            else if (red_explosion_ack >= 1'd1) explosion_flag <= 1'd0;
   
//////////// reset player screen and score when screens change/////////////////   
            else if (reset_plyrScrn >= 1'd1) begin
                                        player_screen <= 2'b00;
                                        green_score <= 1'd0;
                                    end
   
   else begin
           
/////////// this displays red tank orientation ///////////////////////////////
           case (direction1)
           
            ICON_UP:  if ((y == y_tank1) && (x == x_tank1)) 
                        begin
                         up_addr <=10'd0;                       // reset addresses
                         explosion_addr <= 10'd0;
                         end
                       else if ((y >= y_tank1 ) && ( y <= (y_tank1 + 10'd31)) && 
                          (x >= x_tank1 ) && ( x <= (x_tank1 + 10'd31)))
                       begin            
                               first_screen_out <= up_dataOut;   // output red tank up orientation
                               up_addr <= up_addr + 1'd1;        // increase address
                       end
            
                else begin
                        up_addr <= up_addr + 10'd0;             // if pixel location is not over tank, do nothing
                        explosion_addr <= explosion_addr;       // if not over explosion, do nothing
                    end
            ICON_DOWN: if ((y == y_tank1) && (x == x_tank1))
                        begin
                         up_addr <=10'd1023;                    // reset addresses                
                        explosion_addr <= 10'd0;                
                         end
             else if ((y >= y_tank1 ) && ( y <= (y_tank1 + 10'd31)) && 
                    (x >= x_tank1 ) && ( x <= (x_tank1 + 10'd31)))
                       begin 
                                first_screen_out <= up_dataOut;  // output red tank down orientation
                                up_addr <= up_addr - 1'd1;      // decrease address
                               
                       end
             
                else begin
                           up_addr <= up_addr + 10'd0;          // do nothing
                           explosion_addr <= explosion_addr;    // do nothing
                       end
            ICON_LEFT:   
                 if ((y == y_tank1) && (x == x_tank1)) 
                            begin
                                left_addr <=10'd0;                  // reset addresses 
                                explosion_addr <= 10'd0;
                            end
             else if ((y >= y_tank1 ) && ( y <= (y_tank1 + 10'd31)) && 
                    (x >= x_tank1 ) && ( x <= (x_tank1 + 10'd31)))
                       begin            
                               first_screen_out <= left_dataOut;    // output red tank left orientation
                               left_addr <= left_addr + 1'd1;       // increase address
                       end
            
            else begin
                            left_addr <= left_addr + 10'd0;         // do nothing
                            explosion_addr <= explosion_addr;
                    end    
            
					ICON_RIGHT:
             if ((y == y_tank1) && (x == x_tank1))
                begin
                    left_addr <=10'd1023;                                  // reset address 
                    explosion_addr <= 10'd0;
                end              
             else if ((y >= y_tank1 ) && ( y <= (y_tank1 + 10'd31)) && 
                    (x >= x_tank1 ) && ( x <= (x_tank1 + 10'd31)))
                       begin   
                               first_screen_out <= left_dataOut;           // output green tank right data
                               left_addr <= left_addr - 1'd1;
                       end
                    
            else begin
                   left_addr <= left_addr + 10'd0;                    // do nothing
                  explosion_addr <= explosion_addr;
                end
            
            endcase
    
end






//////////////// start of green tank explosion output to screen /////////////////////////////////
    if (reset) begin
            greenup_addr <= 10'd0;
            greenleft_addr <= 10'd0;
        end
//////////////// If red bullet hits green tank output explosion///////////////////////////////////////          
    else if ((bullet_y1 >= y_tank2) && ( bullet_y1 <= (y_tank2+ 10'd31)) && 
        (bullet_x1 >= x_tank2) && ( bullet_x1 <= (x_tank2+ 10'd31)) &&
        (y >= y_tank2 ) && ( y <= (y_tank2 + 10'd31)) && 
        (x >= x_tank2 ) && ( x <= (x_tank2 + 10'd31)))
            begin
                green_explosion_addr <= green_explosion_addr + 1'd1;
                first_screen_out <= green_explosion_dataOut;
                explosion_cnt <= explosion_cnt + 1'd1;                  // count to display explosion for an amount of time
                //explosion_act <= 1'd1;                                  // used to output sound when exploding
					 des_bullet1<=1'b1;
            end
            
////////////////when count reaches 600000 stop displaying explosion////////////////////////////////////            
    else if (explosion_cnt >= 19'd60000)
             begin
                 red_score <= red_score + 1'd1;                         // increment red score
                 explosion_cnt <= 19'd0;
                 explosion_flag <= 1'd1;                                // flag used to reset player location
					  des_bullet1<=1'b0;
                 //explosion_act <= 1'd0;                                 // stop outputting explosion sound
             end
             
/////////////// when red score reaches change screens ///////////////////////////////////////////////////
    else if (red_score == 2'd3)
             begin
                 player_screen <= 2'b10;                                // output to switch interface to display player 1 wins
                 red_score <= 1'd0;                                     // reset score
             end 
              
/////////////// this displays green tank orientation ////////////////////////////////////////////////////////   
    else if (green_explosion_ack >= 1'd1) explosion_flag <= 1'd0;
     else if (reset_plyrScrn >= 1'd1) begin                             
                player_screen <= 2'b0;                                  // reset to 0 when starting over
                red_score <= 1'd0;                                      // when reset high, reset score
              end
    else  begin
                
   
            case (direction2)
           
            ICON_UP:   
            if ((y == y_tank2) && (x == x_tank2)) 
                    begin
                        greenup_addr <=10'd0;                           // reset address
                        green_explosion_addr <= 10'd0;
                    end
             else if ((y >= y_tank2 ) && ( y <= (y_tank2 + 10'd31)) && 
                    (x >= x_tank2 ) && ( x <= (x_tank2 + 10'd31)))
                       begin            
                               first_screen_out <= greenup_dataOut;    // output green tank up data
                               greenup_addr <= greenup_addr + 1'd1;     // increment address
                       end
            
            else begin 
                    greenup_addr <= greenup_addr + 10'd0;               // do nothing, when pixel is not over tank
                    green_explosion_addr <= green_explosion_addr;
                 end
            ICON_DOWN:
              if ((y == y_tank2) && (x == x_tank2))
                    begin
                     greenup_addr <=10'd1023;                           // reset address
                    green_explosion_addr <= 10'd0;
                    end                
             else if ((y >= y_tank2 ) && ( y <= (y_tank2 + 10'd31)) && 
                    (x >= x_tank2 ) && ( x <= (x_tank2 + 10'd31)))
                       begin 
                                first_screen_out <= greenup_dataOut;        // output green tank down data
                                greenup_addr <= greenup_addr - 1'd1;        // deccrement address
                               
                       end
             
            else begin 
                   greenup_addr <= greenup_addr + 10'd0;                    // do nothing
                   green_explosion_addr <= green_explosion_addr;
                end
            ICON_LEFT:   
             if ((y == y_tank2) && (x == x_tank2)) 
                    begin
                        greenleft_addr <=10'd0;                             // reset address       
                        green_explosion_addr <= 10'd0;
                        end                  
             
             else if ((y >= y_tank2 ) && ( y <= (y_tank2 + 10'd31)) && 
                    (x >= x_tank2 ) && ( x <= (x_tank2 + 10'd31)))
                       begin            
                               first_screen_out <= greenleft_dataOut;           // output green tank left data         
                               greenleft_addr <= greenleft_addr + 1'd1;
                       end
            
            else 
                begin
                    greenleft_addr <= greenleft_addr + 10'd0;                    // do nothing
                   green_explosion_addr <= green_explosion_addr;
                 end            
            ICON_RIGHT:
             if ((y == y_tank2) && (x == x_tank2))
                begin
                    greenleft_addr <=10'd1023;                                  // reset address 
                    green_explosion_addr <= 10'd0;
                end              
             else if ((y >= y_tank2 ) && ( y <= (y_tank2 + 10'd31)) && 
                    (x >= x_tank2 ) && ( x <= (x_tank2 + 10'd31)))
                       begin   
                               first_screen_out <= greenleft_dataOut;           // output green tank right data
                               greenleft_addr <= greenleft_addr - 1'd1;
                       end
                    
            else begin
                   greenleft_addr <= greenleft_addr + 10'd0;                    // do nothing
                  green_explosion_addr <= green_explosion_addr;
                end
            endcase    
    end
if (red_bullet_act == 1'd1)
        begin
            case (direction_bullet1)
           
                ICON_UP:   
                    if ((y == y_tank2) && (x == x_tank2)) 
						  bullet_up_addr <= 7'd120;    // reset bullet address
                    else if ((y >= bullet_y1 ) && ( y <= (bullet_y1 + 5'd14)) && 
                    (x >= bullet_x1 ) && ( x <= (bullet_x1 + 4'd7)))
                       begin            
                           first_screen_out <= bullet_up_dataOut;                       // output bullet up data
                           bullet_up_addr <= bullet_up_addr - 1'd1;
                       end
                    else bullet_up_addr <= bullet_up_addr + 7'd0;                      // do nothing
                
                ICON_DOWN:   
                    if ((y == y_tank2) && (x == x_tank2)) bullet_up_addr <= 7'd0;     // reset bullet address     
                    else if ((y >= bullet_y1 ) && ( y <= (bullet_y1 + 5'd14)) && 
                        (x >= bullet_x1 ) && ( x <= (bullet_x1 + 4'd7)))
                           begin            
                               first_screen_out <= bullet_up_dataOut;                   // output bullet down data
                               bullet_up_addr <= bullet_up_addr + 1'd1;
                           end
                    else bullet_up_addr <= bullet_up_addr + 7'd0;                       // do nothing
                
                ICON_LEFT:   
                 if ((y == y_tank2) && (x == x_tank2)) bullet_left_addr <= 7'd120;     // reset bullet address
                 else if ((y >= bullet_y1 ) && ( y <= (bullet_y1 + 4'd7)) && 
                    (x >= bullet_x1 ) && ( x <= (bullet_x1 + 5'd14)))
                       begin            
                           first_screen_out <= bullet_left_dataOut;                     // output bullet left data
                           bullet_left_addr <= bullet_left_addr - 1'd1;
                       end
                else bullet_left_addr <= bullet_left_addr + 7'd0;                      // do nothing
                
                ICON_RIGHT:   
                 if ((y == y_tank2) && (x == x_tank2)) bullet_left_addr <= 7'd0;       // reset bullet address
                 else if ((y >= bullet_y1 ) && ( y <= (bullet_y1 + 4'd7)) && 
                    (x >= bullet_x1 ) && ( x <= (bullet_x1 + 5'd14)))
                       begin            
                           first_screen_out <= bullet_left_dataOut;                     // output bullet right data
                           bullet_left_addr <= bullet_left_addr + 1'd1;
                       end
                else bullet_left_addr <= bullet_left_addr + 7'd0;                      // do nothing
            endcase
        end
    else begin
            bullet_left_addr <= bullet_left_addr;                                       // do nothing
            bullet_up_addr <= bullet_up_addr ;
        end   

//////////////// outputs green bullet info ///////////////////////////////////////////////////////////////////////////           
    if (green_bullet_act == 1'd1)
                begin
                    case (direction_bullet2)
                   
                        ICON_UP:   
                         if ((y == y_tank2) && (x == x_tank2)) greenbullet_down_addr <= 7'd120;    // reset bullet address
                         else if ((y >= bullet_y2 ) && ( y <= (bullet_y2 + 5'd14)) && 
                            (x >= bullet_x2 ) && ( x <= (bullet_x2 + 4'd7)))
                               begin            
                                   first_screen_out <= bullet_down_dataOut;                                 // output bullet up data
                                   greenbullet_down_addr <= greenbullet_down_addr - 1'd1;
                               end
                        else greenbullet_down_addr <= greenbullet_down_addr + 7'd0;                        // do nothing
                        
                        ICON_DOWN:   
                         if ((y == y_tank2) && (x == x_tank2)) greenbullet_down_addr <= 7'd0;      // reset bullet address
                         else if ((y >= bullet_y2 ) && ( y <= (bullet_y2 + 5'd14)) && 
                            (x >= bullet_x2 ) && ( x <= (bullet_x2 + 4'd7)))
                               begin            
                                   first_screen_out <= bullet_down_dataOut;
                                   greenbullet_down_addr <= greenbullet_down_addr + 1'd1;                   // output bullet down data
                               end
                        else greenbullet_down_addr <= greenbullet_down_addr + 7'd0;                        // do nothing
                        
                        ICON_LEFT:   
                         if ((y == y_tank2) && (x == x_tank2)) bullet_right_addr <= 7'd120;        // reset bullet address
                         else if ((y >= bullet_y2 ) && ( y <= (bullet_y2 + 4'd7)) && 
                            (x >= bullet_x2 ) && ( x <= (bullet_x2 + 5'd14)))
                               begin            
                                   first_screen_out <= bullet_right_dataOut;                                // output bullet left data
                                   bullet_right_addr <= bullet_right_addr - 1'd1;
                               end
                        else bullet_right_addr <= bullet_right_addr;                                        // do nothing
                        
                        ICON_RIGHT:   
                         if ((y == y_tank2) && (x == x_tank2)) bullet_right_addr <= 7'd0;          // reset bullet address
                         else if ((y >= bullet_y2 ) && ( y <= (bullet_y2 + 4'd7)) && 
                            (x >= bullet_x2 ) && ( x <= (bullet_x2 + 5'd14)))
                               begin            
                                   first_screen_out <= bullet_right_dataOut;                                // output bullet right data
                                   bullet_right_addr <= bullet_right_addr + 1'd1;
                               end
                        else bullet_right_addr <= bullet_right_addr + 7'd0;                            
    // do nothing
                    endcase
                end
            else begin
                    bullet_right_addr <= bullet_right_addr;                                                 // do nothing
                    greenbullet_down_addr <=greenbullet_down_addr ;
                end  
end
/////////////////////ROM/////////////////////////////////////////////////////////////////////////////////

//redtankup
reduptank (
	up_addr,
	clk25,
	up_dataOut);
//redtankleft
redtankleft (
	left_addr,
	clk25,
	left_dataOut);
//explosion
explosion e1(
	explosion_addr,
	clk25,
	explosion_dataOut);
explosion e2(
	green_explosion_addr,
	clk25,
	green_explosion_dataOut);
//greentankup
greentankup (
	greenup_addr,
	clk25,
	greenup_dataOut);
//greentankleft
greentankleft (
	greenleft_addr,
	clk25,
	greenleft_dataOut);
//bulletup
bulletup b1(
	bullet_up_addr,
	clk25,
	bullet_up_dataOut);
//bulletleft
bulletleft b3(
	bullet_left_addr,
	clk25,
	bullet_left_dataOut);
//bulletdown
bulletup b2(
	greenbullet_down_addr,
	clk25,
	bullet_down_dataOut);
//bulletright
bulletleft b4(
	bullet_right_addr,
	clk25,
	bullet_right_dataOut);

endmodule


