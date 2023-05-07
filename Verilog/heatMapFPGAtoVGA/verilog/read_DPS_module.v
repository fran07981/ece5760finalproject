module read_DPS_module (clock, reset, 
                        sram_readdata, sram_writedata, sram_address, sram_write, 
                        flag, col_select, return_sig, row_select
);
    input clock, reset;
    localparam n = 101;

    output reg 	   sram_write;
    output reg [7 :0] sram_address;
    output reg [31:0] sram_writedata;
//    output reg [31:0] vga_sram_address;
    
    input wire [31:0] sram_readdata;

    output reg [n - 1:0] col_select = 0; // one [] per column
	output reg [9:0]  row_select = 0; // says which row number

    input   [n - 1:0] return_sig ; // one [] per column
	
    // y   =    0 : 479 (9  bits ->  512    ) 12 bits
    // x   =    0 : 639 (10 bits -> 1024    ) 12 bits
    // val = -128 : 128 (7 bits + 1 sign bit) 8  bits 
    // 32 bits: |0000|0000|0000 | 0000|0000|0000 | 0000|0000
    //		    [-------X-------] [-------Y------] [--VAL--]

    reg  [31:0] data_buffer;
    reg  [ 9:0] x, y;
    reg  [ 7:0] data;
    reg  [ 8:0] count;  // total possitble 256 values in M10K block
    reg  [ 8:0] vals;   // # of values that were sent over

    output reg flag = 0;
    
    reg  [7 :0] state = 0;

	always @(posedge clock) begin // CLOCK_50

	    // ---------------- RESET ----------------------
		if (reset) begin
			state          <= 0;
			sram_write     <= 0;
            count          <= 0;
            flag           <= 0;
        end
        else begin
            // ------------------ WAIT --------------------
            if (state == 8'd0) begin    // set up read for HPS data-ready
                sram_address <= 8'd0;
                sram_write   <= 1'b0;
                state        <= 8'd1;
            end
            if (state == 8'd1) begin
                state <= 8'd2;
            end
            if (state == 8'd2) begin    // do data-read read
                data_buffer <= sram_readdata;
                sram_write  <= 1'b0;
                state       <= 8'd3;
            end 
            if (state == 8'd3) begin    // check if there is data
                if ( data_buffer == 0 ) begin
                    state <= 8'd0;     // if (addr 0)==0 try again
                end
                else begin
                    state <= 8'd4;     // if nonzero, move to read values
                    flag  <= 1'd1;
                end
            end 
            
            // ------------------ READ VAL --------------------
            if (state == 8'd4) begin    // check how much data
                sram_address <= 8'd1;
                sram_write   <= 1'b0;
                state        <= 8'd5;
            end
            if (state == 8'd5) begin
                state <= 8'd6;
            end
            if (state == 8'd6) begin    // do data-read vals
                vals        <= sram_readdata[8:0];
                sram_write  <= 1'b0;
                state       <= 8'd7;
            end

            // --------------- READ LOOP -----------------------

            if (state == 8'd7) begin
                sram_address <= 8'd2 + count;       // start at 2 go up by number of vals one at a time
                sram_write   <= 1'b0;
                state        <= 8'd8;
            end
            if (state == 8'd8) begin
                state <= 8'd9;
            end
            if (state == 8'd9) begin
                x          <= sram_readdata[29:20]; // 10 bits
                y          <= sram_readdata[17: 8]; // 10 bits
                data       <= sram_readdata[ 7: 0]; // 8  bits
                sram_write <= 1'b0;
                state      <= 8'd10;
                count      <= count + 1;
            end 

            // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
            // SEND DATA TO CORRECT M10K BLOCK HERE
            // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
            if (state == 8'd10) begin
                col_select[x] <= 1'd1; // one [] per column
                row_select    <= y; // says which row number
                state <= 8'd11;
            end
            if (state == 8'd11) begin
                if (return_sig[x] == 1'd1) begin
                    col_select[x] <= 0;
                    state         <= 8'd12;
                end
                else state <= 8'd10;
            end
            // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            // if there are more values go back and keep plotting 
            if (state == 8'd12) begin
                if (count == vals) state <= 8'd13;
                else state <= 8'd7;
            end

            // ------------------ RESET FLAG --------------------
            if (state == 8'd13) begin
                sram_address    <=  8'd0;   // signal the HPS we are done
                sram_writedata  <= 32'b0;
                sram_write      <=  1'b1;
                state           <=  8'd0;   // go back down to state 0
            end
        end
	end

endmodule