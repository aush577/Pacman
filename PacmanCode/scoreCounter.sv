//Counts the number of dots (1's) in dotShow array
module scoreCounter (
							input Clk,
							input [307:0] in, 
                     output reg [7:0] out
						  );
						  
	logic [7:0] temp;
	always @(Clk)
	begin
		temp = 0;
		
      for(int i = 0; i < 308; i++)
		begin
			temp = temp + in[i];
		end
		
      out <= temp - 6;		//6 offset for removed dots from ghost box
	end
	 
endmodule
