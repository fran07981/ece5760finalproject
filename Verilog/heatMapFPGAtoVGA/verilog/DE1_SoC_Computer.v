`include "helper_modules.v"
`include "compute.v"
`include "column.v"
`include "VGA_helper_modules.v"

module DE1_SoC_Computer (
	////////////////////////////////////
	// FPGA Pins
	////////////////////////////////////

	// Clock pins
	CLOCK_50,
	CLOCK2_50,
	CLOCK3_50,
	CLOCK4_50,

	// ADC
	ADC_CS_N,
	ADC_DIN,
	ADC_DOUT,
	ADC_SCLK,

	// Audio
	AUD_ADCDAT,
	AUD_ADCLRCK,
	AUD_BCLK,
	AUD_DACDAT,
	AUD_DACLRCK,
	AUD_XCK,

	// SDRAM
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_CKE,
	DRAM_CLK,
	DRAM_CS_N,
	DRAM_DQ,
	DRAM_LDQM,
	DRAM_RAS_N,
	DRAM_UDQM,
	DRAM_WE_N,

	// I2C Bus for Configuration of the Audio and Video-In Chips
	FPGA_I2C_SCLK,
	FPGA_I2C_SDAT,

	// 40-Pin Headers
	GPIO_0,
	GPIO_1,
	
	// Seven Segment Displays
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,

	// IR
	IRDA_RXD,
	IRDA_TXD,

	// Pushbuttons
	KEY,

	// LEDs
	LEDR,

	// PS2 Ports
	PS2_CLK,
	PS2_DAT,
	
	PS2_CLK2,
	PS2_DAT2,

	// Slider Switches
	SW,

	// Video-In
	TD_CLK27,
	TD_DATA,
	TD_HS,
	TD_RESET_N,
	TD_VS,

	// VGA
	VGA_B,
	VGA_BLANK_N,
	VGA_CLK,
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_SYNC_N,
	VGA_VS,

	////////////////////////////////////
	// HPS Pins
	////////////////////////////////////
	
	// DDR3 SDRAM
	HPS_DDR3_ADDR,
	HPS_DDR3_BA,
	HPS_DDR3_CAS_N,
	HPS_DDR3_CKE,
	HPS_DDR3_CK_N,
	HPS_DDR3_CK_P,
	HPS_DDR3_CS_N,
	HPS_DDR3_DM,
	HPS_DDR3_DQ,
	HPS_DDR3_DQS_N,
	HPS_DDR3_DQS_P,
	HPS_DDR3_ODT,
	HPS_DDR3_RAS_N,
	HPS_DDR3_RESET_N,
	HPS_DDR3_RZQ,
	HPS_DDR3_WE_N,

	// Ethernet
	HPS_ENET_GTX_CLK,
	HPS_ENET_INT_N,
	HPS_ENET_MDC,
	HPS_ENET_MDIO,
	HPS_ENET_RX_CLK,
	HPS_ENET_RX_DATA,
	HPS_ENET_RX_DV,
	HPS_ENET_TX_DATA,
	HPS_ENET_TX_EN,

	// Flash
	HPS_FLASH_DATA,
	HPS_FLASH_DCLK,
	HPS_FLASH_NCSO,

	// Accelerometer
	HPS_GSENSOR_INT,
		
	// General Purpose I/O
	HPS_GPIO,
		
	// I2C
	HPS_I2C_CONTROL,
	HPS_I2C1_SCLK,
	HPS_I2C1_SDAT,
	HPS_I2C2_SCLK,
	HPS_I2C2_SDAT,

	// Pushbutton
	HPS_KEY,

	// LED
	HPS_LED,
		
	// SD Card
	HPS_SD_CLK,
	HPS_SD_CMD,
	HPS_SD_DATA,

	// SPI
	HPS_SPIM_CLK,
	HPS_SPIM_MISO,
	HPS_SPIM_MOSI,
	HPS_SPIM_SS,

	// UART
	HPS_UART_RX,
	HPS_UART_TX,

	// USB
	HPS_CONV_USB_N,
	HPS_USB_CLKOUT,
	HPS_USB_DATA,
	HPS_USB_DIR,
	HPS_USB_NXT,
	HPS_USB_STP
);

