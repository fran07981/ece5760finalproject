//module int_to_binary(
//	input  decimal,
//	output [9:0] binary
//);
//	integer i;
//
//    for (i = 9; i >= 0; i = i - 1) begin
//      if (decimal >= (1 << i)) begin
//        binary[i] = 1; // set the ith bit in binary to 1
//        decimal = decimal - (1 << i); // subtract 2^i from decimal
//      end
//    end
//  
//endmodule

module i_to_binary_ew (
	input i,
	input clk, 
	output reg [9:0] x
);
    always @(posedge clk) begin
        if (i == 0) x <= 10'd1; 
        else if (i == 1) x <= 10'd2; 
        else if (i == 2) x <= 10'd3;
        else if (i == 3) x <= 10'd4; 
        else if (i == 4) x <= 10'd5;
        else if (i == 5) x <= 10'd6; 
        else if (i == 6) x <= 10'd7;
        else if (i == 7) x <= 10'd8; 
        else if (i == 8) x <= 10'd9;
        else if (i == 9) x <= 10'd10;

        else if (i == 10) x <= 10'd11;
        else if (i == 11) x <= 10'd12; 
        else if (i == 12) x <= 10'd13;
        else if (i == 13) x <= 10'd14; 
        else if (i == 14) x <= 10'd15;
        else if (i == 15) x <= 10'd16; 
        else if (i == 16) x <= 10'd17;
        else if (i == 17) x <= 10'd18; 
        else if (i == 18) x <= 10'd19;
        else if (i == 19) x <= 10'd20;

        else if (i == 20) x <= 10'd21;
        else if (i == 21) x <= 10'd22; 
        else if (i == 22) x <= 10'd23;
        else if (i == 23) x <= 10'd24; 
        else if (i == 24) x <= 10'd25;
        else if (i == 25) x <= 10'd26; 
        else if (i == 26) x <= 10'd27;
        else if (i == 27) x <= 10'd28; 
        else if (i == 28) x <= 10'd29;
        else if (i == 29) x <= 10'd30;

        else if (i == 30) x <= 10'd31;
        else if (i == 31) x <= 10'd32; 
        else if (i == 32) x <= 10'd33;
        else if (i == 33) x <= 10'd34;
        else if (i == 34) x <= 10'd35; 
        else if (i == 35) x <= 10'd36;
        else if (i == 36) x <= 10'd37;
        else if (i == 37) x <= 10'd38; 
        else if (i == 38) x <= 10'd39;
        else if (i == 39) x <= 10'd40;
        else if (i == 40) x <= 10'd41;
    end
endmodule
