module dotGrid (
						input logic Clk, Reset,
						input logic [9:0] pacX, pacY,
						output logic [307:0] show
					);

	//200 TOTAL EDIBLE DOTS
	dotRow dr0 (.dotY(10'd24 ), .show(show[13:0   ]), .*);
	dotRow dr1 (.dotY(10'd40 ), .show(show[27:14  ]), .*);
	dotRow dr2 (.dotY(10'd56 ), .show(show[41:28  ]), .*);
	dotRow dr3 (.dotY(10'd72 ), .show(show[55:42  ]), .*);
	dotRow dr4 (.dotY(10'd88 ), .show(show[69:56  ]), .*);
	dotRow dr5 (.dotY(10'd104), .show(show[83:70  ]), .*);
	dotRow dr6 (.dotY(10'd120), .show(show[97:84  ]), .*);
	dotRow dr7 (.dotY(10'd136), .show(show[111:98 ]), .*);
	dotRow dr8 (.dotY(10'd152), .show(show[125:112]), .*);
	dotRow dr9 (.dotY(10'd168), .show(show[139:126]), .*);
	dotRow dr10(.dotY(10'd184), .show(show[153:140]), .*);
	
	dotRowBox dr11(.dotY(10'd200), .show(show[167:154]), .*);
	
	dotRow dr12(.dotY(10'd216), .show(show[181:168]), .*);
	dotRow dr13(.dotY(10'd232), .show(show[195:182]), .*);
	dotRow dr14(.dotY(10'd248), .show(show[209:196]), .*);
	dotRow dr15(.dotY(10'd264), .show(show[223:210]), .*);
	dotRow dr16(.dotY(10'd280), .show(show[237:224]), .*);
	dotRow dr17(.dotY(10'd296), .show(show[251:238]), .*);
	dotRow dr18(.dotY(10'd312), .show(show[265:252]), .*);
	dotRow dr19(.dotY(10'd328), .show(show[279:266]), .*);
	dotRow dr20(.dotY(10'd344), .show(show[293:280]), .*);
	dotRow dr21(.dotY(10'd360), .show(show[307:294]), .*);
	
	
endmodule




module dotRow (
					input logic Clk, Reset,
					input logic [9:0] dotY,
					input logic [9:0] pacX, pacY,
					output logic [13:0] show
				  );
	
	dot d0 (.dotX(10'd24 ), .show(show[0 ]), .*);
	dot d1 (.dotX(10'd40 ), .show(show[1 ]), .*);
	dot d2 (.dotX(10'd56 ), .show(show[2 ]), .*);
	dot d3 (.dotX(10'd72 ), .show(show[3 ]), .*);
	dot d4 (.dotX(10'd88 ), .show(show[4 ]), .*);
	dot d5 (.dotX(10'd104), .show(show[5 ]), .*);
	dot d6 (.dotX(10'd120), .show(show[6 ]), .*);
	dot d7 (.dotX(10'd136), .show(show[7 ]), .*);
	dot d8 (.dotX(10'd152), .show(show[8 ]), .*);
	dot d9 (.dotX(10'd168), .show(show[9 ]), .*);
	dot d10(.dotX(10'd184), .show(show[10]), .*);
	dot d11(.dotX(10'd200), .show(show[11]), .*);
	dot d12(.dotX(10'd216), .show(show[12]), .*);
	dot d13(.dotX(10'd232), .show(show[13]), .*);
	
	
endmodule



//For hidden dots in ghost box
//ghost box, 88-168, middle 6 
module dotRowBox (
					input logic Clk, Reset,
					input logic [9:0] dotY,
					input logic [9:0] pacX, pacY,
					output logic [13:0] show
				  );
	
	dot d0 (.dotX(10'd24 ), .show(show[0 ]), .*);
	dot d1 (.dotX(10'd40 ), .show(show[1 ]), .*);
	dot d2 (.dotX(10'd56 ), .show(show[2 ]), .*);
	dot d3 (.dotX(10'd72 ), .show(show[3 ]), .*);
	
	dot d10(.dotX(10'd184), .show(show[10]), .*);
	dot d11(.dotX(10'd200), .show(show[11]), .*);
	dot d12(.dotX(10'd216), .show(show[12]), .*);
	dot d13(.dotX(10'd232), .show(show[13]), .*);
	
	assign show[9:4] = 6'b111111;
	
endmodule

