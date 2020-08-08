module  pac2 ( input         Clk,               // 50 MHz clock
                             Reset,             // Active-high reset signal
                             frame_clk,         // The clock indicating a new frame (~60Hz)
					input [7:0]  keycode,				//ADDED KEYCODE FOR W,A,S,D CONFIGURATIONS
					input logic [383:0] wallData,		//get maze walls
					input ggShow,				//game over?
					output logic [9:0] pac_x, pac_y,	//Output pacman coords
					//output logic u, d, l, r,			//for testing up down left right wall collisions
					output [3:0] pacDir,					//current direction udlr
					//output crossing,						//is pacman at a crossing
					output logic start					//start ghost movement
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
    logic [3:0] dir, dir_in, turn, turn_in;			//3210 = up,down,left,right
	 
	 
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
	 
	 
	 assign crossing = (pac_x[3:0] == 8 && pac_y[3:0] == 8);
	 
	 
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
				start <= 1'b0;
        end
        else
        begin
            pac_X_Pos <= pac_X_Pos_in;
            pac_Y_Pos <= pac_Y_Pos_in;
            pac_X_Motion <= pac_X_Motion_in;
            pac_Y_Motion <= pac_Y_Motion_in;
				dir <= dir_in;
				turn <= turn_in;
				if (turn != 4'b0000)
					start <= 1'b1;
				else
					start <= start;
        end
    end
    
	 
	 
    always_comb
    begin
			pac_X_Pos_in = pac_X_Pos;
			pac_Y_Pos_in = pac_Y_Pos;
			pac_X_Motion_in = pac_X_Motion;
			pac_Y_Motion_in = pac_Y_Motion;
			dir_in = dir;
			turn_in = 4'b0000;
			
			if (~ggShow)
			begin 
				case(keycode[7:0])		//keyboard input
				
					8'h1a:	//W
					begin
						turn_in = 4'b1000;
					end
					
					8'h04:	//A
					begin
						turn_in = 4'b0010;
					end
					
					8'h16:	//S
					begin
						turn_in = 4'b0100;
					end
					
					8'h07:	//D
					begin
						turn_in = 4'b0001;
					end
					
					default:
					begin
						turn_in = 4'b0000;
					end
					
				endcase
			end
			
			
			if (crossing)				//At a crossing
			begin
			
				if (turn == 4'b1000 && ~up)			//Want to turn up and there is no wall
				begin
					dir_in = 4'b1000;						//Set new direction to up
					pac_X_Pos_in = pac_X_Pos;			//Push pacman up one pixel
					pac_Y_Pos_in = pac_Y_Pos - 1;
					if (dir == 4'b0010) begin			//Account for off by 1 pixel error
						pac_X_Pos_in = pac_X_Pos_in + 1;
					end
					if (dir == 4'b0001) begin
						pac_X_Pos_in = pac_X_Pos_in - 1;
					end
				end
				else if (turn == 4'b0100 && ~down)
				begin
					dir_in = 4'b0100;
					pac_X_Pos_in = pac_X_Pos;
					pac_Y_Pos_in = pac_Y_Pos + 1;
					if (dir == 4'b0010) begin
						pac_X_Pos_in = pac_X_Pos_in + 1;
					end
					if (dir == 4'b0001) begin
						pac_X_Pos_in = pac_X_Pos_in - 1;
					end
				end
				else if (turn == 4'b0010 && ~left)
				begin
					dir_in = 4'b0010;
					pac_X_Pos_in = pac_X_Pos - 1;
					pac_Y_Pos_in = pac_Y_Pos;
					if (dir == 4'b1000) begin
						pac_Y_Pos_in = pac_Y_Pos_in + 1;
					end
					if (dir == 4'b0100) begin
						pac_Y_Pos_in = pac_Y_Pos_in - 1;
					end
				end
				else if (turn == 4'b0001 && ~right)
				begin
					dir_in = 4'b0001;
					pac_X_Pos_in = pac_X_Pos + 1;
					pac_Y_Pos_in = pac_Y_Pos;
					if (dir == 4'b1000) begin
						pac_Y_Pos_in = pac_Y_Pos_in + 1;
					end
					if (dir == 4'b0100) begin
						pac_Y_Pos_in = pac_Y_Pos_in - 1;
					end
				end
				else			//If no key pressed at crossing, dont move
				begin
					dir_in = dir;
					pac_X_Pos_in = pac_X_Pos;
					pac_Y_Pos_in = pac_Y_Pos;
				end
			
			end
			else			//If not at a crossing, continue until one is reached
			begin
			
				if (dir == 4'b1000)
				begin
					pac_X_Motion_in = 10'd0;
					pac_Y_Motion_in = ~(pac_Y_Step) + 1'd1;
				end
				else if (dir == 4'b0100)
				begin
					pac_X_Motion_in = 10'd0;
					pac_Y_Motion_in = pac_Y_Step;
				end
				else if (dir == 4'b0010)
				begin
					pac_X_Motion_in = ~(pac_X_Step) + 1'd1;
					pac_Y_Motion_in = 10'd0;
				end
				else if (dir == 4'b0001)
				begin
					pac_X_Motion_in = pac_X_Step;
					pac_Y_Motion_in = 10'd0;
				end
				else						//Should never happen
				begin
					pac_X_Motion_in = pac_X_Motion;
					pac_Y_Motion_in = pac_Y_Motion;
				end
				
				pac_X_Pos_in = pac_X_Pos + pac_X_Motion;
				pac_Y_Pos_in = pac_Y_Pos + pac_Y_Motion;
					
			end
			
			
			
			// Update pac's position with its motion
//			pac_X_Pos_in = pac_X_Pos + pac_X_Motion;
//			pac_Y_Pos_in = pac_Y_Pos + pac_Y_Motion;
	 
    end

	 
	 
    
endmodule
