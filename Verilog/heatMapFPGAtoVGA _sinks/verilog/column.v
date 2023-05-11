`include "compute.v"

// ------------------------------------------------------------------------------------
// BUILD_COLUMN
// ------------------------------------------------------------------------------------
// inputs :
// 		clk 				in top level has to be CLOCK_50
// 		reset 				in top level 
// 		current_col 		tells us which column it is (bit size here is based on the max number of rows we can achieve.)
// 		height				tells us how tall column is ( same as current col))
//		width				gives us number of columns we have
//		mult_alpha_delta 
// 		node_right			connected input from other column
// 		node_left			connected input from other column

// 		start				for synchronization purposes 

// For testing purposes, we set the source of heat at the center of the grid and no sinks. 
// outputs :
// 		node_center				becomes the inputs to the other modules
// 		flag 				to know if one value is calculated 

module build_column(clk, reset, current_col, height, width, mult_alpha_delta, node_right, node_left, node_center, flag, start, row_flag);
	localparam row_bits = 7; //
	localparam col_bits = 7; // 
	
	// ---- Inputs & Outputs ----
	input 		 clk, reset;
	
	input [col_bits:0] current_col;
	input [col_bits:0] width;
	input [row_bits:0] height;
	input start;
	input [63:0] row_flag;

	input  wire signed [31:0] mult_alpha_delta;

	input  wire signed [31:0] node_right;
	input  wire signed [31:0] node_left;

	output wire signed [31:0] node_center;
	output wire 			  flag;
	wire  			  initflag;

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
	reg initflag_reg = 0;

	assign node_center 	= (current_row == bottom_row) ? u_reg_bottom : u_reg_center;
	assign flag 		= flag_reg;
	assign initflag 	= initflag_reg;

	// ---- Wires for connecting everything togther ----
	wire signed [31:0] u_read_data;
	wire signed [31:0] u_prev_read_data;
	
	// Switch to registers test*
	reg signed [31:0] u_up;
	reg signed [31:0] u_down;	
	
	reg signed [31:0] u_center;

	// ==== U MEMORY BLOCK FOR COLUMN ====
	reg signed [31:0] u_write_data;
	reg [row_bits:0]  u_write_addr;	// select the row
	reg [row_bits:0]  u_read_addr;	// select the row
	reg 	          u_write_sig;		
	
	M10K_256_32 u(  
		.q				(u_read_data),			// the return data value during reads
		.d				(u_write_data), 	// set to data we want to write
		.write_address	(u_write_addr), 	// send it the address we want to write
		.read_address	(u_read_addr),   	// addr we want to read
		.we				(u_write_sig), 		// if we want to write we = 1'd1, else, we = 1'd0
		.clk			(clk) );
	
	// ----------------- SATE MACHINE -----------------
	// states 1,2 are for initializing all the memory blocks
	// states 3,4,5 are for moving data accordingly 

	reg  [4:0] state = 0; 	// 5 states => 3 bits (max of 7 states)
	wire [4:0] state_0 = 5'd0;
	wire [4:0] state_1 = 5'd1;
	wire [4:0] state_2 = 5'd2;
	wire [4:0] state_3 = 5'd3;
	wire [4:0] state_4 = 5'd4;
	wire [4:0] state_5 = 5'd5;
	wire [4:0] state_6 = 5'd6;
	wire [4:0] state_7 = 5'd7;
	wire [4:0] state_8 = 5'd8;
	wire [4:0] state_9 = 5'd9;

	wire signed [31:0] u_next; 
	reg signed [31:0] temp;

	
	always @(posedge clk) begin
		if ( reset ) state <= state_0;
		// ------------------------------------------------------------------
		// STATE 0 - reset stage
		// ------------------------------------------------------------------
		else if (state == state_0) begin
			current_row 	<= 0;		// set the row we are gonna start on to 0
			bottom_row		<= 0; 		// bottom row is 0th row
			top_row			<= height;	// top row is gonna be based on the height 
			left_edge		<= 0;  		// we are at the left edge when our current col is 0
			right_edge		<= width; 	// set to max number of cols chnged from width
			state 			<= state_1;
			initflag_reg 	<= 1'd0;
			flag_reg <=0;
			temp <= fp_0;
		end
		// ------------------------------------------------------------------
		// STATE 1 - tell M10K block's what addr we want to store & to what
		// ------------------------------------------------------------------
		else if ( state == state_1 ) begin
			// M10K block 
			u_write_addr <= current_row;
			u_write_data <= temp;
			u_write_sig  <= 1'd1;

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
			
			if (current_row == height>>1 && current_col == height>>1) begin
			// if (current_row == 8'd3 && current_col == height>>1) begin
				temp <= 32'b0_1000_0000_0000_0000_0000_0000_0000_000; //Set to 8 middle of grid is the source 		
				current_row <= current_row + 8'd1;
				state 		<= state_1;				
			end
			else if (current_row == 8'd7 && current_col == 8'd5) begin
				temp <= -32'sb0_1000_0000_0000_0000_0000_0000_0000_000; //Set to 8 middle of grid is the source 		
				current_row <= current_row + 8'd1;
				state 		<= state_1;				
			end
			else if ( current_row == top_row ) begin
				current_row <= 0;
				temp 			<= fp_0;
				state 			<= state_3; 
				initflag_reg 	<= 1'd1;			
			end
			else begin
				temp <= fp_0;
				current_row <= current_row + 8'd1;
				state 		<= state_1;				
			end
		end


		// ------------------------------------------------------------------
		else if ( state == state_3 ) begin 
			if ( start == 1'd1 ) begin
				state    <= state_4;
				flag_reg <= 0;
			end
			else state <= state_3;
		end


		// ------------------------------------------------------------------
		// STATE 3 - request M10K block memory 
		// ------------------------------------------------------------------
		else if ( state == state_4 )begin
			current_row 	 <= current_row;

			if ( current_row != top_row ) begin
				u_read_addr 	 <= current_row + 8'd1;
			end
			else begin
				u_read_addr <= 0;
			end
			
			u_write_sig  	 <= 1'd0;

			state 			 <= state_5;
		end
		// ------------------------------------------------------------------
		// STATE 4 - receive memory from M10K & set inputs for compute
		// ------------------------------------------------------------------
		else if ( state == state_5 ) begin
			state <= state_6;
		end
		// ------------------------------------------------------------------
		// STATE 5 - wait for compute moduleeee
		// ------------------------------------------------------------------
		else if ( state == state_6 ) begin
			u_up		  <= (current_row == top_row)    ? 0 : u_read_data;					// if node at top edge, 0 
			u_down		  <= (current_row == bottom_row) ? 0 : u_reg_down; 				// if node at bottom edge
			//u_center	  <= (current_row == bottom_row) ? u_reg_bottom : u_reg_center; 	// if node is at bottom, grab from bottom register
			if (row_flag[current_row] == 1'b1) u_center <= 32'b0_0010_0000_0000_0000_0000_0000_0000_000;
			else u_center	  <= (current_row == bottom_row) ? u_reg_bottom : u_reg_center; 
			state 		  <= state_7;
		end
		// ------------------------------------------------------------------
		// STATE 6 - compute is done, refer to diagram
		// ------------------------------------------------------------------
		else if ( state == state_7 ) begin

			if ( current_row == bottom_row ) begin
				u_reg_bottom <= u_next;
				u_reg_down	 <= u_reg_bottom;

				u_reg_center <= u_up;

				u_write_sig  <= 1'd0;
			end
			else if ( current_row == top_row ) begin
				u_reg_bottom <= u_reg_bottom;
				u_reg_down	 <= u_reg_down;
				u_reg_center <= u_reg_center;

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

				u_reg_down <= u_reg_center;
			end
			
			state <= state_8; // wait a cycle to perform write into M10K
		end
		// ------------------------------------------------------------------
		// STATE 7 - move to next node while M10K Blocks write
		// ------------------------------------------------------------------
		else if (state == state_8) begin
			if ( current_row == top_row ) begin
				current_row <= 0;
			end
			else begin
				current_row <= current_row + 1;	
			end
            flag_reg <= 1'd1;
			state 	 <= state_9; 
		end
		// ------------------------------------------------------------------
		// STATE 8 - Wait for the synchronization signal to start next 
		// ------------------------------------------------------------------
		else if ( state == state_9 )begin
			state <= state_3;
		end

	end
	
	compute next_node(
		.node_center		(u_center),
		.node_up			(u_up), 
		.node_down			(u_down), 
		.node_left			(node_left), 
		.node_right			(node_right), 
		.mult_alpha_delta	(mult_alpha_delta), 
		.new_center			(u_next));

endmodule