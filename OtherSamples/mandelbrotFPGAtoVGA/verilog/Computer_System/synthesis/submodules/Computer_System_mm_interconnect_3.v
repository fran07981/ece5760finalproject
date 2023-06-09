// Computer_System_mm_interconnect_3.v

// This file was auto-generated from altera_mm_interconnect_hw.tcl.  If you edit it your changes
// will probably be lost.
// 
// Generated using ACDS version 15.0 145

`timescale 1 ps / 1 ps
module Computer_System_mm_interconnect_3 (
		input  wire        System_PLL_sys_clk_clk,                               //                             System_PLL_sys_clk.clk
		input  wire        onchip_vga_buffer_reset2_reset_bridge_in_reset_reset, // onchip_vga_buffer_reset2_reset_bridge_in_reset.reset
		input  wire        VGA_Subsystem_sys_reset_reset_bridge_in_reset_reset,  //  VGA_Subsystem_sys_reset_reset_bridge_in_reset.reset
		input  wire [31:0] VGA_Subsystem_pixel_dma_master_address,               //                 VGA_Subsystem_pixel_dma_master.address
		output wire        VGA_Subsystem_pixel_dma_master_waitrequest,           //                                               .waitrequest
		input  wire        VGA_Subsystem_pixel_dma_master_read,                  //                                               .read
		output wire [7:0]  VGA_Subsystem_pixel_dma_master_readdata,              //                                               .readdata
		output wire        VGA_Subsystem_pixel_dma_master_readdatavalid,         //                                               .readdatavalid
		input  wire        VGA_Subsystem_pixel_dma_master_lock,                  //                                               .lock
		output wire [18:0] onchip_vga_buffer_s2_address,                         //                           onchip_vga_buffer_s2.address
		output wire        onchip_vga_buffer_s2_write,                           //                                               .write
		input  wire [7:0]  onchip_vga_buffer_s2_readdata,                        //                                               .readdata
		output wire [7:0]  onchip_vga_buffer_s2_writedata,                       //                                               .writedata
		output wire        onchip_vga_buffer_s2_chipselect,                      //                                               .chipselect
		output wire        onchip_vga_buffer_s2_clken                            //                                               .clken
	);

	wire         vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_waitrequest;   // onchip_vga_buffer_s2_translator:uav_waitrequest -> VGA_Subsystem_pixel_dma_master_translator:uav_waitrequest
	wire   [7:0] vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_readdata;      // onchip_vga_buffer_s2_translator:uav_readdata -> VGA_Subsystem_pixel_dma_master_translator:uav_readdata
	wire         vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_debugaccess;   // VGA_Subsystem_pixel_dma_master_translator:uav_debugaccess -> onchip_vga_buffer_s2_translator:uav_debugaccess
	wire  [31:0] vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_address;       // VGA_Subsystem_pixel_dma_master_translator:uav_address -> onchip_vga_buffer_s2_translator:uav_address
	wire         vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_read;          // VGA_Subsystem_pixel_dma_master_translator:uav_read -> onchip_vga_buffer_s2_translator:uav_read
	wire   [0:0] vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_byteenable;    // VGA_Subsystem_pixel_dma_master_translator:uav_byteenable -> onchip_vga_buffer_s2_translator:uav_byteenable
	wire         vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_readdatavalid; // onchip_vga_buffer_s2_translator:uav_readdatavalid -> VGA_Subsystem_pixel_dma_master_translator:uav_readdatavalid
	wire         vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_lock;          // VGA_Subsystem_pixel_dma_master_translator:uav_lock -> onchip_vga_buffer_s2_translator:uav_lock
	wire         vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_write;         // VGA_Subsystem_pixel_dma_master_translator:uav_write -> onchip_vga_buffer_s2_translator:uav_write
	wire   [7:0] vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_writedata;     // VGA_Subsystem_pixel_dma_master_translator:uav_writedata -> onchip_vga_buffer_s2_translator:uav_writedata
	wire   [0:0] vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_burstcount;    // VGA_Subsystem_pixel_dma_master_translator:uav_burstcount -> onchip_vga_buffer_s2_translator:uav_burstcount

	altera_merlin_master_translator #(
		.AV_ADDRESS_W                (32),
		.AV_DATA_W                   (8),
		.AV_BURSTCOUNT_W             (1),
		.AV_BYTEENABLE_W             (1),
		.UAV_ADDRESS_W               (32),
		.UAV_BURSTCOUNT_W            (1),
		.USE_READ                    (1),
		.USE_WRITE                   (0),
		.USE_BEGINBURSTTRANSFER      (0),
		.USE_BEGINTRANSFER           (0),
		.USE_CHIPSELECT              (0),
		.USE_BURSTCOUNT              (0),
		.USE_READDATAVALID           (1),
		.USE_WAITREQUEST             (1),
		.USE_READRESPONSE            (0),
		.USE_WRITERESPONSE           (0),
		.AV_SYMBOLS_PER_WORD         (1),
		.AV_ADDRESS_SYMBOLS          (1),
		.AV_BURSTCOUNT_SYMBOLS       (0),
		.AV_CONSTANT_BURST_BEHAVIOR  (0),
		.UAV_CONSTANT_BURST_BEHAVIOR (0),
		.AV_LINEWRAPBURSTS           (0),
		.AV_REGISTERINCOMINGSIGNALS  (0)
	) vga_subsystem_pixel_dma_master_translator (
		.clk                    (System_PLL_sys_clk_clk),                                                            //                       clk.clk
		.reset                  (onchip_vga_buffer_reset2_reset_bridge_in_reset_reset),                              //                     reset.reset
		.uav_address            (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_address),       // avalon_universal_master_0.address
		.uav_burstcount         (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_burstcount),    //                          .burstcount
		.uav_read               (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_read),          //                          .read
		.uav_write              (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_write),         //                          .write
		.uav_waitrequest        (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_waitrequest),   //                          .waitrequest
		.uav_readdatavalid      (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_readdatavalid), //                          .readdatavalid
		.uav_byteenable         (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_byteenable),    //                          .byteenable
		.uav_readdata           (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_readdata),      //                          .readdata
		.uav_writedata          (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_writedata),     //                          .writedata
		.uav_lock               (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_lock),          //                          .lock
		.uav_debugaccess        (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_debugaccess),   //                          .debugaccess
		.av_address             (VGA_Subsystem_pixel_dma_master_address),                                            //      avalon_anti_master_0.address
		.av_waitrequest         (VGA_Subsystem_pixel_dma_master_waitrequest),                                        //                          .waitrequest
		.av_read                (VGA_Subsystem_pixel_dma_master_read),                                               //                          .read
		.av_readdata            (VGA_Subsystem_pixel_dma_master_readdata),                                           //                          .readdata
		.av_readdatavalid       (VGA_Subsystem_pixel_dma_master_readdatavalid),                                      //                          .readdatavalid
		.av_lock                (VGA_Subsystem_pixel_dma_master_lock),                                               //                          .lock
		.av_burstcount          (1'b1),                                                                              //               (terminated)
		.av_byteenable          (1'b1),                                                                              //               (terminated)
		.av_beginbursttransfer  (1'b0),                                                                              //               (terminated)
		.av_begintransfer       (1'b0),                                                                              //               (terminated)
		.av_chipselect          (1'b0),                                                                              //               (terminated)
		.av_write               (1'b0),                                                                              //               (terminated)
		.av_writedata           (8'b00000000),                                                                       //               (terminated)
		.av_debugaccess         (1'b0),                                                                              //               (terminated)
		.uav_clken              (),                                                                                  //               (terminated)
		.av_clken               (1'b1),                                                                              //               (terminated)
		.uav_response           (2'b00),                                                                             //               (terminated)
		.av_response            (),                                                                                  //               (terminated)
		.uav_writeresponsevalid (1'b0),                                                                              //               (terminated)
		.av_writeresponsevalid  ()                                                                                   //               (terminated)
	);

	altera_merlin_slave_translator #(
		.AV_ADDRESS_W                   (19),
		.AV_DATA_W                      (8),
		.UAV_DATA_W                     (8),
		.AV_BURSTCOUNT_W                (1),
		.AV_BYTEENABLE_W                (1),
		.UAV_BYTEENABLE_W               (1),
		.UAV_ADDRESS_W                  (32),
		.UAV_BURSTCOUNT_W               (1),
		.AV_READLATENCY                 (1),
		.USE_READDATAVALID              (0),
		.USE_WAITREQUEST                (0),
		.USE_UAV_CLKEN                  (0),
		.USE_READRESPONSE               (0),
		.USE_WRITERESPONSE              (0),
		.AV_SYMBOLS_PER_WORD            (1),
		.AV_ADDRESS_SYMBOLS             (0),
		.AV_BURSTCOUNT_SYMBOLS          (0),
		.AV_CONSTANT_BURST_BEHAVIOR     (0),
		.UAV_CONSTANT_BURST_BEHAVIOR    (0),
		.AV_REQUIRE_UNALIGNED_ADDRESSES (0),
		.CHIPSELECT_THROUGH_READLATENCY (0),
		.AV_READ_WAIT_CYCLES            (0),
		.AV_WRITE_WAIT_CYCLES           (0),
		.AV_SETUP_WAIT_CYCLES           (0),
		.AV_DATA_HOLD_CYCLES            (0)
	) onchip_vga_buffer_s2_translator (
		.clk                    (System_PLL_sys_clk_clk),                                                            //                      clk.clk
		.reset                  (onchip_vga_buffer_reset2_reset_bridge_in_reset_reset),                              //                    reset.reset
		.uav_address            (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_address),       // avalon_universal_slave_0.address
		.uav_burstcount         (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_burstcount),    //                         .burstcount
		.uav_read               (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_read),          //                         .read
		.uav_write              (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_write),         //                         .write
		.uav_waitrequest        (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_waitrequest),   //                         .waitrequest
		.uav_readdatavalid      (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_readdatavalid), //                         .readdatavalid
		.uav_byteenable         (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_byteenable),    //                         .byteenable
		.uav_readdata           (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_readdata),      //                         .readdata
		.uav_writedata          (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_writedata),     //                         .writedata
		.uav_lock               (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_lock),          //                         .lock
		.uav_debugaccess        (vga_subsystem_pixel_dma_master_translator_avalon_universal_master_0_debugaccess),   //                         .debugaccess
		.av_address             (onchip_vga_buffer_s2_address),                                                      //      avalon_anti_slave_0.address
		.av_write               (onchip_vga_buffer_s2_write),                                                        //                         .write
		.av_readdata            (onchip_vga_buffer_s2_readdata),                                                     //                         .readdata
		.av_writedata           (onchip_vga_buffer_s2_writedata),                                                    //                         .writedata
		.av_chipselect          (onchip_vga_buffer_s2_chipselect),                                                   //                         .chipselect
		.av_clken               (onchip_vga_buffer_s2_clken),                                                        //                         .clken
		.av_read                (),                                                                                  //              (terminated)
		.av_begintransfer       (),                                                                                  //              (terminated)
		.av_beginbursttransfer  (),                                                                                  //              (terminated)
		.av_burstcount          (),                                                                                  //              (terminated)
		.av_byteenable          (),                                                                                  //              (terminated)
		.av_readdatavalid       (1'b0),                                                                              //              (terminated)
		.av_waitrequest         (1'b0),                                                                              //              (terminated)
		.av_writebyteenable     (),                                                                                  //              (terminated)
		.av_lock                (),                                                                                  //              (terminated)
		.uav_clken              (1'b0),                                                                              //              (terminated)
		.av_debugaccess         (),                                                                                  //              (terminated)
		.av_outputenable        (),                                                                                  //              (terminated)
		.uav_response           (),                                                                                  //              (terminated)
		.av_response            (2'b00),                                                                             //              (terminated)
		.uav_writeresponsevalid (),                                                                                  //              (terminated)
		.av_writeresponsevalid  (1'b0)                                                                               //              (terminated)
	);

endmodule
