`include "column.v"
`include "compute.v"

// TEST BENCH
module testbench();

    reg clk_50, reset;

    //wire signed [17:0] testbench_next_node;

    //Initialize clock
    initial begin   
        clk_50 = 1'b0;
    end

    //Toggle the clocks
	always begin
		#10
		clk_50  = !clk_50;
	end

    //Intialize and drive signals
	initial begin
		reset  = 1'b0;
		#10 
		reset  = 1'b1;
		#30
		reset  = 1'b0;
	end

	reg [31:0] index = 32'd0;
	//Increment index
	always @ (posedge clk_50) begin
		index  <= index + 32'd1;
	end

	// Constants
	wire signed [31:0] fp_0    = 32'b0_0000_0000_0000_0000_0000_0000_0000_000;	// 0 
	
	// Define alpha
	wire signed [31:0] alpha;	// initial value of alpha = 0.8
	assign alpha = 32'b0_0000_1100_1100_1100_0000_0000_0000_000;

    wire signed [31:0] delta;	// initial value of delta = 0.1
	assign delta = 32'b0_0000_0001_1001_1000_0000_0000_0000_0000_0000_000;

	wire start = 1'd1;

    wire signed [31:0] mult_alpha_delta;
    signed_mult alpdel(
            .out (mult_alpha_delta),
            .a   (alpha),
            .b   (delta)
            );

	// Height and Width start indexing at 0
	reg [31:0] height = 32'd29;
	reg [31:0] width =  32'd29;

	// OUTPUTS
    wire signed [31:0] node_n   [0:29];	// Amptiude of nodes on current row change with time

	reg [31:0] timer = 32'b0;
	// Generate 
	localparam n = 30;
	genvar i;
	generate
		for (i = 0; i < n; i = i + 1) begin : gen_block

			wire [31:0] current_col = i;

			reg signed [31:0] left_val;
			reg signed [31:0] right_val;
			wire flag;

			always @ (posedge clk_50) begin
				left_val  <= (i == 0)     ? 0 : node_n[ i - 1 ];
				right_val <= (i == width) ? 0 : node_n[ i + 1 ];
			end

			// Simulate a column x 1 node with zero boundary conditions
            build_column(clk, reset, current_col, height, width, mult_alpha_delta, node_right, node_left, so_y_coord, si_y_coord, node_center, flag, start);
			build_column col_one(
				.clk	 	            (clk_50),			
				.reset	 	            (reset),
				.current_col            (current_col),	// we are starting with just 1 col, so its the 0th column 
				.height		            (height), 
				.width		            (width), 	// TODO: discuss all together how to get this to a 1
				.mult_alpha_delta 	    (mult_alpha_delta),
				.u_right                (right_val), 
				.u_left	                (left_val), 
				.u_n		            (u_n[i]),
				.flag		            (flag),
				.start		            (start)
			);
		end
	endgenerate

endmodule
	