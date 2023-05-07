// ---------------------------------------------------------------------------
// arbriter 
// ---------------------------------------------------------------------------

// take turns drawing each pixel in the column to the VGA  

module arbriter ( y, vga_pxl_clr, inter_select, inter_done, clk, comp_flag, 
				  vga_sram_address, vga_sram_write, vga_sram_writedata, inter_start, reset);
	// number of iterators we currently have
	localparam n = 101;

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
	
	reg inter_start_;
	
	reg [2:0] 	  state_arbr;
	//reg 	  	  hps_done_;
	reg [31:0] 	  timer;
	reg [31:0] 	  timer_ms;
	//reg [31:0]  hps_send_timer_;
	//reg 		  hps_send_done_; 
	
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
		end

		// ===== STATE 3 =====
		else if ( state_arbr == 3'd3 ) begin
			if ( ~( inter_select == 0 ) ) begin
				if ( inter_select[0] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd0} + ({22'b0, y} * 640); comp_flag_[0] <= 1'b1; end
				else if ( inter_select[1] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd1} + ({22'b0, y} * 640); comp_flag_[1] <= 1'b1; end
				else if ( inter_select[2] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd2} + ({22'b0, y} * 640); comp_flag_[2] <= 1'b1; end
				else if ( inter_select[3] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd3} + ({22'b0, y} * 640); comp_flag_[3] <= 1'b1; end
				else if ( inter_select[4] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd4} + ({22'b0, y} * 640); comp_flag_[4] <= 1'b1; end
				else if ( inter_select[5] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd5} + ({22'b0, y} * 640); comp_flag_[5] <= 1'b1; end
				else if ( inter_select[6] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd6} + ({22'b0, y} * 640); comp_flag_[6] <= 1'b1; end
				else if ( inter_select[7] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd7} + ({22'b0, y} * 640); comp_flag_[7] <= 1'b1; end
				else if ( inter_select[8] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd8} + ({22'b0, y} * 640); comp_flag_[8] <= 1'b1; end
				else if ( inter_select[9] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd9} + ({22'b0, y} * 640); comp_flag_[9] <= 1'b1; end
				else if ( inter_select[10] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd10} + ({22'b0, y} * 640); comp_flag_[10] <= 1'b1; end
				else if ( inter_select[11] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd11} + ({22'b0, y} * 640); comp_flag_[11] <= 1'b1; end
				else if ( inter_select[12] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd12} + ({22'b0, y} * 640); comp_flag_[12] <= 1'b1; end
				else if ( inter_select[13] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd13} + ({22'b0, y} * 640); comp_flag_[13] <= 1'b1; end
				else if ( inter_select[14] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd14} + ({22'b0, y} * 640); comp_flag_[14] <= 1'b1; end
				else if ( inter_select[15] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd15} + ({22'b0, y} * 640); comp_flag_[15] <= 1'b1; end
				else if ( inter_select[16] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd16} + ({22'b0, y} * 640); comp_flag_[16] <= 1'b1; end
				else if ( inter_select[17] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd17} + ({22'b0, y} * 640); comp_flag_[17] <= 1'b1; end
				else if ( inter_select[18] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd18} + ({22'b0, y} * 640); comp_flag_[18] <= 1'b1; end
				else if ( inter_select[19] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd19} + ({22'b0, y} * 640); comp_flag_[19] <= 1'b1; end
				else if ( inter_select[20] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd20} + ({22'b0, y} * 640); comp_flag_[20] <= 1'b1; end
				else if ( inter_select[21] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd21} + ({22'b0, y} * 640); comp_flag_[21] <= 1'b1; end
				else if ( inter_select[22] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd22} + ({22'b0, y} * 640); comp_flag_[22] <= 1'b1; end
				else if ( inter_select[23] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd23} + ({22'b0, y} * 640); comp_flag_[23] <= 1'b1; end
				else if ( inter_select[24] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd24} + ({22'b0, y} * 640); comp_flag_[24] <= 1'b1; end
				else if ( inter_select[25] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd25} + ({22'b0, y} * 640); comp_flag_[25] <= 1'b1; end
				else if ( inter_select[26] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd26} + ({22'b0, y} * 640); comp_flag_[26] <= 1'b1; end
				else if ( inter_select[27] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd27} + ({22'b0, y} * 640); comp_flag_[27] <= 1'b1; end
				else if ( inter_select[28] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd28} + ({22'b0, y} * 640); comp_flag_[28] <= 1'b1; end
				else if ( inter_select[29] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd29} + ({22'b0, y} * 640); comp_flag_[29] <= 1'b1; end
				else if ( inter_select[30] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd30} + ({22'b0, y} * 640); comp_flag_[30] <= 1'b1; end
				else if ( inter_select[31] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd31} + ({22'b0, y} * 640); comp_flag_[31] <= 1'b1; end
				else if ( inter_select[32] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd32} + ({22'b0, y} * 640); comp_flag_[32] <= 1'b1; end
				else if ( inter_select[33] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd33} + ({22'b0, y} * 640); comp_flag_[33] <= 1'b1; end
				else if ( inter_select[34] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd34} + ({22'b0, y} * 640); comp_flag_[34] <= 1'b1; end
				else if ( inter_select[35] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd35} + ({22'b0, y} * 640); comp_flag_[35] <= 1'b1; end
				else if ( inter_select[36] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd36} + ({22'b0, y} * 640); comp_flag_[36] <= 1'b1; end
				else if ( inter_select[37] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd37} + ({22'b0, y} * 640); comp_flag_[37] <= 1'b1; end
				else if ( inter_select[38] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd38} + ({22'b0, y} * 640); comp_flag_[38] <= 1'b1; end
				else if ( inter_select[39] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd39} + ({22'b0, y} * 640); comp_flag_[39] <= 1'b1; end
				else if ( inter_select[40] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd40} + ({22'b0, y} * 640); comp_flag_[40] <= 1'b1; end
				else if ( inter_select[41] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd41} + ({22'b0, y} * 640); comp_flag_[41] <= 1'b1; end
				else if ( inter_select[42] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd42} + ({22'b0, y} * 640); comp_flag_[42] <= 1'b1; end
				else if ( inter_select[43] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd43} + ({22'b0, y} * 640); comp_flag_[43] <= 1'b1; end
				else if ( inter_select[44] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd44} + ({22'b0, y} * 640); comp_flag_[44] <= 1'b1; end
				else if ( inter_select[45] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd45} + ({22'b0, y} * 640); comp_flag_[45] <= 1'b1; end
				else if ( inter_select[46] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd46} + ({22'b0, y} * 640); comp_flag_[46] <= 1'b1; end
				else if ( inter_select[47] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd47} + ({22'b0, y} * 640); comp_flag_[47] <= 1'b1; end
				else if ( inter_select[48] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd48} + ({22'b0, y} * 640); comp_flag_[48] <= 1'b1; end
				else if ( inter_select[49] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd49} + ({22'b0, y} * 640); comp_flag_[49] <= 1'b1; end
				else if ( inter_select[50] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd50} + ({22'b0, y} * 640); comp_flag_[50] <= 1'b1; end
				else if ( inter_select[51] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd51} + ({22'b0, y} * 640); comp_flag_[51] <= 1'b1; end
				else if ( inter_select[52] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd52} + ({22'b0, y} * 640); comp_flag_[52] <= 1'b1; end
				else if ( inter_select[53] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd53} + ({22'b0, y} * 640); comp_flag_[53] <= 1'b1; end
				else if ( inter_select[54] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd54} + ({22'b0, y} * 640); comp_flag_[54] <= 1'b1; end
				else if ( inter_select[55] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd55} + ({22'b0, y} * 640); comp_flag_[55] <= 1'b1; end
				else if ( inter_select[56] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd56} + ({22'b0, y} * 640); comp_flag_[56] <= 1'b1; end
				else if ( inter_select[57] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd57} + ({22'b0, y} * 640); comp_flag_[57] <= 1'b1; end
				else if ( inter_select[58] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd58} + ({22'b0, y} * 640); comp_flag_[58] <= 1'b1; end
				else if ( inter_select[59] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd59} + ({22'b0, y} * 640); comp_flag_[59] <= 1'b1; end
				else if ( inter_select[60] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd60} + ({22'b0, y} * 640); comp_flag_[60] <= 1'b1; end
				else if ( inter_select[61] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd61} + ({22'b0, y} * 640); comp_flag_[61] <= 1'b1; end
				else if ( inter_select[62] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd62} + ({22'b0, y} * 640); comp_flag_[62] <= 1'b1; end
				else if ( inter_select[63] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd63} + ({22'b0, y} * 640); comp_flag_[63] <= 1'b1; end
				else if ( inter_select[64] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd64} + ({22'b0, y} * 640); comp_flag_[64] <= 1'b1; end
				else if ( inter_select[65] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd65} + ({22'b0, y} * 640); comp_flag_[65] <= 1'b1; end
				else if ( inter_select[66] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd66} + ({22'b0, y} * 640); comp_flag_[66] <= 1'b1; end
				else if ( inter_select[67] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd67} + ({22'b0, y} * 640); comp_flag_[67] <= 1'b1; end
				else if ( inter_select[68] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd68} + ({22'b0, y} * 640); comp_flag_[68] <= 1'b1; end
				else if ( inter_select[69] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd69} + ({22'b0, y} * 640); comp_flag_[69] <= 1'b1; end
				else if ( inter_select[70] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd70} + ({22'b0, y} * 640); comp_flag_[70] <= 1'b1; end
				else if ( inter_select[71] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd71} + ({22'b0, y} * 640); comp_flag_[71] <= 1'b1; end
				else if ( inter_select[72] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd72} + ({22'b0, y} * 640); comp_flag_[72] <= 1'b1; end
				else if ( inter_select[73] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd73} + ({22'b0, y} * 640); comp_flag_[73] <= 1'b1; end
				else if ( inter_select[74] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd74} + ({22'b0, y} * 640); comp_flag_[74] <= 1'b1; end
				else if ( inter_select[75] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd75} + ({22'b0, y} * 640); comp_flag_[75] <= 1'b1; end
				else if ( inter_select[76] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd76} + ({22'b0, y} * 640); comp_flag_[76] <= 1'b1; end
				else if ( inter_select[77] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd77} + ({22'b0, y} * 640); comp_flag_[77] <= 1'b1; end
				else if ( inter_select[78] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd78} + ({22'b0, y} * 640); comp_flag_[78] <= 1'b1; end
				else if ( inter_select[79] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd79} + ({22'b0, y} * 640); comp_flag_[79] <= 1'b1; end
				else if ( inter_select[80] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd80} + ({22'b0, y} * 640); comp_flag_[80] <= 1'b1; end
				else if ( inter_select[81] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd81} + ({22'b0, y} * 640); comp_flag_[81] <= 1'b1; end
				else if ( inter_select[82] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd82} + ({22'b0, y} * 640); comp_flag_[82] <= 1'b1; end
				else if ( inter_select[83] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd83} + ({22'b0, y} * 640); comp_flag_[83] <= 1'b1; end
				else if ( inter_select[84] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd84} + ({22'b0, y} * 640); comp_flag_[84] <= 1'b1; end
				else if ( inter_select[85] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd85} + ({22'b0, y} * 640); comp_flag_[85] <= 1'b1; end
				else if ( inter_select[86] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd86} + ({22'b0, y} * 640); comp_flag_[86] <= 1'b1; end
				else if ( inter_select[87] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd87} + ({22'b0, y} * 640); comp_flag_[87] <= 1'b1; end
				else if ( inter_select[88] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd88} + ({22'b0, y} * 640); comp_flag_[88] <= 1'b1; end
				else if ( inter_select[89] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd89} + ({22'b0, y} * 640); comp_flag_[89] <= 1'b1; end
				else if ( inter_select[90] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd90} + ({22'b0, y} * 640); comp_flag_[90] <= 1'b1; end
				else if ( inter_select[91] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd91} + ({22'b0, y} * 640); comp_flag_[91] <= 1'b1; end
				else if ( inter_select[92] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd92} + ({22'b0, y} * 640); comp_flag_[92] <= 1'b1; end
				else if ( inter_select[93] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd93} + ({22'b0, y} * 640); comp_flag_[93] <= 1'b1; end
				else if ( inter_select[94] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd94} + ({22'b0, y} * 640); comp_flag_[94] <= 1'b1; end
				else if ( inter_select[95] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd95} + ({22'b0, y} * 640); comp_flag_[95] <= 1'b1; end
				else if ( inter_select[96] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd96} + ({22'b0, y} * 640); comp_flag_[96] <= 1'b1; end
				else if ( inter_select[97] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd97} + ({22'b0, y} * 640); comp_flag_[97] <= 1'b1; end
				else if ( inter_select[98] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd98} + ({22'b0, y} * 640); comp_flag_[98] <= 1'b1; end
				else if ( inter_select[99] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd99} + ({22'b0, y} * 640); comp_flag_[99] <= 1'b1; end
				else if ( inter_select[98] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd98} + ({22'b0, y} * 640); comp_flag_[98] <= 1'b1; end
				else if ( inter_select[99] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd99} + ({22'b0, y} * 640); comp_flag_[99] <= 1'b1; end
				else if ( inter_select[100] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd100} + ({22'b0, y} * 640); comp_flag_[100] <= 1'b1; end
				// else if ( inter_select[101] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd101} + ({22'b0, y} * 640); comp_flag_[101] <= 1'b1; end
				// else if ( inter_select[102] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd102} + ({22'b0, y} * 640); comp_flag_[102] <= 1'b1; end
				// else if ( inter_select[103] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd103} + ({22'b0, y} * 640); comp_flag_[103] <= 1'b1; end
				// else if ( inter_select[104] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd104} + ({22'b0, y} * 640); comp_flag_[104] <= 1'b1; end
				// else if ( inter_select[105] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd105} + ({22'b0, y} * 640); comp_flag_[105] <= 1'b1; end
				// else if ( inter_select[106] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd106} + ({22'b0, y} * 640); comp_flag_[106] <= 1'b1; end
				// else if ( inter_select[107] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd107} + ({22'b0, y} * 640); comp_flag_[107] <= 1'b1; end
				// else if ( inter_select[108] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd108} + ({22'b0, y} * 640); comp_flag_[108] <= 1'b1; end
				// else if ( inter_select[109] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd109} + ({22'b0, y} * 640); comp_flag_[109] <= 1'b1; end
				// else if ( inter_select[110] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd110} + ({22'b0, y} * 640); comp_flag_[110] <= 1'b1; end
				// else if ( inter_select[111] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd111} + ({22'b0, y} * 640); comp_flag_[111] <= 1'b1; end
				// else if ( inter_select[112] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd112} + ({22'b0, y} * 640); comp_flag_[112] <= 1'b1; end
				// else if ( inter_select[113] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd113} + ({22'b0, y} * 640); comp_flag_[113] <= 1'b1; end
				// else if ( inter_select[114] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd114} + ({22'b0, y} * 640); comp_flag_[114] <= 1'b1; end
				// else if ( inter_select[115] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd115} + ({22'b0, y} * 640); comp_flag_[115] <= 1'b1; end
				// else if ( inter_select[116] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd116} + ({22'b0, y} * 640); comp_flag_[116] <= 1'b1; end
				// else if ( inter_select[117] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd117} + ({22'b0, y} * 640); comp_flag_[117] <= 1'b1; end
				// else if ( inter_select[118] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd118} + ({22'b0, y} * 640); comp_flag_[118] <= 1'b1; end
				// else if ( inter_select[119] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd119} + ({22'b0, y} * 640); comp_flag_[119] <= 1'b1; end
				// else if ( inter_select[120] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd120} + ({22'b0, y} * 640); comp_flag_[120] <= 1'b1; end
				// else if ( inter_select[121] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd121} + ({22'b0, y} * 640); comp_flag_[121] <= 1'b1; end
				// else if ( inter_select[122] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd122} + ({22'b0, y} * 640); comp_flag_[122] <= 1'b1; end
				// else if ( inter_select[123] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd123} + ({22'b0, y} * 640); comp_flag_[123] <= 1'b1; end
				// else if ( inter_select[124] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd124} + ({22'b0, y} * 640); comp_flag_[124] <= 1'b1; end
				// else if ( inter_select[125] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd125} + ({22'b0, y} * 640); comp_flag_[125] <= 1'b1; end
				// else if ( inter_select[126] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd126} + ({22'b0, y} * 640); comp_flag_[126] <= 1'b1; end
				// else if ( inter_select[127] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd127} + ({22'b0, y} * 640); comp_flag_[127] <= 1'b1; end
				// else if ( inter_select[128] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd128} + ({22'b0, y} * 640); comp_flag_[128] <= 1'b1; end
				// else if ( inter_select[129] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd129} + ({22'b0, y} * 640); comp_flag_[129] <= 1'b1; end
				// else if ( inter_select[130] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd130} + ({22'b0, y} * 640); comp_flag_[130] <= 1'b1; end
				// else if ( inter_select[131] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd131} + ({22'b0, y} * 640); comp_flag_[131] <= 1'b1; end
				// else if ( inter_select[132] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd132} + ({22'b0, y} * 640); comp_flag_[132] <= 1'b1; end
				// else if ( inter_select[133] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd133} + ({22'b0, y} * 640); comp_flag_[133] <= 1'b1; end
				// else if ( inter_select[134] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd134} + ({22'b0, y} * 640); comp_flag_[134] <= 1'b1; end
				// else if ( inter_select[135] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd135} + ({22'b0, y} * 640); comp_flag_[135] <= 1'b1; end
				// else if ( inter_select[136] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd136} + ({22'b0, y} * 640); comp_flag_[136] <= 1'b1; end
				// else if ( inter_select[137] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd137} + ({22'b0, y} * 640); comp_flag_[137] <= 1'b1; end
				// else if ( inter_select[138] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd138} + ({22'b0, y} * 640); comp_flag_[138] <= 1'b1; end
				// else if ( inter_select[139] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd139} + ({22'b0, y} * 640); comp_flag_[139] <= 1'b1; end
				// else if ( inter_select[140] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd140} + ({22'b0, y} * 640); comp_flag_[140] <= 1'b1; end
				// else if ( inter_select[141] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd141} + ({22'b0, y} * 640); comp_flag_[141] <= 1'b1; end
				// else if ( inter_select[142] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd142} + ({22'b0, y} * 640); comp_flag_[142] <= 1'b1; end
				// else if ( inter_select[143] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd143} + ({22'b0, y} * 640); comp_flag_[143] <= 1'b1; end
				// else if ( inter_select[144] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd144} + ({22'b0, y} * 640); comp_flag_[144] <= 1'b1; end
				// else if ( inter_select[145] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd145} + ({22'b0, y} * 640); comp_flag_[145] <= 1'b1; end
				// else if ( inter_select[146] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd146} + ({22'b0, y} * 640); comp_flag_[146] <= 1'b1; end
				// else if ( inter_select[147] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd147} + ({22'b0, y} * 640); comp_flag_[147] <= 1'b1; end
				// else if ( inter_select[148] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd148} + ({22'b0, y} * 640); comp_flag_[148] <= 1'b1; end
				// else if ( inter_select[149] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd149} + ({22'b0, y} * 640); comp_flag_[149] <= 1'b1; end
				// else if ( inter_select[150] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd150} + ({22'b0, y} * 640); comp_flag_[150] <= 1'b1; end
				// else if ( inter_select[151] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd151} + ({22'b0, y} * 640); comp_flag_[151] <= 1'b1; end
				// else if ( inter_select[152] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd152} + ({22'b0, y} * 640); comp_flag_[152] <= 1'b1; end
				// else if ( inter_select[153] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd153} + ({22'b0, y} * 640); comp_flag_[153] <= 1'b1; end
				// else if ( inter_select[154] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd154} + ({22'b0, y} * 640); comp_flag_[154] <= 1'b1; end
				// else if ( inter_select[155] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd155} + ({22'b0, y} * 640); comp_flag_[155] <= 1'b1; end
				// else if ( inter_select[156] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd156} + ({22'b0, y} * 640); comp_flag_[156] <= 1'b1; end
				// else if ( inter_select[157] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd157} + ({22'b0, y} * 640); comp_flag_[157] <= 1'b1; end
				// else if ( inter_select[158] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd158} + ({22'b0, y} * 640); comp_flag_[158] <= 1'b1; end
				// else if ( inter_select[159] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd159} + ({22'b0, y} * 640); comp_flag_[159] <= 1'b1; end
				// else if ( inter_select[160] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd160} + ({22'b0, y} * 640); comp_flag_[160] <= 1'b1; end
				// else if ( inter_select[161] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd161} + ({22'b0, y} * 640); comp_flag_[161] <= 1'b1; end
				// else if ( inter_select[162] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd162} + ({22'b0, y} * 640); comp_flag_[162] <= 1'b1; end
				// else if ( inter_select[163] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd163} + ({22'b0, y} * 640); comp_flag_[163] <= 1'b1; end
				// else if ( inter_select[164] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd164} + ({22'b0, y} * 640); comp_flag_[164] <= 1'b1; end
				// else if ( inter_select[165] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd165} + ({22'b0, y} * 640); comp_flag_[165] <= 1'b1; end
				// else if ( inter_select[166] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd166} + ({22'b0, y} * 640); comp_flag_[166] <= 1'b1; end
				// else if ( inter_select[167] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd167} + ({22'b0, y} * 640); comp_flag_[167] <= 1'b1; end
				// else if ( inter_select[168] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd168} + ({22'b0, y} * 640); comp_flag_[168] <= 1'b1; end
				// else if ( inter_select[169] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd169} + ({22'b0, y} * 640); comp_flag_[169] <= 1'b1; end
				// else if ( inter_select[170] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd170} + ({22'b0, y} * 640); comp_flag_[170] <= 1'b1; end
				// else if ( inter_select[171] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd171} + ({22'b0, y} * 640); comp_flag_[171] <= 1'b1; end
				// else if ( inter_select[172] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd172} + ({22'b0, y} * 640); comp_flag_[172] <= 1'b1; end
				// else if ( inter_select[173] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd173} + ({22'b0, y} * 640); comp_flag_[173] <= 1'b1; end
				// else if ( inter_select[174] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd174} + ({22'b0, y} * 640); comp_flag_[174] <= 1'b1; end
				// else if ( inter_select[175] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd175} + ({22'b0, y} * 640); comp_flag_[175] <= 1'b1; end
				// else if ( inter_select[176] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd176} + ({22'b0, y} * 640); comp_flag_[176] <= 1'b1; end
				// else if ( inter_select[177] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd177} + ({22'b0, y} * 640); comp_flag_[177] <= 1'b1; end
				// else if ( inter_select[178] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd178} + ({22'b0, y} * 640); comp_flag_[178] <= 1'b1; end
				// else if ( inter_select[179] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd179} + ({22'b0, y} * 640); comp_flag_[179] <= 1'b1; end
				// else if ( inter_select[180] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd180} + ({22'b0, y} * 640); comp_flag_[180] <= 1'b1; end
				// else if ( inter_select[181] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd181} + ({22'b0, y} * 640); comp_flag_[181] <= 1'b1; end
				// else if ( inter_select[182] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd182} + ({22'b0, y} * 640); comp_flag_[182] <= 1'b1; end
				// else if ( inter_select[183] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd183} + ({22'b0, y} * 640); comp_flag_[183] <= 1'b1; end
				// else if ( inter_select[184] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd184} + ({22'b0, y} * 640); comp_flag_[184] <= 1'b1; end
				// else if ( inter_select[185] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd185} + ({22'b0, y} * 640); comp_flag_[185] <= 1'b1; end
				// else if ( inter_select[186] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd186} + ({22'b0, y} * 640); comp_flag_[186] <= 1'b1; end
				// else if ( inter_select[187] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd187} + ({22'b0, y} * 640); comp_flag_[187] <= 1'b1; end
				// else if ( inter_select[188] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd188} + ({22'b0, y} * 640); comp_flag_[188] <= 1'b1; end
				// else if ( inter_select[189] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd189} + ({22'b0, y} * 640); comp_flag_[189] <= 1'b1; end
				// else if ( inter_select[190] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd190} + ({22'b0, y} * 640); comp_flag_[190] <= 1'b1; end
				// else if ( inter_select[191] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd191} + ({22'b0, y} * 640); comp_flag_[191] <= 1'b1; end
				// else if ( inter_select[192] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd192} + ({22'b0, y} * 640); comp_flag_[192] <= 1'b1; end
				// else if ( inter_select[193] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd193} + ({22'b0, y} * 640); comp_flag_[193] <= 1'b1; end
				// else if ( inter_select[194] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd194} + ({22'b0, y} * 640); comp_flag_[194] <= 1'b1; end
				// else if ( inter_select[195] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd195} + ({22'b0, y} * 640); comp_flag_[195] <= 1'b1; end
				// else if ( inter_select[196] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd196} + ({22'b0, y} * 640); comp_flag_[196] <= 1'b1; end
				// else if ( inter_select[197] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd197} + ({22'b0, y} * 640); comp_flag_[197] <= 1'b1; end
				// else if ( inter_select[198] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd198} + ({22'b0, y} * 640); comp_flag_[198] <= 1'b1; end
				// else if ( inter_select[199] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd199} + ({22'b0, y} * 640); comp_flag_[199] <= 1'b1; end
				// else if ( inter_select[200] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd200} + ({22'b0, y} * 640); comp_flag_[200] <= 1'b1; end
				// else if ( inter_select[201] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd201} + ({22'b0, y} * 640); comp_flag_[201] <= 1'b1; end
				// else if ( inter_select[202] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd202} + ({22'b0, y} * 640); comp_flag_[202] <= 1'b1; end
				// else if ( inter_select[203] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd203} + ({22'b0, y} * 640); comp_flag_[203] <= 1'b1; end
				// else if ( inter_select[204] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd204} + ({22'b0, y} * 640); comp_flag_[204] <= 1'b1; end
				// else if ( inter_select[205] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd205} + ({22'b0, y} * 640); comp_flag_[205] <= 1'b1; end
				// else if ( inter_select[206] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd206} + ({22'b0, y} * 640); comp_flag_[206] <= 1'b1; end
				// else if ( inter_select[207] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd207} + ({22'b0, y} * 640); comp_flag_[207] <= 1'b1; end
				// else if ( inter_select[208] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd208} + ({22'b0, y} * 640); comp_flag_[208] <= 1'b1; end
				// else if ( inter_select[209] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd209} + ({22'b0, y} * 640); comp_flag_[209] <= 1'b1; end
				// else if ( inter_select[210] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd210} + ({22'b0, y} * 640); comp_flag_[210] <= 1'b1; end
				// else if ( inter_select[211] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd211} + ({22'b0, y} * 640); comp_flag_[211] <= 1'b1; end
				// else if ( inter_select[212] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd212} + ({22'b0, y} * 640); comp_flag_[212] <= 1'b1; end
				// else if ( inter_select[213] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd213} + ({22'b0, y} * 640); comp_flag_[213] <= 1'b1; end
				// else if ( inter_select[214] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd214} + ({22'b0, y} * 640); comp_flag_[214] <= 1'b1; end
				// else if ( inter_select[215] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd215} + ({22'b0, y} * 640); comp_flag_[215] <= 1'b1; end
				// else if ( inter_select[216] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd216} + ({22'b0, y} * 640); comp_flag_[216] <= 1'b1; end
				// else if ( inter_select[217] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd217} + ({22'b0, y} * 640); comp_flag_[217] <= 1'b1; end
				// else if ( inter_select[218] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd218} + ({22'b0, y} * 640); comp_flag_[218] <= 1'b1; end
				// else if ( inter_select[219] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd219} + ({22'b0, y} * 640); comp_flag_[219] <= 1'b1; end
				// else if ( inter_select[220] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd220} + ({22'b0, y} * 640); comp_flag_[220] <= 1'b1; end
				// else if ( inter_select[221] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd221} + ({22'b0, y} * 640); comp_flag_[221] <= 1'b1; end
				// else if ( inter_select[222] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd222} + ({22'b0, y} * 640); comp_flag_[222] <= 1'b1; end
				// else if ( inter_select[223] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd223} + ({22'b0, y} * 640); comp_flag_[223] <= 1'b1; end
				// else if ( inter_select[224] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd224} + ({22'b0, y} * 640); comp_flag_[224] <= 1'b1; end
				// else if ( inter_select[225] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd225} + ({22'b0, y} * 640); comp_flag_[225] <= 1'b1; end
				// else if ( inter_select[226] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd226} + ({22'b0, y} * 640); comp_flag_[226] <= 1'b1; end
				// else if ( inter_select[227] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd227} + ({22'b0, y} * 640); comp_flag_[227] <= 1'b1; end
				// else if ( inter_select[228] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd228} + ({22'b0, y} * 640); comp_flag_[228] <= 1'b1; end
				// else if ( inter_select[229] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd229} + ({22'b0, y} * 640); comp_flag_[229] <= 1'b1; end
				// else if ( inter_select[230] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd230} + ({22'b0, y} * 640); comp_flag_[230] <= 1'b1; end
				// else if ( inter_select[231] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd231} + ({22'b0, y} * 640); comp_flag_[231] <= 1'b1; end
				// else if ( inter_select[232] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd232} + ({22'b0, y} * 640); comp_flag_[232] <= 1'b1; end
				// else if ( inter_select[233] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd233} + ({22'b0, y} * 640); comp_flag_[233] <= 1'b1; end
				// else if ( inter_select[234] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd234} + ({22'b0, y} * 640); comp_flag_[234] <= 1'b1; end
				// else if ( inter_select[235] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd235} + ({22'b0, y} * 640); comp_flag_[235] <= 1'b1; end
				// else if ( inter_select[236] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd236} + ({22'b0, y} * 640); comp_flag_[236] <= 1'b1; end
				// else if ( inter_select[237] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd237} + ({22'b0, y} * 640); comp_flag_[237] <= 1'b1; end
				// else if ( inter_select[238] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd238} + ({22'b0, y} * 640); comp_flag_[238] <= 1'b1; end
				// else if ( inter_select[239] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd239} + ({22'b0, y} * 640); comp_flag_[239] <= 1'b1; end
				// else if ( inter_select[240] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd240} + ({22'b0, y} * 640); comp_flag_[240] <= 1'b1; end
				// else if ( inter_select[241] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd241} + ({22'b0, y} * 640); comp_flag_[241] <= 1'b1; end
				// else if ( inter_select[242] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd242} + ({22'b0, y} * 640); comp_flag_[242] <= 1'b1; end
				// else if ( inter_select[243] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd243} + ({22'b0, y} * 640); comp_flag_[243] <= 1'b1; end
				// else if ( inter_select[244] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd244} + ({22'b0, y} * 640); comp_flag_[244] <= 1'b1; end
				// else if ( inter_select[245] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd245} + ({22'b0, y} * 640); comp_flag_[245] <= 1'b1; end
				// else if ( inter_select[246] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd246} + ({22'b0, y} * 640); comp_flag_[246] <= 1'b1; end
				// else if ( inter_select[247] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd247} + ({22'b0, y} * 640); comp_flag_[247] <= 1'b1; end
				// else if ( inter_select[248] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd248} + ({22'b0, y} * 640); comp_flag_[248] <= 1'b1; end
				// else if ( inter_select[249] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd249} + ({22'b0, y} * 640); comp_flag_[249] <= 1'b1; end
				// else if ( inter_select[250] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd250} + ({22'b0, y} * 640); comp_flag_[250] <= 1'b1; end
				// else if ( inter_select[251] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd251} + ({22'b0, y} * 640); comp_flag_[251] <= 1'b1; end
				// else if ( inter_select[252] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd252} + ({22'b0, y} * 640); comp_flag_[252] <= 1'b1; end
				// else if ( inter_select[253] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd253} + ({22'b0, y} * 640); comp_flag_[253] <= 1'b1; end
				// else if ( inter_select[254] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd254} + ({22'b0, y} * 640); comp_flag_[254] <= 1'b1; end
				// else if ( inter_select[255] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd255} + ({22'b0, y} * 640); comp_flag_[255] <= 1'b1; end
				// else if ( inter_select[256] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd256} + ({22'b0, y} * 640); comp_flag_[256] <= 1'b1; end
				// else if ( inter_select[257] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd257} + ({22'b0, y} * 640); comp_flag_[257] <= 1'b1; end
				// else if ( inter_select[258] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd258} + ({22'b0, y} * 640); comp_flag_[258] <= 1'b1; end
				// else if ( inter_select[259] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd259} + ({22'b0, y} * 640); comp_flag_[259] <= 1'b1; end
				// else if ( inter_select[260] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd260} + ({22'b0, y} * 640); comp_flag_[260] <= 1'b1; end
				// else if ( inter_select[261] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd261} + ({22'b0, y} * 640); comp_flag_[261] <= 1'b1; end
				// else if ( inter_select[262] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd262} + ({22'b0, y} * 640); comp_flag_[262] <= 1'b1; end
				// else if ( inter_select[263] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd263} + ({22'b0, y} * 640); comp_flag_[263] <= 1'b1; end
				// else if ( inter_select[264] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd264} + ({22'b0, y} * 640); comp_flag_[264] <= 1'b1; end
				// else if ( inter_select[265] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd265} + ({22'b0, y} * 640); comp_flag_[265] <= 1'b1; end
				// else if ( inter_select[266] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd266} + ({22'b0, y} * 640); comp_flag_[266] <= 1'b1; end
				// else if ( inter_select[267] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd267} + ({22'b0, y} * 640); comp_flag_[267] <= 1'b1; end
				// else if ( inter_select[268] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd268} + ({22'b0, y} * 640); comp_flag_[268] <= 1'b1; end
				// else if ( inter_select[269] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd269} + ({22'b0, y} * 640); comp_flag_[269] <= 1'b1; end
				// else if ( inter_select[270] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd270} + ({22'b0, y} * 640); comp_flag_[270] <= 1'b1; end
				// else if ( inter_select[271] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd271} + ({22'b0, y} * 640); comp_flag_[271] <= 1'b1; end
				// else if ( inter_select[272] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd272} + ({22'b0, y} * 640); comp_flag_[272] <= 1'b1; end
				// else if ( inter_select[273] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd273} + ({22'b0, y} * 640); comp_flag_[273] <= 1'b1; end
				// else if ( inter_select[274] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd274} + ({22'b0, y} * 640); comp_flag_[274] <= 1'b1; end
				// else if ( inter_select[275] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd275} + ({22'b0, y} * 640); comp_flag_[275] <= 1'b1; end
				// else if ( inter_select[276] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd276} + ({22'b0, y} * 640); comp_flag_[276] <= 1'b1; end
				// else if ( inter_select[277] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd277} + ({22'b0, y} * 640); comp_flag_[277] <= 1'b1; end
				// else if ( inter_select[278] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd278} + ({22'b0, y} * 640); comp_flag_[278] <= 1'b1; end
				// else if ( inter_select[279] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd279} + ({22'b0, y} * 640); comp_flag_[279] <= 1'b1; end
				// else if ( inter_select[280] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd280} + ({22'b0, y} * 640); comp_flag_[280] <= 1'b1; end
				// else if ( inter_select[281] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd281} + ({22'b0, y} * 640); comp_flag_[281] <= 1'b1; end
				// else if ( inter_select[282] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd282} + ({22'b0, y} * 640); comp_flag_[282] <= 1'b1; end
				// else if ( inter_select[283] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd283} + ({22'b0, y} * 640); comp_flag_[283] <= 1'b1; end
				// else if ( inter_select[284] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd284} + ({22'b0, y} * 640); comp_flag_[284] <= 1'b1; end
				// else if ( inter_select[285] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd285} + ({22'b0, y} * 640); comp_flag_[285] <= 1'b1; end
				// else if ( inter_select[286] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd286} + ({22'b0, y} * 640); comp_flag_[286] <= 1'b1; end
				// else if ( inter_select[287] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd287} + ({22'b0, y} * 640); comp_flag_[287] <= 1'b1; end
				// else if ( inter_select[288] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd288} + ({22'b0, y} * 640); comp_flag_[288] <= 1'b1; end
				// else if ( inter_select[289] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd289} + ({22'b0, y} * 640); comp_flag_[289] <= 1'b1; end
				// else if ( inter_select[290] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd290} + ({22'b0, y} * 640); comp_flag_[290] <= 1'b1; end
				// else if ( inter_select[291] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd291} + ({22'b0, y} * 640); comp_flag_[291] <= 1'b1; end
				// else if ( inter_select[292] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd292} + ({22'b0, y} * 640); comp_flag_[292] <= 1'b1; end
				// else if ( inter_select[293] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd293} + ({22'b0, y} * 640); comp_flag_[293] <= 1'b1; end
				// else if ( inter_select[294] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd294} + ({22'b0, y} * 640); comp_flag_[294] <= 1'b1; end
				// else if ( inter_select[295] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd295} + ({22'b0, y} * 640); comp_flag_[295] <= 1'b1; end
				// else if ( inter_select[296] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd296} + ({22'b0, y} * 640); comp_flag_[296] <= 1'b1; end
				// else if ( inter_select[297] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd297} + ({22'b0, y} * 640); comp_flag_[297] <= 1'b1; end
				// else if ( inter_select[298] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd298} + ({22'b0, y} * 640); comp_flag_[298] <= 1'b1; end
				// else if ( inter_select[299] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd299} + ({22'b0, y} * 640); comp_flag_[299] <= 1'b1; end
				// else if ( inter_select[300] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd300} + ({22'b0, y} * 640); comp_flag_[300] <= 1'b1; end
				// else if ( inter_select[301] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd301} + ({22'b0, y} * 640); comp_flag_[301] <= 1'b1; end
				// else if ( inter_select[302] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd302} + ({22'b0, y} * 640); comp_flag_[302] <= 1'b1; end
				// else if ( inter_select[303] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd303} + ({22'b0, y} * 640); comp_flag_[303] <= 1'b1; end
				// else if ( inter_select[304] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd304} + ({22'b0, y} * 640); comp_flag_[304] <= 1'b1; end
				// else if ( inter_select[305] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd305} + ({22'b0, y} * 640); comp_flag_[305] <= 1'b1; end
				// else if ( inter_select[306] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd306} + ({22'b0, y} * 640); comp_flag_[306] <= 1'b1; end
				// else if ( inter_select[307] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd307} + ({22'b0, y} * 640); comp_flag_[307] <= 1'b1; end
				// else if ( inter_select[308] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd308} + ({22'b0, y} * 640); comp_flag_[308] <= 1'b1; end
				// else if ( inter_select[309] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd309} + ({22'b0, y} * 640); comp_flag_[309] <= 1'b1; end
				// else if ( inter_select[310] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd310} + ({22'b0, y} * 640); comp_flag_[310] <= 1'b1; end
				// else if ( inter_select[311] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd311} + ({22'b0, y} * 640); comp_flag_[311] <= 1'b1; end
				// else if ( inter_select[312] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd312} + ({22'b0, y} * 640); comp_flag_[312] <= 1'b1; end
				// else if ( inter_select[313] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd313} + ({22'b0, y} * 640); comp_flag_[313] <= 1'b1; end
				// else if ( inter_select[314] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd314} + ({22'b0, y} * 640); comp_flag_[314] <= 1'b1; end
				// else if ( inter_select[315] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd315} + ({22'b0, y} * 640); comp_flag_[315] <= 1'b1; end
				// else if ( inter_select[316] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd316} + ({22'b0, y} * 640); comp_flag_[316] <= 1'b1; end
				// else if ( inter_select[317] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd317} + ({22'b0, y} * 640); comp_flag_[317] <= 1'b1; end
				// else if ( inter_select[318] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd318} + ({22'b0, y} * 640); comp_flag_[318] <= 1'b1; end
				// else if ( inter_select[319] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd319} + ({22'b0, y} * 640); comp_flag_[319] <= 1'b1; end
				// else if ( inter_select[320] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd320} + ({22'b0, y} * 640); comp_flag_[320] <= 1'b1; end
				// else if ( inter_select[321] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd321} + ({22'b0, y} * 640); comp_flag_[321] <= 1'b1; end
				// else if ( inter_select[322] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd322} + ({22'b0, y} * 640); comp_flag_[322] <= 1'b1; end
				// else if ( inter_select[323] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd323} + ({22'b0, y} * 640); comp_flag_[323] <= 1'b1; end
				// else if ( inter_select[324] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd324} + ({22'b0, y} * 640); comp_flag_[324] <= 1'b1; end
				// else if ( inter_select[325] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd325} + ({22'b0, y} * 640); comp_flag_[325] <= 1'b1; end
				// else if ( inter_select[326] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd326} + ({22'b0, y} * 640); comp_flag_[326] <= 1'b1; end
				// else if ( inter_select[327] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd327} + ({22'b0, y} * 640); comp_flag_[327] <= 1'b1; end
				// else if ( inter_select[328] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd328} + ({22'b0, y} * 640); comp_flag_[328] <= 1'b1; end
				// else if ( inter_select[329] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd329} + ({22'b0, y} * 640); comp_flag_[329] <= 1'b1; end
				// else if ( inter_select[330] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd330} + ({22'b0, y} * 640); comp_flag_[330] <= 1'b1; end
				// else if ( inter_select[331] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd331} + ({22'b0, y} * 640); comp_flag_[331] <= 1'b1; end
				// else if ( inter_select[332] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd332} + ({22'b0, y} * 640); comp_flag_[332] <= 1'b1; end
				// else if ( inter_select[333] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd333} + ({22'b0, y} * 640); comp_flag_[333] <= 1'b1; end
				// else if ( inter_select[334] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd334} + ({22'b0, y} * 640); comp_flag_[334] <= 1'b1; end
				// else if ( inter_select[335] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd335} + ({22'b0, y} * 640); comp_flag_[335] <= 1'b1; end
				// else if ( inter_select[336] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd336} + ({22'b0, y} * 640); comp_flag_[336] <= 1'b1; end
				// else if ( inter_select[337] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd337} + ({22'b0, y} * 640); comp_flag_[337] <= 1'b1; end
				// else if ( inter_select[338] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd338} + ({22'b0, y} * 640); comp_flag_[338] <= 1'b1; end
				// else if ( inter_select[339] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd339} + ({22'b0, y} * 640); comp_flag_[339] <= 1'b1; end
				// else if ( inter_select[340] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd340} + ({22'b0, y} * 640); comp_flag_[340] <= 1'b1; end
				// else if ( inter_select[341] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd341} + ({22'b0, y} * 640); comp_flag_[341] <= 1'b1; end
				// else if ( inter_select[342] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd342} + ({22'b0, y} * 640); comp_flag_[342] <= 1'b1; end
				// else if ( inter_select[343] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd343} + ({22'b0, y} * 640); comp_flag_[343] <= 1'b1; end
				// else if ( inter_select[344] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd344} + ({22'b0, y} * 640); comp_flag_[344] <= 1'b1; end
				// else if ( inter_select[345] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd345} + ({22'b0, y} * 640); comp_flag_[345] <= 1'b1; end
				// else if ( inter_select[346] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd346} + ({22'b0, y} * 640); comp_flag_[346] <= 1'b1; end
				// else if ( inter_select[347] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd347} + ({22'b0, y} * 640); comp_flag_[347] <= 1'b1; end
				// else if ( inter_select[348] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd348} + ({22'b0, y} * 640); comp_flag_[348] <= 1'b1; end
				// else if ( inter_select[349] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd349} + ({22'b0, y} * 640); comp_flag_[349] <= 1'b1; end
				// else if ( inter_select[350] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd350} + ({22'b0, y} * 640); comp_flag_[350] <= 1'b1; end
				// else if ( inter_select[351] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd351} + ({22'b0, y} * 640); comp_flag_[351] <= 1'b1; end
				// else if ( inter_select[352] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd352} + ({22'b0, y} * 640); comp_flag_[352] <= 1'b1; end
				// else if ( inter_select[353] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd353} + ({22'b0, y} * 640); comp_flag_[353] <= 1'b1; end
				// else if ( inter_select[354] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd354} + ({22'b0, y} * 640); comp_flag_[354] <= 1'b1; end
				// else if ( inter_select[355] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd355} + ({22'b0, y} * 640); comp_flag_[355] <= 1'b1; end
				// else if ( inter_select[356] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd356} + ({22'b0, y} * 640); comp_flag_[356] <= 1'b1; end
				// else if ( inter_select[357] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd357} + ({22'b0, y} * 640); comp_flag_[357] <= 1'b1; end
				// else if ( inter_select[358] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd358} + ({22'b0, y} * 640); comp_flag_[358] <= 1'b1; end
				// else if ( inter_select[359] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd359} + ({22'b0, y} * 640); comp_flag_[359] <= 1'b1; end
				// else if ( inter_select[360] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd360} + ({22'b0, y} * 640); comp_flag_[360] <= 1'b1; end
				// else if ( inter_select[361] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd361} + ({22'b0, y} * 640); comp_flag_[361] <= 1'b1; end
				// else if ( inter_select[362] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd362} + ({22'b0, y} * 640); comp_flag_[362] <= 1'b1; end
				// else if ( inter_select[363] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd363} + ({22'b0, y} * 640); comp_flag_[363] <= 1'b1; end
				// else if ( inter_select[364] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd364} + ({22'b0, y} * 640); comp_flag_[364] <= 1'b1; end
				// else if ( inter_select[365] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd365} + ({22'b0, y} * 640); comp_flag_[365] <= 1'b1; end
				// else if ( inter_select[366] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd366} + ({22'b0, y} * 640); comp_flag_[366] <= 1'b1; end
				// else if ( inter_select[367] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd367} + ({22'b0, y} * 640); comp_flag_[367] <= 1'b1; end
				// else if ( inter_select[368] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd368} + ({22'b0, y} * 640); comp_flag_[368] <= 1'b1; end
				// else if ( inter_select[369] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd369} + ({22'b0, y} * 640); comp_flag_[369] <= 1'b1; end
				// else if ( inter_select[370] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd370} + ({22'b0, y} * 640); comp_flag_[370] <= 1'b1; end
				// else if ( inter_select[371] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd371} + ({22'b0, y} * 640); comp_flag_[371] <= 1'b1; end
				// else if ( inter_select[372] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd372} + ({22'b0, y} * 640); comp_flag_[372] <= 1'b1; end
				// else if ( inter_select[373] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd373} + ({22'b0, y} * 640); comp_flag_[373] <= 1'b1; end
				// else if ( inter_select[374] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd374} + ({22'b0, y} * 640); comp_flag_[374] <= 1'b1; end
				// else if ( inter_select[375] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd375} + ({22'b0, y} * 640); comp_flag_[375] <= 1'b1; end
				// else if ( inter_select[376] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd376} + ({22'b0, y} * 640); comp_flag_[376] <= 1'b1; end
				// else if ( inter_select[377] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd377} + ({22'b0, y} * 640); comp_flag_[377] <= 1'b1; end
				// else if ( inter_select[378] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd378} + ({22'b0, y} * 640); comp_flag_[378] <= 1'b1; end
				// else if ( inter_select[379] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd379} + ({22'b0, y} * 640); comp_flag_[379] <= 1'b1; end
				// else if ( inter_select[380] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd380} + ({22'b0, y} * 640); comp_flag_[380] <= 1'b1; end
				// else if ( inter_select[381] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd381} + ({22'b0, y} * 640); comp_flag_[381] <= 1'b1; end
				// else if ( inter_select[382] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd382} + ({22'b0, y} * 640); comp_flag_[382] <= 1'b1; end
				// else if ( inter_select[383] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd383} + ({22'b0, y} * 640); comp_flag_[383] <= 1'b1; end
				// else if ( inter_select[384] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd384} + ({22'b0, y} * 640); comp_flag_[384] <= 1'b1; end
				// else if ( inter_select[385] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd385} + ({22'b0, y} * 640); comp_flag_[385] <= 1'b1; end
				// else if ( inter_select[386] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd386} + ({22'b0, y} * 640); comp_flag_[386] <= 1'b1; end
				// else if ( inter_select[387] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd387} + ({22'b0, y} * 640); comp_flag_[387] <= 1'b1; end
				// else if ( inter_select[388] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd388} + ({22'b0, y} * 640); comp_flag_[388] <= 1'b1; end
				// else if ( inter_select[389] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd389} + ({22'b0, y} * 640); comp_flag_[389] <= 1'b1; end
				// else if ( inter_select[390] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd390} + ({22'b0, y} * 640); comp_flag_[390] <= 1'b1; end
				// else if ( inter_select[391] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd391} + ({22'b0, y} * 640); comp_flag_[391] <= 1'b1; end
				// else if ( inter_select[392] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd392} + ({22'b0, y} * 640); comp_flag_[392] <= 1'b1; end
				// else if ( inter_select[393] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd393} + ({22'b0, y} * 640); comp_flag_[393] <= 1'b1; end
				// else if ( inter_select[394] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd394} + ({22'b0, y} * 640); comp_flag_[394] <= 1'b1; end
				// else if ( inter_select[395] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd395} + ({22'b0, y} * 640); comp_flag_[395] <= 1'b1; end
				// else if ( inter_select[396] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd396} + ({22'b0, y} * 640); comp_flag_[396] <= 1'b1; end
				// else if ( inter_select[397] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd397} + ({22'b0, y} * 640); comp_flag_[397] <= 1'b1; end
				// else if ( inter_select[398] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd398} + ({22'b0, y} * 640); comp_flag_[398] <= 1'b1; end
				// else if ( inter_select[399] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd399} + ({22'b0, y} * 640); comp_flag_[399] <= 1'b1; end
				// else if ( inter_select[400] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd400} + ({22'b0, y} * 640); comp_flag_[400] <= 1'b1; end
				// else if ( inter_select[401] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd401} + ({22'b0, y} * 640); comp_flag_[401] <= 1'b1; end
				// else if ( inter_select[402] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd402} + ({22'b0, y} * 640); comp_flag_[402] <= 1'b1; end
				// else if ( inter_select[403] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd403} + ({22'b0, y} * 640); comp_flag_[403] <= 1'b1; end
				// else if ( inter_select[404] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd404} + ({22'b0, y} * 640); comp_flag_[404] <= 1'b1; end
				// else if ( inter_select[405] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd405} + ({22'b0, y} * 640); comp_flag_[405] <= 1'b1; end
				// else if ( inter_select[406] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd406} + ({22'b0, y} * 640); comp_flag_[406] <= 1'b1; end
				// else if ( inter_select[407] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd407} + ({22'b0, y} * 640); comp_flag_[407] <= 1'b1; end
				// else if ( inter_select[408] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd408} + ({22'b0, y} * 640); comp_flag_[408] <= 1'b1; end
				// else if ( inter_select[409] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd409} + ({22'b0, y} * 640); comp_flag_[409] <= 1'b1; end
				// else if ( inter_select[410] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd410} + ({22'b0, y} * 640); comp_flag_[410] <= 1'b1; end
				// else if ( inter_select[411] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd411} + ({22'b0, y} * 640); comp_flag_[411] <= 1'b1; end
				// else if ( inter_select[412] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd412} + ({22'b0, y} * 640); comp_flag_[412] <= 1'b1; end
				// else if ( inter_select[413] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd413} + ({22'b0, y} * 640); comp_flag_[413] <= 1'b1; end
				// else if ( inter_select[414] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd414} + ({22'b0, y} * 640); comp_flag_[414] <= 1'b1; end
				// else if ( inter_select[415] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd415} + ({22'b0, y} * 640); comp_flag_[415] <= 1'b1; end
				// else if ( inter_select[416] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd416} + ({22'b0, y} * 640); comp_flag_[416] <= 1'b1; end
				// else if ( inter_select[417] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd417} + ({22'b0, y} * 640); comp_flag_[417] <= 1'b1; end
				// else if ( inter_select[418] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd418} + ({22'b0, y} * 640); comp_flag_[418] <= 1'b1; end
				// else if ( inter_select[419] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd419} + ({22'b0, y} * 640); comp_flag_[419] <= 1'b1; end
				// else if ( inter_select[420] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd420} + ({22'b0, y} * 640); comp_flag_[420] <= 1'b1; end
				// else if ( inter_select[421] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd421} + ({22'b0, y} * 640); comp_flag_[421] <= 1'b1; end
				// else if ( inter_select[422] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd422} + ({22'b0, y} * 640); comp_flag_[422] <= 1'b1; end
				// else if ( inter_select[423] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd423} + ({22'b0, y} * 640); comp_flag_[423] <= 1'b1; end
				// else if ( inter_select[424] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd424} + ({22'b0, y} * 640); comp_flag_[424] <= 1'b1; end
				// else if ( inter_select[425] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd425} + ({22'b0, y} * 640); comp_flag_[425] <= 1'b1; end
				// else if ( inter_select[426] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd426} + ({22'b0, y} * 640); comp_flag_[426] <= 1'b1; end
				// else if ( inter_select[427] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd427} + ({22'b0, y} * 640); comp_flag_[427] <= 1'b1; end
				// else if ( inter_select[428] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd428} + ({22'b0, y} * 640); comp_flag_[428] <= 1'b1; end
				// else if ( inter_select[429] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd429} + ({22'b0, y} * 640); comp_flag_[429] <= 1'b1; end
				// else if ( inter_select[430] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd430} + ({22'b0, y} * 640); comp_flag_[430] <= 1'b1; end
				// else if ( inter_select[431] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd431} + ({22'b0, y} * 640); comp_flag_[431] <= 1'b1; end
				// else if ( inter_select[432] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd432} + ({22'b0, y} * 640); comp_flag_[432] <= 1'b1; end
				// else if ( inter_select[433] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd433} + ({22'b0, y} * 640); comp_flag_[433] <= 1'b1; end
				// else if ( inter_select[434] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd434} + ({22'b0, y} * 640); comp_flag_[434] <= 1'b1; end
				// else if ( inter_select[435] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd435} + ({22'b0, y} * 640); comp_flag_[435] <= 1'b1; end
				// else if ( inter_select[436] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd436} + ({22'b0, y} * 640); comp_flag_[436] <= 1'b1; end
				// else if ( inter_select[437] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd437} + ({22'b0, y} * 640); comp_flag_[437] <= 1'b1; end
				// else if ( inter_select[438] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd438} + ({22'b0, y} * 640); comp_flag_[438] <= 1'b1; end
				// else if ( inter_select[439] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd439} + ({22'b0, y} * 640); comp_flag_[439] <= 1'b1; end
				// else if ( inter_select[440] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd440} + ({22'b0, y} * 640); comp_flag_[440] <= 1'b1; end
				// else if ( inter_select[441] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd441} + ({22'b0, y} * 640); comp_flag_[441] <= 1'b1; end
				// else if ( inter_select[442] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd442} + ({22'b0, y} * 640); comp_flag_[442] <= 1'b1; end
				// else if ( inter_select[443] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd443} + ({22'b0, y} * 640); comp_flag_[443] <= 1'b1; end
				// else if ( inter_select[444] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd444} + ({22'b0, y} * 640); comp_flag_[444] <= 1'b1; end
				// else if ( inter_select[445] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd445} + ({22'b0, y} * 640); comp_flag_[445] <= 1'b1; end
				// else if ( inter_select[446] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd446} + ({22'b0, y} * 640); comp_flag_[446] <= 1'b1; end
				// else if ( inter_select[447] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd447} + ({22'b0, y} * 640); comp_flag_[447] <= 1'b1; end
				// else if ( inter_select[448] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd448} + ({22'b0, y} * 640); comp_flag_[448] <= 1'b1; end
				// else if ( inter_select[449] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd449} + ({22'b0, y} * 640); comp_flag_[449] <= 1'b1; end
				// else if ( inter_select[450] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd450} + ({22'b0, y} * 640); comp_flag_[450] <= 1'b1; end
				// else if ( inter_select[451] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd451} + ({22'b0, y} * 640); comp_flag_[451] <= 1'b1; end
				// else if ( inter_select[452] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd452} + ({22'b0, y} * 640); comp_flag_[452] <= 1'b1; end
				// else if ( inter_select[453] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd453} + ({22'b0, y} * 640); comp_flag_[453] <= 1'b1; end
				// else if ( inter_select[454] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd454} + ({22'b0, y} * 640); comp_flag_[454] <= 1'b1; end
				// else if ( inter_select[455] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd455} + ({22'b0, y} * 640); comp_flag_[455] <= 1'b1; end
				// else if ( inter_select[456] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd456} + ({22'b0, y} * 640); comp_flag_[456] <= 1'b1; end
				// else if ( inter_select[457] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd457} + ({22'b0, y} * 640); comp_flag_[457] <= 1'b1; end
				// else if ( inter_select[458] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd458} + ({22'b0, y} * 640); comp_flag_[458] <= 1'b1; end
				// else if ( inter_select[459] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd459} + ({22'b0, y} * 640); comp_flag_[459] <= 1'b1; end
				// else if ( inter_select[460] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd460} + ({22'b0, y} * 640); comp_flag_[460] <= 1'b1; end
				// else if ( inter_select[461] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd461} + ({22'b0, y} * 640); comp_flag_[461] <= 1'b1; end
				// else if ( inter_select[462] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd462} + ({22'b0, y} * 640); comp_flag_[462] <= 1'b1; end
				// else if ( inter_select[463] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd463} + ({22'b0, y} * 640); comp_flag_[463] <= 1'b1; end
				// else if ( inter_select[464] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd464} + ({22'b0, y} * 640); comp_flag_[464] <= 1'b1; end
				// else if ( inter_select[465] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd465} + ({22'b0, y} * 640); comp_flag_[465] <= 1'b1; end
				// else if ( inter_select[466] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd466} + ({22'b0, y} * 640); comp_flag_[466] <= 1'b1; end
				// else if ( inter_select[467] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd467} + ({22'b0, y} * 640); comp_flag_[467] <= 1'b1; end
				// else if ( inter_select[468] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd468} + ({22'b0, y} * 640); comp_flag_[468] <= 1'b1; end
				// else if ( inter_select[469] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd469} + ({22'b0, y} * 640); comp_flag_[469] <= 1'b1; end
				// else if ( inter_select[470] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd470} + ({22'b0, y} * 640); comp_flag_[470] <= 1'b1; end
				// else if ( inter_select[471] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd471} + ({22'b0, y} * 640); comp_flag_[471] <= 1'b1; end
				// else if ( inter_select[472] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd472} + ({22'b0, y} * 640); comp_flag_[472] <= 1'b1; end
				// else if ( inter_select[473] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd473} + ({22'b0, y} * 640); comp_flag_[473] <= 1'b1; end
				// else if ( inter_select[474] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd474} + ({22'b0, y} * 640); comp_flag_[474] <= 1'b1; end
				// else if ( inter_select[475] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd475} + ({22'b0, y} * 640); comp_flag_[475] <= 1'b1; end
				// else if ( inter_select[476] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd476} + ({22'b0, y} * 640); comp_flag_[476] <= 1'b1; end
				// else if ( inter_select[477] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd477} + ({22'b0, y} * 640); comp_flag_[477] <= 1'b1; end
				// else if ( inter_select[478] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd478} + ({22'b0, y} * 640); comp_flag_[478] <= 1'b1; end
				// else if ( inter_select[479] == 1'b1 ) begin vga_sram_address_ <= {22'b0, 10'd479} + ({22'b0, y} * 640); comp_flag_[479] <= 1'b1; end

				vga_sram_writedata_ <= vga_pxl_clr;
				vga_sram_write_ 	<= 1'b1;
				state_arbr			<= 3'd4;			// move to state 3 to remove updated flag
			end
			else begin 
				state_arbr <= 3'd3;
			end
		end

		// ===== STATE 4 =====
		else if ( state_arbr == 3'd4 ) begin
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
			else if ( comp_flag_[64] == 1'd1 ) comp_flag_[64] <= 1'b0;
			else if ( comp_flag_[65] == 1'd1 ) comp_flag_[65] <= 1'b0;
			else if ( comp_flag_[66] == 1'd1 ) comp_flag_[66] <= 1'b0;
			else if ( comp_flag_[67] == 1'd1 ) comp_flag_[67] <= 1'b0;
			else if ( comp_flag_[68] == 1'd1 ) comp_flag_[68] <= 1'b0;
			else if ( comp_flag_[69] == 1'd1 ) comp_flag_[69] <= 1'b0;
			else if ( comp_flag_[70] == 1'd1 ) comp_flag_[70] <= 1'b0;
			else if ( comp_flag_[71] == 1'd1 ) comp_flag_[71] <= 1'b0;
			else if ( comp_flag_[72] == 1'd1 ) comp_flag_[72] <= 1'b0;
			else if ( comp_flag_[73] == 1'd1 ) comp_flag_[73] <= 1'b0;
			else if ( comp_flag_[74] == 1'd1 ) comp_flag_[74] <= 1'b0;
			else if ( comp_flag_[75] == 1'd1 ) comp_flag_[75] <= 1'b0;
			else if ( comp_flag_[76] == 1'd1 ) comp_flag_[76] <= 1'b0;
			else if ( comp_flag_[77] == 1'd1 ) comp_flag_[77] <= 1'b0;
			else if ( comp_flag_[78] == 1'd1 ) comp_flag_[78] <= 1'b0;
			else if ( comp_flag_[79] == 1'd1 ) comp_flag_[79] <= 1'b0;
			else if ( comp_flag_[80] == 1'd1 ) comp_flag_[80] <= 1'b0;
			else if ( comp_flag_[81] == 1'd1 ) comp_flag_[81] <= 1'b0;
			else if ( comp_flag_[82] == 1'd1 ) comp_flag_[82] <= 1'b0;
			else if ( comp_flag_[83] == 1'd1 ) comp_flag_[83] <= 1'b0;
			else if ( comp_flag_[84] == 1'd1 ) comp_flag_[84] <= 1'b0;
			else if ( comp_flag_[85] == 1'd1 ) comp_flag_[85] <= 1'b0;
			else if ( comp_flag_[86] == 1'd1 ) comp_flag_[86] <= 1'b0;
			else if ( comp_flag_[87] == 1'd1 ) comp_flag_[87] <= 1'b0;
			else if ( comp_flag_[88] == 1'd1 ) comp_flag_[88] <= 1'b0;
			else if ( comp_flag_[89] == 1'd1 ) comp_flag_[89] <= 1'b0;
			else if ( comp_flag_[90] == 1'd1 ) comp_flag_[90] <= 1'b0;
			else if ( comp_flag_[91] == 1'd1 ) comp_flag_[91] <= 1'b0;
			else if ( comp_flag_[92] == 1'd1 ) comp_flag_[92] <= 1'b0;
			else if ( comp_flag_[93] == 1'd1 ) comp_flag_[93] <= 1'b0;
			else if ( comp_flag_[94] == 1'd1 ) comp_flag_[94] <= 1'b0;
			else if ( comp_flag_[95] == 1'd1 ) comp_flag_[95] <= 1'b0;
			else if ( comp_flag_[96] == 1'd1 ) comp_flag_[96] <= 1'b0;
			else if ( comp_flag_[97] == 1'd1 ) comp_flag_[97] <= 1'b0;
			else if ( comp_flag_[98] == 1'd1 ) comp_flag_[98] <= 1'b0;
			else if ( comp_flag_[99] == 1'd1 ) comp_flag_[99] <= 1'b0;
			else if ( comp_flag_[100] == 1'd1 ) comp_flag_[100] <= 1'b0;
			// else if ( comp_flag_[101] == 1'd1 ) comp_flag_[101] <= 1'b0;
			// else if ( comp_flag_[102] == 1'd1 ) comp_flag_[102] <= 1'b0;
			// else if ( comp_flag_[103] == 1'd1 ) comp_flag_[103] <= 1'b0;
			// else if ( comp_flag_[104] == 1'd1 ) comp_flag_[104] <= 1'b0;
			// else if ( comp_flag_[105] == 1'd1 ) comp_flag_[105] <= 1'b0;
			// else if ( comp_flag_[106] == 1'd1 ) comp_flag_[106] <= 1'b0;
			// else if ( comp_flag_[107] == 1'd1 ) comp_flag_[107] <= 1'b0;
			// else if ( comp_flag_[108] == 1'd1 ) comp_flag_[108] <= 1'b0;
			// else if ( comp_flag_[109] == 1'd1 ) comp_flag_[109] <= 1'b0;
			// else if ( comp_flag_[110] == 1'd1 ) comp_flag_[110] <= 1'b0;
			// else if ( comp_flag_[111] == 1'd1 ) comp_flag_[111] <= 1'b0;
			// else if ( comp_flag_[112] == 1'd1 ) comp_flag_[112] <= 1'b0;
			// else if ( comp_flag_[113] == 1'd1 ) comp_flag_[113] <= 1'b0;
			// else if ( comp_flag_[114] == 1'd1 ) comp_flag_[114] <= 1'b0;
			// else if ( comp_flag_[115] == 1'd1 ) comp_flag_[115] <= 1'b0;
			// else if ( comp_flag_[116] == 1'd1 ) comp_flag_[116] <= 1'b0;
			// else if ( comp_flag_[117] == 1'd1 ) comp_flag_[117] <= 1'b0;
			// else if ( comp_flag_[118] == 1'd1 ) comp_flag_[118] <= 1'b0;
			// else if ( comp_flag_[119] == 1'd1 ) comp_flag_[119] <= 1'b0;
			// else if ( comp_flag_[120] == 1'd1 ) comp_flag_[120] <= 1'b0;
			// else if ( comp_flag_[121] == 1'd1 ) comp_flag_[121] <= 1'b0;
			// else if ( comp_flag_[122] == 1'd1 ) comp_flag_[122] <= 1'b0;
			// else if ( comp_flag_[123] == 1'd1 ) comp_flag_[123] <= 1'b0;
			// else if ( comp_flag_[124] == 1'd1 ) comp_flag_[124] <= 1'b0;
			// else if ( comp_flag_[125] == 1'd1 ) comp_flag_[125] <= 1'b0;
			// else if ( comp_flag_[126] == 1'd1 ) comp_flag_[126] <= 1'b0;
			// else if ( comp_flag_[127] == 1'd1 ) comp_flag_[127] <= 1'b0;
			// else if ( comp_flag_[128] == 1'd1 ) comp_flag_[128] <= 1'b0;
			// else if ( comp_flag_[129] == 1'd1 ) comp_flag_[129] <= 1'b0;
			// else if ( comp_flag_[130] == 1'd1 ) comp_flag_[130] <= 1'b0;
			// else if ( comp_flag_[131] == 1'd1 ) comp_flag_[131] <= 1'b0;
			// else if ( comp_flag_[132] == 1'd1 ) comp_flag_[132] <= 1'b0;
			// else if ( comp_flag_[133] == 1'd1 ) comp_flag_[133] <= 1'b0;
			// else if ( comp_flag_[134] == 1'd1 ) comp_flag_[134] <= 1'b0;
			// else if ( comp_flag_[135] == 1'd1 ) comp_flag_[135] <= 1'b0;
			// else if ( comp_flag_[136] == 1'd1 ) comp_flag_[136] <= 1'b0;
			// else if ( comp_flag_[137] == 1'd1 ) comp_flag_[137] <= 1'b0;
			// else if ( comp_flag_[138] == 1'd1 ) comp_flag_[138] <= 1'b0;
			// else if ( comp_flag_[139] == 1'd1 ) comp_flag_[139] <= 1'b0;
			// else if ( comp_flag_[140] == 1'd1 ) comp_flag_[140] <= 1'b0;
			// else if ( comp_flag_[141] == 1'd1 ) comp_flag_[141] <= 1'b0;
			// else if ( comp_flag_[142] == 1'd1 ) comp_flag_[142] <= 1'b0;
			// else if ( comp_flag_[143] == 1'd1 ) comp_flag_[143] <= 1'b0;
			// else if ( comp_flag_[144] == 1'd1 ) comp_flag_[144] <= 1'b0;
			// else if ( comp_flag_[145] == 1'd1 ) comp_flag_[145] <= 1'b0;
			// else if ( comp_flag_[146] == 1'd1 ) comp_flag_[146] <= 1'b0;
			// else if ( comp_flag_[147] == 1'd1 ) comp_flag_[147] <= 1'b0;
			// else if ( comp_flag_[148] == 1'd1 ) comp_flag_[148] <= 1'b0;
			// else if ( comp_flag_[149] == 1'd1 ) comp_flag_[149] <= 1'b0;
			// else if ( comp_flag_[150] == 1'd1 ) comp_flag_[150] <= 1'b0;
			// else if ( comp_flag_[151] == 1'd1 ) comp_flag_[151] <= 1'b0;
			// else if ( comp_flag_[152] == 1'd1 ) comp_flag_[152] <= 1'b0;
			// else if ( comp_flag_[153] == 1'd1 ) comp_flag_[153] <= 1'b0;
			// else if ( comp_flag_[154] == 1'd1 ) comp_flag_[154] <= 1'b0;
			// else if ( comp_flag_[155] == 1'd1 ) comp_flag_[155] <= 1'b0;
			// else if ( comp_flag_[156] == 1'd1 ) comp_flag_[156] <= 1'b0;
			// else if ( comp_flag_[157] == 1'd1 ) comp_flag_[157] <= 1'b0;
			// else if ( comp_flag_[158] == 1'd1 ) comp_flag_[158] <= 1'b0;
			// else if ( comp_flag_[159] == 1'd1 ) comp_flag_[159] <= 1'b0;
			// else if ( comp_flag_[160] == 1'd1 ) comp_flag_[160] <= 1'b0;
			// else if ( comp_flag_[161] == 1'd1 ) comp_flag_[161] <= 1'b0;
			// else if ( comp_flag_[162] == 1'd1 ) comp_flag_[162] <= 1'b0;
			// else if ( comp_flag_[163] == 1'd1 ) comp_flag_[163] <= 1'b0;
			// else if ( comp_flag_[164] == 1'd1 ) comp_flag_[164] <= 1'b0;
			// else if ( comp_flag_[165] == 1'd1 ) comp_flag_[165] <= 1'b0;
			// else if ( comp_flag_[166] == 1'd1 ) comp_flag_[166] <= 1'b0;
			// else if ( comp_flag_[167] == 1'd1 ) comp_flag_[167] <= 1'b0;
			// else if ( comp_flag_[168] == 1'd1 ) comp_flag_[168] <= 1'b0;
			// else if ( comp_flag_[169] == 1'd1 ) comp_flag_[169] <= 1'b0;
			// else if ( comp_flag_[170] == 1'd1 ) comp_flag_[170] <= 1'b0;
			// else if ( comp_flag_[171] == 1'd1 ) comp_flag_[171] <= 1'b0;
			// else if ( comp_flag_[172] == 1'd1 ) comp_flag_[172] <= 1'b0;
			// else if ( comp_flag_[173] == 1'd1 ) comp_flag_[173] <= 1'b0;
			// else if ( comp_flag_[174] == 1'd1 ) comp_flag_[174] <= 1'b0;
			// else if ( comp_flag_[175] == 1'd1 ) comp_flag_[175] <= 1'b0;
			// else if ( comp_flag_[176] == 1'd1 ) comp_flag_[176] <= 1'b0;
			// else if ( comp_flag_[177] == 1'd1 ) comp_flag_[177] <= 1'b0;
			// else if ( comp_flag_[178] == 1'd1 ) comp_flag_[178] <= 1'b0;
			// else if ( comp_flag_[179] == 1'd1 ) comp_flag_[179] <= 1'b0;
			// else if ( comp_flag_[180] == 1'd1 ) comp_flag_[180] <= 1'b0;
			// else if ( comp_flag_[181] == 1'd1 ) comp_flag_[181] <= 1'b0;
			// else if ( comp_flag_[182] == 1'd1 ) comp_flag_[182] <= 1'b0;
			// else if ( comp_flag_[183] == 1'd1 ) comp_flag_[183] <= 1'b0;
			// else if ( comp_flag_[184] == 1'd1 ) comp_flag_[184] <= 1'b0;
			// else if ( comp_flag_[185] == 1'd1 ) comp_flag_[185] <= 1'b0;
			// else if ( comp_flag_[186] == 1'd1 ) comp_flag_[186] <= 1'b0;
			// else if ( comp_flag_[187] == 1'd1 ) comp_flag_[187] <= 1'b0;
			// else if ( comp_flag_[188] == 1'd1 ) comp_flag_[188] <= 1'b0;
			// else if ( comp_flag_[189] == 1'd1 ) comp_flag_[189] <= 1'b0;
			// else if ( comp_flag_[190] == 1'd1 ) comp_flag_[190] <= 1'b0;
			// else if ( comp_flag_[191] == 1'd1 ) comp_flag_[191] <= 1'b0;
			// else if ( comp_flag_[192] == 1'd1 ) comp_flag_[192] <= 1'b0;
			// else if ( comp_flag_[193] == 1'd1 ) comp_flag_[193] <= 1'b0;
			// else if ( comp_flag_[194] == 1'd1 ) comp_flag_[194] <= 1'b0;
			// else if ( comp_flag_[195] == 1'd1 ) comp_flag_[195] <= 1'b0;
			// else if ( comp_flag_[196] == 1'd1 ) comp_flag_[196] <= 1'b0;
			// else if ( comp_flag_[197] == 1'd1 ) comp_flag_[197] <= 1'b0;
			// else if ( comp_flag_[198] == 1'd1 ) comp_flag_[198] <= 1'b0;
			// else if ( comp_flag_[199] == 1'd1 ) comp_flag_[199] <= 1'b0;
			// else if ( comp_flag_[200] == 1'd1 ) comp_flag_[200] <= 1'b0;
			// else if ( comp_flag_[201] == 1'd1 ) comp_flag_[201] <= 1'b0;
			// else if ( comp_flag_[202] == 1'd1 ) comp_flag_[202] <= 1'b0;
			// else if ( comp_flag_[203] == 1'd1 ) comp_flag_[203] <= 1'b0;
			// else if ( comp_flag_[204] == 1'd1 ) comp_flag_[204] <= 1'b0;
			// else if ( comp_flag_[205] == 1'd1 ) comp_flag_[205] <= 1'b0;
			// else if ( comp_flag_[206] == 1'd1 ) comp_flag_[206] <= 1'b0;
			// else if ( comp_flag_[207] == 1'd1 ) comp_flag_[207] <= 1'b0;
			// else if ( comp_flag_[208] == 1'd1 ) comp_flag_[208] <= 1'b0;
			// else if ( comp_flag_[209] == 1'd1 ) comp_flag_[209] <= 1'b0;
			// else if ( comp_flag_[210] == 1'd1 ) comp_flag_[210] <= 1'b0;
			// else if ( comp_flag_[211] == 1'd1 ) comp_flag_[211] <= 1'b0;
			// else if ( comp_flag_[212] == 1'd1 ) comp_flag_[212] <= 1'b0;
			// else if ( comp_flag_[213] == 1'd1 ) comp_flag_[213] <= 1'b0;
			// else if ( comp_flag_[214] == 1'd1 ) comp_flag_[214] <= 1'b0;
			// else if ( comp_flag_[215] == 1'd1 ) comp_flag_[215] <= 1'b0;
			// else if ( comp_flag_[216] == 1'd1 ) comp_flag_[216] <= 1'b0;
			// else if ( comp_flag_[217] == 1'd1 ) comp_flag_[217] <= 1'b0;
			// else if ( comp_flag_[218] == 1'd1 ) comp_flag_[218] <= 1'b0;
			// else if ( comp_flag_[219] == 1'd1 ) comp_flag_[219] <= 1'b0;
			// else if ( comp_flag_[220] == 1'd1 ) comp_flag_[220] <= 1'b0;
			// else if ( comp_flag_[221] == 1'd1 ) comp_flag_[221] <= 1'b0;
			// else if ( comp_flag_[222] == 1'd1 ) comp_flag_[222] <= 1'b0;
			// else if ( comp_flag_[223] == 1'd1 ) comp_flag_[223] <= 1'b0;
			// else if ( comp_flag_[224] == 1'd1 ) comp_flag_[224] <= 1'b0;
			// else if ( comp_flag_[225] == 1'd1 ) comp_flag_[225] <= 1'b0;
			// else if ( comp_flag_[226] == 1'd1 ) comp_flag_[226] <= 1'b0;
			// else if ( comp_flag_[227] == 1'd1 ) comp_flag_[227] <= 1'b0;
			// else if ( comp_flag_[228] == 1'd1 ) comp_flag_[228] <= 1'b0;
			// else if ( comp_flag_[229] == 1'd1 ) comp_flag_[229] <= 1'b0;
			// else if ( comp_flag_[230] == 1'd1 ) comp_flag_[230] <= 1'b0;
			// else if ( comp_flag_[231] == 1'd1 ) comp_flag_[231] <= 1'b0;
			// else if ( comp_flag_[232] == 1'd1 ) comp_flag_[232] <= 1'b0;
			// else if ( comp_flag_[233] == 1'd1 ) comp_flag_[233] <= 1'b0;
			// else if ( comp_flag_[234] == 1'd1 ) comp_flag_[234] <= 1'b0;
			// else if ( comp_flag_[235] == 1'd1 ) comp_flag_[235] <= 1'b0;
			// else if ( comp_flag_[236] == 1'd1 ) comp_flag_[236] <= 1'b0;
			// else if ( comp_flag_[237] == 1'd1 ) comp_flag_[237] <= 1'b0;
			// else if ( comp_flag_[238] == 1'd1 ) comp_flag_[238] <= 1'b0;
			// else if ( comp_flag_[239] == 1'd1 ) comp_flag_[239] <= 1'b0;
			// else if ( comp_flag_[240] == 1'd1 ) comp_flag_[240] <= 1'b0;
			// else if ( comp_flag_[241] == 1'd1 ) comp_flag_[241] <= 1'b0;
			// else if ( comp_flag_[242] == 1'd1 ) comp_flag_[242] <= 1'b0;
			// else if ( comp_flag_[243] == 1'd1 ) comp_flag_[243] <= 1'b0;
			// else if ( comp_flag_[244] == 1'd1 ) comp_flag_[244] <= 1'b0;
			// else if ( comp_flag_[245] == 1'd1 ) comp_flag_[245] <= 1'b0;
			// else if ( comp_flag_[246] == 1'd1 ) comp_flag_[246] <= 1'b0;
			// else if ( comp_flag_[247] == 1'd1 ) comp_flag_[247] <= 1'b0;
			// else if ( comp_flag_[248] == 1'd1 ) comp_flag_[248] <= 1'b0;
			// else if ( comp_flag_[249] == 1'd1 ) comp_flag_[249] <= 1'b0;
			// else if ( comp_flag_[250] == 1'd1 ) comp_flag_[250] <= 1'b0;
			// else if ( comp_flag_[251] == 1'd1 ) comp_flag_[251] <= 1'b0;
			// else if ( comp_flag_[252] == 1'd1 ) comp_flag_[252] <= 1'b0;
			// else if ( comp_flag_[253] == 1'd1 ) comp_flag_[253] <= 1'b0;
			// else if ( comp_flag_[254] == 1'd1 ) comp_flag_[254] <= 1'b0;
			// else if ( comp_flag_[255] == 1'd1 ) comp_flag_[255] <= 1'b0;
			// else if ( comp_flag_[256] == 1'd1 ) comp_flag_[256] <= 1'b0;
			// else if ( comp_flag_[257] == 1'd1 ) comp_flag_[257] <= 1'b0;
			// else if ( comp_flag_[258] == 1'd1 ) comp_flag_[258] <= 1'b0;
			// else if ( comp_flag_[259] == 1'd1 ) comp_flag_[259] <= 1'b0;
			// else if ( comp_flag_[260] == 1'd1 ) comp_flag_[260] <= 1'b0;
			// else if ( comp_flag_[261] == 1'd1 ) comp_flag_[261] <= 1'b0;
			// else if ( comp_flag_[262] == 1'd1 ) comp_flag_[262] <= 1'b0;
			// else if ( comp_flag_[263] == 1'd1 ) comp_flag_[263] <= 1'b0;
			// else if ( comp_flag_[264] == 1'd1 ) comp_flag_[264] <= 1'b0;
			// else if ( comp_flag_[265] == 1'd1 ) comp_flag_[265] <= 1'b0;
			// else if ( comp_flag_[266] == 1'd1 ) comp_flag_[266] <= 1'b0;
			// else if ( comp_flag_[267] == 1'd1 ) comp_flag_[267] <= 1'b0;
			// else if ( comp_flag_[268] == 1'd1 ) comp_flag_[268] <= 1'b0;
			// else if ( comp_flag_[269] == 1'd1 ) comp_flag_[269] <= 1'b0;
			// else if ( comp_flag_[270] == 1'd1 ) comp_flag_[270] <= 1'b0;
			// else if ( comp_flag_[271] == 1'd1 ) comp_flag_[271] <= 1'b0;
			// else if ( comp_flag_[272] == 1'd1 ) comp_flag_[272] <= 1'b0;
			// else if ( comp_flag_[273] == 1'd1 ) comp_flag_[273] <= 1'b0;
			// else if ( comp_flag_[274] == 1'd1 ) comp_flag_[274] <= 1'b0;
			// else if ( comp_flag_[275] == 1'd1 ) comp_flag_[275] <= 1'b0;
			// else if ( comp_flag_[276] == 1'd1 ) comp_flag_[276] <= 1'b0;
			// else if ( comp_flag_[277] == 1'd1 ) comp_flag_[277] <= 1'b0;
			// else if ( comp_flag_[278] == 1'd1 ) comp_flag_[278] <= 1'b0;
			// else if ( comp_flag_[279] == 1'd1 ) comp_flag_[279] <= 1'b0;
			// else if ( comp_flag_[280] == 1'd1 ) comp_flag_[280] <= 1'b0;
			// else if ( comp_flag_[281] == 1'd1 ) comp_flag_[281] <= 1'b0;
			// else if ( comp_flag_[282] == 1'd1 ) comp_flag_[282] <= 1'b0;
			// else if ( comp_flag_[283] == 1'd1 ) comp_flag_[283] <= 1'b0;
			// else if ( comp_flag_[284] == 1'd1 ) comp_flag_[284] <= 1'b0;
			// else if ( comp_flag_[285] == 1'd1 ) comp_flag_[285] <= 1'b0;
			// else if ( comp_flag_[286] == 1'd1 ) comp_flag_[286] <= 1'b0;
			// else if ( comp_flag_[287] == 1'd1 ) comp_flag_[287] <= 1'b0;
			// else if ( comp_flag_[288] == 1'd1 ) comp_flag_[288] <= 1'b0;
			// else if ( comp_flag_[289] == 1'd1 ) comp_flag_[289] <= 1'b0;
			// else if ( comp_flag_[290] == 1'd1 ) comp_flag_[290] <= 1'b0;
			// else if ( comp_flag_[291] == 1'd1 ) comp_flag_[291] <= 1'b0;
			// else if ( comp_flag_[292] == 1'd1 ) comp_flag_[292] <= 1'b0;
			// else if ( comp_flag_[293] == 1'd1 ) comp_flag_[293] <= 1'b0;
			// else if ( comp_flag_[294] == 1'd1 ) comp_flag_[294] <= 1'b0;
			// else if ( comp_flag_[295] == 1'd1 ) comp_flag_[295] <= 1'b0;
			// else if ( comp_flag_[296] == 1'd1 ) comp_flag_[296] <= 1'b0;
			// else if ( comp_flag_[297] == 1'd1 ) comp_flag_[297] <= 1'b0;
			// else if ( comp_flag_[298] == 1'd1 ) comp_flag_[298] <= 1'b0;
			// else if ( comp_flag_[299] == 1'd1 ) comp_flag_[299] <= 1'b0;
			// else if ( comp_flag_[300] == 1'd1 ) comp_flag_[300] <= 1'b0;
			// else if ( comp_flag_[301] == 1'd1 ) comp_flag_[301] <= 1'b0;
			// else if ( comp_flag_[302] == 1'd1 ) comp_flag_[302] <= 1'b0;
			// else if ( comp_flag_[303] == 1'd1 ) comp_flag_[303] <= 1'b0;
			// else if ( comp_flag_[304] == 1'd1 ) comp_flag_[304] <= 1'b0;
			// else if ( comp_flag_[305] == 1'd1 ) comp_flag_[305] <= 1'b0;
			// else if ( comp_flag_[306] == 1'd1 ) comp_flag_[306] <= 1'b0;
			// else if ( comp_flag_[307] == 1'd1 ) comp_flag_[307] <= 1'b0;
			// else if ( comp_flag_[308] == 1'd1 ) comp_flag_[308] <= 1'b0;
			// else if ( comp_flag_[309] == 1'd1 ) comp_flag_[309] <= 1'b0;
			// else if ( comp_flag_[310] == 1'd1 ) comp_flag_[310] <= 1'b0;
			// else if ( comp_flag_[311] == 1'd1 ) comp_flag_[311] <= 1'b0;
			// else if ( comp_flag_[312] == 1'd1 ) comp_flag_[312] <= 1'b0;
			// else if ( comp_flag_[313] == 1'd1 ) comp_flag_[313] <= 1'b0;
			// else if ( comp_flag_[314] == 1'd1 ) comp_flag_[314] <= 1'b0;
			// else if ( comp_flag_[315] == 1'd1 ) comp_flag_[315] <= 1'b0;
			// else if ( comp_flag_[316] == 1'd1 ) comp_flag_[316] <= 1'b0;
			// else if ( comp_flag_[317] == 1'd1 ) comp_flag_[317] <= 1'b0;
			// else if ( comp_flag_[318] == 1'd1 ) comp_flag_[318] <= 1'b0;
			// else if ( comp_flag_[319] == 1'd1 ) comp_flag_[319] <= 1'b0;
			// else if ( comp_flag_[320] == 1'd1 ) comp_flag_[320] <= 1'b0;
			// else if ( comp_flag_[321] == 1'd1 ) comp_flag_[321] <= 1'b0;
			// else if ( comp_flag_[322] == 1'd1 ) comp_flag_[322] <= 1'b0;
			// else if ( comp_flag_[323] == 1'd1 ) comp_flag_[323] <= 1'b0;
			// else if ( comp_flag_[324] == 1'd1 ) comp_flag_[324] <= 1'b0;
			// else if ( comp_flag_[325] == 1'd1 ) comp_flag_[325] <= 1'b0;
			// else if ( comp_flag_[326] == 1'd1 ) comp_flag_[326] <= 1'b0;
			// else if ( comp_flag_[327] == 1'd1 ) comp_flag_[327] <= 1'b0;
			// else if ( comp_flag_[328] == 1'd1 ) comp_flag_[328] <= 1'b0;
			// else if ( comp_flag_[329] == 1'd1 ) comp_flag_[329] <= 1'b0;
			// else if ( comp_flag_[330] == 1'd1 ) comp_flag_[330] <= 1'b0;
			// else if ( comp_flag_[331] == 1'd1 ) comp_flag_[331] <= 1'b0;
			// else if ( comp_flag_[332] == 1'd1 ) comp_flag_[332] <= 1'b0;
			// else if ( comp_flag_[333] == 1'd1 ) comp_flag_[333] <= 1'b0;
			// else if ( comp_flag_[334] == 1'd1 ) comp_flag_[334] <= 1'b0;
			// else if ( comp_flag_[335] == 1'd1 ) comp_flag_[335] <= 1'b0;
			// else if ( comp_flag_[336] == 1'd1 ) comp_flag_[336] <= 1'b0;
			// else if ( comp_flag_[337] == 1'd1 ) comp_flag_[337] <= 1'b0;
			// else if ( comp_flag_[338] == 1'd1 ) comp_flag_[338] <= 1'b0;
			// else if ( comp_flag_[339] == 1'd1 ) comp_flag_[339] <= 1'b0;
			// else if ( comp_flag_[340] == 1'd1 ) comp_flag_[340] <= 1'b0;
			// else if ( comp_flag_[341] == 1'd1 ) comp_flag_[341] <= 1'b0;
			// else if ( comp_flag_[342] == 1'd1 ) comp_flag_[342] <= 1'b0;
			// else if ( comp_flag_[343] == 1'd1 ) comp_flag_[343] <= 1'b0;
			// else if ( comp_flag_[344] == 1'd1 ) comp_flag_[344] <= 1'b0;
			// else if ( comp_flag_[345] == 1'd1 ) comp_flag_[345] <= 1'b0;
			// else if ( comp_flag_[346] == 1'd1 ) comp_flag_[346] <= 1'b0;
			// else if ( comp_flag_[347] == 1'd1 ) comp_flag_[347] <= 1'b0;
			// else if ( comp_flag_[348] == 1'd1 ) comp_flag_[348] <= 1'b0;
			// else if ( comp_flag_[349] == 1'd1 ) comp_flag_[349] <= 1'b0;
			// else if ( comp_flag_[350] == 1'd1 ) comp_flag_[350] <= 1'b0;
			// else if ( comp_flag_[351] == 1'd1 ) comp_flag_[351] <= 1'b0;
			// else if ( comp_flag_[352] == 1'd1 ) comp_flag_[352] <= 1'b0;
			// else if ( comp_flag_[353] == 1'd1 ) comp_flag_[353] <= 1'b0;
			// else if ( comp_flag_[354] == 1'd1 ) comp_flag_[354] <= 1'b0;
			// else if ( comp_flag_[355] == 1'd1 ) comp_flag_[355] <= 1'b0;
			// else if ( comp_flag_[356] == 1'd1 ) comp_flag_[356] <= 1'b0;
			// else if ( comp_flag_[357] == 1'd1 ) comp_flag_[357] <= 1'b0;
			// else if ( comp_flag_[358] == 1'd1 ) comp_flag_[358] <= 1'b0;
			// else if ( comp_flag_[359] == 1'd1 ) comp_flag_[359] <= 1'b0;
			// else if ( comp_flag_[360] == 1'd1 ) comp_flag_[360] <= 1'b0;
			// else if ( comp_flag_[361] == 1'd1 ) comp_flag_[361] <= 1'b0;
			// else if ( comp_flag_[362] == 1'd1 ) comp_flag_[362] <= 1'b0;
			// else if ( comp_flag_[363] == 1'd1 ) comp_flag_[363] <= 1'b0;
			// else if ( comp_flag_[364] == 1'd1 ) comp_flag_[364] <= 1'b0;
			// else if ( comp_flag_[365] == 1'd1 ) comp_flag_[365] <= 1'b0;
			// else if ( comp_flag_[366] == 1'd1 ) comp_flag_[366] <= 1'b0;
			// else if ( comp_flag_[367] == 1'd1 ) comp_flag_[367] <= 1'b0;
			// else if ( comp_flag_[368] == 1'd1 ) comp_flag_[368] <= 1'b0;
			// else if ( comp_flag_[369] == 1'd1 ) comp_flag_[369] <= 1'b0;
			// else if ( comp_flag_[370] == 1'd1 ) comp_flag_[370] <= 1'b0;
			// else if ( comp_flag_[371] == 1'd1 ) comp_flag_[371] <= 1'b0;
			// else if ( comp_flag_[372] == 1'd1 ) comp_flag_[372] <= 1'b0;
			// else if ( comp_flag_[373] == 1'd1 ) comp_flag_[373] <= 1'b0;
			// else if ( comp_flag_[374] == 1'd1 ) comp_flag_[374] <= 1'b0;
			// else if ( comp_flag_[375] == 1'd1 ) comp_flag_[375] <= 1'b0;
			// else if ( comp_flag_[376] == 1'd1 ) comp_flag_[376] <= 1'b0;
			// else if ( comp_flag_[377] == 1'd1 ) comp_flag_[377] <= 1'b0;
			// else if ( comp_flag_[378] == 1'd1 ) comp_flag_[378] <= 1'b0;
			// else if ( comp_flag_[379] == 1'd1 ) comp_flag_[379] <= 1'b0;
			// else if ( comp_flag_[380] == 1'd1 ) comp_flag_[380] <= 1'b0;
			// else if ( comp_flag_[381] == 1'd1 ) comp_flag_[381] <= 1'b0;
			// else if ( comp_flag_[382] == 1'd1 ) comp_flag_[382] <= 1'b0;
			// else if ( comp_flag_[383] == 1'd1 ) comp_flag_[383] <= 1'b0;
			// else if ( comp_flag_[384] == 1'd1 ) comp_flag_[384] <= 1'b0;
			// else if ( comp_flag_[385] == 1'd1 ) comp_flag_[385] <= 1'b0;
			// else if ( comp_flag_[386] == 1'd1 ) comp_flag_[386] <= 1'b0;
			// else if ( comp_flag_[387] == 1'd1 ) comp_flag_[387] <= 1'b0;
			// else if ( comp_flag_[388] == 1'd1 ) comp_flag_[388] <= 1'b0;
			// else if ( comp_flag_[389] == 1'd1 ) comp_flag_[389] <= 1'b0;
			// else if ( comp_flag_[390] == 1'd1 ) comp_flag_[390] <= 1'b0;
			// else if ( comp_flag_[391] == 1'd1 ) comp_flag_[391] <= 1'b0;
			// else if ( comp_flag_[392] == 1'd1 ) comp_flag_[392] <= 1'b0;
			// else if ( comp_flag_[393] == 1'd1 ) comp_flag_[393] <= 1'b0;
			// else if ( comp_flag_[394] == 1'd1 ) comp_flag_[394] <= 1'b0;
			// else if ( comp_flag_[395] == 1'd1 ) comp_flag_[395] <= 1'b0;
			// else if ( comp_flag_[396] == 1'd1 ) comp_flag_[396] <= 1'b0;
			// else if ( comp_flag_[397] == 1'd1 ) comp_flag_[397] <= 1'b0;
			// else if ( comp_flag_[398] == 1'd1 ) comp_flag_[398] <= 1'b0;
			// else if ( comp_flag_[399] == 1'd1 ) comp_flag_[399] <= 1'b0;
			// else if ( comp_flag_[400] == 1'd1 ) comp_flag_[400] <= 1'b0;
			// else if ( comp_flag_[401] == 1'd1 ) comp_flag_[401] <= 1'b0;
			// else if ( comp_flag_[402] == 1'd1 ) comp_flag_[402] <= 1'b0;
			// else if ( comp_flag_[403] == 1'd1 ) comp_flag_[403] <= 1'b0;
			// else if ( comp_flag_[404] == 1'd1 ) comp_flag_[404] <= 1'b0;
			// else if ( comp_flag_[405] == 1'd1 ) comp_flag_[405] <= 1'b0;
			// else if ( comp_flag_[406] == 1'd1 ) comp_flag_[406] <= 1'b0;
			// else if ( comp_flag_[407] == 1'd1 ) comp_flag_[407] <= 1'b0;
			// else if ( comp_flag_[408] == 1'd1 ) comp_flag_[408] <= 1'b0;
			// else if ( comp_flag_[409] == 1'd1 ) comp_flag_[409] <= 1'b0;
			// else if ( comp_flag_[410] == 1'd1 ) comp_flag_[410] <= 1'b0;
			// else if ( comp_flag_[411] == 1'd1 ) comp_flag_[411] <= 1'b0;
			// else if ( comp_flag_[412] == 1'd1 ) comp_flag_[412] <= 1'b0;
			// else if ( comp_flag_[413] == 1'd1 ) comp_flag_[413] <= 1'b0;
			// else if ( comp_flag_[414] == 1'd1 ) comp_flag_[414] <= 1'b0;
			// else if ( comp_flag_[415] == 1'd1 ) comp_flag_[415] <= 1'b0;
			// else if ( comp_flag_[416] == 1'd1 ) comp_flag_[416] <= 1'b0;
			// else if ( comp_flag_[417] == 1'd1 ) comp_flag_[417] <= 1'b0;
			// else if ( comp_flag_[418] == 1'd1 ) comp_flag_[418] <= 1'b0;
			// else if ( comp_flag_[419] == 1'd1 ) comp_flag_[419] <= 1'b0;
			// else if ( comp_flag_[420] == 1'd1 ) comp_flag_[420] <= 1'b0;
			// else if ( comp_flag_[421] == 1'd1 ) comp_flag_[421] <= 1'b0;
			// else if ( comp_flag_[422] == 1'd1 ) comp_flag_[422] <= 1'b0;
			// else if ( comp_flag_[423] == 1'd1 ) comp_flag_[423] <= 1'b0;
			// else if ( comp_flag_[424] == 1'd1 ) comp_flag_[424] <= 1'b0;
			// else if ( comp_flag_[425] == 1'd1 ) comp_flag_[425] <= 1'b0;
			// else if ( comp_flag_[426] == 1'd1 ) comp_flag_[426] <= 1'b0;
			// else if ( comp_flag_[427] == 1'd1 ) comp_flag_[427] <= 1'b0;
			// else if ( comp_flag_[428] == 1'd1 ) comp_flag_[428] <= 1'b0;
			// else if ( comp_flag_[429] == 1'd1 ) comp_flag_[429] <= 1'b0;
			// else if ( comp_flag_[430] == 1'd1 ) comp_flag_[430] <= 1'b0;
			// else if ( comp_flag_[431] == 1'd1 ) comp_flag_[431] <= 1'b0;
			// else if ( comp_flag_[432] == 1'd1 ) comp_flag_[432] <= 1'b0;
			// else if ( comp_flag_[433] == 1'd1 ) comp_flag_[433] <= 1'b0;
			// else if ( comp_flag_[434] == 1'd1 ) comp_flag_[434] <= 1'b0;
			// else if ( comp_flag_[435] == 1'd1 ) comp_flag_[435] <= 1'b0;
			// else if ( comp_flag_[436] == 1'd1 ) comp_flag_[436] <= 1'b0;
			// else if ( comp_flag_[437] == 1'd1 ) comp_flag_[437] <= 1'b0;
			// else if ( comp_flag_[438] == 1'd1 ) comp_flag_[438] <= 1'b0;
			// else if ( comp_flag_[439] == 1'd1 ) comp_flag_[439] <= 1'b0;
			// else if ( comp_flag_[440] == 1'd1 ) comp_flag_[440] <= 1'b0;
			// else if ( comp_flag_[441] == 1'd1 ) comp_flag_[441] <= 1'b0;
			// else if ( comp_flag_[442] == 1'd1 ) comp_flag_[442] <= 1'b0;
			// else if ( comp_flag_[443] == 1'd1 ) comp_flag_[443] <= 1'b0;
			// else if ( comp_flag_[444] == 1'd1 ) comp_flag_[444] <= 1'b0;
			// else if ( comp_flag_[445] == 1'd1 ) comp_flag_[445] <= 1'b0;
			// else if ( comp_flag_[446] == 1'd1 ) comp_flag_[446] <= 1'b0;
			// else if ( comp_flag_[447] == 1'd1 ) comp_flag_[447] <= 1'b0;
			// else if ( comp_flag_[448] == 1'd1 ) comp_flag_[448] <= 1'b0;
			// else if ( comp_flag_[449] == 1'd1 ) comp_flag_[449] <= 1'b0;
			// else if ( comp_flag_[450] == 1'd1 ) comp_flag_[450] <= 1'b0;
			// else if ( comp_flag_[451] == 1'd1 ) comp_flag_[451] <= 1'b0;
			// else if ( comp_flag_[452] == 1'd1 ) comp_flag_[452] <= 1'b0;
			// else if ( comp_flag_[453] == 1'd1 ) comp_flag_[453] <= 1'b0;
			// else if ( comp_flag_[454] == 1'd1 ) comp_flag_[454] <= 1'b0;
			// else if ( comp_flag_[455] == 1'd1 ) comp_flag_[455] <= 1'b0;
			// else if ( comp_flag_[456] == 1'd1 ) comp_flag_[456] <= 1'b0;
			// else if ( comp_flag_[457] == 1'd1 ) comp_flag_[457] <= 1'b0;
			// else if ( comp_flag_[458] == 1'd1 ) comp_flag_[458] <= 1'b0;
			// else if ( comp_flag_[459] == 1'd1 ) comp_flag_[459] <= 1'b0;
			// else if ( comp_flag_[460] == 1'd1 ) comp_flag_[460] <= 1'b0;
			// else if ( comp_flag_[461] == 1'd1 ) comp_flag_[461] <= 1'b0;
			// else if ( comp_flag_[462] == 1'd1 ) comp_flag_[462] <= 1'b0;
			// else if ( comp_flag_[463] == 1'd1 ) comp_flag_[463] <= 1'b0;
			// else if ( comp_flag_[464] == 1'd1 ) comp_flag_[464] <= 1'b0;
			// else if ( comp_flag_[465] == 1'd1 ) comp_flag_[465] <= 1'b0;
			// else if ( comp_flag_[466] == 1'd1 ) comp_flag_[466] <= 1'b0;
			// else if ( comp_flag_[467] == 1'd1 ) comp_flag_[467] <= 1'b0;
			// else if ( comp_flag_[468] == 1'd1 ) comp_flag_[468] <= 1'b0;
			// else if ( comp_flag_[469] == 1'd1 ) comp_flag_[469] <= 1'b0;
			// else if ( comp_flag_[470] == 1'd1 ) comp_flag_[470] <= 1'b0;
			// else if ( comp_flag_[471] == 1'd1 ) comp_flag_[471] <= 1'b0;
			// else if ( comp_flag_[472] == 1'd1 ) comp_flag_[472] <= 1'b0;
			// else if ( comp_flag_[473] == 1'd1 ) comp_flag_[473] <= 1'b0;
			// else if ( comp_flag_[474] == 1'd1 ) comp_flag_[474] <= 1'b0;
			// else if ( comp_flag_[475] == 1'd1 ) comp_flag_[475] <= 1'b0;
			// else if ( comp_flag_[476] == 1'd1 ) comp_flag_[476] <= 1'b0;
			// else if ( comp_flag_[477] == 1'd1 ) comp_flag_[477] <= 1'b0;
			// else if ( comp_flag_[478] == 1'd1 ) comp_flag_[478] <= 1'b0;
			// else if ( comp_flag_[479] == 1'd1 ) comp_flag_[479] <= 1'b0;

			state_arbr <= 3'd5;	// return to state 2
		end

		// ===== STATE 5 =====
		else if ( state_arbr == 3'd5 ) begin
			vga_sram_write_ <= 1'b0;
			state_arbr      <= 3'd3;
		end
		
	end

	assign vga_sram_write  	  = vga_sram_write_; 
	assign vga_sram_address   = vga_sram_address_; 
	assign vga_sram_writedata = vga_sram_writedata_; 
	assign comp_flag		  = comp_flag_; 
	assign inter_start 		  = inter_start_;

endmodule