module dotSprite (
						input [1:0] addr,
						output [3:0] data
					  );
	
	//2 addr bits = 4 spots
	logic [3:0][3:0] ROM = 
	{
		//Dot
		4'b 0110,
		4'b 1111,
		4'b 1111,
		4'b 0110
	
	};

	assign data = ROM[addr];


endmodule
