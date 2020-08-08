//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( //input              is_ball,            // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
							  input  [9:0] pac_x, pac_y,					//pacman coords
							  input [3:0] pacDir,							//pacman direction
							  input [9:0] ghost1X, ghost1Y,				//ghost 1 coords
							  input [9:0] ghost2X, ghost2Y,				//ghost 2 coords
							  input [9:0] ghost3X, ghost3Y,				//ghost 3 coords
							  input [9:0] ghost4X, ghost4Y,				//ghost 4 coords
							  input [307:0] dotShow,				//Dot grid
							  input [7:0] score,				//full game score (not in mults of 4)
							  input ggShow,				//show good game label
							  input sd1Show, sd2Show, sd3Show, sd4Show,	//super dot show
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    


	//pacman sprite
	logic [6:0] pacSprAddr;
	logic [9:0] pacSprAddrTempY;
	assign pacSprAddrTempY = DrawY - pac_y+8;
	logic [15:0] pacSprData;
	sprites pacSpr(.addr(pacSprAddr), .data(pacSprData));
	
	//maze sprite
	logic [8:0] mazeAddr;
	logic [255:0] mazeData;
	maze map(.addr(mazeAddr), .data(mazeData));
	
	//dot grid sprite
	logic [1:0] dotAddr;
	logic [9:0] dotAddrTempY;
	assign dotAddrTempY = DrawY-22;
	logic [9:0] dotAddrTempX;
	assign dotAddrTempX = DrawX-22;
	logic [3:0] dotData;
	dotSprite dot(.addr(dotAddr), .data(dotData));
	
	//super dots
	dotSprite sd1(.addr(sd1Addr), .data(sd1Data));
	logic [1:0] sd1Addr;
	logic [3:0] sd1Data;
	dotSprite sd2(.addr(sd2Addr), .data(sd2Data));
	logic [1:0] sd2Addr;
	logic [3:0] sd2Data;
	dotSprite sd3(.addr(sd3Addr), .data(sd3Data));
	logic [1:0] sd3Addr;
	logic [3:0] sd3Data;
	dotSprite sd4(.addr(sd4Addr), .data(sd4Data));
	logic [1:0] sd4Addr;
	logic [3:0] sd4Data;

	//ghost1 sprite
	logic [6:0] ghost1Addr;
	logic [9:0] ghost1AddrTempY;
	assign ghost1AddrTempY = DrawY - ghost1Y+8;
	logic [15:0] ghost1Data;
	ghostSprite ghost1(.addr(ghost1Addr), .data(ghost1Data));
	
	//ghost2 sprite
	logic [6:0] ghost2Addr;
	logic [9:0] ghost2AddrTempY;
	assign ghost2AddrTempY = DrawY - ghost2Y+8;
	logic [15:0] ghost2Data;
	ghostSprite ghost2(.addr(ghost2Addr), .data(ghost2Data));
	
	//ghost3 sprite
	logic [6:0] ghost3Addr;
	logic [9:0] ghost3AddrTempY;
	assign ghost3AddrTempY = DrawY - ghost3Y+8;
	logic [15:0] ghost3Data;
	ghostSprite ghost3(.addr(ghost3Addr), .data(ghost3Data));
	
	//ghost4 sprite
	logic [6:0] ghost4Addr;
	logic [9:0] ghost4AddrTempY;
	assign ghost4AddrTempY = DrawY - ghost4Y+8;
	logic [15:0] ghost4Data;
	ghostSprite ghost4(.addr(ghost4Addr), .data(ghost4Data));
	
	//score digits 1 and 2
	numbers dig1(.addr(dig1Addr), .data(dig1Data));
	logic [7:0] dig1Addr, dig1Data;
	numbers dig2(.addr(dig2Addr), .data(dig2Data));
	logic [7:0] dig2Addr, dig2Data;
	//Score display controller
	scoreDisplay scoreControl(.score(score[7:2]), .numAddr1(dig1Temp), .numAddr2(dig2Temp));
	logic [7:0] dig1Temp, dig2Temp;		//Addresses of numbers in rom
	
	//Score label
	scoreChars scoreLabel(.addr(scoreLabAddr), .data(scoreLabData));
	logic [3:0] scoreLabAddr;
	logic [47:0] scoreLabData;
	
	//gg label
	gameOver ggLabel(.addr(ggLabAddr), .data(ggLabData));
	logic [3:0] ggLabAddr;
	logic [71:0] ggLabData;
	
	
	logic is_pac, is_maze, is_dot, is_ghost1, is_ghost2, is_ghost3, is_ghost4; 
	logic is_score1, is_score2, is_scoreLab, is_ggLab; 
	logic is_sd1, is_sd2, is_sd3, is_sd4;
	

	//Which sprite is it
	always_comb 
	begin
		
		//maze (256x384)
		if (DrawX < 256 && DrawY < 384)
		begin
			mazeAddr = DrawY;
			is_maze = 1'b1;
		end
		else begin
			mazeAddr = 9'b0;
			is_maze = 1'b0;
		end
		
		//if (DrawX < 256 && DrawY < 384 && dotShow[dotAddrTempY[9:5]*14 + dotAddrTempX[9:5]] == 1'b1 && dotAddrTempX[4:0] <= 3 && dotAddrTempY[4:0] <= 3)
		//if (DrawX < 256 && DrawY < 384 && dotShow[DrawY[9:4]*14 + DrawX[9:4]] == 1'b1)
		//Dot size = 2 (radius)
		if (DrawX < 256 && DrawY < 384 && dotShow[dotAddrTempY[9:4]*14 + dotAddrTempX[9:4]] == 1'b0 && dotAddrTempX[3:0] < 4 && dotAddrTempY[3:0] < 4)
		begin
			dotAddr = dotAddrTempY[1:0];
			is_dot = 1'b1;
		end
		else
		begin
			dotAddr = 2'b0;
			is_dot = 1'b0;
		end
		
		
		//pacman size = 8 (radius)
		if ((DrawX >= pac_x-8) && (DrawX <= pac_x+8) && (DrawY >= pac_y-8) && (DrawY <= pac_y+8))
		begin
			case (pacDir)
				4'b1000: pacSprAddr = pacSprAddrTempY[6:0] + 48;	//up (2nd sprite)
				4'b0100: pacSprAddr = pacSprAddrTempY[6:0] + 32;	//down (1st sprite)
				4'b0010: pacSprAddr = pacSprAddrTempY[6:0] + 16;	//left (4th sprite)
				4'b0001: pacSprAddr = pacSprAddrTempY[6:0];			//right (3rd sprite)
				default: pacSprAddr = pacSprAddrTempY[6:0];			//Default right (no dir)
			endcase
			is_pac = 1'b1;
		end 
		else 
		begin
			pacSprAddr = 7'b0;
			is_pac = 1'b0;
		end
	
		
		//ghost1 size = 8
		if ((DrawX >= ghost1X-8) && (DrawX <= ghost1X+8) && (DrawY >= ghost1Y-8) && (DrawY <= ghost1Y+8))
		begin
			ghost1Addr = ghost1AddrTempY[6:0];
			is_ghost1 = 1'b1;
		end 
		else 
		begin
			ghost1Addr = 7'b0;
			is_ghost1 = 1'b0;
		end
	
		
		//ghost2 size = 8
		if ((DrawX >= ghost2X-8) && (DrawX <= ghost2X+8) && (DrawY >= ghost2Y-8) && (DrawY <= ghost2Y+8))
		begin
			ghost2Addr = ghost2AddrTempY[6:0];
			is_ghost2 = 1'b1;
		end 
		else 
		begin
			ghost2Addr = 7'b0;
			is_ghost2 = 1'b0;
		end
		
		
		//ghost3 size = 8
		if ((DrawX >= ghost3X-8) && (DrawX <= ghost3X+8) && (DrawY >= ghost3Y-8) && (DrawY <= ghost3Y+8))
		begin
			ghost3Addr = ghost3AddrTempY[6:0];
			is_ghost3 = 1'b1;
		end 
		else 
		begin
			ghost3Addr = 7'b0;
			is_ghost3 = 1'b0;
		end
		
		
		//ghost4 size = 8
		if ((DrawX >= ghost4X-8) && (DrawX <= ghost4X+8) && (DrawY >= ghost4Y-8) && (DrawY <= ghost4Y+8))
		begin
			ghost4Addr = ghost4AddrTempY[6:0];
			is_ghost4 = 1'b1;
		end 
		else 
		begin
			ghost4Addr = 7'b0;
			is_ghost4 = 1'b0;
		end
		
		
		//score display digit1 8x16
		if ((DrawX >= 450) && (DrawX < 450+8) && (DrawY >= 240) && (DrawY < 240+16))
		begin
			dig1Addr = DrawY - 240 + dig1Temp;		//Temp is offset for correct number
			is_score1 = 1'b1;
		end 
		else 
		begin
			dig1Addr = 8'b0;
			is_score1 = 1'b0;
		end
		
		
		//score display digit2 8x16
		if ((DrawX >= 460) && (DrawX < 460+8) && (DrawY >= 240) && (DrawY < 240+16))
		begin
			dig2Addr = DrawY - 240 + dig2Temp;		//Temp is offset for correct number
			is_score2 = 1'b1;
		end 
		else 
		begin
			dig2Addr = 8'b0;
			is_score2 = 1'b0;
		end
		
		
		//score label 48x16
		if ((DrawX >= 400) && (DrawX < 400+48) && (DrawY >= 240) && (DrawY < 240+16))
		begin
			scoreLabAddr = DrawY - 240;
			is_scoreLab = 1'b1;
		end 
		else 
		begin
			scoreLabAddr = 4'b0;
			is_scoreLab = 1'b0;
		end
		
		
		//gg label 72x16
		if ((DrawX >= 400) && (DrawX < 400+72) && (DrawY >= 120) && (DrawY < 120+16) && ggShow)
		begin
			ggLabAddr = DrawY - 120;
			is_ggLab = 1'b1;
		end 
		else 
		begin
			ggLabAddr = 4'b0;
			is_ggLab = 1'b0;
		end
		
		
		//super dot 4x4 018,078
		if ((DrawX >= 10'h016) && (DrawX < 10'h016+4) && (DrawY >= 10'h076) && (DrawY < 10'h076+4) && sd1Show)
		begin
			sd1Addr = DrawY - 10'h076;
			is_sd1 = 1'b1;
		end 
		else 
		begin
			sd1Addr = 2'b0;
			is_sd1 = 1'b0;
		end
		
		//super dot 4x4 0e8,078
		if ((DrawX >= 10'h0e6) && (DrawX < 10'h0e6+4) && (DrawY >= 10'h076) && (DrawY < 10'h076+4) && sd2Show)
		begin
			sd2Addr = DrawY - 10'h076;
			is_sd2 = 1'b1;
		end 
		else 
		begin
			sd2Addr = 2'b0;
			is_sd2 = 1'b0;
		end
		
		//super dot 4x4 0e8,118
		if ((DrawX >= 10'h0e6) && (DrawX < 10'h0e6+4) && (DrawY >= 10'h116) && (DrawY < 10'h116+4) && sd3Show)
		begin
			sd3Addr = DrawY - 10'h116;
			is_sd3 = 1'b1;
		end 
		else 
		begin
			sd3Addr = 2'b0;
			is_sd3 = 1'b0;
		end
		
		//super dot 4x4 018,118
		if ((DrawX >= 10'h016) && (DrawX < 10'h016+4) && (DrawY >= 10'h116) && (DrawY < 10'h116+4) && sd4Show)
		begin
			sd4Addr = DrawY - 10'h116;
			is_sd4 = 1'b1;
		end 
		else 
		begin
			sd4Addr = 2'b0;
			is_sd4 = 1'b0;
		end
		
		
	end
	
	
	
	logic [9:0] pacSprDataTempX;
	assign pacSprDataTempX = DrawX - pac_x+8;
	
	logic [9:0] ghost1DataTempX;
	assign ghost1DataTempX = DrawX - ghost1X+8;
	
	logic [9:0] ghost2DataTempX;
	assign ghost2DataTempX = DrawX - ghost2X+8;
	
	logic [9:0] ghost3DataTempX;
	assign ghost3DataTempX = DrawX - ghost3X+8;
	
	logic [9:0] ghost4DataTempX;
	assign ghost4DataTempX = DrawX - ghost4X+8;

	
	//Assign colors
	always_comb
	begin
	
		if (is_ghost1 && ghost1Data[ghost1DataTempX])		//red ghost1
		begin
			Red = 8'hff;
			Green = 8'h22;
			Blue = 8'h22;
		end
		else if (is_ghost2 && ghost2Data[ghost2DataTempX])		//green ghost2
		begin
			Red = 8'h22;
			Green = 8'hff;
			Blue = 8'h22;
		end
		else if (is_ghost3 && ghost3Data[ghost3DataTempX])		//pink ghost3
		begin
			Red = 8'hed;
			Green = 8'h71;
			Blue = 8'heb;
		end
		else if (is_ghost4 && ghost4Data[ghost4DataTempX])		//orange ghost4
		begin
			Red = 8'hff;
			Green = 8'h92;
			Blue = 8'h1e;
		end
		else if (is_pac && pacSprData[pacSprDataTempX])		//Yellow pacman
		begin
			Red = 8'hff;
			Green = 8'hff;
			Blue = 8'h22;
		end
		else if (is_maze && mazeData[DrawX[7:0]])				//Blue maze walls
		begin
			Red = 8'h22;
			Green = 8'h22;
			Blue = 8'hff;
		end
		else if (is_sd1 && sd1Data[DrawX - 10'h016])			//super Dot 1
		begin
			Red = 8'hff;
			Green = 8'hff;
			Blue = 8'hff;
		end
		else if (is_sd2 && sd2Data[DrawX - 10'h0e6])			//super Dot 2
		begin
			Red = 8'hff;
			Green = 8'hff;
			Blue = 8'hff;
		end
		else if (is_sd3 && sd3Data[DrawX - 10'h0e6])			//super Dot 3
		begin
			Red = 8'hff;
			Green = 8'hff;
			Blue = 8'hff;
		end
		else if (is_sd4 && sd4Data[DrawX - 10'h016])			//super Dot 4
		begin
			Red = 8'hff;
			Green = 8'hff;
			Blue = 8'hff;
		end
		else if (is_dot && dotData[dotAddrTempX[1:0]])			//Dots
		begin
			Red = 8'hff;
			Green = 8'hdc;
			Blue = 8'h6b;
		end
		else if (is_score1 && dig1Data[DrawX - 450])			//score 1
		begin
			Red = 8'hff;
			Green = 8'hff;
			Blue = 8'hff;
		end
		else if (is_score2 && dig2Data[DrawX - 460])			//score 2
		begin
			Red = 8'hff;
			Green = 8'hff;
			Blue = 8'hff;
		end
		else if (is_scoreLab && scoreLabData[DrawX - 400])			//score label
		begin
			Red = 8'hff;
			Green = 8'hff;
			Blue = 8'hff;
		end
		else if (is_ggLab && ggLabData[DrawX - 400])			//gg label
		begin
			Red = 8'hff;
			Green = 8'hff;
			Blue = 8'hff;
		end
		else											//background
		begin
			Red = 8'h00; 
			Green = 8'h00;
			Blue = 8'h00;
		end
	
	end
	

    
endmodule
