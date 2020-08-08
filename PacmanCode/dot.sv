module dot (
					input logic Clk, Reset,
					input logic [9:0] dotX, dotY,
					input logic [9:0] pacX, pacY,
					output logic show
			  );

	logic show_in;
	//initial show_in = 1'b1;
	
	always_ff @ (posedge Clk)
	begin
		if (Reset) begin
			show <= 1'b0;
		end else begin
			show <= show_in;
		end
	end


	always_comb 
	begin
		//show_in = show;
	
		if ((dotX >= pacX-6) && (dotX <= pacX+6) && (dotY >= pacY-6) && (dotY <= pacY+6) && show == 1'b0) begin
			show_in = 1'b1;	//if collision with pacman dont show
		end else begin
			show_in = show;
		end
	
	end
	

endmodule