////////////////////////////////////
// FPGA Pins
////////////////////////////////////

// Clock pins
wire 						CLOCK_25;
input						CLOCK_50;
input						CLOCK2_50;
input						CLOCK3_50;
input						CLOCK4_50;

// ADC
inout						ADC_CS_N;
output						ADC_DIN;
input						ADC_DOUT;
output						ADC_SCLK;

// Audio
input						AUD_ADCDAT;
inout						AUD_ADCLRCK;
inout						AUD_BCLK;
output						AUD_DACDAT;
inout						AUD_DACLRCK;
output						AUD_XCK;

// SDRAM
output [12: 0]	DRAM_ADDR;
output [ 1: 0]	DRAM_BA;
output 			DRAM_CAS_N;
output 			DRAM_CKE;
output 			DRAM_CLK;
output 			DRAM_CS_N;
inout  [15: 0]	DRAM_DQ;
output 			DRAM_LDQM;
output 			DRAM_RAS_N;
output 			DRAM_UDQM;
output 			DRAM_WE_N;

// I2C Bus for Configuration of the Audio and Video-In Chips
output FPGA_I2C_SCLK;
inout  FPGA_I2C_SDAT;

// 40-pin headers
inout [35: 0]	GPIO_0;
inout [35: 0]	GPIO_1;

// Seven Segment Displays
output [ 6: 0]	HEX0;
output [ 6: 0]	HEX1;
output [ 6: 0]	HEX2;
output [ 6: 0]	HEX3;
output [ 6: 0]	HEX4;
output [ 6: 0]	HEX5;

// IR
input	IRDA_RXD;
output	IRDA_TXD;

// Pushbuttons
input			[ 3: 0]	KEY;

// LEDs
output		[ 9: 0]	LEDR;

// PS2 Ports
inout PS2_CLK;
inout PS2_DAT;
inout PS2_CLK2;
inout PS2_DAT2;

// Slider Switches
input			[ 9: 0]	SW;

// Video-In
input			TD_CLK27;
input [ 7: 0]	TD_DATA;
input			TD_HS;
output			TD_RESET_N;
input			TD_VS;

// VGA
output [ 7: 0]	VGA_B;
output			VGA_BLANK_N;
output			VGA_CLK;
output [ 7: 0]	VGA_G;
output			VGA_HS;
output [ 7: 0]	VGA_R;
output			VGA_SYNC_N;
output			VGA_VS;

////////////////////////////////////
// HPS Pins
////////////////////////////////////
	
// DDR3 SDRAM
output		[14: 0]	HPS_DDR3_ADDR;
output		[ 2: 0]  HPS_DDR3_BA;
output					HPS_DDR3_CAS_N;
output					HPS_DDR3_CKE;
output					HPS_DDR3_CK_N;
output					HPS_DDR3_CK_P;
output					HPS_DDR3_CS_N;
output		[ 3: 0]	HPS_DDR3_DM;
inout			[31: 0]	HPS_DDR3_DQ;
inout			[ 3: 0]	HPS_DDR3_DQS_N;
inout			[ 3: 0]	HPS_DDR3_DQS_P;
output					HPS_DDR3_ODT;
output					HPS_DDR3_RAS_N;
output					HPS_DDR3_RESET_N;
input						HPS_DDR3_RZQ;
output					HPS_DDR3_WE_N;

// Ethernet
output					HPS_ENET_GTX_CLK;
inout						HPS_ENET_INT_N;
output					HPS_ENET_MDC;
inout						HPS_ENET_MDIO;
input						HPS_ENET_RX_CLK;
input			[ 3: 0]	HPS_ENET_RX_DATA;
input						HPS_ENET_RX_DV;
output		[ 3: 0]	HPS_ENET_TX_DATA;
output					HPS_ENET_TX_EN;

// Flash
inout			[ 3: 0]	HPS_FLASH_DATA;
output					HPS_FLASH_DCLK;
output					HPS_FLASH_NCSO;

// Accelerometer
inout						HPS_GSENSOR_INT;

