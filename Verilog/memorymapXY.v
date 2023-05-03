//============================================================
// MEMORY MAPPING - write hps values  
//============================================================
module memorymapXY(x_coord, y_coord, incr, arr_size, clk, reset);
// passed from HPS

    input wire [31:0] x_coord;
    input wire [31:0] y_coord;
    input wire [7:0] incr;
    input wire [7:0] arr_size;

    // ==== MEMORY BLOCK FOR X COORDINATES ====
    reg signed [31:0] x_write_data;
    reg [31:0]        x_write_addr;
    reg [31:0]        x_read_addr;
    reg 	          x_write_sig;		

    M10K_256_32 x_mem(  
        .q				(x_read_data),	    // the return data value during reads
        .d				(x_write_data), 	// set to data we want to write
        .write_address	(x_write_addr), 	// send it the address we want to write
        .read_address	(x_read_addr),   	// addr we want to read
        .we				(x_write_sig), 		// if we want to write we = 1'd1, else, we = 1'd0
        .clk			(clk) );

    // ==== MEMORY BLOCK FOR X COORDINATES ====
    reg	signed  [17:0]   y_write_data;
    reg	        [31:0]   ;
    reg         [31:0]   y_read_addr;
    reg	 	   		     y_write_sig;

    M10K_256_32 y_mem( 
        .q				(y_read_addr),
        .d				(y_write_data),
        .write_address	(u_prev_write_addr), 
        .read_address	(y_read_addr),
        .we				(y_write_sig), 
        .clk			(clk) );

    
    reg  [2:0] state; 	 // 3 bits (max of 2^3 states)
	wire [2:0] state_0 = 2'd0;
	wire [2:0] state_1 = 2'd1;

    //STATE MACHINE TO WRITE TO MEMORY
    always @(posedge clk) begin
        if ( reset ) state <= state_0; 
        else if (state == state_0) begin //RESET STATE
            //WRITE O to all blocks in X
            //write 0 to all blocks in Y

        end else if (state == state_1) //UPDATE M10K 
            //WRITE TO X
            x_write_data <= x_coord;
            x_write_addr <= ;
            x_write_sig  <= 1'b1;	
            //WRITE TO Y
            y_write_data <= y_coord;
            y_read_addr  <= ;
            y_write_sig  <= 1'b1;






end module



 //============================================================
// M10K Module Definitions
//============================================================

// M10K Memory block structure: 
// word 1		node 1 = u [ 31:0 ]
// word 2		node 2
// .
// word 256		node 256

module M10K_256_32( 
    output reg [31:0] q,
    input      [31:0] d,
    input      [7:0] write_address, read_address,	// 2^8 selects from 256 words
    input      we, clk
);
	// 32-bit x 512 - 512 words (nodes) each 32 bits long 
	
	reg [31:0] mem [255:0];
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
		end
        q <= mem[read_address]; 
    end
endmodule