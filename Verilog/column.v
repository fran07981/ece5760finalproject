`include "compute.v"

// ------------------------------------------------------------------------------------
// BUILD_COLUMN
// ------------------------------------------------------------------------------------
// inputs :
// 		clk 			in top level has to be CLOCK_50
// 		reset 			in top level 
// 		current_col 	tells us which column it is (bit size here is based on the max number of rows we can achieve.)
// 		height			tells us how tall column is ( same as current col))
//		width			gives us number of columns we have
//		alpha 
// 		delta
// 		n_reg_right		connected input from other column
// 		n_reg_left		connected input from other column
//		so_y_coord		source set val at this height/row number
//		si_y_coord		sink set val at this height/row number
// outputs :
// 		node_center				becomes the inputs to the other modules

module build_column(clk, reset, current_col, height, width, mult_alpha_delta, node_right, node_left, so_y_coord, si_y_coord, node_center, flag, start);
	localparam row_bits = 31; // For consistency, actually shold be ok with 9 bits/n=8
	localparam col_bits = 31; // 
	
	// ---- Inputs & Outputs ----
	input 		 clk, reset;
	
	input [col_bits:0] current_col;
	input [col_bits:0] width;
	input [row_bits:0] height;
	input start;

	input  wire signed [31:0] mult_alpha_delta;

	input  wire signed [31:0] node_right;
	input  wire signed [31:0] node_left;

	input  wire signed [31:0] so_y_coord;
	input  wire signed [31:0] si_y_coord;
    
	output wire signed [31:0] node_center;
	output wire 			  flag;

	// ---- General Registers ----
	reg [row_bits:0] bottom_row; // bottom row is 0th row
	reg [row_bits:0] top_row;	  // top row is gonna be based on the height 

	reg [col_bits:0] left_edge;  // we are at the left edge when our current col is 0
	reg [col_bits:0] right_edge; // set to max number of cols chnged from width

	reg [row_bits:0] current_row;		   // we have possible 256 rows, use this for moving up 

	// ---- Const Values ----
	wire signed [31:0] fp_0    = 32'b0_0000_0000_0000_0000_0000_0000_0000_000;	// 0 

	// ---- Registers that store info ----
	reg signed [31:0]  u_reg_bottom; // saves the bottom node
	reg signed [31:0]  u_reg_down;	 // saves tge down at t=n from prev u 
	reg signed [31:0]  u_reg_center; // saves the current at t=n from prev up from M10K

	reg flag_reg = 0;

	assign node_center 			= (current_row == bottom_row) ? u_reg_bottom : u_reg_center;
	assign flag 		= flag_reg;

	// ---- Wires for connecting everything togther ----
	wire signed [31:0] u_read_data;
	wire signed [31:0] u_prev_read_data;
	
	// Switch to registers test*
	reg signed [31:0] u_up;
	reg signed [31:0] u_down;	
	
	reg signed [31:0] u_center;
	reg signed [31:0] u_center_prev;

	// ==== U MEMORY BLOCK FOR COLUMN ====
	reg signed [31:0] u_write_data;
	reg [row_bits:0]  u_write_addr;	// select the row
	reg [row_bits:0]  u_read_addr;	// select the row
	reg 	          u_write_sig;		
	
	M10K_512_18 u(  
		.q				(u_read_data),			// the return data value during reads
		.d				(u_write_data), 	// set to data we want to write
		.write_address	(u_write_addr), 	// send it the address we want to write
		.read_address	(u_read_addr),   	// addr we want to read
		.we				(u_write_sig), 		// if we want to write we = 1'd1, else, we = 1'd0
		.clk			(clk) );

	// ==== U_PREV MEMORY BLOCK FOR COLUMN ====
	reg	signed [17:0] u_prev_write_data;
	reg	[row_bits:0]  u_prev_write_addr;
	reg	[row_bits:0]  u_prev_read_addr;
	reg	 	   		  u_prev_write_sig;
	
	M10K_256_32 u_prev( 
		.q				(u_prev_read_data),
		.d				(u_prev_write_data),
		.write_address	(u_prev_write_addr), 
		.read_address	(u_prev_read_addr),
		.we				(u_prev_write_sig), 
		.clk			(clk) );
	
	// ----------------- SATE MACHINE -----------------
	// states 1,2 are for initializing all the memory blocks
	// states 3,4,5 are for moving data accordingly 

	reg  [3:0] state; 	// 5 states => 3 bits (max of 7 states)
	wire [3:0] state_0 = 4'd0;
	wire [3:0] state_1 = 4'd1;
	wire [3:0] state_2 = 4'd2;
	wire [3:0] state_3 = 4'd3;
	wire [3:0] state_4 = 4'd4;
	wire [3:0] state_5 = 4'd5;
	wire [3:0] state_6 = 4'd6;
	wire [3:0] state_7 = 4'd7;
	wire [3:0] state_8 = 4'd8;

	wire signed [17:0] u_next; 
	reg signed [17:0] temp;

	
	always @(posedge clk) begin
		if ( reset ) state <= state_0;
		// ------------------------------------------------------------------
		// STATE 0 - reset stage
		// ------------------------------------------------------------------
		else if (state == state_0) begin
			current_row <= 0;		// set the row we are gonna start on to 0
			bottom_row	<= 0; 		// bottom row is 0th row
			top_row		<= height;	// top row is gonna be based on the height 
			left_edge	<= 0;  		// we are at the left edge when our current col is 0
			right_edge	<= width; 	// set to max number of cols chnged from width
			state 		<= state_1;
			
			temp <= fp_0;
		end
		// ------------------------------------------------------------------
		// STATE 1 - tell M10K block's what addr we want to store & to what
		// ------------------------------------------------------------------
		else if ( state == state_1 ) begin
			// M10K block for t = n should  ( TODO: set to triangle vals, Nikitha is working on this step )
			u_write_addr <= current_row;
			u_write_data <= temp;
			u_write_sig  <= 1'd1;

			// M10K block for u_prev is initially the same as u current 
			u_prev_write_addr <= current_row;
			u_prev_write_data <= temp;
			u_prev_write_sig  <= 1'd1;

			if ( current_row == bottom_row ) begin
				u_reg_bottom <= temp;
			end

			state <= state_2;
		end
		// ------------------------------------------------------------------
		// STATE 2 - wait for M10K block
		// ------------------------------------------------------------------
		else if ( state == state_2 ) begin
			// ( we gotta give 1 time cycle for the M10K block to write)
			
			if (current_row == si_y_coord) begin
				temp <= 32'b1_0010_0000_0000_0000_0000_0000_0000_000; //Set to -2			
				current_row <= current_row + 32'd1;
				state 		<= state_1;				
			end
			else if (current_row == so_y_coord) begin
				temp <= 32'b0_0010_0000_0000_0000_0000_0000_0000_000;		// Set to 2, NEED TO CHECK.
				current_row <= current_row + 32'd1;
				state 		<= state_1;				
			end
			else if ( current_row == top_row ) begin
				current_row <= 0;
				temp 		<= fp_0;
				state 		<= state_3; 			
			end
			else begin
				temp <= fp_0;
				current_row <= current_row + 32'd1;
				state 		<= state_1;				
			end
			
		end

		// ------------------------------------------------------------------
		// STATE 3 - request M10K block memory 
		// ------------------------------------------------------------------
		else if ( state == state_3 )begin
			current_row 	 <= current_row;

			if ( current_row != top_row ) begin
				u_read_addr 	 <= current_row + 9'd1;
			end
			else begin
				u_read_addr <= 0;
			end
			
			u_write_sig  	 <= 1'd0;

			u_prev_read_addr <= current_row;
			u_prev_write_sig <= 1'd0;

			state 			 <= state_4;
		end
		// ------------------------------------------------------------------
		// STATE 4 - receive memory from M10K & set inputs for compute
		// ------------------------------------------------------------------
		else if ( state == state_4 ) begin
			state <= state_5;
		end
		// ------------------------------------------------------------------
		// STATE 5 - wait for compute moduleeee
		// ------------------------------------------------------------------
		else if ( state == state_5 ) begin
			u_up		  <= (current_row == top_row)    ? 0 : u_read_data;					// if node at top edge, 0 
			u_down		  <= (current_row == bottom_row) ? 0 : u_reg_down; 				// if node at bottom edge
			u_center	  <= (current_row == bottom_row) ? u_reg_bottom : u_reg_center; 	// if node is at bottom, grab from bottom register
			u_center_prev <= u_prev_read_data; // At prev time step, just grab from block
			
			state 		  <= state_6;
		end
		// ------------------------------------------------------------------
		// STATE 6 - compute is done, refer to diagram
		// ------------------------------------------------------------------
		else if ( state == state_6 ) begin

			if ( current_row == bottom_row ) begin
				u_reg_bottom <= u_next;
				u_reg_down	 <= u_reg_bottom;

				u_prev_write_addr <= current_row;
				u_prev_write_data <= u_reg_bottom;
				u_prev_write_sig  <= 1'd1;

				u_reg_center <= u_up;

				u_write_sig  <= 1'd0;
			end
			else if ( current_row == top_row ) begin
				u_reg_bottom <= u_reg_bottom;
				u_reg_down	 <= u_reg_down;
				u_reg_center <= u_reg_center;

				u_prev_write_addr <= current_row;
				u_prev_write_data <= u_reg_center;
				u_prev_write_sig  <= 1'd1;

				u_write_addr <= current_row;
				u_write_data <= u_next;
				u_write_sig  <= 1'd1;
			end
			else begin
				u_reg_bottom <= u_reg_bottom;

				u_write_addr <= current_row;
				u_write_data <= u_next;
				u_write_sig  <= 1'd1;

				u_reg_center <= u_up;

				u_prev_write_addr <= current_row;
				u_prev_write_data <= u_reg_center;
				u_prev_write_sig  <= 1'd1;

				u_reg_down <= u_reg_center;
			end
			
			state <= state_7; // wait a cycle to perform write into M10K
		end
		// ------------------------------------------------------------------
		// STATE 7 - move to next node while M10K Blocks write
		// ------------------------------------------------------------------
		else if (state == state_7) begin
			if ( current_row == top_row ) begin
				current_row <= 0;
				flag_reg <=1;
				state <= state_8; 
			end
			else if ( current_row == mid ) begin
				u_mid <= u_reg_center;
				current_row <= current_row + 1;	
				state <= state_3; 
			end
			else begin
				current_row <= current_row + 1;	
				state <= state_3; 
			end
			
		end
		// ------------------------------------------------------------------
		// STATE 8 - Wait for the synchronization signal to start next 
		// ------------------------------------------------------------------
		else if ( state == state_8 )begin
			if ( start == 1'd1 )begin
				state<=state_3;
			end
			else state<=state_8;
		end

	end
	
	compute next_node(
		.node_center		(),
		.node_up			(), 
		.node_down			(), 
		.node_left			(), 
		.node_right			(), 
		.mult_alpha_delta	(mult_alpha_delta), 
		.new_center			());

endmodule