// `include "helper_modules.v"
// `include "read_DPS_module.v"

module DE1_SoC_Computer (
	////////////////////////////////////
	// FPGA Pins
	////////////////////////////////////

	// Clock pins
	CLOCK_50, CLOCK2_50, CLOCK3_50, CLOCK4_50,

	// ADC
	ADC_CS_N, ADC_DIN, ADC_DOUT, ADC_SCLK,

	// Audio
	AUD_ADCDAT, AUD_ADCLRCK, AUD_BCLK, AUD_DACDAT, AUD_DACLRCK, AUD_XCK,

	// SDRAM
	DRAM_ADDR, DRAM_BA, DRAM_CAS_N, DRAM_CKE, DRAM_CLK, DRAM_CS_N, DRAM_DQ, DRAM_LDQM, DRAM_RAS_N, DRAM_UDQM, DRAM_WE_N,

	// I2C Bus for Configuration of the Audio and Video-In Chips
	FPGA_I2C_SCLK, FPGA_I2C_SDAT,

	// 40-Pin Headers
	GPIO_0, GPIO_1,
	
	// Seven Segment Displays
	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,

	// IR
	IRDA_RXD, IRDA_TXD,

	// Pushbuttons
	KEY,

	// LEDs
	LEDR,

	// PS2 Ports
	PS2_CLK, PS2_DAT, PS2_CLK2, PS2_DAT2,

	// Slider Switches
	SW,

	// Video-In
	TD_CLK27, TD_DATA, TD_HS, TD_RESET_N, TD_VS,

	// VGA
	VGA_B, VGA_BLANK_N, VGA_CLK, VGA_G, VGA_HS, VGA_R, VGA_SYNC_N, VGA_VS,

	////////////////////////////////////
	// HPS Pins
	////////////////////////////////////
	
	// DDR3 SDRAM 
	HPS_DDR3_ADDR, HPS_DDR3_BA, HPS_DDR3_CAS_N, HPS_DDR3_CKE, HPS_DDR3_CK_N, HPS_DDR3_CK_P, HPS_DDR3_CS_N, HPS_DDR3_DM, HPS_DDR3_DQ, HPS_DDR3_DQS_N, HPS_DDR3_DQS_P, HPS_DDR3_ODT, HPS_DDR3_RAS_N, HPS_DDR3_RESET_N, HPS_DDR3_RZQ, HPS_DDR3_WE_N,

	// Ethernet
	HPS_ENET_GTX_CLK, HPS_ENET_INT_N, HPS_ENET_MDC, HPS_ENET_MDIO, HPS_ENET_RX_CLK, HPS_ENET_RX_DATA, HPS_ENET_RX_DV, HPS_ENET_TX_DATA, HPS_ENET_TX_EN,

	// Flash
	HPS_FLASH_DATA, HPS_FLASH_DCLK, HPS_FLASH_NCSO,

	// Accelerometer
	HPS_GSENSOR_INT,
		
	// General Purpose I/O
	HPS_GPIO,
		
	// I2C
	HPS_I2C_CONTROL, HPS_I2C1_SCLK, HPS_I2C1_SDAT, HPS_I2C2_SCLK, HPS_I2C2_SDAT,

	// Pushbutton
	HPS_KEY,

	// LED
	HPS_LED,
		
	// SD Card
	HPS_SD_CLK, HPS_SD_CMD, HPS_SD_DATA,

	// SPI
	HPS_SPIM_CLK, HPS_SPIM_MISO, HPS_SPIM_MOSI, HPS_SPIM_SS,

	// UART
	HPS_UART_RX, HPS_UART_TX,

	// USB
	HPS_CONV_USB_N, HPS_USB_CLKOUT, HPS_USB_DATA, HPS_USB_DIR, HPS_USB_NXT, HPS_USB_STP
);

	////////////////////////////////////
	// FPGA Pins
	////////////////////////////////////

	// Clock pins
	input	CLOCK_50;
	input	CLOCK2_50;
	input	CLOCK3_50;
	input	CLOCK4_50;

	// ADC
	inout	ADC_CS_N;
	output	ADC_DIN;
	input	ADC_DOUT;
	output	ADC_SCLK;

	// Audio
	input	AUD_ADCDAT;
	inout	AUD_ADCLRCK;
	inout	AUD_BCLK;
	output	AUD_DACDAT;
	inout	AUD_DACLRCK;
	output	AUD_XCK;

	// SDRAM
	output 		[12: 0]	DRAM_ADDR;
	output		[ 1: 0]	DRAM_BA;
	output				DRAM_CAS_N;
	output				DRAM_CKE;
	output				DRAM_CLK;
	output				DRAM_CS_N;
	inout		[15: 0]	DRAM_DQ;
	output				DRAM_LDQM;
	output				DRAM_RAS_N;
	output				DRAM_UDQM;
	output				DRAM_WE_N;

	// I2C Bus for Configuration of the Audio and Video-In Chips
	output	FPGA_I2C_SCLK;
	inout	FPGA_I2C_SDAT;

	// 40-pin headers
	inout	[35: 0]	GPIO_0;
	inout	[35: 0]	GPIO_1;

	// Seven Segment Displays
	output	[ 6: 0]	HEX0;
	output	[ 6: 0]	HEX1;
	output	[ 6: 0]	HEX2;
	output	[ 6: 0]	HEX3;
	output	[ 6: 0]	HEX4;
	output	[ 6: 0]	HEX5;

	// IR
	input						IRDA_RXD;
	output					IRDA_TXD;

	// Pushbuttons
	input			[ 3: 0]	KEY;

	// LEDs
	output		[ 9: 0]	LEDR;

	// PS2 Ports
	inout						PS2_CLK;
	inout						PS2_DAT;

	inout						PS2_CLK2;
	inout						PS2_DAT2;

	// Slider Switches
	input			[ 9: 0]	SW;

	// Video-In
	input						TD_CLK27;
	input			[ 7: 0]	TD_DATA;
	input						TD_HS;
	output					TD_RESET_N;
	input						TD_VS;

	// VGA
	output		[ 7: 0]	VGA_B;
	output					VGA_BLANK_N;
	output					VGA_CLK;
	output		[ 7: 0]	VGA_G;
	output					VGA_HS;
	output		[ 7: 0]	VGA_R;
	output					VGA_SYNC_N;
	output					VGA_VS;



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

	wire			[15: 0]	hex3_hex0;

	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;

	HexDigit Digit0(HEX0, hex3_hex0[3:0]);
	HexDigit Digit1(HEX1, hex3_hex0[7:4]);
	HexDigit Digit2(HEX2, hex3_hex0[11:8]);
	HexDigit Digit3(HEX3, hex3_hex0[15:12]);

	wire sram_clken 		 = 1'b1;
	wire sram_chipselect = 1'b1;

	//=======================================================
	// SRAM/HPS data transfer
	//=======================================================
	
	wire [31:0] sram_readdata;
	reg  [31:0] sram_writedata;
	reg  [7 :0] sram_address; 
	reg  				sram_write;
	
	reg  flag = 0;

	read_DPS_module readOne(
		.clock					(CLOCK_50),
		.pixel_color			(pixel_color),
		.reset					(~KEY[0]),
		.sram_readdata	(sram_readdata),
		.sram_writedata	(sram_writedata),
		.sram_address		(sram_address),
		.sram_write			(sram_write),
		.flag						(flag),						// flag is just for signalTap 
		.col_select			(col_select),
		.return_sig			(return_sig),
		.row_select			(row_select)
	);
	
	localparam n = 64;	// number of columns

	reg [n - 1:0] col_select; // lets start with 100 cols (100 pixels)
	reg [n - 1:0] return_sig; //   			""
	reg [    9:0] row_select; // says which row number

	//=======================================================
	// Controls for VGA memory
	//=======================================================
	reg  [7 :0] vga_sram_writedata;
	reg  [31:0] vga_sram_address;

	reg  vga_sram_write;
	wire vga_sram_clken 		 = 1'b1;
	wire vga_sram_chipselect = 1'b1;

	reg  [ 7:0] pixel_color;
    wire [31:0] vga_out_base_address = 32'h0000_0000;  // vga base addr

	// --------------------------------------
	// GENERATE COLUMNS HERE
	// --------------------------------------
	reg [( n * 32 - 1 ):0] 	vga_addr; 		// n = # of iterators, second [] is length of data (32 bits)
	reg [( n * 32 - 1 ):0] 	vga_pxl_clr; 	// n = # of iterators, [] is length of data (32 bits)

	reg  [n - 1:0] inter_select; 	// tels us which iterator is ready to be plotted via flag
	wire [n - 1:0] comp_flag ;		// return to nth iterator to move to next point
	reg  [n - 1:0] inter_done;
	wire 		inter_start;


	genvar i;
	generate
		for (i = 0; i < n; i = i + 1) begin : gen_block
			wire data_sig = col_select[i];
			reg  [5:0] state = 0;

			always @(posedge CLOCK_50) begin

				if (state == 0 && data_sig == 1'd1) begin
					inter_select[i] <= 1'b1;			// tell arbitrer we are ready to plot
					state <= 6'd1;						// move to state that waits for arbitrer to finish
				end
				else begin
					// ===== STATE 1 =====
					if (state == 6'd1) begin
					 	if ( comp_flag[i] == 1'b1 ) begin
							inter_select[i] <= 1'b0;	// tell arbitrer we are done to plotting
							state 					<= 6'd2;	// move to draw next point 
						end
						else begin
							state <= 6'd1;
						end
					end
					// ===== STATE 2 =====
					else if (state == 6'd2) begin
						return_sig[i]	 <= 1'd1;		// tell HPS reader we finished
						state          <= 6'd3;
					end
					// ===== STATE 3 =====
					else if (state == 6'd3) begin
						if (data_sig == 0) begin
							state <= 6'd0;
							return_sig[i] <= 1'd0;
						end
						else state <= 6'd3;
					end
				end
			end
		end
	endgenerate

	arbriter genArbri( 
		.y					(row_select),
		.vga_pxl_clr		(pixel_color),
		.inter_select		(inter_select),
		.inter_done			(inter_done),
		.clk				(CLOCK_50),
		.comp_flag			(comp_flag),
		.vga_sram_address	(vga_sram_address),
		.vga_sram_write		(vga_sram_write),
		.vga_sram_writedata	(vga_sram_writedata),
		.inter_start		(inter_start),
		.reset				(~KEY[0])
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
		.clock_bridge_0_in_clk_clk            		(CLOCK_50), //(CLOCK_50), 
		
		// VGA Subsystem
		.vga_pll_ref_clk_clk 						(CLOCK2_50),
		.vga_pll_ref_reset_reset					(1'b0),
		.vga_CLK									(VGA_CLK),
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
		.memory_mem_cke			(HPS_DDR3_CKE),
		.memory_mem_cs_n		(HPS_DDR3_CS_N),
		.memory_mem_ras_n		(HPS_DDR3_RAS_N),
		.memory_mem_cas_n		(HPS_DDR3_CAS_N),
		.memory_mem_we_n		(HPS_DDR3_WE_N),
		.memory_mem_reset_n		(HPS_DDR3_RESET_N),
		.memory_mem_dq			(HPS_DDR3_DQ),
		.memory_mem_dqs			(HPS_DDR3_DQS_P),
		.memory_mem_dqs_n		(HPS_DDR3_DQS_N),
		.memory_mem_odt			(HPS_DDR3_ODT),
		.memory_mem_dm			(HPS_DDR3_DM),
		.memory_oct_rzqin		(HPS_DDR3_RZQ),
			
		// Ethernet
		.hps_io_hps_io_gpio_inst_GPIO35	(HPS_ENET_INT_N),
		.hps_io_hps_io_emac1_inst_TX_CLK(HPS_ENET_GTX_CLK),
		.hps_io_hps_io_emac1_inst_TXD0	(HPS_ENET_TX_DATA[0]),
		.hps_io_hps_io_emac1_inst_TXD1	(HPS_ENET_TX_DATA[1]),
		.hps_io_hps_io_emac1_inst_TXD2	(HPS_ENET_TX_DATA[2]),
		.hps_io_hps_io_emac1_inst_TXD3	(HPS_ENET_TX_DATA[3]),
		.hps_io_hps_io_emac1_inst_RXD0	(HPS_ENET_RX_DATA[0]),
		.hps_io_hps_io_emac1_inst_MDIO	(HPS_ENET_MDIO),
		.hps_io_hps_io_emac1_inst_MDC	(HPS_ENET_MDC),
		.hps_io_hps_io_emac1_inst_RX_CTL(HPS_ENET_RX_DV),
		.hps_io_hps_io_emac1_inst_TX_CTL(HPS_ENET_TX_EN),
		.hps_io_hps_io_emac1_inst_RX_CLK(HPS_ENET_RX_CLK),
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
		.hps_io_hps_io_i2c0_inst_SDA	(HPS_I2C1_SDAT),
		.hps_io_hps_io_i2c0_inst_SCL	(HPS_I2C1_SCLK),
		.hps_io_hps_io_i2c1_inst_SDA	(HPS_I2C2_SDAT),
		.hps_io_hps_io_i2c1_inst_SCL	(HPS_I2C2_SCLK),

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

// module M10K_256_32( 
//     output reg [31:0] q,
//     input [31:0] d,
//     input [7:0] write_address, read_address,
//     input we, clk
// );
// 	 // force M10K ram style
// 	 // 256 words of 32 bits
//     reg [31:0] mem [255:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
//     always @ (posedge clk) begin
//         if (we) begin
//             mem[write_address] <= d;
// 		  end
//         q <= mem[read_address]; // q doesn't get d in this clock cycle
//     end
// endmodule

/// end /////////////////////////////////////////////////////////////////////