// General Purpose I/O
inout			[ 1: 0]	HPS_GPIO;

// I2C
inout						HPS_I2C_CONTROL;
inout						HPS_I2C1_SCLK;
inout						HPS_I2C1_SDAT;
inout						HPS_I2C2_SCLK;
inout						HPS_I2C2_SDAT;

// Pushbutton
inout						HPS_KEY;

// LED
inout						HPS_LED;

// SD Card
output					HPS_SD_CLK;
inout						HPS_SD_CMD;
inout			[ 3: 0]	HPS_SD_DATA;

// SPI
output					HPS_SPIM_CLK;
input						HPS_SPIM_MISO;
output					HPS_SPIM_MOSI;
inout						HPS_SPIM_SS;

// UART
input						HPS_UART_RX;
output					HPS_UART_TX;

// USB
inout						HPS_CONV_USB_N;
input						HPS_USB_CLKOUT;
inout			[ 7: 0]	HPS_USB_DATA;
input						HPS_USB_DIR;
input						HPS_USB_NXT;
output					HPS_USB_STP;

//=======================================================
//  REG/WIRE declarations
//=======================================================

wire   [15: 0]	hex3_hex0;
assign 			HEX4 = 7'b1111111;
assign 			HEX5 = 7'b1111111;

HexDigit Digit0(HEX0, hex3_hex0[3:0]);
HexDigit Digit1(HEX1, hex3_hex0[7:4]);
HexDigit Digit2(HEX2, hex3_hex0[11:8]);
HexDigit Digit3(HEX3, hex3_hex0[15:12]);

//=======================================================
// SRAM/VGA state machine
//=======================================================

//=======================================================
// Controls for Qsys sram slave exported in system module
//=======================================================
wire [31:0] sram_readdata;
reg  [31:0] data_buffer, sram_writedata;
reg  [7 :0] sram_address; 

reg  sram_write;

wire sram_clken      = 1'b1;
wire sram_chipselect = 1'b1;

//INPUT: FROM FPGA TO HPS
wire [31:0] pp_in_mandel_timer;
wire 		pp_in_done;

//INPUT: FROM HPS TO FPGA
wire 			   pp_out_reset;			// allow HPS to restart plotting
wire signed [26:0] pp_out_dx_c;				// change in x 
wire signed [26:0] pp_out_dy_c;				// change in y
wire 		[26:0] pp_out_max_iterations;	// change N
wire 		[3 :0] pp_out_zoom_num;			// zoom val 1 - 15
wire 			   pp_out_done;				// reset done

//=======================================================
// Controls for VGA memory
//=======================================================
wire [31:0] vga_out_base_address = 32'h0000_0000;  // vga base addr
wire [7 :0] vga_sram_writedata; 				   // originally registers
wire [31:0] vga_sram_address;   				   // originally registers

wire vga_sram_write;				// originally registers
wire vga_sram_clken 	 = 1'b1;
wire vga_sram_chipselect = 1'b1;

//=======================================================

reg  [26:0] vga_x_max 	   = 10'd640;		// 640 pixels
reg  [26:0] vga_y_max 	   = 10'd480;		// 480 pixels

wire [26:0] delta_x;
wire [26:0] delta_y;

assign delta_x = 27'b0000_0000_0001_0011_0011_0011_001 >> pp_out_zoom_num; 
assign delta_y = 27'b0000_0000_0001_0001_0001_0001_000 >> pp_out_zoom_num; 

wire  [26:0] x_init;
wire  [26:0] y_init;

assign y_init = pp_out_dy_c; // ( 27'b0001_0000_0000_0000_0000_0000_000 + pp_out_dy_c ) >> pp_out_zoom_num;		// 480 pixels
assign x_init = pp_out_dx_c; //(-27'sb0010_0000_0000_0000_0000_0000_000 + pp_out_dx_c ) >>> pp_out_zoom_num;		// 640 pixels


//=======================================================
// number of iterators
localparam n = 6;

// arbriter connections
reg [( n * 32 - 1 ):0] 	vga_addr; 		// n = # of iterators, secont [] is length of data (32 bits)
reg [( n * 32 - 1 ):0] 	vga_pxl_clr; 	// n = # of iterators, [] is length of data (32 bits)

