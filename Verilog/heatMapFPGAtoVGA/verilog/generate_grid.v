`include "column.v"


module generate_grid ( clk_50, reset, write_data, write_addr, comp_allow, done_write_sig, flag_send ); // node_n, start);
	input clk_50, reset;

	// Drum Dimensions - Height and Width start indexing at 0
	reg  [7:0] height = 8'd63;
	reg  [7:0] width  = 8'd63;
	
	// Constants
	wire signed [31:0] fp_0    = 32'b0_0000_0000_0000_0000_0000_0000_0000_000;	// 0 
	wire signed [31:0] fp_red  = 32'b0_0110_0000_0000_0000_0000_0000_0000_000;	// red
	wire signed [31:0] fp_orange = 32'b0_0100_0000_0000_0000_0000_0000_0000_000; //orange
	wire signed [31:0] fp_gold = 32'b0_0010_0000_0000_0000_0000_0000_0000_000;
	wire signed [31:0] fp_cyan = -32'sb0_0010_0000_0000_0000_0000_0000_0000_000; //cyanblue
	wire signed [31:0] fp_pink = -32'sb0_0100_0000_0000_0000_0000_0000_0000_000; //pink
	wire signed [31:0] fp_purple = -32'sb0_0110_0000_0000_0000_0000_0000_0000_000; //purple

	reg start = 0;
    output reg flag_send;

	// Delta*Alpha Calculation
    wire signed [31:0] mult_alpha_delta;
    signed_mult alpdel(
        .out (mult_alpha_delta),
        .a   (alpha),
        .b   (delta)
    );

    input                      comp_allow;
    output reg unsigned [31:0] write_data;
    output reg         [ 7:0] write_addr;
    output reg done_write_sig;

    reg [7:0] write_counter = 0;
    reg [7:0] state = 8'd30;

    always @ (posedge clk_50) begin
        if ( comp_allow == 1'd1 ) begin
            state <= 0;
            done_write_sig <= 0;
            write_counter <= 8'd0;
        end
        else begin
            if (state == 0) begin
                state <= 8'd1;
            end

            else if (state == 8'd1) begin
                
                if (node_n[write_counter] >= fp_red)  begin // >6
                    write_data <= 8'b111_000_00; //red
                end
                else if (node_n[write_counter] >= fp_orange) begin // >4
                    write_data <= 8'b_111_010_00 ; //orange
                end
                else if (node_n[write_counter] >= fp_gold)  begin  // >2
                    write_data <= 8'b_110_011_01 ; //marigold??
                end
                else if (node_n[write_counter] >= fp_0) begin // >0
                    write_data <= 8'b_000_000_00 ; //black
                end
                else if (node_n[write_counter] >= fp_cyan)  begin // >-2
                    write_data <= 8'b_011_101_11 ; // cyan-blue ish
                end
                else if (node_n[write_counter] >= fp_pink)  begin // >-4
                    write_data <= 8'b111_110_00; //pink
                end
                else if (node_n[write_counter] >= fp_purple) begin // >-6
                    write_data <= 8'b111_000_11 ; //purple 
                end else begin //<=-6
                    write_data <= 8'b_1111_1111 ; //black
                end

                write_addr <= write_counter;
                state <= 8'd2;
            end
            
            else if (state == 8'd2) begin
                state <= 8'd3;
            end
            
            else if (state == 8'd3) begin
                state <= 8'd4;
            end
            
            else if (state == 8'd4) begin
                if ( write_counter == 8'd63 ) begin
                    write_counter <= 8'd0;
                    state <= 8'd5;
                    start <= 1'd1;
                    done_write_sig <= 1'd1;
                end
                else begin
                    write_counter <= write_counter + 8'd1;
                    state <= 8'd0;
                end
            end
            
            else if (state == 8'd5 ) begin
                state <= 8'd5;
                start <= 1'd0;
                done_write_sig <= 0;
            end
        end
    end

    // wire signed [31:0] alpha;	// initial value of alpha = 0.8
    assign alpha = 32'b0_0000_1100_1100_1100_0000_0000_0000_000;

    wire signed [31:0] delta;	// initial value of delta = 0.1
    assign delta = 32'b0_0000_0001_1001_1000_0000_0000_0000_000;

        // OUTPUTS
    wire signed [31:0] node_n   [0:63];	// Amptiude of nodes on current row change with time

        reg done_reg;

    //	Generate 
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
                    if ( i == 0 ) flag_send <= temp;
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
                    .start		 		(start)   // When initialization is done, i.e entire grid to 0s
                );
            end
        endgenerate

endmodule