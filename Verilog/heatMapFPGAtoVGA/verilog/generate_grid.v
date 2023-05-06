`include "column.v"

module generate_grid ( clk_50, reset, start, u_init, rho_init, height, u_center, timer_output, done );
	input clk_50, reset;
	input wire start; 
	output done;
	
	// Drum Dimensions - Height and Width start indexing at 0
	input wire  [8:0] height;
	reg 	    [8:0] width =  9'd29;
	
	// delta calculation here *
	input wire signed [17:0] u_init;

	// Define rho
	input wire signed [17:0] rho_init;

	wire signed [17:0] rho;
	reg  signed [17:0] rho_eff;
	
	// Constants
	wire signed [17:0] fp_0    = 18'b0_0000_0000_0000_0000_0;	// 0
	wire signed [17:0] fp_0312 = 18'b0_0000_1000_0000_0000_0;	// 0.0625
	wire signed [17:0] fp_0625 = 18'b0_0001_0000_0000_0000_0;	// 0.0625
	wire signed [17:0] fp_1250 = 18'b0_0010_0000_0000_0000_0; 	// 0.125
	wire signed [17:0] fp_049  = 18'b0_0111_1101_0111_0000_1; 	//0.49

	// OUTPUTS
    wire signed [17:0] u_n   [0:29];	// Amptiude of nodes on current row change with time
	wire signed [17:0] u_mid [0:29]; // Amptiude of nodes in the middle of the column change with full col change

	output wire signed [17:0] u_center; 
	assign u_center = u_mid[14];
	
	wire signed [17:0] mult_uG_square;
	signed_mult ug2(
		.out (mult_uG_square),
		.a   (u_mid[14]>>>4),
		.b   (u_mid[14]>>>4)
		);

	reg [31:0] timer;
	output wire [31:0] timer_output;

	reg done_reg;

	// Generate 
	localparam n = 29;
	genvar i;
	generate
		for (i = 0; i <= n; i = i + 1) begin : gen_block

			wire [8:0] current_col = i;
			
			reg signed [17:0] left_val;
			reg signed [17:0] right_val;
			wire flag;

			always @ (posedge clk_50) begin
				left_val  <= (i == 0)     ? 0 : u_n[ i - 1 ];
				right_val <= (i == 9'd29) ? 0 : u_n[ i + 1 ];
				
				// set start based on when audio is ready for next samples
				if (flag == 1'b1 & i==0)begin
					rho_eff <= fp_049 < rho_init + mult_uG_square ? fp_049 : rho_init + mult_uG_square;
					timer   <= timer;
					done_reg <= 1'b1;
				end
				// else if (start == 1'b1) timer <= 1'd0;
				else if (i==0 & flag ==1'b1) begin
					rho_eff <= rho_init;
					timer   <= timer + 32'd1;
					done_reg <= 1'b0;
				end 
				else if (reset == 32'b1 & i==0) begin
					timer <= 32'b0;
					done_reg <= 1'b0;
				end
			end

			assign rho = rho_eff;
			assign done = done_reg;
		   assign timer_output = timer;

			// Simulate a column x 1 node with zero boundary conditions
			build_column col_one(
				.clk	 	 (clk_50),			
				.reset	 	 (reset),
				.current_col (current_col),	// we are starting with just 1 col, so its the 0th column 
				.height		 (height), 
				.width		 (width), 	// TODO: discuss all together how to get this to a 1
				.rho_eff 	 (rho),
				.u_right     (right_val), 
				.u_left	    (left_val), 
				.u_n		    (u_n[i]),
				.u_mid_output(u_mid[i]),
				.flag		    (flag),		// tells us when we are done with 1 iteration so recalc rho!
				.start		 (start)		// wait for audio to finish then start next 
			);
		end
	endgenerate

endmodule
	