reg [n-1:0] inter_select; 	// tels us which iterator is ready to be plotted via flag
reg [n-1:0] inter_done; 	// tels us which iterator is done plotting

wire inter_start;

wire [n-1:0] comp_flag ;	// return to nth iterator to move to next point
genvar j;

generate
	
	for ( j = 0; j < n; j = j + 1 ) begin: mandelGen

		reg [2:0] state ;
		//=======================================================
		// pixel address is
		reg [9:0] vga_x_cood, vga_y_cood;
		reg [7:0] pixel_color;
		//=======================================================
		// mandel inputs
		reg [26:0] x, y;
		wire signed [26:0] counter;
		wire signed [26:0] flag;
		reg reset;
		//=======================================================

		// j_delta_y = delta_y * [000j_0000_0000_0000_0000_0000_000]  ( in fixed point )
		wire signed [26:0] j_delta_y;

		if ( j == 0 ) begin
			signed_mult mult_j(
				.out( j_delta_y          ),
				.a  ( delta_y            ), 
				.b  ( { 4'd0, 23'b00000000000000000000000 } )
				);
		end	
		else if ( j == 1 ) begin
			signed_mult mult_j(
				.out( j_delta_y          ),
				.a  ( delta_y            ), 
				.b  ( { 4'd1, 23'b00000000000000000000000 } )
				);
		end
		else if ( j == 2 ) begin
			signed_mult mult_j(
				.out( j_delta_y          ),
				.a  ( delta_y            ), 
				.b  ( { 4'd2, 23'b00000000000000000000000 } )
				);
		end	 
		else if ( j == 3 ) begin
			signed_mult mult_j(
				.out( j_delta_y          ),
				.a  ( delta_y            ), 
				.b  ( { 4'd3, 23'b00000000000000000000000 } )
				);
		end	
		else if ( j == 4 ) begin
			signed_mult mult_j(
				.out( j_delta_y          ),
				.a  ( delta_y            ), 
				.b  ( { 4'd4, 23'b00000000000000000000000 } )
				);
		end	
		else if ( j == 5 ) begin
			signed_mult mult_j(
				.out( j_delta_y          ),
				.a  ( delta_y            ), 
				.b  ( { 4'd5, 23'b00000000000000000000000 } )
				);
		end
		
		// inc_delta_y = delta_y * 8  ( in fixed point )
		wire signed [26:0] inc_delta_y;
		signed_mult mult_jinc(
			.out( inc_delta_y							),
		    .a	( delta_y								), 
			.b	( 27'b0110_0000_0000_0000_0000_0000_000 )	// 6 = 0110  // 2 = 0010
			);

		// --------------------------------------
		// STATE MACHINE
		// --------------------------------------
		always @(posedge CLOCK_50) begin
			if (inter_start) begin			// waits to receive signal from arbriter to start
				state <= 3'd1;
				
				// initialize mandel plot values
				x <= x_init;    		  // gets sent to mandel -2/-1 to 1
				y <= y_init - j_delta_y;

				vga_x_cood  <= 10'd0;     // one that gets plotted 0-640/480
				vga_y_cood  <= 10'd0 + j; //sign extended the j value

				pixel_color 	<= 8'd0;
				reset 			<= 1'b1;
				inter_select[j] <= 1'b0;
				inter_done[j] 	<= 1'b0;
			end

			// ===== STATE 1 =====
			else if (state == 3'd1) begin
				reset <= 1'b1;
				state <= 3'd2;
			end 
			// ===== STATE 2 =====
			else if (state == 3'd2) begin
				reset <= 1'b0;
				state <= 3'd3;
			end 
			// ===== STATE 3 =====
			else if (state == 3'd3) begin
				if (flag == 27'b1) begin 	// flag from mandel has been triggered
					// update pixel_color ------------------------------
					if (counter >= pp_out_max_iterations) begin
						pixel_color <= 8'b_000_000_00 ; // black
					end
					else if (counter >= (pp_out_max_iterations >>> 1)) begin
						pixel_color <= 8'b_011_001_00 ; // white ???? brown not white :(
					end
					else if (counter >= (pp_out_max_iterations >>> 2)) begin
						pixel_color <= 8'b_011_001_00 ;
					end
					else if (counter >= (pp_out_max_iterations >>> 3)) begin
						pixel_color <= 8'b_101_010_01 ;
					end
					else if (counter >= (pp_out_max_iterations >>> 4)) begin
						pixel_color <= 8'b_011_001_01 ;
					end
					else if (counter >= (pp_out_max_iterations >>> 5)) begin
						pixel_color <= 8'b_001_001_01 ;
					end
					else if (counter >= (pp_out_max_iterations >>> 6)) begin
						pixel_color <= 8'b_011_010_10 ;
					end
					else if (counter >= (pp_out_max_iterations >>> 7)) begin
						pixel_color <= 8'b_010_100_10 ;
					end
					else if (counter >= (pp_out_max_iterations >>> 8)) begin
						pixel_color <= 8'b_010_100_10 ;
					end
					else begin
						pixel_color <= 8'b_010_100_10 ;
					end

					vga_addr   [ ((j+1)*32-1) : (((j+1)*32-1) - 31) ] <= vga_out_base_address + {22'b0, vga_x_cood} + ({22'b0,vga_y_cood}*640) ; // sram is 32 bits = 22 + 9 bits
					vga_pxl_clr[ ((j+1)*32-1) : (((j+1)*32-1) - 31) ] <= pixel_color;
					inter_select[j] <= 1'b1;
					state <= 3'd4;
				end
				else begin
					state <= 3'd3;
				end
			end
			// ===== STATE 4 =====
			else if (state == 3'd4) begin
				if ( comp_flag[j] == 1'b1 ) begin
					inter_select[j] <= 1'b0;
					state 			<= 3'd5;	// draw next point 
				end
				else begin
					state <= 3'd4;
				end
			end
			// ===== STATE 5 =====
			else if (state == 3'd5) begin
				// move to next point
				// calculate next Ci and Cr points
				if (vga_x_cood < vga_x_max) begin
					vga_x_cood 	<= vga_x_cood + 10'd1 ;
					x 			<= x + delta_x;
				end else begin	//reached end of VGA screen
					vga_x_cood 	<= 10'd0 ;
					x 			<= x_init;
					vga_y_cood 	<= vga_y_cood + 10'd6;	// skip every 2
					y 			<= y - inc_delta_y ;	// dont ** skip every other one
				end

				if ( (vga_x_cood >= vga_x_max) && (vga_y_cood >= ( vga_y_max - 5 )) ) begin 
					state <= 3'd6;	// DONE ploting whole screen
				end
				else begin
					state <= 3'd1;	// move to next mandel point by reseting 
				end
			end 
			// ===== STATE 6 =====
			else if (state == 3'd6) begin
				inter_done[j] <= 1'b1;
				state 		  <= 3'd6;
			end		
		end // always @(posedge state_clock)
		
		// mandelbrot instantiation
		mandelbrot mandelIterator(
			.clock          (CLOCK_50),  
            .reset          (reset),            // connect to reset in state machine
            .max_iterations (pp_out_max_iterations), //pp_out_max_iterations),   // 1000 in not fixed point  (would be too small w fixed point)
            .ci             (y),                // y axis -1 to  1 
            .cr             (x),                // x axis -2 to -1 
            .N              (counter),           // output connect to state machine val between 0 - 1000 into color range
            .flag           (flag)             // output connect to state machine val between 0 - 1000 into color range
			);
	end
endgenerate


arbriter mandelArbri(
	.vga_addr			(vga_addr), 	// n = # of iterators, secont [] is length of data (32 bits)
	.vga_pxl_clr		(vga_pxl_clr), 	// n = # of iterators, [] is length of data (32 bits)
	.inter_select		(inter_select), // tels us which iterator is ready to be plotted via flag
	.inter_done			(inter_done), 	// tels us which iterator is done plotting
	.clk				(CLOCK_50),
	.comp_flag 			(comp_flag),		// outputs
	.vga_sram_address	(vga_sram_address),
	.vga_sram_write		(vga_sram_write),
	.vga_sram_writedata	(vga_sram_writedata),
	.inter_start		(inter_start),
	.KEY				(KEY),
	.hps_reset			(pp_out_reset),
	.hps_done			(pp_out_done), 
	.hps_send_timer		(pp_in_mandel_timer),			// send timer to HPS
	.hps_send_done		(pp_in_done)					// tell HPS we are done plotting
	); 
		
        
//=======================================================
//  Structural coding
//=======================================================
// From Qsys

Computer_System The_System (
	////////////////////////////////////
	// FPGA Side
	////////////////////////////////////

	// Global signals
	.system_pll_ref_clk_clk					(CLOCK_50),
	.system_pll_ref_reset_reset			(1'b0),
	.pll_0_outclk0_clk						(CLOCK_25),
	
	
	// PIO PORTS ADDED
	//INPUT: FROM FPGA TO HPS
	.pio_mandel_timer_external_connection_export		(pp_in_mandel_timer),
	.pio_in_done_external_connection_export				(pp_in_done),
	

	.pio_done_external_connection_export				(pp_out_done), // set as an input rn

	//INPUT: FROM HPS TO FPGA
	
	.pio_dx_c_external_connection_1_export				(pp_out_dx_c),
	.pio_dy_c_external_connection_2_export				(pp_out_dy_c),
	.pio_max_iterations_external_connection_export	(pp_out_max_iterations),
	.pio_reset_external_connection_export				(pp_out_reset),
	.pio_zoom_num_external_connection_export			(pp_out_zoom_num),
	
	
	// SRAM shared block with HPS
	.onchip_sram_s1_address               (sram_address),               
	.onchip_sram_s1_clken                 (sram_clken),                 
	.onchip_sram_s1_chipselect            (sram_chipselect),            
	.onchip_sram_s1_write                 (sram_write),                 
	.onchip_sram_s1_readdata              (sram_readdata),              
	.onchip_sram_s1_writedata             (sram_writedata),             
	.onchip_sram_s1_byteenable            (4'b1111), 
	
	//  sram to video
	.onchip_vga_buffer_s1_address    (vga_sram_address),    
	.onchip_vga_buffer_s1_clken      (vga_sram_clken),      
	.onchip_vga_buffer_s1_chipselect (vga_sram_chipselect), 
	.onchip_vga_buffer_s1_write      (vga_sram_write),      
	.onchip_vga_buffer_s1_readdata   (),   // never read from vga here
	.onchip_vga_buffer_s1_writedata  (vga_sram_writedata),   

	// AV Config
	.av_config_SCLK							(FPGA_I2C_SCLK),
	.av_config_SDAT							(FPGA_I2C_SDAT),

	// 50 MHz clock bridge
	.clock_bridge_0_in_clk_clk            (CLOCK_50), //(CLOCK_50), 
	
	// VGA Subsystem
	.vga_pll_ref_clk_clk 					(CLOCK2_50),
	.vga_pll_ref_reset_reset				(1'b0),
	.vga_CLK										(VGA_CLK),
	.vga_BLANK									(VGA_BLANK_N),
	.vga_SYNC									(VGA_SYNC_N),
	.vga_HS										(VGA_HS),
	.vga_VS										(VGA_VS),
	.vga_R										(VGA_R),
	.vga_G										(VGA_G),
	.vga_B										(VGA_B),
		
	// SDRAM
	.sdram_clk_clk								(DRAM_CLK),
   .sdram_addr									(DRAM_ADDR),
	.sdram_ba									(DRAM_BA),
	.sdram_cas_n								(DRAM_CAS_N),
	.sdram_cke									(DRAM_CKE),
	.sdram_cs_n									(DRAM_CS_N),
	.sdram_dq									(DRAM_DQ),
	.sdram_dqm									({DRAM_UDQM,DRAM_LDQM}),
	.sdram_ras_n								(DRAM_RAS_N),
	.sdram_we_n									(DRAM_WE_N),
	
	////////////////////////////////////
	// HPS Side
	////////////////////////////////////
	// DDR3 SDRAM
	.memory_mem_a			(HPS_DDR3_ADDR),
	.memory_mem_ba			(HPS_DDR3_BA),
	.memory_mem_ck			(HPS_DDR3_CK_P),
	.memory_mem_ck_n		(HPS_DDR3_CK_N),
	.memory_mem_cke		(HPS_DDR3_CKE),
	.memory_mem_cs_n		(HPS_DDR3_CS_N),
	.memory_mem_ras_n		(HPS_DDR3_RAS_N),
	.memory_mem_cas_n		(HPS_DDR3_CAS_N),
	.memory_mem_we_n		(HPS_DDR3_WE_N),
	.memory_mem_reset_n	(HPS_DDR3_RESET_N),
	.memory_mem_dq			(HPS_DDR3_DQ),
	.memory_mem_dqs		(HPS_DDR3_DQS_P),
	.memory_mem_dqs_n		(HPS_DDR3_DQS_N),
	.memory_mem_odt		(HPS_DDR3_ODT),
	.memory_mem_dm			(HPS_DDR3_DM),
	.memory_oct_rzqin		(HPS_DDR3_RZQ),
		  
	// Ethernet
	.hps_io_hps_io_gpio_inst_GPIO35	(HPS_ENET_INT_N),
	.hps_io_hps_io_emac1_inst_TX_CLK	(HPS_ENET_GTX_CLK),
	.hps_io_hps_io_emac1_inst_TXD0	(HPS_ENET_TX_DATA[0]),
	.hps_io_hps_io_emac1_inst_TXD1	(HPS_ENET_TX_DATA[1]),
	.hps_io_hps_io_emac1_inst_TXD2	(HPS_ENET_TX_DATA[2]),
	.hps_io_hps_io_emac1_inst_TXD3	(HPS_ENET_TX_DATA[3]),
	.hps_io_hps_io_emac1_inst_RXD0	(HPS_ENET_RX_DATA[0]),
	.hps_io_hps_io_emac1_inst_MDIO	(HPS_ENET_MDIO),
	.hps_io_hps_io_emac1_inst_MDC		(HPS_ENET_MDC),
	.hps_io_hps_io_emac1_inst_RX_CTL	(HPS_ENET_RX_DV),
	.hps_io_hps_io_emac1_inst_TX_CTL	(HPS_ENET_TX_EN),
	.hps_io_hps_io_emac1_inst_RX_CLK	(HPS_ENET_RX_CLK),
	.hps_io_hps_io_emac1_inst_RXD1	(HPS_ENET_RX_DATA[1]),
	.hps_io_hps_io_emac1_inst_RXD2	(HPS_ENET_RX_DATA[2]),
	.hps_io_hps_io_emac1_inst_RXD3	(HPS_ENET_RX_DATA[3]),

	// Flash
	.hps_io_hps_io_qspi_inst_IO0	(HPS_FLASH_DATA[0]),
	.hps_io_hps_io_qspi_inst_IO1	(HPS_FLASH_DATA[1]),
	.hps_io_hps_io_qspi_inst_IO2	(HPS_FLASH_DATA[2]),
	.hps_io_hps_io_qspi_inst_IO3	(HPS_FLASH_DATA[3]),
	.hps_io_hps_io_qspi_inst_SS0	(HPS_FLASH_NCSO),
	.hps_io_hps_io_qspi_inst_CLK	(HPS_FLASH_DCLK),

	// Accelerometer
	.hps_io_hps_io_gpio_inst_GPIO61	(HPS_GSENSOR_INT),

	//.adc_sclk                        (ADC_SCLK),
	//.adc_cs_n                        (ADC_CS_N),
	//.adc_dout                        (ADC_DOUT),
	//.adc_din                         (ADC_DIN),

	// General Purpose I/O
	.hps_io_hps_io_gpio_inst_GPIO40	(HPS_GPIO[0]),
	.hps_io_hps_io_gpio_inst_GPIO41	(HPS_GPIO[1]),

	// I2C
	.hps_io_hps_io_gpio_inst_GPIO48	(HPS_I2C_CONTROL),
	.hps_io_hps_io_i2c0_inst_SDA		(HPS_I2C1_SDAT),
	.hps_io_hps_io_i2c0_inst_SCL		(HPS_I2C1_SCLK),
	.hps_io_hps_io_i2c1_inst_SDA		(HPS_I2C2_SDAT),
	.hps_io_hps_io_i2c1_inst_SCL		(HPS_I2C2_SCLK),

	// Pushbutton
	.hps_io_hps_io_gpio_inst_GPIO54	(HPS_KEY),

	// LED
	.hps_io_hps_io_gpio_inst_GPIO53	(HPS_LED),

	// SD Card
	.hps_io_hps_io_sdio_inst_CMD	(HPS_SD_CMD),
	.hps_io_hps_io_sdio_inst_D0	(HPS_SD_DATA[0]),
	.hps_io_hps_io_sdio_inst_D1	(HPS_SD_DATA[1]),
	.hps_io_hps_io_sdio_inst_CLK	(HPS_SD_CLK),
	.hps_io_hps_io_sdio_inst_D2	(HPS_SD_DATA[2]),
	.hps_io_hps_io_sdio_inst_D3	(HPS_SD_DATA[3]),

	// SPI
	.hps_io_hps_io_spim1_inst_CLK		(HPS_SPIM_CLK),
	.hps_io_hps_io_spim1_inst_MOSI	(HPS_SPIM_MOSI),
	.hps_io_hps_io_spim1_inst_MISO	(HPS_SPIM_MISO),
	.hps_io_hps_io_spim1_inst_SS0		(HPS_SPIM_SS),

	// UART
	.hps_io_hps_io_uart0_inst_RX	(HPS_UART_RX),
	.hps_io_hps_io_uart0_inst_TX	(HPS_UART_TX),

	// USB
	.hps_io_hps_io_gpio_inst_GPIO09	(HPS_CONV_USB_N),
	.hps_io_hps_io_usb1_inst_D0		(HPS_USB_DATA[0]),
	.hps_io_hps_io_usb1_inst_D1		(HPS_USB_DATA[1]),
	.hps_io_hps_io_usb1_inst_D2		(HPS_USB_DATA[2]),
	.hps_io_hps_io_usb1_inst_D3		(HPS_USB_DATA[3]),
	.hps_io_hps_io_usb1_inst_D4		(HPS_USB_DATA[4]),
	.hps_io_hps_io_usb1_inst_D5		(HPS_USB_DATA[5]),
	.hps_io_hps_io_usb1_inst_D6		(HPS_USB_DATA[6]),
	.hps_io_hps_io_usb1_inst_D7		(HPS_USB_DATA[7]),
	.hps_io_hps_io_usb1_inst_CLK		(HPS_USB_CLKOUT),
	.hps_io_hps_io_usb1_inst_STP		(HPS_USB_STP),
	.hps_io_hps_io_usb1_inst_DIR		(HPS_USB_DIR),
	.hps_io_hps_io_usb1_inst_NXT		(HPS_USB_NXT)
);
endmodule // end top level

//============================================================
// M10K module for testing
//============================================================
// See example 12-16 in 
// http://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/HDL_style_qts_qii51007.pdf
//============================================================

module M10K_256_32( 
    output reg [31:0] q,
    input [31:0] d,
    input [7:0] write_address, read_address,
    input we, clk
);
	 // force M10K ram style
	 // 256 words of 32 bits
    reg [31:0] mem [255:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
		  end
        q <= mem[read_address]; // q doesn't get d in this clock cycle
    end
endmodule

//============================================================
// MLAB module for testing
//============================================================
// See example 12-16 in 
// http://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/HDL_style_qts_qii51007.pdf
//============================================================
module MLAB_20_32(
	output reg signed [31:0] q,
	input  [31:0] data,
	input [7:0] readaddr, writeaddr,
	input wren, clock
);
	// force MLAB ram style
	// 20 words of 32 bits
	reg signed [31:0] mem [19:0] /* synthesis ramstyle = "no_rw_check, MLAB" */;
	
	always @ (posedge clock)
	begin
		if (wren) begin
			mem[writeaddr] <= data;
		end
		q <= mem[readaddr];
	end
endmodule

