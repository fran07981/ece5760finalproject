//------------------------------------------------------------
// TOP LEVEL MODULE
//------------------------------------------------------------
module mandelbrot(clock, reset, max_iterations, ci, cr, N, flag); 
    
    input clock, reset;
    input signed [26:0] max_iterations, ci, cr;
    output wire signed [26:0] N;
    output wire signed [26:0] flag;

    wire signed [26:0] zr_in_2,  zi_in_2,  zr_in,  zi_in;

    //calculate zr_out and zr_out_2
    wire signed [26:0] zr_out;
    zr_out_m zr_out_(.out_zr(zr_out), 
                .cr(cr), 
                .zr_in_2(zr_in_2), 
                .zi_in_2(zi_in_2));
    
    wire signed [26:0] zr_out_2;
    signed_mult zr_zr_mult(.out(zr_out_2),
                        .a(zr_out),
                        .b(zr_out));

    //calculate zi_out and zi_out_2
    wire signed [26:0] zi_out;
    zi_out_m zi_out_(.out_zi(zi_out), 
                    .ci(ci), 
                    .zr_in(zr_in), 
                    .zi_in(zi_in));

    wire signed [26:0]  zi_out_2;               
    signed_mult zi_zi_mult(.out(zi_out_2),
                        .a(zi_out),
                        .b(zi_out));

    incrementor mandelIt(   
        .zr_out_2       ( zr_in_2 ), // module updates current in's
        .zi_out_2       ( zi_in_2 ),
        .zr_out     ( zr_in ),
        .zi_out     ( zi_in ),
		.zr_in_2        ( zr_out_2 ), // module uses calculated out's
        .zi_in_2        ( zi_out_2 ),
        .zr_in      ( zr_out ),
        .zi_in      ( zi_out ),
		.clk        ( clock ),                // clock
		.reset      ( reset ),               // reset
        .new_N      ( N ),                   // output
        .flag      ( flag ),                   // output
        .maxiter        ( max_iterations ),    // input
        .ci      ( ci ),                   // output
        .cr        ( cr )    // input
		);
endmodule

//------------------------------------------------------------
// BUILD zr_out, zi_out, zr_out_2, zi_out_2
//------------------------------------------------------------ 
module zr_out_m(out_zr, cr, zr_in_2, zi_in_2);
	output signed [26:0] out_zr;
	input  signed [26:0] cr, zr_in_2, zi_in_2; 
    wire   signed [26:0] sum_squares;

    assign sum_squares =  zr_in_2 - zi_in_2;
    assign out_zr = sum_squares + cr;    // assigned to output 
endmodule


module zi_out_m(out_zi, ci, zr_in, zi_in);
	output signed [26:0] out_zi;
	input  signed [26:0] ci, zr_in, zi_in; 

    wire signed [26:0] zr_zi_mult_out;
    signed_mult zr_zi_mult(.out(zr_zi_mult_out),
                           .a(zr_in),
                           .b(zi_in));

    wire signed [26:0] zr_zi_shifted;
	shift_left zr_zi_shift(.out(zr_zi_shifted),
                           .a(zr_zi_mult_out));

    assign out_zi = zr_zi_shifted + ci;     //sum_shifted_and_ci;
endmodule

