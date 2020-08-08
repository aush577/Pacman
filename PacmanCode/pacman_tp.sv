//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module pacman_tp( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
				 input		  [17:0] SW,			//18 switches
				 output		  [17:0] LEDR,			//17 board LEDs (red)
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk;
    logic [7:0] keycode;
	 logic [9:0] DrawX, DrawY;
	 
	 
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     pacman_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset),
									  
									  .rnd_dir1_export(rnd_dir1),
									  .rnd_dir2_export(rnd_dir2),
									  .rnd_dir3_export(rnd_dir3),
									  .rnd_percent_export(rnd_percent) 
    );
    
	 //randomness exports for ghosts
	 logic [2:0] rnd_percent; 
	 logic [1:0] rnd_dir1, rnd_dir2, rnd_dir3;
	 
	 
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    VGA_controller vga_controller_instance(.*, .Reset(Reset_h));
    
	 //maps rgb colors for vga draw coords
	 color_mapper color_instance(.*);
	 logic ggShow;
	 assign ggShow = (gg1 || gg2 || gg3 || gg4 || (score >= 200)) && ~freeze;
	 
	 //pacman sprite
    pac2 pacman(.*, .Reset(Reset_h), .frame_clk(VGA_VS));
    logic [9:0] pac_x, pac_y;
	 logic [3:0] pacDir;
	 logic start;
	 
	 //red
	 ghost ghost1(.*, .Reset(Reset_h), .frame_clk(VGA_VS), .ghostX(ghost1X), .ghostY(ghost1Y), .gStartX(gStartX1), .gStartY(gStartY1), .rnd_dir(rnd_dir1), .AIpercent(AIpercent1), .ggOut(gg1), .on(on1));
	 logic [9:0] ghost1X, ghost1Y;
	 logic [9:0] gStartX1, gStartY1;
	 assign gStartX1 = 10'h0a8;
	 assign gStartY1 = 10'h0c8;
	 logic AIpercent1;
	 assign AIpercent1 = (1'b1);	// 0/8 chance rnd
	 logic gg1, on1;
	 assign on1 = SW[0];
	 
	 //green
	 ghost ghost2(.*, .Reset(Reset_h), .frame_clk(VGA_VS), .ghostX(ghost2X), .ghostY(ghost2Y), .gStartX(gStartX2), .gStartY(gStartY2), .rnd_dir(rnd_dir2), .AIpercent(AIpercent2), .ggOut(gg2), .on(on2));
	 logic [9:0] ghost2X, ghost2Y;
	 logic [9:0] gStartX2, gStartY2;
	 assign gStartX2 = 10'h058;
	 assign gStartY2 = 10'h0c8;
	 logic AIpercent2;
	 assign AIpercent2 = (rnd_percent > 2);	// 3/8 chance rnd
	 logic gg2, on2;
	 assign on2 = SW[1];
    
	 //pink
	 ghost ghost3(.*, .Reset(Reset_h), .frame_clk(VGA_VS), .ghostX(ghost3X), .ghostY(ghost3Y), .gStartX(gStartX3), .gStartY(gStartY3), .rnd_dir(rnd_dir3), .AIpercent(AIpercent3), .ggOut(gg3), .on(on3));
	 logic [9:0] ghost3X, ghost3Y;
	 logic [9:0] gStartX3, gStartY3;
	 assign gStartX3 = 10'h078;
	 assign gStartY3 = 10'h0c8;
	 logic AIpercent3;
	 assign AIpercent3 = (rnd_percent > 2);	// 3/8 chance rnd
	 logic gg3, on3;
	 assign on3 = SW[2];
	 
	 //orange
	 ghost ghost4(.*, .Reset(Reset_h), .frame_clk(VGA_VS), .ghostX(ghost4X), .ghostY(ghost4Y), .gStartX(gStartX4), .gStartY(gStartY4), .rnd_dir(rnd_dir1), .AIpercent(AIpercent4), .ggOut(gg4), .on(on4));
	 logic [9:0] ghost4X, ghost4Y;
	 logic [9:0] gStartX4, gStartY4;
	 assign gStartX4 = 10'h088;
	 assign gStartY4 = 10'h0c8;
	 logic AIpercent4;
	 assign AIpercent4 = (rnd_percent > 3);	// 4/8 chance rnd
	 logic gg4, on4;
	 assign on4 = SW[3];
	 
	 //normal dots
	 dotGrid dots(.*, .Reset(Reset_h), .pacX(pac_x), .pacY(pac_y), .show(dotShow));
	 logic [307:0] dotShow;
	 
	 //super dots (make gohsts freeze)
	 superDot sd1(.*, .Reset(Reset_h), .pacX(pac_x), .pacY(pac_y), .dotX(10'h018), .dotY(10'h078), .show(sd1Show), .freeze(f1));
	 superDot sd2(.*, .Reset(Reset_h), .pacX(pac_x), .pacY(pac_y), .dotX(10'h0e8), .dotY(10'h078), .show(sd2Show), .freeze(f2));
	 superDot sd3(.*, .Reset(Reset_h), .pacX(pac_x), .pacY(pac_y), .dotX(10'h0e8), .dotY(10'h118), .show(sd3Show), .freeze(f3));
	 superDot sd4(.*, .Reset(Reset_h), .pacX(pac_x), .pacY(pac_y), .dotX(10'h018), .dotY(10'h118), .show(sd4Show), .freeze(f4));
	 logic sd1Show, sd2Show, sd3Show, sd4Show;
	 logic f1, f2, f3, f4, freeze;
	 assign freeze = f1 || f2 || f3 || f4;
	 
	 //score counter controler
	 logic [7:0] score;
	 scoreCounter scoreCount(.in(dotShow), .out(score));
	 
	 //maze walls rom
	 mazeWalls walls(.*);
	 logic [383:0] wallData;
	 
	 
	 //debugging:
    //HEX displays
	 HexDriver hex_inst_0 (score[5:2], HEX0);
	 HexDriver hex_inst_1 ({2'b00, score[7:6]}, HEX1);
	 HexDriver hex_inst_2 (pac_y[3:0], HEX2);
	 HexDriver hex_inst_3 (pac_y[7:4], HEX3);
	 HexDriver hex_inst_4 ({2'b00, pac_y[9:8]}, HEX4);
	 HexDriver hex_inst_5 (pac_x[3:0], HEX5);
	 HexDriver hex_inst_6 (pac_x[7:4], HEX6);
	 HexDriver hex_inst_7 ({2'b00, pac_x[9:8]}, HEX7);

	 //LEDs
	 assign LEDR[17] = gg1;
	 assign LEDR[16] = gg2;
	 assign LEDR[15] = gg3;
	 
	 assign LEDR[1] = f1;
	 assign LEDR[2] = f2;
	 assign LEDR[3] = f3;
	 assign LEDR[4] = f4;
	 
endmodule
