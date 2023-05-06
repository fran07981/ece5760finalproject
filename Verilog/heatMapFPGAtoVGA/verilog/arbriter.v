// ---------------------------------------------------------------------------
// arbriter 
// ---------------------------------------------------------------------------

module arbriter ( vga_addr, vga_pxl_clr, inter_select, inter_done, clk, comp_flag, 
				  vga_sram_address, vga_sram_write, vga_sram_writedata, inter_start, KEY);
	// number of iterators we currently have
	localparam n = 7;

	input [3:0]	KEY;
	input	 	clk;

	// Communicate with individual iterators with these inputs	
	input [( n * 32 - 1):0] vga_addr; 	 // n = # of iterators, secont [] is length of data (32 bits)
	input [( n * 32 - 1):0] vga_pxl_clr; // n = # of iterators, [] is length of data (32 bits)
	
	input [n - 1:0] inter_select;		// tells us which iterator is ready to be plotted via flag	
	input [n - 1:0] inter_done;			// tells us which iterator is done plotting
	
	output wire [n-1:0] comp_flag;		// return to nth iterator to move to next point
	output wire 	    inter_start; 	// tells iterators to start
	
	input 				hps_reset;		// tells us HPS sent a reset

	// Write to VGA Data with these wires
	output wire [31:0] 	vga_sram_address;
	output wire 		vga_sram_write;
	output wire [7:0] 	vga_sram_writedata;
	

	// Internal Registers
	reg [ 31:0 ]  vga_sram_address_;
	reg [ 7 :0 ]  vga_sram_writedata_;
	reg 		  vga_sram_write_;
	reg [n - 1:0] comp_flag_;
	reg 	  	  inter_start_;
	reg [2:0] 	  state_arbr;
	reg 	  	  hps_done_;
	reg [31:0] 	  timer;
	reg [31:0] 	  timer_ms;
	reg [31:0] 	  hps_send_timer_;
	reg 		  hps_send_done_;
	
	always @(posedge clk) begin

		// ===== STATE 0 =====
		if ( state_arbr == 3'd0 || hps_reset) begin
			// button gets pressed 
			if (~KEY[0]) begin
				state_arbr <= 3'd1;
			end
			
			// hanshake HPS reset flag
			// raise HPS_done so that the HPS knows we good
			if ( hps_reset ) begin 
				hps_send_done_ <= 1'b0;
				hps_done_      <= 1'b1;
				state_arbr 	   <= 3'd1;
			end

			// no reset signal or button pressed yet! stay here
			else begin
				state_arbr <= 3'd0;
			end
		end

		// ===== STATE 1 =====
		else if ( state_arbr == 3'd1 ) begin
			inter_start_ <= 1'b1; // tell mandels to start
			state_arbr   <= 3'd2; // move to state 2

			// tell HPS we are not done plotting yet
			hps_send_done_ <= 1'b0;
		end

		// ===== STATE 2 =====
		else if( state_arbr == 3'd2 ) begin
			inter_start_ <= 1'b0;	// lower mandel start flag 
			state_arbr   <= 3'd3;	// move to state 3
		end

		// ===== STATE 3 =====
		else if ( state_arbr == 3'd3 ) begin
			if ( ~( inter_select == 0 ) ) begin
				if ( inter_select[0] == 1'b1 ) begin		// if this first iterator is ready, plot it
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr   [ ((0+1)*32-1) : (((0+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((0+1)*32-1) : (((0+1)*32-1) - 31) ];
					comp_flag_[0]  		<= 1'b1;			// raise comp flag
					state_arbr			<= 3'd4;			// move to state 3 to remove updated flag
				end
				else if ( inter_select[1] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((1+1)*32-1) : (((1+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((1+1)*32-1) : (((1+1)*32-1) - 31) ];
					comp_flag_[1] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
				else if ( inter_select[2] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((2+1)*32-1) : (((2+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((2+1)*32-1) : (((2+1)*32-1) - 31) ];
					comp_flag_[2] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
				else if ( inter_select[3] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((3+1)*32-1) : (((3+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((3+1)*32-1) : (((3+1)*32-1) - 31) ];
					comp_flag_[3] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
				else if ( inter_select[4] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((4+1)*32-1) : (((4+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((4+1)*32-1) : (((4+1)*32-1) - 31) ];
					comp_flag_[4] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
				else if ( inter_select[5] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((5+1)*32-1) : (((5+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((5+1)*32-1) : (((5+1)*32-1) - 31) ];
					comp_flag_[5] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
				else if ( inter_select[6] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((6+1)*32-1) : (((6+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((6+1)*32-1) : (((6+1)*32-1) - 31) ];
					comp_flag_[6] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
			end
			else if (inter_done == 7'd111_1111) begin		// ALL Iterators are done - 4'b11_11
				state_arbr <= 3'd5;
			end
			else begin 
				state_arbr <= 3'd3;
			end
		end

		// ===== STATE 4 =====
		else if ( state_arbr == 3'd4 ) begin
			if ( comp_flag_[0] == 1'd1 ) begin
				comp_flag_[0] <= 1'b0;	
			end
			else if ( comp_flag_[1] == 1'd1 ) begin	
				comp_flag_[1] <= 1'b0;				
			end
			else if ( comp_flag_[2] == 1'd1 ) begin	
				comp_flag_[2] <= 1'b0;				
			end
			else if ( comp_flag_[3] == 1'd1 ) begin	
				comp_flag_[3] <= 1'b0;				
			end 
			else if ( comp_flag_[4] == 1'd1 ) begin	
				comp_flag_[4] <= 1'b0;				
			end 
			else if ( comp_flag_[5] == 1'd1 ) begin	
				comp_flag_[5] <= 1'b0;				
			end 
			else if ( comp_flag_[6] == 1'd1 ) begin	
				comp_flag_[6] <= 1'b0;				
			end 

			state_arbr <= 3'd3;	// return to state 2
		end

		// ===== STATE 5 =====
		// done state, VGA done, send info to HPS
		else if ( state_arbr == 3'd5 ) begin
			vga_sram_write_ <= 1'b0;
			hps_send_timer_ <= timer_ms;	
			hps_send_done_  <= 1'b1;
			state_arbr      <= 3'd5;
		end
		
	end

	always @(posedge clk) begin
		// only increment while we're actually potting and waiting to plot, not to receive signals
		if ((state_arbr == 3'd3) || (state_arbr == 3'd4)) begin
			// every clock iteration timer += 1
			if ( timer == 32'd50_000 ) begin
				timer_ms <= timer_ms + 1;
				timer 	 <= 0;
			end
			else begin
				timer <= timer + 1;
			end
		end
		else if (state_arbr == 3'd1) begin
			// set up timer
			timer_ms     <= 32'b0;
			timer        <= 32'b0;
		end
	
	end

	assign vga_sram_write  	  = vga_sram_write_; 
	assign vga_sram_address   = vga_sram_address_; 
	assign vga_sram_writedata = vga_sram_writedata_; 
	assign comp_flag		  = comp_flag_; 
	assign inter_start 		  = inter_start_;
	assign hps_done 		  = hps_done_;
	assign hps_send_timer 	  = hps_send_timer_;
	assign hps_send_done 	  = hps_send_done_;

endmodule