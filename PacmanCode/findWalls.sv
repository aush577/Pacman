//takes x and y position as input. outputs the walls in surrounding 4 directions
module findWalls (
							input logic [383:0] wallData,
							input logic [9:0] xPos, yPos,
							output logic up, right, left, down	
					  );
	
	logic [5:0] xPosTemp, yPosTemp;
	assign xPosTemp = xPos[9:4];	
	assign yPosTemp = yPos[9:4];


	logic u, d, l, r;
	
	always_comb 
	begin
		
		l = wallData[(yPosTemp)*16 + (xPosTemp-1)];
		r = wallData[(yPosTemp)*16 + (xPosTemp+1)];
		u = wallData[(yPosTemp-1)*16 + (xPosTemp)];
		d = wallData[(yPosTemp+1)*16 + (xPosTemp)];
	
	end
	
	assign up = u;
	assign down = d;
	assign left = l;
	assign right = r;

endmodule
