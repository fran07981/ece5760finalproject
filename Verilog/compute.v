//============================================================
// COMPUTE - finds the center_Grid values value at time t = n + 1 
//============================================================
module compute(node_center, node_up, node_down, node_left, node_right, alpha, delta, new_center);

    // 5.27 Signed Fixed Point 

    input   wire signed [31:0] node_center;
    input   wire signed [31:0] node_up;
    input   wire signed [31:0] node_down;
    input   wire signed [31:0] node_left;
    input   wire signed [31:0] node_right;

    input   wire signed [31:0] alpha;
    input   wire signed [31:0] delta;

    output  wire signed [31:0] new_center;

    wire signed [17:0] u_sum_part_1;
    wire signed [17:0] u_sum_part_2;
    wire signed [17:0] u_sum_part_3;
    wire signed [17:0] u_sum_part_4;

    assign n_sum_part_1 = node_down     - node_center;
    assign n_sum_part_2 = node_left     - node_center;
    assign n_sum_part_3 = node_right    - node_center;
    assign n_sum_part_4 = node_up       - node_center;

    wire signed [31:0] mult_alpha_delta;
    signed_mult alpdel(
            .out (mult_alpha_delta),
            .a   (alpha),
            .b   (delta)
            );
            
    wire signed [31:0] n_sum_result;
    assign n_sum_result = n_sum_part_1 + n_sum_part_2 +  n_sum_part_3 + n_sum_part_4;

    wire signed [31:0] n_add;
    signed_mult newval(
            .out (n_add),
            .a   (mult_alpha_delta),
            .b   (n_sum_result)
            );

    assign new_center = node_center + n_add;
endmodule

//============================================================
// 5.27 Fixed Point Signed Multiplication
//============================================================

module signed_mult(out, a, b);
    output  signed [31:0] out;
    input   signed [31:0] a;
    intput  signed [31:0] b;

    // intermediate full bit length 
    wire    signed [63:0] mult_out;
    assign mult_out = a*b;

    assign out = {mult_out[63],mult_out[61:30]} 
endmodule