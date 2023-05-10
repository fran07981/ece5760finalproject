`include "generate_grid.v"

module read_DPS_module (clock, reset, button,  
                        sram_readdata, sram_writedata, sram_address, sram_write, 
                        flag, col_select, return_sig, row_select, pixel_color
);
    input clock, reset, button;
    localparam n = 64;

    output reg 	   sram_write;
    output reg [7 :0] sram_address;
    output reg [31:0] sram_writedata;

    output reg  [ 7:0] pixel_color;
    
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
                start        <= 1'd0;
            end
            else if (state == 8'd1) begin
                state <= 8'd2;
            end
            else if (state == 8'd2) begin    // do data-read read
                data_buffer <= sram_readdata;
                sram_write  <= 1'b0;
                state       <= 8'd3;
            end 
            else if (state == 8'd3) begin    // check if there is data
                if ( data_buffer == 0 ) begin
                    state <= 8'd0;     // if (addr 0)==0 try again
                end
                else begin
                    state <= 8'd4;     // if nonzero, move to read values
                    
                end
            end 
            
            // ------------------ READ VAL --------------------
            else if (state == 8'd4) begin    // check how much data
                sram_address <= 8'd1;
                sram_write   <= 1'b0;
                state        <= 8'd5;
            end
            else if (state == 8'd5) begin
                state <= 8'd6;
            end
            else if (state == 8'd6) begin    // do data-read vals
                vals        <= sram_readdata[8:0];
                sram_write  <= 1'b0;
                state       <= 8'd7;
            end

            // --------------- READ LOOP -----------------------

            else if (state == 8'd7) begin
                sram_address <= 8'd2 + count;       // start at 2 go up by number of vals one at a time
                sram_write   <= 1'b0;
                state        <= 8'd8;
            end
            else if (state == 8'd8) begin
                state <= 8'd9;
            end
            else if (state == 8'd9) begin
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
            else if (state == 8'd10) begin
                col_select[x] <= 1'd1; // one [] per column
                row_select    <= y; // says which row number
                pixel_color   <= 8'b1111_1111;
                state <= 8'd11;
            end
            else if (state == 8'd11) begin
                if (return_sig[x] == 1'd1) begin
                    col_select[x] <= 0;
                    state         <= 8'd12;
                end
                else state <= 8'd10;
            end
            // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            // if there are more values go back and keep plotting 
            else if (state == 8'd12) begin
                if (count == vals) state <= 8'd13;
                else state <= 8'd7;
            end

            // ------------------ RESET FLAG --------------------
            else if (state == 8'd13) begin
                sram_address    <=  8'd0;   // signal the HPS we are done
                sram_writedata  <= 32'b0;
                sram_write      <=  1'b1;
                // state           <=  8'd0;   // go back down to state 0
                state           <=  8'd14;
                plot_row        <= 0;
                flag  <= 1'd1;
                
            end
            // ===========================================================================
            // ===========================================================================
            // ===========================================================================
            // ===========================================================================
            // ===========================================================================


            // Read from the HPS 1 heat value
            // per row

            //      tell column to start
            else if (state == 8'd14) begin
                start <= 1'd1;
                state <= 8'd15;
            end
            else if (state == 8'd15) begin
                start <= 1'd0;
                if (flag_send == 1'd1) begin
                    state      <= 8'd16;
                    comp_allow <= 1'd1;
                end
                else state <= 8'd15;                
            end

            //      tell grid write to M10K
            else if (state == 8'd16) begin                
                write_sig  <= 1'd1;             // TELL GRID TO WRITE, wait until its done
                comp_allow <= 1'd0;
                if (done_write_sig == 1'd1) state <= 8'd17;
                else state <= 8'd16;
            end
            
            else if (state == 8'd17) begin
                state <= 8'd18;
            end

            else if (state == 8'd18) begin
                state <= 8'd19;
            end

            else if (state == 8'd19) begin
                write_sig  <= 1'd0;
                state <= 8'd20;
            end
            else if (state == 8'd20) begin
                state <= 8'd21;
                
                read_counter <= 0;              // go to each of these columns (for 1 row)
            end
            
            //      we read M10K and plot it 
            else if (state == 8'd21) begin
                read_addr <= read_counter;
                state <= 8'd22;
            end
            else if (state == 8'd22) begin
                state <= 8'd23;
            end
            else if (state == 8'd23) begin
                read_val <= read_data;
                state <= 8'd24;
            end
            
            // PLOT THE DATA

            else if (state == 8'd24) begin
                col_select[read_counter] <= 1'd1; // one [] per column
                row_select               <= plot_row; // says which row number
                pixel_color              <= read_val;
                state                    <= 8'd25;
            end

            else if (state == 8'd25) begin
                if (return_sig[read_counter] == 1'd1) begin
                    col_select[read_counter] <= 0;
                    state                    <= 8'd26;
                end
                else state <= 8'd25;
            end

            // MOVE TO NEXT POINT

            else if (state == 8'd26) begin
                if (read_counter == 8'd63) state <= 8'd27;
                else begin
                    read_counter <= read_counter + 8'd1;
                    state <= 8'd21;
                end
            end

            else if (state == 8'd27) begin
                if ( plot_row == 8'd63 ) begin
                    plot_row <= 8'd0;
                end
                else begin
                    plot_row <= plot_row + 8'd1;
                end
                state <= 8'd14;
            end

        end
	end
    
    reg [7:0] plot_row = 0;
    reg [7:0] read_counter = 0;
    wire done_write_sig;
    wire flag_send;

    reg  unsigned [31:0] read_val;
    wire unsigned [31:0] read_data;

    wire  unsigned [31:0] write_data;
    wire           [ 7:0] write_addr;

    reg            [ 7:0] read_addr;
    reg 	             write_sig;

    reg comp_allow;

    reg start;

    M10K_256_32 mem_com_block(  
        .q				(read_data),			// the return data value during reads
        .d				(write_data), 	// set to data we want to write
        .write_address	(write_addr), 	// send it the address we want to write
        .read_address	(read_addr),   	// addr we want to read
        .we				(write_sig), 		// if we want to write we = 1'd1, else, we = 1'd0
        .clk			(clock) 
    );

    
    

    generate_grid grid( 
        .clk_50     (clock), 
        .reset      (reset), 
        .write_data (write_data),
        .write_addr (write_addr),
        .comp_allow  (comp_allow),
        .done_write_sig (done_write_sig),
        .flag_send  (flag_send),
        .start      (start)
    ); // node_n);

endmodule