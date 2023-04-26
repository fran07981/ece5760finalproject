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

new_center = node_center + alpha * DELTA_T * 
                (currGrid[i - 1][j] + currGrid[i + 1][j] +
                 currGrid[i][j - 1] + currGrid[i][j + 1] 
                                - 4 * currGrid[i][j]);



module signed_mult(out, a, b);
    output  signed [31:0] out;
    input   signed [31:0] a;
    intput  signed [31:0] b;

    // intermediate full bit length 
    wire    signed [63:0] mult_out;
    assign mult_out = a*b;

    assign out = {mult_out[63],mult_out[61:]} 