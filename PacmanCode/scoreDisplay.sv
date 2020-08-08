//takes input of current score. outputs the addresses of the digits in the numbers rom
module scoreDisplay (input logic[5:0] score,
							output logic[7:0] numAddr1,
							output logic[7:0] numAddr2
							);

	always_comb
	begin
		case(score)
		
			8'd0:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd0;
			end
			
			8'd01:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd16;
			end
			
			8'd02:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd32;
			end
			
			8'd03:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd48;
			end
			
			8'd04:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd64;
			end
			
			8'd05:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd80;
			end
			
			8'd06:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd96;
			end
			
			8'd07:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd112;
			end
			
			8'd08:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd128;
			end
			
			8'd09:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd144;
			end
			
			8'd10:
			begin
			numAddr1 = 8'd16;
			numAddr2 = 8'd0;
			end
			
			8'd11:
			begin
			numAddr1 = 8'd16;
			numAddr2 = 8'd16;
			end
			
			8'd12:
			begin
			numAddr1 = 8'd16;
			numAddr2 = 8'd32;
			end
			
			8'd13:
			begin
			numAddr1 = 8'd16;
			numAddr2 = 8'd48;
			end
			
			8'd14:
			begin
			numAddr1 = 8'd16;
			numAddr2 = 8'd64;
			end
			
			8'd15:
			begin
			numAddr1 = 8'd16;
			numAddr2 = 8'd80;
			end
			
			8'd16:
			begin
			numAddr1 = 8'd16;
			numAddr2 = 8'd96;
			end
			
			8'd17:
			begin
			numAddr1 = 8'd16;
			numAddr2 = 8'd112;
			end
			
			8'd18:
			begin
			numAddr1 = 8'd16;
			numAddr2 = 8'd128;
			end
			
			8'd19:
			begin
			numAddr1 = 8'd16;
			numAddr2 = 8'd144;
			end
			
			8'd20:
			begin
			numAddr1 = 8'd32;
			numAddr2 = 8'd0;
			end
			
			8'd21:
			begin
			numAddr1 = 8'd32;
			numAddr2 = 8'd16;
			end
			
			8'd22:
			begin
			numAddr1 = 8'd32;
			numAddr2 = 8'd32;
			end
			
			8'd23:
			begin
			numAddr1 = 8'd32;
			numAddr2 = 8'd48;
			end
			
			8'd24:
			begin
			numAddr1 = 8'd32;
			numAddr2 = 8'd64;
			end
			
			8'd25:
			begin
			numAddr1 = 8'd32;
			numAddr2 = 8'd80;
			end
			
			8'd26:
			begin
			numAddr1 = 8'd32;
			numAddr2 = 8'd96;
			end

			8'd27:
			begin
			numAddr1 = 8'd32;
			numAddr2 = 8'd112;
			end

			8'd28:
			begin
			numAddr1 = 8'd32;
			numAddr2 = 8'd128;
			end

			8'd29:
			begin
			numAddr1 = 8'd32;
			numAddr2 = 8'd144;
			end

			8'd30:
			begin
			numAddr1 = 8'd48;
			numAddr2 = 8'd0;
			end

			8'd31:
			begin
			numAddr1 = 8'd48;
			numAddr2 = 8'd16;
			end

			8'd32:
			begin
			numAddr1 = 8'd48;
			numAddr2 = 8'd32;
			end

			8'd33:
			begin
			numAddr1 = 8'd48;
			numAddr2 = 8'd48;
			end

			8'd34:
			begin
			numAddr1 = 8'd48;
			numAddr2 = 8'd64;
			end

			8'd35:
			begin
			numAddr1 = 8'd48;
			numAddr2 = 8'd80;
			end

			8'd36:
			begin
			numAddr1 = 8'd48;
			numAddr2 = 8'd96;
			end

			8'd37:
			begin
			numAddr1 = 8'd48;
			numAddr2 = 8'd112;
			end

			8'd38:
			begin
			numAddr1 = 8'd48;
			numAddr2 = 8'd128;
			end

			8'd39:
			begin
			numAddr1 = 8'd48;
			numAddr2 = 8'd144;
			end

			8'd40:
			begin
			numAddr1 = 8'd64;
			numAddr2 = 8'd0;
			end

			8'd41:
			begin
			numAddr1 = 8'd64;
			numAddr2 = 8'd16;
			end

			8'd42:
			begin
			numAddr1 = 8'd64;
			numAddr2 = 8'd32;
			end

			8'd43:
			begin
			numAddr1 = 8'd64;
			numAddr2 = 8'd48;
			end

			8'd44:
			begin
			numAddr1 = 8'd64;
			numAddr2 = 8'd64;
			end

			8'd45:
			begin
			numAddr1 = 8'd64;
			numAddr2 = 8'd80;
			end

			8'd46:
			begin
			numAddr1 = 8'd64;
			numAddr2 = 8'd96;
			end

			8'd47:
			begin
			numAddr1 = 8'd64;
			numAddr2 = 8'd112;
			end

			8'd48:
			begin
			numAddr1 = 8'd64;
			numAddr2 = 8'd128;
			end

			8'd49:
			begin
			numAddr1 = 8'd64;
			numAddr2 = 8'd144;
			end

			8'd50:
			begin
			numAddr1 = 8'd80;
			numAddr2 = 8'd0;
			end
			
			
			default:
			begin
			numAddr1 = 8'd0;
			numAddr2 = 8'd0;
			end
			
		endcase
	end
	
endmodule 
