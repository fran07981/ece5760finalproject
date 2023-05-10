//============================================================
// COMPUTE - finds the center_Grid values value at time t = n + 1 
//============================================================
module compute(node_center, node_up, node_down, node_left, node_right, mult_alpha_delta, new_center);

    // 5.27 Signed Fixed Point 

    input   wire signed [31:0] node_center;
    input   wire signed [31:0] node_up;
    input   wire signed [31:0] node_down;
    input   wire signed [31:0] node_left;
    input   wire signed [31:0] node_right;

    input   wire signed [31:0] mult_alpha_delta;

    output  wire signed [31:0] new_center;

    wire signed [31:0] n_sum_part_1;
    wire signed [31:0] n_sum_part_2;
    wire signed [31:0] n_sum_part_3;
    wire signed [31:0] n_sum_part_4;

    wire signed [31:0] fp_src    = 32'b0_1000_0000_0000_0000_0000_0000_0000_000;	// 8 
    wire signed [31:0] fp_snk    = -32'sb0_1000_0000_0000_0000_0000_0000_0000_000;	// -8

    // Add logic to check for value of source/sink before modifying. 

    assign n_sum_part_1 = node_down     - node_center;
    assign n_sum_part_2 = node_left     - node_center;
    assign n_sum_part_3 = node_right    - node_center;
    assign n_sum_part_4 = node_up       - node_center;

            
    wire signed [31:0] n_sum_result;
    assign n_sum_result = n_sum_part_1 + n_sum_part_2 +  n_sum_part_3 + n_sum_part_4;

    wire signed [31:0] n_add;
    signed_mult newval(
            .out (n_add),
            .a   (mult_alpha_delta),
            .b   (n_sum_result)
            );

    assign new_center = node_center != fp_src ? (node_center != fp_snk ? node_center + n_add : node_center) : node_center;
endmodule

//============================================================
// 5.27 Fixed Point Signed Multiplication
//============================================================

module signed_mult(out, a, b);
    output  signed [31:0] out;
    input   signed [31:0] a;
    input  signed [31:0] b;

    // intermediate full bit length 
    wire    signed [63:0] mult_out;
    assign mult_out = a*b;

    assign out = {mult_out[58],mult_out[57:27]} ;
endmodule

//============================================================
// M10K Module Definitions
//============================================================

// M10K Memory block structure: 
// word 1		node 1 = u [ 17:0 ]
// word 2		node 2
// .
// .
// word 256		node 32

module M10K_256_32( 
    output reg [31:0] q,
    input [31:0] d,
    input [7:0] write_address, read_address,
    input we, clk
);
	 // force M10K ram style
    reg [31:0] mem [255:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
        end
        q <= mem[read_address]; // q doesn't get d in this clock cycle
    end
endmodule