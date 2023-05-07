// `include "column.v"
// `include "compute.v"

// module generate_grid ( clk_50, reset, start, alpha, delta, height, node_n);
// 	input clk_50, reset;
// 	input wire start; 
// 	//output done;
	
// 	// Drum Dimensions - Height and Width start indexing at 0
// 	input wire  [7:0] height;
// 	reg 	    [7:0] width =  8'd29;
	
// 	// Constants
// 	wire signed [31:0] fp_0    = 32'b0_0000_0000_0000_0000_0000_0000_0000_000;	// 0 

// 	input wire signed [31:0] alpha;	// initial value of alpha = 0.8
//     input wire signed [31:0] delta;	// initial value of delta = 0.1

// 	wire start = 1'd1;

// 	// Delta*Alpha Calculation
//     wire signed [31:0] mult_alpha_delta;
//     signed_mult alpdel(
//             .out (mult_alpha_delta),
//             .a   (alpha),
//             .b   (delta)
//             );

// 	// OUTPUTS
//    	output wire signed [31:0] node_n   [0:29];	// Amptiude of nodes on current row change with time
	
// 	//reg done_reg;

// 	// Generate 
// 	localparam n = 29;
// 	genvar i;
// 	generate
// 		for (i = 0; i <= n; i = i + 1) begin : gen_block

// 			wire [8:0] current_col = i;
			
// 			reg signed [31:0] left_val;
// 			reg signed [31:0] right_val;
// 			wire flag;

// 			always @ (posedge clk_50) begin
// 				left_val  <= (i == 0)     ? 0 : node_n[ i - 1 ];
// 				right_val <= (i == width) ? 0 : node_n[ i + 1 ];
// 			end

// 			// unsure on how we are setting this up
// 			// assign done = done_reg;

// 			// Simulate a column x 1 node with zero boundary conditions
// 			build_column(clk, reset, current_col, height, width, mult_alpha_delta, node_right, node_left, node_center, flag, start, initflag);
// 			build_column col_one(
// 				.clk	 	 		(clk_50),			
// 				.reset	 	 		(reset),
// 				.current_col 		(current_col),	// we are starting with just 1 col, so its the 0th column 
// 				.height		 		(height), 
// 				.width		 		(width), 	// TODO: discuss all together how to get this to a 1
// 				.mult_alpha_delta	(mult_alpha_delta),
// 				.node_right			(right_val), 
// 				.node_left	    	(left_val), 
// 				.node_center		(node_n[i]),
// 				.flag		    	(flag),		// tells us when we are done with calculating and waiting for next to start
// 				.start		 		(start),		// wait for vga to finish then start next ?? 
// 				.initflag 			(initflag)   // When initialization is done, i.e entire grid to 0s
// 			);
// 		end
// 	endgenerate

// endmodule
	