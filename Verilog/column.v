`include "compute.v"

// ------------------------------------------------------------------------------------
// BUILD_COLUMN
// ------------------------------------------------------------------------------------
// inputs :
// 		clk 			in top level has to be CLOCK_50
// 		reset 			in top level 
// 		current_col 	tells us which column it is (bit size here is based on the max number of rows we can achieve. Start with 3 bits (for now))
// 		height			tells us how tall column is ( same as current col, lets start with 3 bits)
//		width			gives us number of columns we have
//		rho_eff
// 		u_reg_right		connected input from other column
// 		u_reg_left		connected input from other column
// outputs :
// 		u_n				becomes the inputs to the other modules

module build_column(clk, reset, current_col, height, width, alpha, delta, node_right, node_left, node_center, flag, start);
	localparam row_bits = 8; // 9 total [8:0]
	localparam col_bits = 8; // idk total [???:0]
	
	// ---- Inputs & Outputs ----
	input 		 clk, reset;
	
	input [col_bits:0] current_col;
	input [col_bits:0] width;
	input [row_bits:0] height;
	input start;

	reg [row_bits:0] mid; 
	
	input  wire signed [31:0] node_right;
	input  wire signed [31:0] node_left;
    
	output wire signed [17:0] u_n;
	output wire signed [17:0] u_mid_output;
	output wire 			  flag;

	reg signed [17:0] u_mid;

	// ---- General Registers ----
	reg [row_bits:0] bottom_row; // bottom row is 0th row
	reg [row_bits:0] top_row;	  // top row is gonna be based on the height 

	reg [col_bits:0] left_edge;  // we are at the left edge when our current col is 0
	reg [col_bits:0] right_edge; // set to max number of cols chnged from width

	reg [row_bits:0] current_row;		   // we have possible 512 rows, use this for moving up 

	// ---- Const Values ----
	wire signed [17:0] fp_0    = 18'b0_0000_0000_0000_0000_0;	// 0
	wire signed [17:0] fp_0625 = 18'b0_0001_0000_0000_0000_0;	// 0.0625
	wire signed [17:0] fp_1250 = 18'b0_0010_0000_0000_0000_0; 	// 0.125
	// wire signed [17:0] delta   = 18'b0_0000_0010_0001_1111_1;  // increment by 0.125/15 until 15 
	wire signed [17:0] delta   = 18'b0_0000_0100_0001_1000_1;  // increment by 0.25/15 until 15 

	// ---- Registers that store info (based on slides figure) ----
	reg signed [17:0]  u_reg_bottom; // saves the bottom node
	reg signed [17:0]  u_reg_down;	 // saves tge down at t=n from prev u 
	reg signed [17:0]  u_reg_center; // saves the current at t=n from prev up from M10K

	reg flag_reg = 0;

	assign u_n 			= (current_row == bottom_row) ? u_reg_bottom : u_reg_center;
	assign u_mid_output = u_mid;
	assign flag 		= flag_reg;

	// ---- Wires for connecting everything togther ----
	wire signed [17:0] u_read_data;
	wire signed [17:0] u_prev_read_data;
	
	// Switch to registers test*
	reg signed [17:0] u_up;
	reg signed [17:0] u_down;	
	
	reg signed [17:0] u_center;
	reg signed [17:0] u_center_prev;

	// ==== U MEMORY BLOCK FOR COLUMN ====
	reg signed [17:0] u_write_data;
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
	
	M10K_512_18 u_prev( 
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
			mid 		<= height >> 1; // mid is 14
			
			temp <= 18'b0;
		end
		// ------------------------------------------------------------------
		// STATE 1 - tell M10K block's what addr we want to store & to what
		// ------------------------------------------------------------------
		else if ( state == state_1 ) begin
			// M10K block for t = n should  ( TODO: set to triangle vals, Nikitha is working on this step )
			u_write_addr <= current_row;
			u_write_data <= temp;
			u_write_sig  <= 1'd1;

			// M10K block for u_prev can be all zeros
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
			// $display(" current row = %d, current col = %d, mid = %d, math = %d", current_row, current_col, mid, (current_col < 9'd15 ? current_col : ( current_col == 9'd15 ? 9'd14 : ( mid - (current_col - mid - 9'd1) ) )) );
			if (current_row < (current_col < 9'd14 ? current_col : ( current_col == 9'd15 ? 9'd14 : ( mid - (current_col - mid - 9'd1) ) )) ) begin
				temp <= temp + delta;  				
				current_row <= current_row + 9'd1;
				state 		<= state_1;				
			end
			else if ( current_row == top_row ) begin
				current_row <= 0;
				temp 		<= 0;
				state 		<= state_3; 			
			end
			else if (current_row > (current_col > 9'd16 ? current_col : ( height - current_col ))  ) begin
				temp <= temp - delta; 				
				current_row <= current_row + 9'd1;
				state 		<= state_1;				
			end
			else begin	// middle section stays the same ( 14 and 15 the same )
				temp <= temp;
				current_row <= current_row + 9'd1;
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

	input [17:0] rho_eff;
	
	compute next_node(	
		.u		 (u_center),	  // center 		u_i,j at t = n	 from 1 of 2 registers
		.u_prev  (u_center_prev), // center prev u_i,j at t = n-1 from M10K block
		.u_left  (u_left),		  // lets not deal w this yet
		.u_right (u_right),
		.u_up    (u_up),		  // up u_i, j+1  at t = n from the M10K block or 0
		.u_down  (u_down),		  // down u_i,j-1 at time t = n from register or 0
		.rho_eff (rho_eff),		  // const ... for now
		.u_next  (u_next) );	  // output of center (gets sent either to u_bottom or M10K block)

endmodule