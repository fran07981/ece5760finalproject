 `include "column.v"
 //`include "compute.v"

module generate_grid ( clk_50, reset, start, flag,
    node_n0, node_n1, node_n2, node_n3, node_n4, node_n5, 
    node_n6, node_n7, node_n8, node_n9, node_n10, node_n11, node_n12, node_n13, node_n14, node_n15, node_n16, node_n17, 
    node_n18, node_n19, node_n20, node_n21, node_n22, node_n23, node_n24, node_n25, node_n26, node_n27, node_n28, node_n29, 
    node_n30, node_n31, node_n32, node_n33, node_n34, node_n35, node_n36, node_n37, node_n38, node_n39, node_n40, node_n41, 
    node_n42, node_n43, node_n44, node_n45, node_n46, node_n47, node_n48, node_n49, node_n50, node_n51, node_n52, node_n53, 
    node_n54, node_n55, node_n56, node_n57, node_n58, node_n59, node_n60, node_n61, node_n62, node_n63
);
	input clk_50, reset;
	input wire start; 
	
    output wire flag;
    reg flag_send;
    assign flag = flag_send;
	
	// Drum Dimensions - Height and Width start indexing at 0
	reg [7:0] height    =  8'd63;
	reg [7:0] width     =  8'd63;
	
	// Constants
	wire signed [31:0] fp_0    = 32'b0_0000_0000_0000_0000_0000_0000_0000_000;	// 0 

	// input wire signed [31:0] alpha;	// initial value of alpha = 0.8
    // input wire signed [31:0] delta;	// initial value of delta = 0.1

    // Define alpha
	wire signed [31:0] alpha;	// initial value of alpha = 0.8
	assign alpha = 32'b0_0000_1100_1100_1100_0000_0000_0000_000;

    wire signed [31:0] delta;	// initial value of delta = 0.1
	assign delta = 32'b0_0000_0001_1001_1000_0000_0000_0000_000;

	// Delta*Alpha Calculation
    wire signed [31:0] mult_alpha_delta;
    signed_mult alpdel(
            .out (mult_alpha_delta),
            .a   (alpha),
            .b   (delta)
            );

	// OUTPUTS
    wire signed [31:0] node_n   [0:63];	// Amptiude of nodes on current row change with time
    
    output reg signed [31:0] node_n0 = 8'b1111_1111;
    output reg signed [31:0] node_n1 = 8'b1111_1111;
    output reg signed [31:0] node_n2 = 8'b1111_1111;
    output reg signed [31:0] node_n3 = 8'b1111_1111;
    output reg signed [31:0] node_n4 = 8'b1111_1111;
    output reg signed [31:0] node_n5 = 8'b1111_1111;
    output reg signed [31:0] node_n6 = 8'b1111_1111;
    output reg signed [31:0] node_n7 = 8'b1111_1111;
    output reg signed [31:0] node_n8 = 8'b1111_1111;
    output reg signed [31:0] node_n9 = 8'b1111_1111;
    output reg signed [31:0] node_n10 = 8'b1111_1111;
    output reg signed [31:0] node_n11 = 8'b1111_1111;
    output reg signed [31:0] node_n12 = 8'b1111_1111;
    output reg signed [31:0] node_n13 = 8'b1111_1111;
    output reg signed [31:0] node_n14 = 8'b1111_1111;
    output reg signed [31:0] node_n15 = 8'b1111_1111;
    output reg signed [31:0] node_n16 = 8'b1111_1111;
    output reg signed [31:0] node_n17 = 8'b1111_1111;
    output reg signed [31:0] node_n18 = 8'b1111_1111;
    output reg signed [31:0] node_n19 = 8'b1111_1111;
    output reg signed [31:0] node_n20 = 8'b1111_1111;
    output reg signed [31:0] node_n21 = 8'b1111_1111;
    output reg signed [31:0] node_n22 = 8'b1111_1111;
    output reg signed [31:0] node_n23 = 8'b1111_1111;
    output reg signed [31:0] node_n24 = 8'b1111_1111;
    output reg signed [31:0] node_n25 = 8'b1111_1111;
    output reg signed [31:0] node_n26 = 8'b1111_1111;
    output reg signed [31:0] node_n27 = 8'b1111_1111;
    output reg signed [31:0] node_n28 = 8'b1111_1111;
    output reg signed [31:0] node_n29 = 8'b1111_1111;
    output reg signed [31:0] node_n30 = 8'b1111_1111;
    output reg signed [31:0] node_n31 = 8'b1111_1111;
    output reg signed [31:0] node_n32 = 8'b1111_1111;
    output reg signed [31:0] node_n33 = 8'b1111_1111;
    output reg signed [31:0] node_n34 = 8'b1111_1111;
    output reg signed [31:0] node_n35 = 8'b1111_1111;
    output reg signed [31:0] node_n36 = 8'b1111_1111;
    output reg signed [31:0] node_n37 = 8'b1111_1111;
    output reg signed [31:0] node_n38 = 8'b1111_1111;
    output reg signed [31:0] node_n39 = 8'b1111_1111;
    output reg signed [31:0] node_n40 = 8'b1111_1111;
    output reg signed [31:0] node_n41 = 8'b1111_1111;
    output reg signed [31:0] node_n42 = 8'b1111_1111;
    output reg signed [31:0] node_n43 = 8'b1111_1111;
    output reg signed [31:0] node_n44 = 8'b1111_1111;
    output reg signed [31:0] node_n45 = 8'b1111_1111;
    output reg signed [31:0] node_n46 = 8'b1111_1111;
    output reg signed [31:0] node_n47 = 8'b1111_1111;
    output reg signed [31:0] node_n48 = 8'b1111_1111;
    output reg signed [31:0] node_n49 = 8'b1111_1111;
    output reg signed [31:0] node_n50 = 8'b1111_1111;
    output reg signed [31:0] node_n51 = 8'b1111_1111;
    output reg signed [31:0] node_n52 = 8'b1111_1111;
    output reg signed [31:0] node_n53 = 8'b1111_1111;
    output reg signed [31:0] node_n54 = 8'b1111_1111;
    output reg signed [31:0] node_n55 = 8'b1111_1111;
    output reg signed [31:0] node_n56 = 8'b1111_1111;
    output reg signed [31:0] node_n57 = 8'b1111_1111;
    output reg signed [31:0] node_n58 = 8'b1111_1111;
    output reg signed [31:0] node_n59 = 8'b1111_1111;
    output reg signed [31:0] node_n60 = 8'b1111_1111;
    output reg signed [31:0] node_n61 = 8'b1111_1111;
    output reg signed [31:0] node_n62 = 8'b1111_1111;
    output reg signed [31:0] node_n63 = 8'b1111_1111;

	
	//reg done_reg;

	// Generate 
	localparam n = 63;
	genvar i;
	generate
		for (i = 0; i <= n; i = i + 1) begin : gen_block

			wire [8:0] current_col = i;
			
			reg signed [31:0] left_val;
			reg signed [31:0] right_val;

         wire temp;

			always @ (posedge clk_50) begin
				left_val  <= (i == 0)     ? 0 : node_n[ i - 1 ];
				right_val <= (i == 63) ? 0 : node_n[ i + 1 ];
                if( i == 0 ) flag_send <= temp;
                // else if( i == 1 ) node_n1 <= node_n[i];
                // else if( i == 2 ) node_n2 <= node_n[i];
			end

			// unsure on how we are setting this up
			// assign done = done_reg;

			// Simulate a column x 1 node with zero boundary conditions
			
			build_column col_one(
				.clk	 	 		(clk_50),			
				.reset	 	 		(reset),
				.current_col 		(current_col),	// we are starting with just 1 col, so its the 0th column 
				.height		 		(height), 
				.width		 		(width), 	// TODO: discuss all together how to get this to a 1
				.mult_alpha_delta	(mult_alpha_delta),
				.node_right			(right_val), 
				.node_left	    	(left_val), 
				.node_center		(node_n[i]),
				.flag		    	(temp),		// tells us when we are done with calculating and waiting for next to start
				.start		 		(start),		// wait for vga to finish then start next ?? 
				.initflag 			(initflag)   // When initialization is done, i.e entire grid to 0s
			);
		end
	endgenerate

endmodule
	