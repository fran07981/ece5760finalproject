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

// module i_to_binary_ew (
// 	input i,
// 	input clk, 
// 	output reg [9:0] x
// );
//     always @(posedge clk) begin
//         if (i == 0) x <= 10'd0; 
//         else if (i ==  1) x <= 10'd1; 
//         else if (i ==  2) x <= 10'd2;
//         else if (i ==  3) x <= 10'd3;
//         else if (i ==  4) x <= 10'd4;
//         else if (i ==  5) x <= 10'd5;
//         else if (i ==  6) x <= 10'd6;
//         else if (i ==  7) x <= 10'd7;
//         else if (i ==  8) x <= 10'd8;
//         else if (i ==  9) x <= 10'd9;
//         else if (i == 10) x <= 10'd10;
//         else if (i == 11) x <= 10'd11;
//         else if (i == 12) x <= 10'd12;
//         else if (i == 13) x <= 10'd13;
//         else if (i == 14) x <= 10'd14;
//         else if (i == 15) x <= 10'd15;
//         else if (i == 16) x <= 10'd16;
//         else if (i == 17) x <= 10'd17;
//         else if (i == 18) x <= 10'd18;
//         else if (i == 19) x <= 10'd19;
//         else if (i == 20) x <= 10'd20;
//         else if (i == 21) x <= 10'd21;
//         else if (i == 22) x <= 10'd22;
//         else if (i == 23) x <= 10'd23;
//         else if (i == 24) x <= 10'd24;
//         else if (i == 25) x <= 10'd25;
//         else if (i == 26) x <= 10'd26;
//         else if (i == 27) x <= 10'd27;
//         else if (i == 28) x <= 10'd28;
//         else if (i == 29) x <= 10'd29;
//         else if (i == 30) x <= 10'd30;
//         else if (i == 31) x <= 10'd31;
//         else if (i == 32) x <= 10'd32;
//         else if (i == 33) x <= 10'd33;
//         else if (i == 34) x <= 10'd34;
//         else if (i == 35) x <= 10'd35;
//         else if (i == 36) x <= 10'd36;
//         else if (i == 37) x <= 10'd37;
//         else if (i == 38) x <= 10'd38;
//         else if (i == 39) x <= 10'd39;
//         else if (i == 40) x <= 10'd40;
//         else if (i == 41) x <= 10'd41;
//         else if (i == 42) x <= 10'd42;
//         else if (i == 43) x <= 10'd43;
//         else if (i == 44) x <= 10'd44;
//         else if (i == 45) x <= 10'd45;
//         else if (i == 46) x <= 10'd46;
//         else if (i == 47) x <= 10'd47;
//         else if (i == 48) x <= 10'd48;
//         else if (i == 49) x <= 10'd49;
//         else if (i == 50) x <= 10'd50;
//         else if (i == 51) x <= 10'd51;
//         else if (i == 52) x <= 10'd52;
//         else if (i == 53) x <= 10'd53;
//         else if (i == 54) x <= 10'd54;
//         else if (i == 55) x <= 10'd55;
//         else if (i == 56) x <= 10'd56;
//         else if (i == 57) x <= 10'd57;
//         else if (i == 58) x <= 10'd58;
//         else if (i == 59) x <= 10'd59;
//         else if (i == 60) x <= 10'd60;
//         else if (i == 61) x <= 10'd61;
//         else if (i == 62) x <= 10'd62;
//         else if (i == 63) x <= 10'd63;
//         else if (i == 64) x <= 10'd64;
//         else if (i == 65) x <= 10'd65;
//         else if (i == 66) x <= 10'd66;
//         else if (i == 67) x <= 10'd67;
//         else if (i == 68) x <= 10'd68;
//         else if (i == 69) x <= 10'd69;
//         else if (i == 70) x <= 10'd70;
//         else if (i == 71) x <= 10'd71;
//         else if (i == 72) x <= 10'd72;
//         else if (i == 73) x <= 10'd73;
//         else if (i == 74) x <= 10'd74;
//         else if (i == 75) x <= 10'd75;
//         else if (i == 76) x <= 10'd76;
//         else if (i == 77) x <= 10'd77;
//         else if (i == 78) x <= 10'd78;
//         else if (i == 79) x <= 10'd79;
//         else if (i == 80) x <= 10'd80;
//         else if (i == 81) x <= 10'd81;
//         else if (i == 82) x <= 10'd82;
//         else if (i == 83) x <= 10'd83;
//         else if (i == 84) x <= 10'd84;
//         else if (i == 85) x <= 10'd85;
//         else if (i == 86) x <= 10'd86;
//         else if (i == 87) x <= 10'd87;
//         else if (i == 88) x <= 10'd88;
//         else if (i == 89) x <= 10'd89;
//         else if (i == 90) x <= 10'd90;
//         else if (i == 91) x <= 10'd91;
//         else if (i == 92) x <= 10'd92;
//         else if (i == 93) x <= 10'd93;
//         else if (i == 94) x <= 10'd94;
//         else if (i == 95) x <= 10'd95;
//         else if (i == 96) x <= 10'd96;
//         else if (i == 97) x <= 10'd97;
//         else if (i == 98) x <= 10'd98;
//         else if (i == 99) x <= 10'd99;
        
//     end
// endmodule
