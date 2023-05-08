module read_DPS_module (clock, pixel_color, reset, 
                        sram_readdata, sram_writedata, sram_address, sram_write, 
                        flag, col_select, return_sig, row_select
);
    input clock, reset;
    localparam n = 64;
    
    input wire [   31:0] sram_readdata;
    input      [n - 1:0] return_sig; // one [] per column

    output reg 	         sram_write;
    output reg [   7 :0] sram_address;
    output reg [   31:0] sram_writedata;
    output reg [n - 1:0] col_select  = 0; // one [] per column
	output reg [    9:0] row_select  = 0; // says which row number
    output reg           pixel_color = 8'b1111_1111;
    output reg           flag = 0;

    reg signed [7:0] node_n0;
    reg signed [7:0] node_n1;
    reg signed [7:0] node_n2;
    reg signed [7:0] node_n3;
    reg signed [7:0] node_n4;
    reg signed [7:0] node_n5;
    reg signed [7:0] node_n6;
    reg signed [7:0] node_n7;
    reg signed [7:0] node_n8;
    reg signed [7:0] node_n9;
    reg signed [7:0] node_n10;
    reg signed [7:0] node_n11;
    reg signed [7:0] node_n12;
    reg signed [7:0] node_n13;
    reg signed [7:0] node_n14;
    reg signed [7:0] node_n15;
    reg signed [7:0] node_n16;
    reg signed [7:0] node_n17;
    reg signed [7:0] node_n18;
    reg signed [7:0] node_n19;
    reg signed [7:0] node_n20;
    reg signed [7:0] node_n21;
    reg signed [7:0] node_n22;
    reg signed [7:0] node_n23;
    reg signed [7:0] node_n24;
    reg signed [7:0] node_n25;
    reg signed [7:0] node_n26;
    reg signed [7:0] node_n27;
    reg signed [7:0] node_n28;
    reg signed [7:0] node_n29;
    reg signed [7:0] node_n30;
    reg signed [7:0] node_n31;
    reg signed [7:0] node_n32;
    reg signed [7:0] node_n33;
    reg signed [7:0] node_n34;
    reg signed [7:0] node_n35;
    reg signed [7:0] node_n36;
    reg signed [7:0] node_n37;
    reg signed [7:0] node_n38;
    reg signed [7:0] node_n39;
    reg signed [7:0] node_n40;
    reg signed [7:0] node_n41;
    reg signed [7:0] node_n42;
    reg signed [7:0] node_n43;
    reg signed [7:0] node_n44;
    reg signed [7:0] node_n45;
    reg signed [7:0] node_n46;
    reg signed [7:0] node_n47;
    reg signed [7:0] node_n48;
    reg signed [7:0] node_n49;
    reg signed [7:0] node_n50;
    reg signed [7:0] node_n51;
    reg signed [7:0] node_n52;
    reg signed [7:0] node_n53;
    reg signed [7:0] node_n54;
    reg signed [7:0] node_n55;
    reg signed [7:0] node_n56;
    reg signed [7:0] node_n57;
    reg signed [7:0] node_n58;
    reg signed [7:0] node_n59;
    reg signed [7:0] node_n60;
    reg signed [7:0] node_n61;
    reg signed [7:0] node_n62;
    reg signed [7:0] node_n63;
	
    reg start = 0;  //start the next grid calculation
    reg grid_flag = 0;

    reg  [31:0] data_buffer;
    reg  [ 9:0] x, y, row;
    reg  [ 7:0] data;
    reg  [ 8:0] count;      // total possitble 256 values in M10K block
    reg  [ 8:0] vals;       // # of values that were sent over
    reg  [7 :0] state = 0;

	always @(posedge clock) begin // CLOCK_50

	    // ---------------- RESET ----------------------
		if (reset && (state == 0)) begin
			state          <= 8'd140;
			// sram_write     <= 0;
            // count          <= 0;
            flag           <= 1'd1;
            row <= 0;
        end
        
        if (state == 8'd140) begin
            state <= 8'd141;
        end
        
        else if (state == 8'd141) begin
            start <= 0;
            if (grid_flag == 1'd1) begin
                flag <= 1'd1;
                state <= 8'd1;
            end
            else state <= 8'd141;
        end
        
        // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
        else if (state == 8'd1)  begin col_select[0] <= 1'd1; row_select <= row; state <= 8'd2; pixel_color <= node_n0; end
        else if (state == 8'd2)  begin if (return_sig[0] == 1'd1) begin col_select[0] <= 0; state <= 8'd3; end else state <= 8'd1; end
        else if (state == 8'd3)  begin col_select[1] <= 1'd1; row_select <= row; state <= 8'd4; pixel_color <= node_n1; end
        else if (state == 8'd4)  begin if (return_sig[1] == 1'd1) begin col_select[1] <= 0; state <= 8'd5; end else state <= 8'd3; end
        else if (state == 8'd5)  begin col_select[2] <= 1'd1; row_select <= row; state <= 8'd6; pixel_color <= node_n2; end
        else if (state == 8'd6)  begin if (return_sig[2] == 1'd1) begin col_select[2] <= 0; state <= 8'd7; end else state <= 8'd5; end
        else if (state == 8'd7)  begin col_select[3] <= 1'd1; row_select <= row; state <= 8'd8; pixel_color <= node_n3; end
        else if (state == 8'd8)  begin if (return_sig[3] == 1'd1) begin col_select[3] <= 0; state <= 8'd9; end else state <= 8'd7; end
        else if (state == 8'd9)  begin col_select[4] <= 1'd1; row_select <= row; state <= 8'd10; pixel_color <= node_n4; end
        else if (state == 8'd10) begin if (return_sig[4] == 1'd1) begin col_select[4] <= 0; state <= 8'd11; end else state <= 8'd9; end
        else if (state == 8'd11)  begin col_select[5] <= 1'd1; row_select <= row; state <= 8'd12; pixel_color <= node_n5; end
        else if (state == 8'd12) begin if (return_sig[5] == 1'd1) begin col_select[5] <= 0; state <= 8'd13; end else state <= 8'd11; end
        else if (state == 8'd13)  begin col_select[6] <= 1'd1; row_select <= row; state <= 8'd14; pixel_color <= node_n6; end
        else if (state == 8'd14) begin if (return_sig[6] == 1'd1) begin col_select[6] <= 0; state <= 8'd15; end else state <= 8'd13; end
        else if (state == 8'd15)  begin col_select[7] <= 1'd1; row_select <= row; state <= 8'd16; pixel_color <= node_n7; end
        else if (state == 8'd16) begin if (return_sig[7] == 1'd1) begin col_select[7] <= 0; state <= 8'd17; end else state <= 8'd15; end
        else if (state == 8'd17)  begin col_select[8] <= 1'd1; row_select <= row; state <= 8'd18; pixel_color <= node_n8; end
        else if (state == 8'd18) begin if (return_sig[8] == 1'd1) begin col_select[8] <= 0; state <= 8'd19; end else state <= 8'd17; end
        else if (state == 8'd19)  begin col_select[9] <= 1'd1; row_select <= row; state <= 8'd20; pixel_color <= node_n9; end
        else if (state == 8'd20) begin if (return_sig[9] == 1'd1) begin col_select[9] <= 0; state <= 8'd21; end else state <= 8'd19; end
        else if (state == 8'd21)  begin col_select[10] <= 1'd1; row_select <= row; state <= 8'd22; pixel_color <= node_n10; end
        else if (state == 8'd22) begin if (return_sig[10] == 1'd1) begin col_select[10] <= 0; state <= 8'd23; end else state <= 8'd21; end
        else if (state == 8'd23)  begin col_select[11] <= 1'd1; row_select <= row; state <= 8'd24; pixel_color <= node_n11; end
        else if (state == 8'd24) begin if (return_sig[11] == 1'd1) begin col_select[11] <= 0; state <= 8'd25; end else state <= 8'd23; end
        else if (state == 8'd25)  begin col_select[12] <= 1'd1; row_select <= row; state <= 8'd26; pixel_color <= node_n12; end
        else if (state == 8'd26) begin if (return_sig[12] == 1'd1) begin col_select[12] <= 0; state <= 8'd27; end else state <= 8'd25; end
        else if (state == 8'd27)  begin col_select[13] <= 1'd1; row_select <= row; state <= 8'd28; pixel_color <= node_n13; end
        else if (state == 8'd28) begin if (return_sig[13] == 1'd1) begin col_select[13] <= 0; state <= 8'd29; end else state <= 8'd27; end
        else if (state == 8'd29)  begin col_select[14] <= 1'd1; row_select <= row; state <= 8'd30; pixel_color <= node_n14; end
        else if (state == 8'd30) begin if (return_sig[14] == 1'd1) begin col_select[14] <= 0; state <= 8'd31; end else state <= 8'd29; end
        else if (state == 8'd31)  begin col_select[15] <= 1'd1; row_select <= row; state <= 8'd32; pixel_color <= node_n15; end
        else if (state == 8'd32) begin if (return_sig[15] == 1'd1) begin col_select[15] <= 0; state <= 8'd33; end else state <= 8'd31; end
        else if (state == 8'd33)  begin col_select[16] <= 1'd1; row_select <= row; state <= 8'd34; pixel_color <= node_n16; end
        else if (state == 8'd34) begin if (return_sig[16] == 1'd1) begin col_select[16] <= 0; state <= 8'd35; end else state <= 8'd33; end
        else if (state == 8'd35)  begin col_select[17] <= 1'd1; row_select <= row; state <= 8'd36; pixel_color <= node_n17; end
        else if (state == 8'd36) begin if (return_sig[17] == 1'd1) begin col_select[17] <= 0; state <= 8'd37; end else state <= 8'd35; end
        else if (state == 8'd37)  begin col_select[18] <= 1'd1; row_select <= row; state <= 8'd38; pixel_color <= node_n18; end
        else if (state == 8'd38) begin if (return_sig[18] == 1'd1) begin col_select[18] <= 0; state <= 8'd39; end else state <= 8'd37; end
        else if (state == 8'd39)  begin col_select[19] <= 1'd1; row_select <= row; state <= 8'd40; pixel_color <= node_n19; end
        else if (state == 8'd40) begin if (return_sig[19] == 1'd1) begin col_select[19] <= 0; state <= 8'd41; end else state <= 8'd39; end
        else if (state == 8'd41)  begin col_select[20] <= 1'd1; row_select <= row; state <= 8'd42; pixel_color <= node_n20; end
        else if (state == 8'd42) begin if (return_sig[20] == 1'd1) begin col_select[20] <= 0; state <= 8'd43; end else state <= 8'd41; end
        else if (state == 8'd43)  begin col_select[21] <= 1'd1; row_select <= row; state <= 8'd44; pixel_color <= node_n21; end
        else if (state == 8'd44) begin if (return_sig[21] == 1'd1) begin col_select[21] <= 0; state <= 8'd45; end else state <= 8'd43; end
        else if (state == 8'd45)  begin col_select[22] <= 1'd1; row_select <= row; state <= 8'd46; pixel_color <= node_n22; end
        else if (state == 8'd46) begin if (return_sig[22] == 1'd1) begin col_select[22] <= 0; state <= 8'd47; end else state <= 8'd45; end
        else if (state == 8'd47)  begin col_select[23] <= 1'd1; row_select <= row; state <= 8'd48; pixel_color <= node_n23; end
        else if (state == 8'd48) begin if (return_sig[23] == 1'd1) begin col_select[23] <= 0; state <= 8'd49; end else state <= 8'd47; end
        else if (state == 8'd49)  begin col_select[24] <= 1'd1; row_select <= row; state <= 8'd50; pixel_color <= node_n24; end
        else if (state == 8'd50) begin if (return_sig[24] == 1'd1) begin col_select[24] <= 0; state <= 8'd51; end else state <= 8'd49; end
        else if (state == 8'd51)  begin col_select[25] <= 1'd1; row_select <= row; state <= 8'd52; pixel_color <= node_n25; end
        else if (state == 8'd52) begin if (return_sig[25] == 1'd1) begin col_select[25] <= 0; state <= 8'd53; end else state <= 8'd51; end
        else if (state == 8'd53)  begin col_select[26] <= 1'd1; row_select <= row; state <= 8'd54; pixel_color <= node_n26; end
        else if (state == 8'd54) begin if (return_sig[26] == 1'd1) begin col_select[26] <= 0; state <= 8'd5; end else state <= 8'd53; end
        else if (state == 8'd55)  begin col_select[27] <= 1'd1; row_select <= row; state <= 8'd56; pixel_color <= node_n27; end
        else if (state == 8'd56) begin if (return_sig[27] == 1'd1) begin col_select[27] <= 0; state <= 8'd57; end else state <= 8'd55; end
        else if (state == 8'd57)  begin col_select[28] <= 1'd1; row_select <= row; state <= 8'd58; pixel_color <= node_n28; end
        else if (state == 8'd58) begin if (return_sig[28] == 1'd1) begin col_select[28] <= 0; state <= 8'd59; end else state <= 8'd57; end
        else if (state == 8'd59)  begin col_select[29] <= 1'd1; row_select <= row; state <= 8'd60; pixel_color <= node_n29; end
        else if (state == 8'd60) begin if (return_sig[29] == 1'd1) begin col_select[29] <= 0; state <= 8'd61; end else state <= 8'd59; end
        else if (state == 8'd61)  begin col_select[30] <= 1'd1; row_select <= row; state <= 8'd62; pixel_color <= node_n30; end
        else if (state == 8'd62) begin if (return_sig[30] == 1'd1) begin col_select[30] <= 0; state <= 8'd63; end else state <= 8'd61; end
        else if (state == 8'd63)  begin col_select[31] <= 1'd1; row_select <= row; state <= 8'd64; pixel_color <= node_n31; end
        else if (state == 8'd64) begin if (return_sig[31] == 1'd1) begin col_select[31] <= 0; state <= 8'd65; end else state <= 8'd63; end
        else if (state == 8'd65)  begin col_select[32] <= 1'd1; row_select <= row; state <= 8'd66; pixel_color <= node_n32; end
        else if (state == 8'd66) begin if (return_sig[32] == 1'd1) begin col_select[32] <= 0; state <= 8'd67; end else state <= 8'd65; end
        else if (state == 8'd67)  begin col_select[33] <= 1'd1; row_select <= row; state <= 8'd68; pixel_color <= node_n33; end
        else if (state == 8'd68) begin if (return_sig[33] == 1'd1) begin col_select[33] <= 0; state <= 8'd69; end else state <= 8'd67; end
        else if (state == 8'd69)  begin col_select[34] <= 1'd1; row_select <= row; state <= 8'd70; pixel_color <= node_n34; end
        else if (state == 8'd70) begin if (return_sig[34] == 1'd1) begin col_select[34] <= 0; state <= 8'd71; end else state <= 8'd69; end
        else if (state == 8'd71)  begin col_select[35] <= 1'd1; row_select <= row; state <= 8'd72; pixel_color <= node_n35; end
        else if (state == 8'd72) begin if (return_sig[35] == 1'd1) begin col_select[35] <= 0; state <= 8'd73; end else state <= 8'd71; end
        else if (state == 8'd73)  begin col_select[36] <= 1'd1; row_select <= row; state <= 8'd74; pixel_color <= node_n36; end
        else if (state == 8'd74) begin if (return_sig[36] == 1'd1) begin col_select[36] <= 0; state <= 8'd75; end else state <= 8'd73; end
        else if (state == 8'd75)  begin col_select[37] <= 1'd1; row_select <= row; state <= 8'd76; pixel_color <= node_n37; end
        else if (state == 8'd76) begin if (return_sig[37] == 1'd1) begin col_select[37] <= 0; state <= 8'd77; end else state <= 8'd75; end
        else if (state == 8'd77)  begin col_select[38] <= 1'd1; row_select <= row; state <= 8'd78; pixel_color <= node_n38; end
        else if (state == 8'd78) begin if (return_sig[38] == 1'd1) begin col_select[38] <= 0; state <= 8'd79; end else state <= 8'd77; end
        else if (state == 8'd79)  begin col_select[39] <= 1'd1; row_select <= row; state <= 8'd80; pixel_color <= node_n39; end
        else if (state == 8'd80) begin if (return_sig[39] == 1'd1) begin col_select[39] <= 0; state <= 8'd81; end else state <= 8'd79; end
        else if (state == 8'd81)  begin col_select[40] <= 1'd1; row_select <= row; state <= 8'd82; pixel_color <= node_n40; end
        else if (state == 8'd82) begin if (return_sig[40] == 1'd1) begin col_select[40] <= 0; state <= 8'd83; end else state <= 8'd81; end
        else if (state == 8'd83)  begin col_select[41] <= 1'd1; row_select <= row; state <= 8'd84; pixel_color <= node_n41; end
        else if (state == 8'd84) begin if (return_sig[41] == 1'd1) begin col_select[41] <= 0; state <= 8'd85; end else state <= 8'd83; end
        else if (state == 8'd85)  begin col_select[42] <= 1'd1; row_select <= row; state <= 8'd86; pixel_color <= node_n42; end
        else if (state == 8'd86) begin if (return_sig[42] == 1'd1) begin col_select[42] <= 0; state <= 8'd87; end else state <= 8'd85; end
        else if (state == 8'd87)  begin col_select[43] <= 1'd1; row_select <= row; state <= 8'd88; pixel_color <= node_n43; end
        else if (state == 8'd88) begin if (return_sig[43] == 1'd1) begin col_select[43] <= 0; state <= 8'd89; end else state <= 8'd87; end
        else if (state == 8'd89)  begin col_select[44] <= 1'd1; row_select <= row; state <= 8'd90; pixel_color <= node_n44; end
        else if (state == 8'd90) begin if (return_sig[44] == 1'd1) begin col_select[44] <= 0; state <= 8'd91; end else state <= 8'd89; end
        else if (state == 8'd91)  begin col_select[45] <= 1'd1; row_select <= row; state <= 8'd92; pixel_color <= node_n45; end
        else if (state == 8'd92) begin if (return_sig[45] == 1'd1) begin col_select[45] <= 0; state <= 8'd93; end else state <= 8'd91; end
        else if (state == 8'd93)  begin col_select[46] <= 1'd1; row_select <= row; state <= 8'd94; pixel_color <= node_n46; end
        else if (state == 8'd94) begin if (return_sig[46] == 1'd1) begin col_select[46] <= 0; state <= 8'd95; end else state <= 8'd93; end
        else if (state == 8'd95)  begin col_select[47] <= 1'd1; row_select <= row; state <= 8'd96; pixel_color <= node_n47; end
        else if (state == 8'd96) begin if (return_sig[47] == 1'd1) begin col_select[47] <= 0; state <= 8'd97; end else state <= 8'd95; end
        else if (state == 8'd97)  begin col_select[48] <= 1'd1; row_select <= row; state <= 8'd98; pixel_color <= node_n48; end
        else if (state == 8'd98) begin if (return_sig[48] == 1'd1) begin col_select[48] <= 0; state <= 8'd99; end else state <= 8'd97; end
        else if (state == 8'd99)  begin col_select[49] <= 1'd1; row_select <= row; state <= 8'd100; pixel_color <= node_n49; end
        else if (state == 8'd100) begin if (return_sig[49] == 1'd1) begin col_select[49] <= 0; state <= 8'd101; end else state <= 8'd99; end
        else if (state == 8'd101)  begin col_select[50] <= 1'd1; row_select <= row; state <= 8'd102; pixel_color <= node_n50; end
        else if (state == 8'd102) begin if (return_sig[50] == 1'd1) begin col_select[50] <= 0; state <= 8'd103; end else state <= 8'd101; end
        else if (state == 8'd103)  begin col_select[51] <= 1'd1; row_select <= row; state <= 8'd104; pixel_color <= node_n51; end
        else if (state == 8'd104) begin if (return_sig[51] == 1'd1) begin col_select[51] <= 0; state <= 8'd105; end else state <= 8'd103; end
        else if (state == 8'd105)  begin col_select[52] <= 1'd1; row_select <= row; state <= 8'd106; pixel_color <= node_n52; end
        else if (state == 8'd106) begin if (return_sig[52] == 1'd1) begin col_select[52] <= 0; state <= 8'd107; end else state <= 8'd105; end
        else if (state == 8'd107)  begin col_select[53] <= 1'd1; row_select <= row; state <= 8'd108; pixel_color <= node_n53; end
        else if (state == 8'd108) begin if (return_sig[53] == 1'd1) begin col_select[53] <= 0; state <= 8'd109; end else state <= 8'd107; end
        else if (state == 8'd109)  begin col_select[54] <= 1'd1; row_select <= row; state <= 8'd110; pixel_color <= node_n54; end
        else if (state == 8'd110) begin if (return_sig[54] == 1'd1) begin col_select[54] <= 0; state <= 8'd111; end else state <= 8'd109; end
        else if (state == 8'd111)  begin col_select[55] <= 1'd1; row_select <= row; state <= 8'd112; pixel_color <= node_n55; end
        else if (state == 8'd112) begin if (return_sig[55] == 1'd1) begin col_select[55] <= 0; state <= 8'd113; end else state <= 8'd111; end
        else if (state == 8'd113)  begin col_select[56] <= 1'd1; row_select <= row; state <= 8'd114; pixel_color <= node_n56; end
        else if (state == 8'd114) begin if (return_sig[56] == 1'd1) begin col_select[56] <= 0; state <= 8'd115; end else state <= 8'd113; end
        else if (state == 8'd115)  begin col_select[57] <= 1'd1; row_select <= row; state <= 8'd116; pixel_color <= node_n57; end
        else if (state == 8'd116) begin if (return_sig[57] == 1'd1) begin col_select[57] <= 0; state <= 8'd117; end else state <= 8'd115; end
        else if (state == 8'd117)  begin col_select[58] <= 1'd1; row_select <= row; state <= 8'd118; pixel_color <= node_n58; end
        else if (state == 8'd118) begin if (return_sig[58] == 1'd1) begin col_select[58] <= 0; state <= 8'd119; end else state <= 8'd117; end
        else if (state == 8'd119)  begin col_select[59] <= 1'd1; row_select <= row; state <= 8'd120; pixel_color <= node_n59; end
        else if (state == 8'd120) begin if (return_sig[59] == 1'd1) begin col_select[59] <= 0; state <= 8'd121; end else state <= 8'd119; end
        else if (state == 8'd121)  begin col_select[60] <= 1'd1; row_select <= row; state <= 8'd122; pixel_color <= node_n60; end
        else if (state == 8'd122) begin if (return_sig[60] == 1'd1) begin col_select[60] <= 0; state <= 8'd123; end else state <= 8'd121; end
        else if (state == 8'd123)  begin col_select[61] <= 1'd1; row_select <= row; state <= 8'd124; pixel_color <= node_n61; end
        else if (state == 8'd124) begin if (return_sig[61] == 1'd1) begin col_select[61] <= 0; state <= 8'd125; end else state <= 8'd123; end
        else if (state == 8'd125)  begin col_select[62] <= 1'd1; row_select <= row; state <= 8'd126; pixel_color <= node_n62; end
        else if (state == 8'd126) begin if (return_sig[62] == 1'd1) begin col_select[62] <= 0; state <= 8'd127; end else state <= 8'd125; end
        else if (state == 8'd127)  begin col_select[63] <= 1'd1; row_select <= row; state <= 8'd128; pixel_color <= node_n63; end
        else if (state == 8'd128) begin if (return_sig[63] == 1'd1) begin col_select[63] <= 0; state <= 8'd129; end else state <= 8'd127; end


        // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        else if (state == 8'd129) begin
            start <= 1;
            state <= 8'd130;
        end
        else if (state == 8'd130) begin
            start <= 0;
            if (grid_flag == 1'd1) begin
                state <= 8'd1;
                if ( row == 9'd63 ) row <= 9'd0;
                else row <= row + 9'd1;
            end
            else state <= 8'd130;
        end
            

	end


    generate_grid ( 
        .clk_50     (clock),
        .reset      (reset),
        .start      (start),
        .flag       (grid_flag),
        .node_n0    (node_n0),
        .node_n1    (node_n1),
        .node_n2    (node_n2),
        .node_n3    (node_n3),
        .node_n4    (node_n4),
        .node_n5    (node_n5),
        .node_n6    (node_n6),
        .node_n7    (node_n7),
        .node_n8    (node_n8),
        .node_n9    (node_n9),
        .node_n10   (node_n10),
        .node_n11   (node_n11),
        .node_n12   (node_n12),
        .node_n13   (node_n13),
        .node_n14   (node_n14),
        .node_n15   (node_n15),
        .node_n16   (node_n16),
        .node_n17   (node_n17),
        .node_n18   (node_n18),
        .node_n19   (node_n19),
        .node_n20   (node_n20),
        .node_n21   (node_n21),
        .node_n22   (node_n22),
        .node_n23   (node_n23),
        .node_n24   (node_n24),
        .node_n25   (node_n25),
        .node_n26   (node_n26),
        .node_n27   (node_n27),
        .node_n28   (node_n28),
        .node_n29   (node_n29),
        .node_n30   (node_n30),
        .node_n31   (node_n31),
        .node_n32   (node_n32),
        .node_n33   (node_n33),
        .node_n34   (node_n34),
        .node_n35   (node_n35),
        .node_n36   (node_n36),
        .node_n37   (node_n37),
        .node_n38   (node_n38),
        .node_n39   (node_n39),
        .node_n40   (node_n40),
        .node_n41   (node_n41),
        .node_n42   (node_n42),
        .node_n43   (node_n43),
        .node_n44   (node_n44),
        .node_n45   (node_n45),
        .node_n46   (node_n46),
        .node_n47   (node_n47),
        .node_n48   (node_n48),
        .node_n49   (node_n49),
        .node_n50   (node_n50),
        .node_n51   (node_n51),
        .node_n52   (node_n52),
        .node_n53   (node_n53),
        .node_n54   (node_n54),
        .node_n55   (node_n55),
        .node_n56   (node_n56),
        .node_n57   (node_n57),
        .node_n58   (node_n58),
        .node_n59   (node_n59),
        .node_n60   (node_n60),
        .node_n61   (node_n61),
        .node_n62   (node_n62),
        .node_n63   (node_n63),
    );



endmodule

// ------------------ WAIT --------------------
            // if (state == 8'd0) begin    // set up read for HPS data-ready
            //     sram_address <= 8'd0;
            //     sram_write   <= 1'b0;
            //     state        <= 8'd1;
            // end
            // if (state == 8'd1) begin
            //     state <= 8'd2;
            // end
            // if (state == 8'd2) begin    // do data-read read
            //     data_buffer <= sram_readdata;
            //     sram_write  <= 1'b0;
            //     state       <= 8'd3;
            // end 
            // if (state == 8'd3) begin    // check if there is data
            //     if ( data_buffer == 0 ) begin
            //         state <= 8'd0;     // if (addr 0)==0 try again
            //     end
            //     else begin
            //         state <= 8'd4;     // if nonzero, move to read values
            //         flag  <= 1'd1;
            //     end
            // end 
            
            // // ------------------ READ VAL --------------------
            // if (state == 8'd4) begin    // check how much data
            //     sram_address <= 8'd1;
            //     sram_write   <= 1'b0;
            //     state        <= 8'd5;
            // end
            // if (state == 8'd5) begin
            //     state <= 8'd6;
            // end
            // if (state == 8'd6) begin    // do data-read vals
            //     vals        <= sram_readdata[8:0];
            //     sram_write  <= 1'b0;
            //     state       <= 8'd7;
            // end

            // // --------------- READ LOOP -----------------------

            // if (state == 8'd7) begin
            //     sram_address <= 8'd2 + count;       // start at 2 go up by number of vals one at a time
            //     sram_write   <= 1'b0;
            //     state        <= 8'd8;
            // end
            // if (state == 8'd8) begin
            //     state <= 8'd9;
            // end
            // if (state == 8'd9) begin
            //     x          <= sram_readdata[29:20]; // 10 bits
            //     y          <= sram_readdata[17: 8]; // 10 bits
            //     data       <= sram_readdata[ 7: 0]; // 8  bits
            //     sram_write <= 1'b0;
            //     state      <= 8'd10;
            //     count      <= count + 1;
            // end 

            // // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
            // // PLOTTING
            // // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
            // if (state == 8'd10) begin
            //     col_select[x] <= 1'd1; // one [] per column
            //     row_select    <= y; // says which row number
            //     state <= 8'd11;
            // end
            // if (state == 8'd11) begin
            //     if (return_sig[x] == 1'd1) begin
            //         col_select[x] <= 0;
            //         state         <= 8'd12;
            //     end
            //     else state <= 8'd10;
            // end
            // // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            // // if there are more values go back and keep plotting 
            // if (state == 8'd12) begin
            //     if (count == vals) state <= 8'd13;
            //     else state <= 8'd7;
            // end

            // // ------------------ RESET FLAG --------------------
            // if (state == 8'd13) begin
            //     sram_address    <=  8'd0;   // signal the HPS we are done
            //     sram_writedata  <= 32'b0;
            //     sram_write      <=  1'b1;
            //     state           <=  8'd0;   // go back down to state 0
            // end