module incrementor( zr_out_2, zi_out_2, zr_out, zi_out,
			        zr_in_2, zi_in_2, zr_in, zi_in,
			        clk, reset, new_N, flag, maxiter,
                    ci, cr);

    output signed [26:0] zr_out_2, zi_out_2, zr_out, zi_out;
	input signed  [26:0] zr_in_2, zi_in_2, zr_in, zi_in;
    input signed  [26:0] ci, cr;
    input clk, reset;
    
    output signed [26:0] new_N;
    output signed [26:0] flag;
    input signed  [26:0] maxiter;

    reg signed	[26:0] v_N;
    reg signed	[26:0] v_flag;
    reg signed	[26:0] v_zi;
    reg signed	[26:0] v_zr;
    reg signed	[26:0] v_zr_2;
    reg signed	[26:0] v_zi_2;


    wire signed [26:0] two  = 27'b0010_0000_0000_0000_0000_0000_000;
    wire signed [26:0] four = 27'b0100_0000_0000_0000_0000_0000_000;
    
    always @ (posedge clk) 
    begin
	    
        if (reset) begin //reset	
            v_zr   <= 27'b0;
            v_zi   <= 27'b0;
            v_zr_2 <= 27'b0;
            v_zi_2 <= 27'b0;
            v_N    <= 27'b1;
            v_flag <= 27'b0;
        end
        else if ( ( (v_N >= maxiter) || ((zr_in_2 + zi_in_2) >= four) || (zr_in > two) || (zi_in > two) ) && (v_flag == 27'b0) ) begin
            v_N    <= v_N  + 27'b1; //increment    
            v_flag <= 27'b1;
        end
	    else if (v_flag == 27'b0) begin
		    v_zr   <= zr_in;
            v_zi   <= zi_in;
            v_zr_2 <= zr_in_2;
            v_zi_2 <= zi_in_2;
            v_N    <= v_N  + 27'b1; //increment
	    end
    end

    
    assign flag    = v_flag; 
    assign new_N    = v_N; 
    assign zi_out   = v_zi; 
    assign zr_out   = v_zr; 
    assign zr_out_2 = v_zr_2; 
    assign zi_out_2 = v_zi_2; 
endmodule


module shift_left (out, a);
	output signed [26:0] out;
	input  signed [26:0] a;
	
	assign out = a << 1;
endmodule 
//------------------------------------------------------------
// signed mult of 4.23 format 2'comp
//------------------------------------------------------------

module signed_mult (out, a, b);
	output 	signed  [26:0]	out;
	input 	signed	[26:0] 	a;
	input 	signed	[26:0] 	b;
	
	// intermediate full bit length
	wire 	signed	[53:0]	mult_out;
	assign mult_out = a * b;
	
	// select bits for 4.23 fixed point
	// assign out = {mult_out[53], mult_out[48:23]};
    assign out = {mult_out[53], mult_out[48:23]}; // [53] + 26 bits
endmodule


// ---------------------------------------------------------------------------
// arbriter 
// ---------------------------------------------------------------------------

// n = 2

// 0000_0000_0000_0110_0110_0110_000 = 1/640
//0000_0000_0000_1000_1000_1001_000 = 1/480
module arbriter (vga_addr,vga_pxl_clr, inter_select, inter_done, clk, comp_flag, 
vga_sram_address, vga_sram_write, vga_sram_writedata, inter_start, KEY, 
hps_reset,hps_done, hps_send_timer, hps_send_done);

	input [3:0]	KEY;
	input	 	clk;
	localparam n = 6;
	input [(n*32-1):0] vga_addr; 		// n = # of iterators, secont [] is length of data (32 bits)
	input [(n*32-1):0] vga_pxl_clr; 	// n = # of iterators, [] is length of data (32 bits)
	
	input [n-1:0] inter_select;			// tells us which iterator is ready to be plotted via flag	
	input [n-1:0] inter_done;				// tells us which iterator is done plotting
	input 		hps_reset;				// tells us HPS sent a reset
		
	output wire [31:0] 	hps_send_timer;	// -> HPS
	output wire 		hps_send_done;  // -> HPS
	output wire 		hps_done;		// -> HPS

	output wire [n-1:0] comp_flag;		// return to nth iterator to move to next point
	output wire 	  inter_start; 		// tells iterators to start

	// write to VGA Data
	output wire [31:0] 	vga_sram_address;
	output wire 		vga_sram_write;
	output wire [7:0] 	vga_sram_writedata;
	

	// Internal registers
	reg [ 31:0 ] vga_sram_address_;
	reg [ 7 :0 ] vga_sram_writedata_;
	reg 		 vga_sram_write_;

	reg [n-1:0] comp_flag_;
	reg 	  inter_start_;
	reg [2:0] state_arbr;
	reg hps_done_;

	reg [31:0] timer; 			// may need to throttle write-rate
	reg [31:0] timer_ms;

	reg [31:0] 	hps_send_timer_;
	reg 		hps_send_done_;
	
	always @(posedge clk) begin

		// if (hps_reset) begin
		// 	hps_send_done_ <= 1'b0;
		// 	state_arbr   <= 3'd1;
		// end
	
		// ===== STATE 0 =====
		if ( state_arbr == 3'd0 || hps_reset) begin
			// button gets pressed 
			if (~KEY[0]) begin
				state_arbr <= 3'd1;
			end
			
			// hanshake HPS reset flag
			if ( hps_reset ) begin 
				hps_send_done_ <= 1'b0;
				hps_done_      <= 1'b1; // raise HPS_done so that the HPS knows we good
				state_arbr 	   <= 3'd1;
			end

			// no reset signal or button pressed yet! stay here
			else begin
				state_arbr <= 3'd0;
			end
		end

		// ===== STATE 1 =====
		else if ( state_arbr == 3'd1 ) begin
			inter_start_ <= 1'b1; // tell mandels to start
			state_arbr   <= 3'd2; // move to state 2

			// tell HPS we are not done plotting yet
			hps_send_done_ <= 1'b0;
		end


		// ===== STATE 2 =====
		else if( state_arbr == 3'd2 ) begin
			inter_start_ <= 1'b0;	// lower mandel start flag 
			state_arbr   <= 3'd3;	// move to state 3
		end

		// ===== STATE 3 =====
		else if ( state_arbr == 3'd3 ) begin
			if ( ~( inter_select == 0 ) ) begin
				if ( inter_select[0] == 1'b1 ) begin		// if this first iterator is ready, plot it
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr   [ ((0+1)*32-1) : (((0+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((0+1)*32-1) : (((0+1)*32-1) - 31) ];
					comp_flag_[0]  		<= 1'b1;			// raise comp flag
					state_arbr			<= 3'd4;			// move to state 3 to remove updated flag
				end
				else if ( inter_select[1] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((1+1)*32-1) : (((1+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((1+1)*32-1) : (((1+1)*32-1) - 31) ];
					comp_flag_[1] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
				else if ( inter_select[2] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((2+1)*32-1) : (((2+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((2+1)*32-1) : (((2+1)*32-1) - 31) ];
					comp_flag_[2] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
				else if ( inter_select[3] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((3+1)*32-1) : (((3+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((3+1)*32-1) : (((3+1)*32-1) - 31) ];
					comp_flag_[3] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
				else if ( inter_select[4] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((4+1)*32-1) : (((4+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((4+1)*32-1) : (((4+1)*32-1) - 31) ];
					comp_flag_[4] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
				else if ( inter_select[5] == 1'b1 ) begin
					vga_sram_write_ 	<= 1'b1;
					vga_sram_address_ 	<= vga_addr	  [ ((5+1)*32-1) : (((5+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
					vga_sram_writedata_ <= vga_pxl_clr[ ((5+1)*32-1) : (((5+1)*32-1) - 31) ];
					comp_flag_[5] 		<= 1'b1;	
					state_arbr			<= 3'd4;	
				end
				// else if ( inter_select[6] == 1'b1 ) begin
				// 	vga_sram_write_ 	<= 1'b1;
				// 	vga_sram_address_ 	<= vga_addr	  [ ((6+1)*32-1) : (((6+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
				// 	vga_sram_writedata_ <= vga_pxl_clr[ ((6+1)*32-1) : (((6+1)*32-1) - 31) ];
				// 	comp_flag_[6] 		<= 1'b1;	
				// 	state_arbr			<= 3'd4;	
				// end
				// else if ( inter_select[7] == 1'b1 ) begin
				// 	vga_sram_write_ 	<= 1'b1;
				// 	vga_sram_address_ 	<= vga_addr	  [ ((7+1)*32-1) : (((7+1)*32-1) - 31) ];		// send it just the bits from the ith iterator
				// 	vga_sram_writedata_ <= vga_pxl_clr[ ((7+1)*32-1) : (((7+1)*32-1) - 31) ];
				// 	comp_flag_[7] 		<= 1'b1;	
				// 	state_arbr			<= 3'd4;	
				// end

			end
			else if (inter_done == 6'b11_1111) begin		// ALL Iterators are done
				state_arbr <= 3'd5;
			end
			else begin 
				state_arbr <= 3'd3;
			end
		end
		// ===== STATE 4 =====
		else if ( state_arbr == 3'd4 ) begin
			if ( comp_flag_[0] == 1'd1 ) begin
				comp_flag_[0] <= 1'b0;	
			end
			else if ( comp_flag_[1] == 1'd1 ) begin	
				comp_flag_[1] <= 1'b0;				
			end
			else if ( comp_flag_[2] == 1'd1 ) begin	
				comp_flag_[2] <= 1'b0;				
			end
			else if ( comp_flag_[3] == 1'd1 ) begin	
				comp_flag_[3] <= 1'b0;				
			end 
			else if ( comp_flag_[4] == 1'd1 ) begin	
				comp_flag_[4] <= 1'b0;				
			end 
			else if ( comp_flag_[5] == 1'd1 ) begin	
				comp_flag_[5] <= 1'b0;				
			end 
			// else if ( comp_flag_[6] == 1'd1 ) begin	
			// 	comp_flag_[6] <= 1'b0;				
			// end 
			// else if ( comp_flag_[7] == 1'd1 ) begin	
			// 	comp_flag_[7] <= 1'b0;				
			// end 


			state_arbr <= 3'd3;	// return to state 2
		end
		// ===== STATE 5 =====
		// done state, VGA done, send info to HPS
		else if ( state_arbr == 3'd5 ) begin
			vga_sram_write_ <= 1'b0;
			hps_send_timer_ <= timer_ms;	
			hps_send_done_  <= 1'b1;
			state_arbr      <= 3'd5;
		end
		
	end

	always @(posedge clk) begin
		// only increment while we're actually potting and waiting to plot, not to receive signals
		if ((state_arbr == 3'd3) || (state_arbr == 3'd4)) begin
			// every clock iteration timer += 1
			if ( timer == 32'd50_000 ) begin
				timer_ms <= timer_ms + 1;
				timer 	 <= 0;
			end
			else begin
				timer <= timer + 1;
			end
		end
		else if (state_arbr == 3'd1) begin
			// set up timer
			timer_ms     <= 32'b0;
			timer        <= 32'b0;
		end
	
	end

	assign vga_sram_write  	  = vga_sram_write_; 
	assign vga_sram_address   = vga_sram_address_; 
	assign vga_sram_writedata = vga_sram_writedata_; 
	assign comp_flag		  = comp_flag_; 
	assign inter_start 		  = inter_start_;
	assign hps_done 		  = hps_done_;
	assign hps_send_timer 	  = hps_send_timer_;
	assign hps_send_done 	  = hps_send_done_;

endmodule