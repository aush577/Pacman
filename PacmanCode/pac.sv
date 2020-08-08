module  pac ( 	input         Clk,               // 50 MHz clock
                             Reset,             // Active-high reset signal
                             frame_clk,         // The clock indicating a new frame (~60Hz)
					input [7:0]  keycode,				//ADDED KEYCODE FOR W,A,S,D CONFIGURATIONS
					input logic [383:0] wallData,		//get maze walls
					output logic [9:0] pac_x, pac_y,	//Output pacman coords
					output logic u, d, l, r,			//for testing up down left right wall collisions
					output [3:0] pacDir,					//current direction udlr
					output crossing						//is pacman at a crossing
				);
    
	 //Constants
    parameter [9:0] pac_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] pac_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] pac_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] pac_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] pac_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] pac_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [9:0] pac_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] pac_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] pac_Size = 10'd8;        // pac size
    
    logic [9:0] pac_X_Pos, pac_X_Motion, pac_Y_Pos, pac_Y_Motion;
    logic [9:0] pac_X_Pos_in, pac_X_Motion_in, pac_Y_Pos_in, pac_Y_Motion_in;
    logic [3:0] dir, dir_in, turn, turn_in;		//3210 = up,down,left,right
	 logic [9:0] pac_X_TurnMotion_in, pac_Y_TurnMotion_in;
	 
	 
	 assign pac_x = pac_X_Pos;		//output x and y location
	 assign pac_y = pac_Y_Pos;
	 
	 //output variables
	 assign u = up;
	 assign d = down;
	 assign l = left;
	 assign r = right;
	 assign pacDir = dir;
	 
	 
	 logic [9:0] pacXWalls, pacYWalls;	//input for wall detector
	 logic up, down, left, right;	//wall status
	 
	 assign crossing = (pac_x[3:0] >= 6 && pac_x[3:0] <= 10 && pac_y[3:0] >= 6 && pac_y[3:0] <= 10);
	 logic wall;	//is wall in way on turn
	 
	 
	 findWalls findwalls(.up(up), .down(down), .left(left), .right(right), .xPos(pacXWalls), .yPos(pacYWalls), .*);
	 
	 //wall detector sprite boundaries
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
	 
	 
	 
    always_ff @ (posedge frame_clk or posedge Reset)
    begin
        if (Reset)
        begin
            pac_X_Pos <= 10'h088;	//starting position
            pac_Y_Pos <= 10'h0e8;
            pac_X_Motion <= 10'd0;
            pac_Y_Motion <= 10'd0;
				dir <= 4'b0001;
				turn <= 4'b0000;
        end
        else
        begin
            pac_X_Pos <= pac_X_Pos_in;
            pac_Y_Pos <= pac_Y_Pos_in;
            pac_X_Motion <= pac_X_Motion_in;
            pac_Y_Motion <= pac_Y_Motion_in;
				dir <= dir_in;
				turn <= turn_in;
        end
    end
    
	 
	 
	 
    always_comb
    begin
			pac_X_Pos_in = pac_X_Pos;
			pac_Y_Pos_in = pac_Y_Pos;
			pac_X_Motion_in = pac_X_Motion;
			pac_Y_Motion_in = pac_Y_Motion;
			dir_in = dir;
			turn_in = 4'b0000;		//keyboard input direction
			
			
			case(keycode[7:0])		//keyboard input
			
				8'h1a:	//W
				begin
					pac_X_TurnMotion_in = 10'd0;
					pac_Y_TurnMotion_in = ~(pac_Y_Step) + 1'd1;
					dir_in = 4'b1000;
					turn_in = 4'b1000;
					wall = up;
				end
				
				8'h04:	//A
				begin
					pac_Y_TurnMotion_in = 10'd0;
					pac_X_TurnMotion_in = ~(pac_X_Step) + 1'd1;
					dir_in = 4'b0010;
					turn_in = 4'b0010;
					wall = left;
				end
				
				8'h16:	//S
				begin
					pac_X_TurnMotion_in = 10'd0;
					pac_Y_TurnMotion_in = pac_Y_Step;
					dir_in = 4'b0100;
					turn_in = 4'b0100;
					wall = down;
				end
				
				8'h07:	//D
				begin
					pac_Y_TurnMotion_in = 10'd0;
					pac_X_TurnMotion_in = pac_X_Step;
					dir_in = 4'b0001;
					turn_in = 4'b0001;
					wall = right;
				end
				
				default:
				begin
					pac_X_TurnMotion_in = pac_X_Motion;
					pac_Y_TurnMotion_in = pac_Y_Motion;
					turn_in = 4'b0000;
					wall = 1'b1;
				end
				
			endcase
			
			
			
			if(crossing)
			begin
			
				if(turn == 4'b1000 && up == 1'b0)	//up
				begin
					pac_X_Motion_in = 10'd0;
					pac_Y_Motion_in = ~(pac_Y_Step) + 1'd1;
				end
				else if(turn == 4'b0100 && down == 1'b0) //down
				begin
					pac_X_Motion_in = 10'd0;
					pac_Y_Motion_in = pac_Y_Step;
				end
				else if(turn == 4'b0010 && left == 1'b0) //left
				begin
					pac_Y_Motion_in = 10'd0;
					pac_X_Motion_in = ~(pac_X_Step) + 1'd1;
				end
				else if(turn == 4'b0001 && right == 1'b0) //right
				begin	
					pac_Y_Motion_in = 10'd0;
					pac_X_Motion_in = pac_X_Step;
				end
				else
				begin
					pac_Y_Motion_in = 10'd0;
					pac_X_Motion_in = 10'd0;
				end
				
			end 
			else 
			begin
			
				if(turn == 4'b1000 && dir == 4'b0100)	//going down, turn up
				begin
					pac_X_Motion_in = 10'd0;
					pac_Y_Motion_in = ~(pac_Y_Step) + 1'd1;
				end
				else if(turn == 4'b0100 && dir == 4'b1000) //going up, turn down
				begin
					pac_X_Motion_in = 10'd0;
					pac_Y_Motion_in = pac_Y_Step;
				end
				else if(turn == 4'b0010 && dir == 4'b0001) //going right, turn left
				begin
					pac_Y_Motion_in = 10'd0;
					pac_X_Motion_in = ~(pac_X_Step) + 1'd1;
				end
				else if(turn == 4'b0001 && dir == 4'b0010) //going left, turn right
				begin	
					pac_Y_Motion_in = 10'd0;
					pac_X_Motion_in = pac_X_Step;
				end
				else
				begin
					pac_X_Motion_in = pac_X_Motion;
					pac_Y_Motion_in = pac_Y_Motion;
				end
				
			end
			
			
			
			if (wall || ~crossing)
			begin
				pac_X_Motion_in = pac_X_Motion_in;
				pac_Y_Motion_in = pac_Y_Motion_in;
			end
			else
			begin
				pac_X_Motion_in = pac_X_TurnMotion_in;
				pac_Y_Motion_in = pac_Y_TurnMotion_in;
			end
			
			
			
			// Update pac's position with its motion
			pac_X_Pos_in = pac_X_Pos + pac_X_Motion;
			pac_Y_Pos_in = pac_Y_Pos + pac_Y_Motion;
	 
    end

	 
	 
    
endmodule
