module  ghost (input         Clk,               // 50 MHz clock
                             Reset,             // Active-high reset signal
                             frame_clk,         // The clock indicating a new frame (~60Hz)
					input logic [9:0] gStartX, gStartY,	//starting position
					input logic [383:0] wallData,		//get maze walls
					input logic [9:0] pac_x, pac_y,	//input pacman coords
					input logic start,
					input logic [2:0] AIpercent,	//percentage of rnd or ai
					input logic [1:0] rnd_dir,			//random dir
					input logic ggShow,				//good game sign show
					input logic on,					//switches on off
					input logic freeze,				//super dot freeze
					output logic [9:0] ghostX, ghostY,
					output logic ggOut
					//output crossing						//is ghost at a crossing
				  );
    
	 //Constants
    parameter [9:0] g_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] g_Y_Step = 10'd1;      // Step size on the Y axis
    
    logic [9:0] g_X_Pos, g_X_Motion, g_Y_Pos, g_Y_Motion;
    logic [9:0] g_X_Pos_in, g_X_Motion_in, g_Y_Pos_in, g_Y_Motion_in;
    logic [3:0] dir, dir_in, turn, turn_in, prev, prev_in;			//3210 = up,down,left,right
	 logic gg_in, gg;			//collision with pacman
	 assign ggOut = gg;
	 
	 logic [9:0] g_x, g_y;
	 assign g_x = g_X_Pos;
	 assign g_y = g_Y_Pos;
	 assign ghostX = g_x;			//output x and y location
	 assign ghostY = g_y;
	 
	 logic [9:0] gXWalls, gYWalls;	//input for wall detector
	 logic up, down, left, right;		//wall status
	 
	 logic AI, AIstart, AIstart_in;
	 
	 assign crossing = (g_x[3:0] == 8 && g_y[3:0] == 8);
	 
	 //wall detection module
	 findWalls findwalls(.up(up), .down(down), .left(left), .right(right), .xPos(gXWalls), .yPos(gYWalls), .*);
	 
	 //wall detector sprite boundaries
	 always_comb
	 begin
		if (dir == 4'b1000) begin
			gXWalls = g_x;
			gYWalls = g_y+7;
		end
		else if (dir == 4'b0100) begin
			gXWalls = g_x;
			gYWalls = g_y-7;
		end
		else if (dir == 4'b0010) begin
			gXWalls = g_x+7;
			gYWalls = g_y;
		end
		else if (dir == 4'b0001) begin
			gXWalls = g_x-7;
			gYWalls = g_y;
		end
		else begin		//should never happen
			gXWalls = g_x;
			gYWalls = g_y;
		end	
	 end
	 
	 
	 
    always_ff @ (posedge frame_clk or posedge Reset)
    begin
        if (Reset)
        begin
            g_X_Pos <= gStartX;	//starting position
            g_Y_Pos <= gStartY;
            g_X_Motion <= 10'd0;
            g_Y_Motion <= 10'd0;
				dir <= 4'b0001;
				turn <= 4'b0000;
				prev <= 4'b0000;
				AI <= 1'b0;
				AIstart <= 1'b0;
				gg <= 1'b0;
        end
        else
        begin
            g_X_Pos <= g_X_Pos_in;
            g_Y_Pos <= g_Y_Pos_in;
            g_X_Motion <= g_X_Motion_in;
            g_Y_Motion <= g_Y_Motion_in;
				dir <= dir_in;
				turn <= turn_in;
				prev <= prev_in;
				gg <= gg_in;
				AIstart <= AIstart_in;
				if (AIstart == 1'b1)
					AI <= 1'b1;
				else
					AI <= AI;
        end
    end
    
	 
	 
    always_comb
    begin
			g_X_Pos_in = g_X_Pos;
			g_Y_Pos_in = g_Y_Pos;
			g_X_Motion_in = g_X_Motion;
			g_Y_Motion_in = g_Y_Motion;
			dir_in = dir;
			turn_in = 4'b0000;
			prev_in = prev;
			AIstart_in = 1'b0;
			gg_in = gg;
			
			
			if(~ggShow)
			begin
			
				//Exit ghost box		//y=a8, x=88/78, box ends y=c8 x= a8/58
				if (start && on && ~AI)
				begin
					
					g_Y_Pos_in = 10'h0a8;
					if (g_X_Pos >= 10'h086)
					begin
						g_X_Pos_in = 10'h088;
					end
					if (g_X_Pos <= 10'h080)
					begin
						g_X_Pos_in = 10'h078;
					end
					
					AIstart_in = 1'b1;
					
				end
				
				
				
				//AI code
				if (AI)
				begin
				
					//Turn selection code
					if (crossing)
					begin
						
						//AI or rnd direction?
						if(AIpercent)
						begin
						
							//take a AI direction
							if ((pac_x[9:4] == ghostX[9:4]) && (pac_y[9:4] == ghostY[9:4]))		//If in same block dont move
							begin
								turn_in = 4'b0000;
							end
						
							else if (pac_x < ghostX && pac_y < ghostY)		//pac is left and up
							begin
								if (~left && prev != 4'b0001) begin
									turn_in = 4'b0010;
									prev_in = turn_in;
								end
								else if (~up && prev != 4'b0100) begin
									turn_in = 4'b1000;
									prev_in = turn_in;
								end
								else if (~right && prev != 4'b0010) begin
									turn_in = 4'b0001;
									prev_in = turn_in;
								end
								else if (~down &&  prev != 4'b1000) begin
									turn_in = 4'b0100;
									prev_in = turn_in;
								end
							end
							
							else if (pac_x > ghostX && pac_y < ghostY)		//pac is right and up
							begin
								if (~right && prev != 4'b0010) begin
									turn_in = 4'b0001;
									prev_in = turn_in;
								end
								else if (~up && prev != 4'b0100) begin
									turn_in = 4'b1000;
									prev_in = turn_in;
								end
								else if (~left && prev != 4'b0001) begin
									turn_in = 4'b0010;
									prev_in = turn_in;
								end
								else if (~down && prev != 4'b1000) begin
									turn_in = 4'b0100;
									prev_in = turn_in;
								end
							end
						
							else if (pac_x < ghostX && pac_y > ghostY)		//pac is left and down
							begin
								if (~left && prev != 4'b0001) begin
									turn_in = 4'b0010;
									prev_in = turn_in;
								end
								else if (~down && prev != 4'b1000) begin
									turn_in = 4'b0100;
									prev_in = turn_in;
								end
								else if (~right && prev != 4'b0010) begin
									turn_in = 4'b0001;
									prev_in = turn_in;
								end
								else if (~up && prev != 4'b0100) begin
									turn_in = 4'b1000;
									prev_in = turn_in;
								end
							end
						
							else if (pac_x > ghostX && pac_y > ghostY)		//pac is right and down
							begin
								if (~right && prev != 4'b0010) begin
									turn_in = 4'b0001;
									prev_in = turn_in;
								end
								else if (~down && prev != 4'b1000) begin
									turn_in = 4'b0100;
									prev_in = turn_in;
								end
								else if (~left && prev != 4'b0001) begin
									turn_in = 4'b0010;
									prev_in = turn_in;
								end
								else if (~up && prev != 4'b0100) begin
									turn_in = 4'b1000;
									prev_in = turn_in;
								end
							end
						
							else if (pac_x < ghostX)				//pac is left
							begin
								if (~left) begin
									turn_in = 4'b0010;
									prev_in = turn_in;
								end
								else if (~up) begin
									turn_in = 4'b1000;
									prev_in = turn_in;
								end
								else if (~down) begin
									turn_in = 4'b0100;
									prev_in = turn_in;
								end
								else if (~right) begin
									turn_in = 4'b0001;
									prev_in = turn_in;
								end
							end
							
							else if (pac_x > ghostX)		//pac is right
							begin
								if (~right) begin
									turn_in = 4'b0001;
									prev_in = turn_in;
								end
								else if (~up) begin
									turn_in = 4'b1000;
									prev_in = turn_in;
								end
								else if (~down) begin
									turn_in = 4'b0100;
									prev_in = turn_in;
								end
								else if (~left) begin
									turn_in = 4'b0010;
									prev_in = turn_in;
								end
							end
							
							else if (pac_y < ghostY)		//pac is up
							begin
								if (~up) begin
									turn_in = 4'b1000;
									prev_in = turn_in;
								end
								else if (~left) begin
									turn_in = 4'b0010;
									prev_in = turn_in;
								end
								else if (~right) begin
									turn_in = 4'b0001;
									prev_in = turn_in;
								end
								else if (~down) begin
									turn_in = 4'b0100;
									prev_in = turn_in;
								end
							end
							
							else if (pac_y > ghostY)		//pac is down
							begin
								if (~down) begin
									turn_in = 4'b0100;
									prev_in = turn_in;
								end
								else if (~left) begin
									turn_in = 4'b0010;
									prev_in = turn_in;
								end
								else if (~right) begin
									turn_in = 4'b0001;
									prev_in = turn_in;
								end
								else if (~up) begin
									turn_in = 4'b1000;
									prev_in = turn_in;
								end
							end
							
				
						end
						else			//take a random direction
						begin
							
							if (rnd_dir == 0 && ~up && prev != 4'b0100)
							begin
								turn_in = 4'b1000;
								prev_in = turn_in;
							end
							else if (rnd_dir == 1 && ~down && prev != 4'b1000)
							begin
								turn_in = 4'b0100;
								prev_in = turn_in;
							end
							else if (rnd_dir == 2 && ~left && prev != 4'b0001)
							begin
								turn_in = 4'b0010;
								prev_in = turn_in;
							end
							else if (rnd_dir == 3 && ~right && prev != 4'b0010)
							begin
								turn_in = 4'b0001;
								prev_in = turn_in;
							end
							
						end
						
						
					end
					
					
					if (~freeze)		//do movement when not in frozen mode (from super dot)
					begin
					
						//Movement code
						if (crossing)				//At a crossing
						begin
						
							if (turn == 4'b1000 && ~up)			//Want to turn up and there is no wall
							begin
								dir_in = 4'b1000;						//Set new direction to up
								g_X_Pos_in = g_X_Pos;				//Push ghost up one pixel
								g_Y_Pos_in = g_Y_Pos - 1;
								if (dir == 4'b0010) begin			//Account for off by 1 pixel error
									g_X_Pos_in = g_X_Pos_in + 1;
								end
								if (dir == 4'b0001) begin
									g_X_Pos_in = g_X_Pos_in - 1;
								end
							end
							else if (turn == 4'b0100 && ~down)
							begin
								dir_in = 4'b0100;
								g_X_Pos_in = g_X_Pos;
								g_Y_Pos_in = g_Y_Pos + 1;
								if (dir == 4'b0010) begin
									g_X_Pos_in = g_X_Pos_in + 1;
								end
								if (dir == 4'b0001) begin
									g_X_Pos_in = g_X_Pos_in - 1;
								end
							end
							else if (turn == 4'b0010 && ~left)
							begin
								dir_in = 4'b0010;
								g_X_Pos_in = g_X_Pos - 1;
								g_Y_Pos_in = g_Y_Pos;
								if (dir == 4'b1000) begin
									g_Y_Pos_in = g_Y_Pos_in + 1;
								end
								if (dir == 4'b0100) begin
									g_Y_Pos_in = g_Y_Pos_in - 1;
								end
							end
							else if (turn == 4'b0001 && ~right)
							begin
								dir_in = 4'b0001;
								g_X_Pos_in = g_X_Pos + 1;
								g_Y_Pos_in = g_Y_Pos;
								if (dir == 4'b1000) begin
									g_Y_Pos_in = g_Y_Pos_in + 1;
								end
								if (dir == 4'b0100) begin
									g_Y_Pos_in = g_Y_Pos_in - 1;
								end
							end
							else			//If no key pressed at crossing, dont move
							begin
								dir_in = dir;
								g_X_Pos_in = g_X_Pos;
								g_Y_Pos_in = g_Y_Pos;
							end
						
						end
						else			//If not at a crossing, continue until one is reached
						begin
						
							if (dir == 4'b1000)
							begin
								g_X_Motion_in = 10'd0;
								g_Y_Motion_in = ~(g_Y_Step) + 1'd1;
							end
							else if (dir == 4'b0100)
							begin
								g_X_Motion_in = 10'd0;
								g_Y_Motion_in = g_Y_Step;
							end
							else if (dir == 4'b0010)
							begin
								g_X_Motion_in = ~(g_X_Step) + 1'd1;
								g_Y_Motion_in = 10'd0;
							end
							else if (dir == 4'b0001)
							begin
								g_X_Motion_in = g_X_Step;
								g_Y_Motion_in = 10'd0;
							end
							else						//Should never happen
							begin
								g_X_Motion_in = g_X_Motion;
								g_Y_Motion_in = g_Y_Motion;
							end
							
							g_X_Pos_in = g_X_Pos + g_X_Motion;
							g_Y_Pos_in = g_Y_Pos + g_Y_Motion;
								
						end
						
					end
					
					
				end
			
			
			end
			
			
			//pacman collision with ghost
			if (
					((ghostX >= pac_x-12) && (ghostX <= pac_x+12) && (ghostY >= pac_y-12) && (ghostY <= pac_y+12))
				|| ((pac_x >= ghostX-12) && (pac_x <= ghostX+12) && (pac_y >= ghostY-12) && (pac_y <= ghostY+12))
				|| (ghostX[9:4] == pac_x[9:4] && ghostY[9:4] == pac_y[9:4])
				)
			begin
				gg_in = 1'b1;
			end
			else
			begin
				gg_in = 1'b0;
			end
			
			
	 
    end

	 
	 
    
endmodule
