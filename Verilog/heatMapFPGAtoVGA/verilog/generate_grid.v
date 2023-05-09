 `include "column.v"
 //`include "compute.v"

module generate_grid ( clk_50, reset, start, flag //, u_read_addr, u_read_data 
);
	input clk_50, reset;
	input wire start; 
	
    output wire flag;
    reg flag_computing;
    reg flag_writing;
    assign flag = flag_writing;
	
	// Drum Dimensions - Height and Width start indexing at 0
	reg [7:0] height    =  8'd63;
	reg [7:0] width     =  8'd63;
    
    reg [7:0] pixel_color;
	
	// Constants
	wire signed [31:0] fp_0    = 32'b0_0000_0000_0000_0000_0000_0000_0000_000;	// 0 

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
    reg         [ 7:0] col;
	 reg [5:0] state = 0;

    always @ (posedge clk_50) begin
        if (flag_computing == 1'd1) begin // WRITING TO M10K BLOCK
            // State 0
            if (state == 6'd0) begin
                flag_writing <= 1'd0; 
                col          <= 0;
                state        <= 6'd1;
            end

            // State 1
            if (state == 6'd1) begin
                state        <= 6'd2;
            end

            // State 2
            if (state == 6'd2) begin
                u_write_addr <= 0; //{ 2'd0, col};
				u_write_data <= 8'b11111111; //pixel_color; //node_n[col];
				u_write_sig  <= 1'd1;
                state        <= 6'd3;
            end

            // State 3 - waiting to write
            if (state == 6'd3) begin
                state <= 6'd4;
            end

            if (state == 6'd4) begin
                state <= 6'd5;
            end
            
            // State 4
            if (state == 6'd5) begin
                if ( col == 8'd63) begin
                    col         <= 0;
                    state       <= 6'd6;
                    u_write_sig <= 0;
                end
                else begin
                    col <= col + 1'd1;
                    state <= 6'd1;
                end
            end

            // State 5
            if (state == 6'd6) begin
                flag_writing <= 1'd1;
                state        <= 6'd7;
            end
            if (state == 6'd7) begin
                u_read_addr <= 0;
                state       <= 6'd8;
            end
            if (state == 6'd8) begin
                state        <= 6'd8;
            end
        end
        else begin  // WATING FOR COMPUTE
            u_write_sig  <= 1'd0;
            flag_writing <= 1'd0; 
            state        <= 0;
        end
    end


    reg          [ 7:0] u_read_addr;	// select the row
    reg unsigned [31:0] u_read_data;
    reg unsigned [31:0] u_write_data;
	reg          [ 7:0] u_write_addr;	// select the row
	reg 	            u_write_sig;
    wire unsigned [31:0] u_read_data_wire;
    
    always @ (posedge clk_50) begin
        u_read_data<=u_read_data_wire;
    end
	
	M10K_256_32 u(  
		.q				(u_read_data_wire),		// the return data value during reads
		.d				(u_write_data), 	// set to data we want to write
		.write_address	(u_write_addr), 	// send it the address we want to write
		.read_address	(u_read_addr),   	// addr we want to read
		.we				(u_write_sig), 		// if we want to write we = 1'd1, else, we = 1'd0
		.clk			(clk) 
    );
    
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
                if( i == 0 ) flag_computing <= temp; 
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
	


     // 8 bits
                // R bits 5-7
                // G bits 2-4
                // B bits 0-1
        
                //node center is in 5.27
                // if (node_n[col] >= 32'b0_0110_0000_0000_0000_0000_0000_0000_000)  begin // >6
                //     pixel_color <= 8'b111_000_00; //red
                // end
                // else if (node_n[col] >= 32'b0_0100_0000_0000_0000_0000_0000_0000_000) begin // >4
                //     pixel_color <= 8'b_111_010_00 ; //orange
                // end
                // else if (node_n[col] >= 32'b0_0010_0000_0000_0000_0000_0000_0000_000)  begin  // >2
                //     pixel_color <= 8'b_110_011_01 ; //marigold??
                // end
                // else if (node_n[col] >= 32'b0_0000_0000_0000_0000_0000_0000_0000_000) begin // >0
                //     pixel_color <= 8'b_111_111_11 ; //white
                // end
                // else if (node_n[col] >= -32'sb0_0010_0000_0000_0000_0000_0000_0000_000)  begin // >-2
                //     pixel_color <= 8'b_011_101_11 ; // cyan-blue ish
                // end
                // else if (node_n[col] >= -32'sb0_0100_0000_0000_0000_0000_0000_0000_000)  begin // >-4
                //     pixel_color <= 8'b111_110_00; //pink
                // end
                // else if (node_n[col] >= -32'sb0_0110_0000_0000_0000_0000_0000_0000_000) begin // >-6
                //     pixel_color <= 8'b111_000_11 ; //purple 
                // end else begin //<=-6
                //     pixel_color <= 8'b_1111_1111 ; //black
                // end