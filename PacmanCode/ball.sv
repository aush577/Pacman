//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					input [7:0]  keycode,				//ADDED KEYCODE FOR W,A,S,D CONFIGURATIONS
					input logic [383:0] wallData,			//get maze walls
					output logic [9:0] pac_x, pac_y,	//Output pacman coords
					output logic u, d, l, r,		//for testing up down left right
					output [3:0] pacDir		//current direction udlr
              );
    
    parameter [9:0] Ball_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] Ball_Size = 10'd8;        // Ball size
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
    
	 
	 
	 assign pac_x = Ball_X_Pos;
	 assign pac_y = Ball_Y_Pos;
	 
	 logic [3:0] dir, dir_in;		//3210 = up,down,left,right
	 logic [9:0] pacXWalls, pacYWalls;
	 logic up, down, left, right;
	 logic crossing;
	 assign crossing = (pac_x[3:0] == 8 && pac_y[3:0] == 8);
	 
	 
	 findWalls findwalls(.up(up), .down(down), .left(left), .right(right), .xPos(pacXWalls), .yPos(pacYWalls), .*);
	 assign u = up;
	 assign d = down;
	 assign l = left;
	 assign r = right;
	 assign pacDir = dir;
	 
	 always_comb
	 begin
		if (dir == 4'b1000) begin
			pacXWalls = pac_x;
			pacYWalls = pac_y+7;
		end
		else if (dir == 4'b0100) begin
			pacXWalls = pac_x;
			pacYWalls = pac_y-7;
		end
		else if (dir == 4'b0010) begin
			pacXWalls = pac_x+7;
			pacYWalls = pac_y;
		end
		else if (dir == 4'b0001) begin
			pacXWalls = pac_x-7;
			pacYWalls = pac_y;
		end
		else begin		//should never happen
			pacXWalls = pac_x;
			pacYWalls = pac_y;
		end	
	 end
	 
	 
	 
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= 10'h080;	//Ball_X_Center;
            Ball_Y_Pos <= 10'h0e8;	//Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;	//Ball_Y_Step;
				dir <= 4'b0001;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
				dir <= dir_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion;
		  dir_in = dir;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
            
				if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max ) // Ball is at the bottom edge, BOUNCE!
            begin
					 Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.  
					 dir_in = 4'b1000;
            end
				
				else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
            begin
					 Ball_Y_Motion_in = Ball_Y_Step;
					 dir_in = 4'b0100;
            end
				
				// TODO: Add other boundary detections and handle keypress here.
				
				
				else if( Ball_X_Pos + Ball_Size >= Ball_X_Max )  // Ball is at the right edge, BOUNCE!
				begin
                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);  // 2's complement. 
					 Ball_Y_Motion_in = 10'd0;
					 dir_in = 4'b0010;
				end
				
            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size )  // Ball is at the left edge, BOUNCE!
				begin
                Ball_X_Motion_in = Ball_X_Step;
					 Ball_Y_Motion_in = 10'd0;
					 dir_in = 4'b0001;
				end
					
					
//				else if (up == 1'b1 && Ball_Y_Motion < 0)
//				begin
//					Ball_Y_Motion_in = 10'd0;
//				end
//				else if (down == 1'b1 && Ball_Y_Motion > 0)
//				begin
//					Ball_Y_Motion_in = 10'd0;
//				end
//				else if (left == 1'b1 && Ball_X_Motion < 0)
//				begin
//					Ball_X_Motion_in = 10'd0;
//				end
//				else if (right == 1'b1 && Ball_X_Motion > 0)
//				begin
//					Ball_X_Motion_in = 10'd0;
//				end
					
					
				else 
				begin
				
					case(keycode[7:0])		//Check for the input keycode
					
						8'd26:	//W
						begin
							//if (up == 1'b0) begin
								Ball_X_Motion_in = 10'd0;
								Ball_Y_Motion_in = ~(Ball_Y_Step) + 1'd1;
								dir_in = 4'b1000;
							//end
						end
						
						8'd4:		//A
						begin
							//if (left == 1'b0 ) begin
								Ball_Y_Motion_in = 10'd0;
								Ball_X_Motion_in = ~(Ball_X_Step) + 1'd1;
								dir_in = 4'b0010;
							//end
						end
						
						8'd22:	//S
						begin
							//if (down == 1'b0) begin
								Ball_X_Motion_in = 10'd0;
								Ball_Y_Motion_in = Ball_Y_Step;
								dir_in = 4'b0100;
							//end
						end
						
						8'd7:		//D
						begin
							//if (right == 1'b0) begin
								Ball_Y_Motion_in = 10'd0;
								Ball_X_Motion_in = Ball_X_Step;
								dir_in = 4'b0001;
							//end
						end
						
						default:
						begin
							Ball_Y_Motion_in = 10'd0;
							Ball_X_Motion_in = 10'd0;
							//dir_in = 4'b0000;
						end
						
					endcase
					
				end	 
				
				
//				if (up == 1'b0)
//				begin
//				
//				end
				
        
            // Update the ball's position with its motion
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
        end
        
      
    end
    
	 
//    // Compute whether the pixel corresponds to ball or background
//    /* Since the multiplicants are required to be signed, we have to first cast them
//       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//    assign Size = Ball_Size;
//    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
//            is_ball = 1'b1;
//        else
//            is_ball = 1'b0;
//        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
//           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
//           of the 12 available multipliers on the chip! */
//    end
    
endmodule
