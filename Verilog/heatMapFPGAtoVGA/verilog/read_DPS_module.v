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
    output reg [    7:0] pixel_color;
    output reg           flag = 0;
	
    reg start = 0;  //start the next grid calculation
    reg grid_flag = 0;

    reg  [31:0] data_buffer;
    reg  [ 9:0] x, y, row;

    reg  [ 9:0] current_row;
    reg  [ 9:0] current_col;

    reg  [ 7:0] data;
    reg  [ 8:0] count;      // total possitble 256 values in M10K block
    reg  [ 8:0] vals;       // # of values that were sent over
    reg  [7 :0] state = 0;

	always @(posedge clock) begin // CLOCK_50

	    // ---------------- RESET ----------------------
		if (reset && (state == 0)) begin
			state          <= 8'd0;
			sram_write     <= 0;
            count          <= 0;
            flag           <= 1'd0;
            row            <= 0;
            start          <= 0;
        end
        else begin
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
            // PLOTTING
            // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
            if (state == 8'd10) begin
                col_select[x] <= 1'd1; // one [] per column
                row_select    <= y; // says which row number
                pixel_color   <= 8'b1111_1111; //data;
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
                // state           <=  8'd0;   // go back down to state 0
                state           <=  8'd14;

                current_row <= 0;
                current_col <= 0;
                
            end
            if (state == 8'd14) begin
                state <= 8'd14;
            end
            
            // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
            // ------------------ PLOT HEAT ------------------
            // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            // if (state == 8'd14) begin 
            //     start   <= 1'd0;
            //     if (flag == 1'd1) state <= 8'd15;
            //     else state <= 8'd14;
            // end
            // if (state == 8'd15) begin 
            //     u_read_addr <= 0; //{ 2'd0, current_col};
            //     state       <= 8'd16;
            // end
            // if (state == 8'd16) begin 
            //     state <= 8'd17;
            // end
            // if (state == 8'd17) begin 
            //     data  <= u_read_data;
            //     state <= 8'd18;
            // end
            
            // // PLOTTING
            // if (state == 8'd18) begin
            //     col_select[current_col] <= 1'd1; // one [] per column
            //     row_select              <= current_row; // says which row number
            //     pixel_color             <= data; //u_read_data;
            //     state                   <= 8'd19;
            // end
            // if (state == 8'd19) begin
            //     if (return_sig[current_col] == 1'd1) begin
            //         col_select[current_col] <= 0;
            //         state                   <= 8'd20;
            //     end
            //     else state <= 8'd19;
            // end
            // // if there are more values go back and keep plotting 
            // if (state == 8'd20) begin
            //     if (current_col == 8'd63) begin
            //         current_col <= 0;
                    
            //         if (current_row == 8'd63) current_row <= 0;
            //         else current_row <= current_row + 1'd1;
                    
            //         start <= 1'd1;
            //         state <= 8'd14;
            //     end
            //     else begin
            //         state <= 8'd15;
            //         current_col <= current_col + 1'd1;
            //     end
            // end
            // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        end
	end

    // reg          [7:0] u_read_addr;	// select the row
    // reg unsigned [31:0] u_read_data;

    generate_grid ( 
        .clk_50      (clock),
        .reset       (reset),
        .start       (start),
        .flag        (grid_flag)
        // .u_read_addr (u_read_addr),
        // .u_read_data (u_read_data)
    );



endmodule
