module superDot (
						input logic Clk, Reset,
						input logic [9:0] dotX, dotY,
						input logic [9:0] pacX, pacY,
						output logic show,
						output logic freeze
					 );

	logic show_in;
	logic [27:0] counter;
	logic cnt, cnt_in;
	
	always_ff @ (posedge Clk)
	begin
		if (Reset) begin
			show <= 1'b1;
			counter <= 28'b0;
			freeze <= 1'b0;
			cnt <= 1'b0;
		end else begin
			show <= show_in;
			cnt <= cnt_in;
			if (cnt == 1'b1) begin			//wait logic (about 5 seconds freeze time)
				counter <= counter + 1;
				freeze <= 1'b1;
			end else begin
				freeze <= 1'b0;
			end
		end
	end


	always_comb 
	begin

		if ((dotX >= pacX-6) && (dotX <= pacX+6) && (dotY >= pacY-6) && (dotY <= pacY+6) && show == 1'b1) 
		begin
			show_in = 1'b0;	//if collision with pacman, dissapear
			cnt_in = 1'b1;
		end 
		else if (counter == 2**28 - 1) 	//count from 0 to 2^28 at 50 MHz. (2^28) / (50*10^6) = 5.36 seconds
		begin
			cnt_in = 1'b0;
			show_in = 1'b0;
		end
		else 
		begin
			cnt_in = cnt;
			show_in = show;
		end

	end
	

endmodule
