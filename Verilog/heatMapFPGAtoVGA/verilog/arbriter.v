// ---------------------------------------------------------------------------
// arbriter 
// ---------------------------------------------------------------------------

// take turns drawing each pixel in the column to the VGA  

module arbriter ( y, vga_pxl_clr, inter_select, inter_done, clk, comp_flag, 
				  vga_sram_address, vga_sram_write, vga_sram_writedata, inter_start, reset);
	// number of iterators we currently have
	localparam n = 64;
	input	 	clk;

	// Communicate with individual columns with these inputs	
	// input [( n * 32 - 1):0] vga_addr; 	 // n = # of iterators, secont [] is length of data (32 bits)
	input [7:0] vga_pxl_clr; // n = # of iterators, [] is length of data (32 bits)
	
	input [n - 1:0] inter_select;		// inter_select: tells us which column is ready to be plotted via flag	
	input [n - 1:0] inter_done;			// inter_done: tells us which column is done plotting
	input [    9:0] y;
	
	output wire [n-1:0] comp_flag;		// return to nth iterator to move to next point
	output wire 		inter_start;    // inter_start: tells columns to start (beginning of arbiter state machine)

	input 				reset; 			// hps_reset: tells us HPS sent a reset

	// Write to VGA Data with these wires
	output wire [31:0] 	vga_sram_address;
	output wire 		vga_sram_write;
	output wire [7:0] 	vga_sram_writedata;

	// Internal Registers
	reg [ 31:0 ]  vga_sram_address_;
	reg [ 7 :0 ]  vga_sram_writedata_;
	reg 		  vga_sram_write_;
	reg [n - 1:0] comp_flag_;
	reg 		  inter_start_;
	
	reg [2:0] 	  state_arbr;
	reg [31:0] 	  timer;
	reg [31:0] 	  timer_ms;
	
	reg  [ 9:0] x_coor, y_coor;
	
	always @(posedge clk) begin

		// ===== STATE 0 =====
		if ( state_arbr == 3'd0 || reset) begin
			state_arbr <= 3'd1;
		end

		// ===== STATE 1 =====
		else if ( state_arbr == 3'd1 ) begin
			inter_start_ <= 1'b1; 
			state_arbr   <= 3'd2; 
		end

		// ===== STATE 2 =====
		else if( state_arbr == 3'd2 ) begin
			inter_start_ <= 1'b0;	// lower mandel start flag 
			state_arbr   <= 3'd3;	// move to state 3
			x_coor		 <= 10'd0;
			y_coor		 <= 10'd0;
		end

		// ===== STATE 3 =====
		else if ( state_arbr == 3'd3 ) begin
			if ( ~( inter_select == 0 ) ) begin
				if ( inter_select[0] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd0 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[0] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[1] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd7 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[1] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[2] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd14 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[2] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[3] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd21 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[3] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[4] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd28 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[4] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[5] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd35 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[5] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[6] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd42 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[6] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end

				else if ( inter_select[7] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd49 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[7] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end

				else if ( inter_select[8] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd56 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[8] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end

				else if ( inter_select[9] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd63 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[9] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[10] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd70 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[10] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[11] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd77 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[11] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[12] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd84 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[12] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[13] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd91 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[13] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[14] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd98 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[14] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[15] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd105 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[15] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[16] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd112 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[16] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[17] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd119 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[17] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[18] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd126 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[18] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[19] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd133 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[19] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				else if ( inter_select[20] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd140 + x_coor} + ({22'b0, 7 * y + y_coor} * 640);
					if( y_coor == 10'd6 && x_coor == 10'd6) begin 
						comp_flag_[20] <= 1'b1; 
						state_arbr <= 3'd5;
					end
					else if( x_coor == 10'd6) begin
						y_coor <= y_coor + 10'd1;
						x_coor <= 10'd0;
						state_arbr <= 3'd4;
					end
					else begin
						x_coor <= x_coor + 10'd1;
						state_arbr <= 3'd4;
					end
				end
				if ( inter_select[21] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd147 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[21] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[22] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd154 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[22] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[23] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd161 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[23] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[24] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd168 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[24] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[25] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd175 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[25] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[26] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd182 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[26] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[27] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd189 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[27] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[28] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd196 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[28] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[29] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd203 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[29] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[30] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd210 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[30] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[31] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd217 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[31] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[32] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd224 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[32] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[33] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd231 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[33] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[34] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd238 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[34] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[35] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd245 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[35] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[36] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd252 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[36] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[37] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd259 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[37] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[38] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd266 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[38] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[39] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd273 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[39] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[40] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd280 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[40] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[41] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd287 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[41] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[42] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd294 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[42] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[43] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd301 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[43] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[44] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd308 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[44] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[45] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd315 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[45] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[46] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd322 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[46] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[47] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd329 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[47] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[48] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd336 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[48] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[49] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd343 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[49] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[50] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd350 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[50] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[51] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd357 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[51] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[52] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd364 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[52] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[53] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd371 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[53] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[54] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd378 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[54] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[55] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd385 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[55] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[56] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd392 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[56] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[57] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd399 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[57] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[58] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd406 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[58] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[59] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd413 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[59] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[60] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd420 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[60] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[61] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd427 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[61] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[62] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd434 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[62] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				if ( inter_select[63] == 1'b1 ) begin 
					vga_sram_address_ <= {22'b0, 10'd441 + x_coor} + ({22'b0, 7 * y + y_coor} * 640); 
					
					if( y_coor == 10'd6 && x_coor == 10'd6) begin  
						comp_flag_[63] <= 1'b1;  
						state_arbr <= 3'd5; 
					end
					else if( x_coor == 10'd6) begin 
						y_coor <= y_coor + 10'd1; 
						x_coor <= 10'd0; 
						state_arbr <= 3'd4; 
					end
					else begin 
						x_coor <= x_coor + 10'd1; 
						state_arbr <= 3'd4; 
					end
				end
				

				vga_sram_writedata_ <= vga_pxl_clr;
				vga_sram_write_ 	<= 1'b1;

			end
			else begin 
				state_arbr <= 3'd3;
			end
		end


		// ===== STATE 4 =====
		else if ( state_arbr == 3'd4 ) begin
			state_arbr <= 3'd3;
		end

		// ===== STATE 5 =====
		else if ( state_arbr == 3'd5 ) begin
			if 		( comp_flag_[0 ] == 1'd1 ) comp_flag_[0 ] <= 1'b0;	
			else if ( comp_flag_[1 ] == 1'd1 ) comp_flag_[1 ] <= 1'b0;
			else if ( comp_flag_[2 ] == 1'd1 ) comp_flag_[2 ] <= 1'b0;
			else if ( comp_flag_[3 ] == 1'd1 ) comp_flag_[3 ] <= 1'b0;
			else if ( comp_flag_[4 ] == 1'd1 ) comp_flag_[4 ] <= 1'b0;
			else if ( comp_flag_[5 ] == 1'd1 ) comp_flag_[5 ] <= 1'b0;
			else if ( comp_flag_[6 ] == 1'd1 ) comp_flag_[6 ] <= 1'b0;
			else if ( comp_flag_[7 ] == 1'd1 ) comp_flag_[7 ] <= 1'b0;
			else if ( comp_flag_[8 ] == 1'd1 ) comp_flag_[8 ] <= 1'b0;
			else if ( comp_flag_[9 ] == 1'd1 ) comp_flag_[9 ] <= 1'b0;
			else if ( comp_flag_[10] == 1'd1 ) comp_flag_[10] <= 1'b0;
			else if ( comp_flag_[11] == 1'd1 ) comp_flag_[11] <= 1'b0;
			else if ( comp_flag_[12] == 1'd1 ) comp_flag_[12] <= 1'b0;
			else if ( comp_flag_[13] == 1'd1 ) comp_flag_[13] <= 1'b0;
			else if ( comp_flag_[14] == 1'd1 ) comp_flag_[14] <= 1'b0;
			else if ( comp_flag_[15] == 1'd1 ) comp_flag_[15] <= 1'b0;
			else if ( comp_flag_[16] == 1'd1 ) comp_flag_[16] <= 1'b0;
			else if ( comp_flag_[17] == 1'd1 ) comp_flag_[17] <= 1'b0;
			else if ( comp_flag_[18] == 1'd1 ) comp_flag_[18] <= 1'b0;
			else if ( comp_flag_[19] == 1'd1 ) comp_flag_[19] <= 1'b0;
			else if ( comp_flag_[20] == 1'd1 ) comp_flag_[20] <= 1'b0;
			else if ( comp_flag_[21] == 1'd1 ) comp_flag_[21] <= 1'b0;
			else if ( comp_flag_[22] == 1'd1 ) comp_flag_[22] <= 1'b0;
			else if ( comp_flag_[23] == 1'd1 ) comp_flag_[23] <= 1'b0;
			else if ( comp_flag_[24] == 1'd1 ) comp_flag_[24] <= 1'b0;
			else if ( comp_flag_[25] == 1'd1 ) comp_flag_[25] <= 1'b0;
			else if ( comp_flag_[26] == 1'd1 ) comp_flag_[26] <= 1'b0;
			else if ( comp_flag_[27] == 1'd1 ) comp_flag_[27] <= 1'b0;
			else if ( comp_flag_[28] == 1'd1 ) comp_flag_[28] <= 1'b0;
			else if ( comp_flag_[29] == 1'd1 ) comp_flag_[29] <= 1'b0;
			else if ( comp_flag_[30] == 1'd1 ) comp_flag_[30] <= 1'b0;
			else if ( comp_flag_[31] == 1'd1 ) comp_flag_[31] <= 1'b0;
			else if ( comp_flag_[32] == 1'd1 ) comp_flag_[32] <= 1'b0;
			else if ( comp_flag_[33] == 1'd1 ) comp_flag_[33] <= 1'b0;
			else if ( comp_flag_[34] == 1'd1 ) comp_flag_[34] <= 1'b0;
			else if ( comp_flag_[35] == 1'd1 ) comp_flag_[35] <= 1'b0;
			else if ( comp_flag_[36] == 1'd1 ) comp_flag_[36] <= 1'b0;
			else if ( comp_flag_[37] == 1'd1 ) comp_flag_[37] <= 1'b0;
			else if ( comp_flag_[38] == 1'd1 ) comp_flag_[38] <= 1'b0;
			else if ( comp_flag_[39] == 1'd1 ) comp_flag_[39] <= 1'b0;
			else if ( comp_flag_[40] == 1'd1 ) comp_flag_[40] <= 1'b0;
			else if ( comp_flag_[41] == 1'd1 ) comp_flag_[41] <= 1'b0;
			else if ( comp_flag_[42] == 1'd1 ) comp_flag_[42] <= 1'b0;
			else if ( comp_flag_[43] == 1'd1 ) comp_flag_[43] <= 1'b0;
			else if ( comp_flag_[44] == 1'd1 ) comp_flag_[44] <= 1'b0;
			else if ( comp_flag_[45] == 1'd1 ) comp_flag_[45] <= 1'b0;
			else if ( comp_flag_[46] == 1'd1 ) comp_flag_[46] <= 1'b0;
			else if ( comp_flag_[47] == 1'd1 ) comp_flag_[47] <= 1'b0;
			else if ( comp_flag_[48] == 1'd1 ) comp_flag_[48] <= 1'b0;
			else if ( comp_flag_[49] == 1'd1 ) comp_flag_[49] <= 1'b0;
			else if ( comp_flag_[50] == 1'd1 ) comp_flag_[50] <= 1'b0;
			else if ( comp_flag_[51] == 1'd1 ) comp_flag_[51] <= 1'b0;
			else if ( comp_flag_[52] == 1'd1 ) comp_flag_[52] <= 1'b0;
			else if ( comp_flag_[53] == 1'd1 ) comp_flag_[53] <= 1'b0;
			else if ( comp_flag_[54] == 1'd1 ) comp_flag_[54] <= 1'b0;
			else if ( comp_flag_[55] == 1'd1 ) comp_flag_[55] <= 1'b0;
			else if ( comp_flag_[56] == 1'd1 ) comp_flag_[56] <= 1'b0;
			else if ( comp_flag_[57] == 1'd1 ) comp_flag_[57] <= 1'b0;
			else if ( comp_flag_[58] == 1'd1 ) comp_flag_[58] <= 1'b0;
			else if ( comp_flag_[59] == 1'd1 ) comp_flag_[59] <= 1'b0;
			else if ( comp_flag_[60] == 1'd1 ) comp_flag_[60] <= 1'b0;
			else if ( comp_flag_[61] == 1'd1 ) comp_flag_[61] <= 1'b0;
			else if ( comp_flag_[62] == 1'd1 ) comp_flag_[62] <= 1'b0;
			else if ( comp_flag_[63] == 1'd1 ) comp_flag_[63] <= 1'b0;

			state_arbr <= 3'd6;	// return to state 2
		end

		// ===== STATE 6 =====
		else if ( state_arbr == 3'd6 ) begin
			vga_sram_write_ <= 1'b0;
			state_arbr      <= 3'd2;
		end
		
	end

	assign vga_sram_write  	  = vga_sram_write_; 
	assign vga_sram_address   = vga_sram_address_; 
	assign vga_sram_writedata = vga_sram_writedata_; 
	assign comp_flag		  = comp_flag_; 
	assign inter_start 		  = inter_start_;

endmodule