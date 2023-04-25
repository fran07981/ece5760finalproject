///////////////////////////////////////
/// 640x480 version!
/// test VGA with hardware video input copy to VGA
// compile with
// gcc lorenz_user.c -o gr -O2 -lm
///////////////////////////////////////

// includes & code for the display
// includes & code for the verilog comms & lorenz code
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ipc.h> 
#include <sys/shm.h> 
#include <sys/mman.h>
#include <sys/time.h> 
#include <math.h> 

#include <sys/select.h>
#include <termios.h>
#include <fcntl.h>

typedef int fix;
#define float2fix(a) (fix)(a * 1048576)

// main bus; PIO
#define FPGA_AXI_BASE 	0xC0000000
#define FPGA_AXI_SPAN   0x00001000
// main axi bus base
void *h2p_virtual_base;
volatile unsigned int * axi_pio_ptr = NULL ;
volatile unsigned int * axi_pio_read_ptr = NULL ;

// lw bus; PIO
#define FPGA_LW_BASE 	0xff200000
#define FPGA_LW_SPAN	0x00001000
// the light weight bus base
void *h2p_lw_virtual_base;
// HPS_to_FPGA FIFO status address = 0
volatile unsigned int * lw_pio_ptr = NULL ;
volatile unsigned int * lw_pio_read_ptr = NULL ;

volatile unsigned int * pio_clk_ptr = NULL ; 
volatile unsigned int * pio_rst_ptr = NULL ; 
volatile signed int * pio_x_ptr = NULL ; 
volatile signed int * pio_y_ptr = NULL ; 
volatile signed int * pio_z_ptr = NULL ; 

volatile signed int * pio_sigma_ptr = NULL ; 
volatile signed int * pio_rho_ptr = NULL ; 
volatile signed int * pio_beta_ptr = NULL ; 

// read offset is 0x10 for both busses
// remember that eaxh axi master bus needs unique address
#define FPGA_PIO_READ	0x10
#define FPGA_PIO_WRITE	0x00
#define CLK_OFFSET      0X20
#define RESET_OFFSET    0X30
#define X_OFFSET        0X40
#define Y_OFFSET        0X50
#define Z_OFFSET        0X60
#define SIGMA_OFFSET	0x70
#define RHO_OFFSET		0x80
#define BETA_OFFSET		0x90


//////// COPIED FROM VGA C CODE ///////////
// video display
#define SDRAM_BASE            0xC0000000
#define SDRAM_END             0xC3FFFFFF
#define SDRAM_SPAN			  0x04000000
// characters
#define FPGA_CHAR_BASE        0xC9000000 
#define FPGA_CHAR_END         0xC9001FFF
#define FPGA_CHAR_SPAN        0x00002000
/* Cyclone V FPGA devices */
#define HW_REGS_BASE          0xff200000
//#define HW_REGS_SPAN        0x00200000 
#define HW_REGS_SPAN          0x00005000 

// graphics primitives
void VGA_text (int, int, char *);
void VGA_text_clear();
void VGA_box (int, int, int, int, short);
void VGA_rect (int, int, int, int, short);
void VGA_line(int, int, int, int, short) ;
void VGA_Vline(int, int, int, short) ;
void VGA_Hline(int, int, int, short) ;
void VGA_disc (int, int, int, short);
void VGA_circle (int, int, int, int);

void draw();

// 16-bit primary colors
#define red  (0+(0<<5)+(31<<11))
#define dark_red (0+(0<<5)+(15<<11))
#define green (0+(63<<5)+(0<<11))
#define dark_green (0+(31<<5)+(0<<11))
#define blue (31+(0<<5)+(0<<11))
#define dark_blue (15+(0<<5)+(0<<11))
#define yellow (0+(63<<5)+(31<<11))
#define cyan (31+(63<<5)+(0<<11))
#define magenta (31+(0<<5)+(31<<11))
#define black (0x0000)
#define gray (15+(31<<5)+(51<<11))
#define white (0xffff)
int colors[] = {red, dark_red, green, dark_green, blue, dark_blue, 
		yellow, cyan, magenta, gray, black, white};

#define fix2float(a) ((float)(a) / 1048576) 

// pixel macro
#define VGA_PIXEL(x,y,color) do{\
	int  *pixel_ptr ;\
	pixel_ptr = (int*)((char *)vga_pixel_ptr + (((y)*640+(x))<<1)) ; \
	*(short *)pixel_ptr = (color);\
} while(0)

// the light weight buss base
void *h2p_lw_virtual_base;

// pixel buffer
volatile unsigned int * vga_pixel_ptr = NULL ;
void *vga_pixel_virtual_base;

// character buffer
volatile unsigned int * vga_char_ptr = NULL ;
void *vga_char_virtual_base;

// /dev/mem file id
int fd;

// measure time
struct timeval t1, t2;
double elapsedTime;

int main(void)
{

    // === need to mmap: =======================
	// FPGA_CHAR_BASE
	// FPGA_ONCHIP_BASE      
	// HW_REGS_BASE    

	// Declare volatile pointers to I/O registers (volatile 	
	// means that IO load and store instructions will be used 	
	// to access these pointer locations,  
  
	// === get FPGA addresses ==================
    // Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) 	{
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}
    
	//============================================
    // get virtual addr that maps to physical
	// for light weight AXI bus
	h2p_lw_virtual_base = mmap( NULL, FPGA_LW_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_LW_BASE );	
	if( h2p_lw_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap1() failed...\n" );
		close( fd );
		return(1);
	}
	// Get the addresses that map to the two parallel ports on the light-weight bus
	lw_pio_ptr = (unsigned int *)(h2p_lw_virtual_base);
	lw_pio_read_ptr = (unsigned int *)(h2p_lw_virtual_base + FPGA_PIO_READ);
	pio_clk_ptr = (unsigned int *)(h2p_lw_virtual_base + CLK_OFFSET);
    pio_rst_ptr = (unsigned int *)(h2p_lw_virtual_base + RESET_OFFSET);
    pio_x_ptr   = (signed int *)(h2p_lw_virtual_base + X_OFFSET);
    pio_y_ptr   = (signed int *)(h2p_lw_virtual_base + Y_OFFSET);
    pio_z_ptr   = (signed int *)(h2p_lw_virtual_base + Z_OFFSET);

	pio_sigma_ptr = (signed int *)(h2p_lw_virtual_base + SIGMA_OFFSET);
	pio_rho_ptr = (signed int *)(h2p_lw_virtual_base + RHO_OFFSET);
	pio_beta_ptr = (signed int *)(h2p_lw_virtual_base + BETA_OFFSET);
	//============================================
	
	// ===========================================
	// get virtual address for
	// AXI bus addr 
	h2p_virtual_base = mmap( NULL, FPGA_AXI_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_AXI_BASE); 	
	if( h2p_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap3() failed...\n" );
		close( fd );
		return(1);
	}
    // Get the addresses that map to the two parallel ports on the AXI bus
	axi_pio_ptr =(unsigned int *)(h2p_virtual_base);
	axi_pio_read_ptr =(unsigned int *)(h2p_virtual_base + FPGA_PIO_READ);
	//============================================
	
    // INSERT VGA C CODE 
    // === get VGA char addr =====================
	// get virtual addr that maps to physical
	vga_char_virtual_base = mmap( NULL, FPGA_CHAR_SPAN, ( 	PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_CHAR_BASE );	
	if( vga_char_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap2() failed...\n" );
		close( fd );
		return(1);
	}
    
    // Get the address that maps to the FPGA LED control 
	vga_char_ptr =(unsigned int *)(vga_char_virtual_base);

	// === get VGA pixel addr ====================
	// get virtual addr that maps to physical
	vga_pixel_virtual_base = mmap( NULL, SDRAM_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, SDRAM_BASE);	
	if( vga_pixel_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap3() failed...\n" );
		close( fd );
		return(1);
	}
    
    // Get the address that maps to the FPGA pixel buffer
	vga_pixel_ptr =(unsigned int *)(vga_pixel_virtual_base);

	// ===========================================

	/* create a message to be displayed on the VGA and LCD displays */
	char text_top_row[40] = "DE1-SoC ARM/FPGA\0";
	char text_bottom_row[40] = "Cornell ece5760\0";
	char text_next[40] = "Graphics primitives\0";
	char num_string[20], time_string[20] ;
	char color_index = 0 ;
	int color_counter = 0 ;
	
	// position of disk primitive
	int disc_x = 0;
	// position of circle primitive
	int circle_x = 0 ;
	// position of box primitive
	int box_x = 5 ;
	// position of vertical line primitive
	int Vline_x = 350;
	// position of horizontal line primitive
	int Hline_y = 250;

	// clear the screen
	VGA_box (0, 0, 639, 479, 0x0000);
	VGA_text_clear();	// clear the text

	// set the default vaules of rho, sigma, and beta
	*(pio_sigma_ptr) = float2fix(10.0); 
	*(pio_rho_ptr)   = float2fix(28.0);
	*(pio_beta_ptr)  = float2fix(8.0/3.0);

	// Reset the module in VERILOG by making sure the clock & reset is set to low
    *(pio_clk_ptr) = 0; // lower to 0
    *(pio_rst_ptr) = 1; // set reset to 1
    *(pio_clk_ptr) = 1; // raise to 1 clk
    *(pio_clk_ptr) = 0; // lower to 0
    *(pio_rst_ptr) = 0; // set reset to 0

	int x_val;
	int y_val;
	int z_val;

	float delay = 10000;	// default delay value
	int pause = 0; 			// 0 = go 1 = paused

	// ----------------------------------------------------------------
	// code for grabbing terminal inputs
	// ----------------------------------------------------------------
	
	// non-blocking mode
    fcntl(STDIN_FILENO, F_SETFL, (int)fcntl(STDIN_FILENO, F_GETFL, 0) | O_NONBLOCK);

	fd_set read_message;

    // buffer for the typed text
    char buf[1024];
    int buf_index = 0;
	
	// ----------------------------------------------------------------
	// while loop that repeats indefinately
	// ----------------------------------------------------------------

	while(1) {	
		// read the terminal values and store in read_message
		FD_ZERO(&read_message);
        FD_SET(STDIN_FILENO, &read_message);

        struct timeval tv;
        tv.tv_sec = 0;
        tv.tv_usec = 0;	// formally set to 100

        // check the file with a timeout time of 0 to perform non-blocking task of displaying 
        int select_result = select(STDIN_FILENO + 1, &read_message, NULL, NULL, &tv);

        // if a new char was read, check it
        if (select_result > 0) {

            char c;
            int read_result = read(STDIN_FILENO, &c, sizeof(c));

            // only fully ready message if pressed enter
            // else just add to the buffer and continue
            if (c == '\n') {
                buf[buf_index] = '\0';
                
                // if the commands w, s are pressed the delay is either shortened
                // or expand the delay time with upper and lower bounds
                // if the p or r are presed pause or unpause state
				if 		( strcmp( buf, "w" ) == 0 ) delay = (delay / 10 < 0.0001) ? 0.0001 : delay / 10;
				else if ( strcmp( buf, "s" ) == 0 ) delay = (delay * 10 >= FLT_MAX / 10) ? FLT_MAX / 10 : delay * 10;
				else if ( strcmp( buf, "p" ) == 0 ) pause = 1;  
				else if ( strcmp( buf, "r" ) == 0 ) pause = 0; 
				
				// clear screen & reset 
				else if (strcmp(buf, "clear") == 0) {
					printf("clearing\n");
                	VGA_box(0, 0, 640, 480, black); // clear screen

                	// reset solver
					*(pio_clk_ptr) = 0;
					*(pio_rst_ptr) = 1; 
					*(pio_clk_ptr) = 1;
					*(pio_clk_ptr) = 0;
					*(pio_rst_ptr) = 0; 
            	}
            	// reset the solver with new user-inputted values
				else if (strcmp(buf,"reset")==0) {
					printf("reseting\n");
					VGA_box(0, 0, 640, 480, black); // clear screen

					// temp vars that will save new user inputed values
					float tempsigma, temprho, tempbeta;
					
					// wait until user types new sigma value
					int change = 0;
					printf("new sigma = ");
					while (change == 0) { if (scanf("%f", &tempsigma) == 1 ) change = 1; }
					
					// wait until user types new rho value
					change = 0;
					printf("new rho = ");
					while (change == 0) { if (scanf("%f", &temprho) == 1 ) change = 1; }

					// wait until user types new beta value
					change = 0;
					printf("new beta = ");
					while (change == 0) { if (scanf("%f", &tempbeta) == 1 ) change = 1; }
					
					printf("Thanks! \n The new values are sigma = %f rho = %f beta = %f\n", tempsigma, temprho, tempbeta);

					// reset solver with the new values
					*(pio_sigma_ptr) = float2fix(tempsigma); 
					*(pio_rho_ptr)   = float2fix(temprho);
					*(pio_beta_ptr)  = float2fix(tempbeta);

					*(pio_clk_ptr) = 0;
					*(pio_rst_ptr) = 1; 
					*(pio_clk_ptr) = 1;
					*(pio_clk_ptr) = 0;
					*(pio_rst_ptr) = 0; 
				}
				else if (strcmp(buf,"sigma")==0) {
					printf("reseting\n");
					VGA_box(0, 0, 640, 480, black); // clear screen

					// update values
					float tempsigma;
					int change = 0;

					// wait until user types new sigma value
					printf("new sigma = ");
					while (change == 0) { if (scanf("%f", &tempsigma) == 1 ) change = 1; }

					// reset with the new values
					*(pio_sigma_ptr) = float2fix(tempsigma);
					*(pio_clk_ptr) = 0;
					*(pio_rst_ptr) = 1; 
					*(pio_clk_ptr) = 1;
					*(pio_clk_ptr) = 0;
					*(pio_rst_ptr) = 0; 
				}
				else if (strcmp(buf,"rho")==0) {
					printf("reseting\n");
					VGA_box(0, 0, 640, 480, black); // clear screen

					float temprho;
					int change = 0;

					// wait until user types new rho value
					printf("new rho = ");
					while (change == 0) { if (scanf("%f", &temprho) == 1 ) change = 1; }

					// reset with the new values
					*(pio_rho_ptr) = float2fix(temprho);
					*(pio_clk_ptr) = 0;
					*(pio_rst_ptr) = 1; 
					*(pio_clk_ptr) = 1;
					*(pio_clk_ptr) = 0;
					*(pio_rst_ptr) = 0; 
				}
				// if the text wants to update beta 
				else if ( strcmp(buf,"beta") == 0 ) {
					printf("reseting\n");
					VGA_box(0, 0, 640, 480, black); // clear screen

					float tempbeta;
					int change = 0;

					// wait until user types new beta value
					printf("new beta = ");
					while (change == 0) { if (scanf("%f", &tempbeta) == 1 ) change = 1; }

					// reset with the new values
					*(pio_beta_ptr) = float2fix(tempbeta);
					*(pio_clk_ptr) = 0;
					*(pio_rst_ptr) = 1; 
					*(pio_clk_ptr) = 1;
					*(pio_clk_ptr) = 0;
					*(pio_rst_ptr) = 0; 
				}
                
                // since entire buffer has been read, set index back to 0
                // to overwrite previous values
				buf_index = 0;

            } 
            // if enter was not pressed just add text to the buffer and continue
            else {
                buf[buf_index] = c;	
                buf_index++;
            }
        }

		// ----------------------------------------------------------------
		// Plot the current simulation values and labels on the VGA display
		// ----------------------------------------------------------------

		VGA_box(64, 430, 240, 480, blue); // blue box
		sprintf(time_string, "Beta = %f", (float) (fix2float(*(pio_beta_ptr))));
		VGA_text (10, 55, time_string);
		sprintf(time_string, "Rho = %f", (float) (fix2float(*(pio_rho_ptr))));
		VGA_text (10, 56, time_string);
		sprintf(time_string, "Sigma = %f", (float) (fix2float(*(pio_sigma_ptr))));
		VGA_text (10, 57, time_string);
		sprintf(time_string, "X Y Projection");
		VGA_text (45, 57, time_string);
		sprintf(time_string, "Y Z Projection");
		VGA_text (55, 35, time_string);
		sprintf(time_string, "X Z Projection");
		VGA_text (10, 35, time_string);

		// while we are not paused, draw 
		if (!pause) draw();

		// sleep for the set delay amount
		usleep(delay);
	}
} // end main


// ****************************************************************************************
// Draw Function to display the Lorentz Plots
// ****************************************************************************************
void draw() {
	int x_val;
	int y_val;
	int z_val;
	int num, pio_read;

    // move to next clock cycle in the FPGA
    *(pio_clk_ptr) = 1; // raise to 1 clk
    *(pio_clk_ptr) = 0; // raise to 1 clk

	// receive back and print
	// cast to float / 2^20 , scale up by a factor of 5 , cast to an int , plot
	x_val = (int) (fix2float( *(pio_x_ptr)) * 5 );
	y_val = (int) (fix2float( *(pio_y_ptr)) * 5 );
	z_val = (int) (fix2float( *(pio_z_ptr)) * 5 );

	// cast to float / 2^20 , scale up by a factor of 5 , cast to an int , plot 
    // display xy, xz, and yz lorenz displays
	VGA_PIXEL( x_val + 370, y_val + 320, red);
	VGA_PIXEL( x_val + 150, z_val + 20,  blue);
    VGA_PIXEL( y_val + 500, z_val + 20,  green);
}

/****************************************************************************************
 * Subroutine to send a string of text to the VGA monitor 
****************************************************************************************/
void VGA_text(int x, int y, char * text_ptr)
{
  	volatile char * character_buffer = (char *) vga_char_ptr ;	// VGA character buffer
	int offset;
	/* assume that the text string fits on one line */
	offset = (y << 7) + x;
	while ( *(text_ptr) )
	{
		// write to the character buffer
		*(character_buffer + offset) = *(text_ptr);	
		++text_ptr;
		++offset;
	}
}

/****************************************************************************************
 * Subroutine to clear text to the VGA monitor 
****************************************************************************************/
void VGA_text_clear()
{
  	volatile char * character_buffer = (char *) vga_char_ptr ;	// VGA character buffer
	int offset, x, y;
	for (x=0; x<79; x++){
		for (y=0; y<59; y++){
	/* assume that the text string fits on one line */
			offset = (y << 7) + x;
			// write to the character buffer
			*(character_buffer + offset) = ' ';		
		}
	}
}

/****************************************************************************************
 * Draw a filled rectangle on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_box(int x1, int y1, int x2, int y2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
	if (x1>x2) SWAP(x1,x2);
	if (y1>y2) SWAP(y1,y2);
	for (row = y1; row <= y2; row++)
		for (col = x1; col <= x2; ++col)
		{
			//640x480
			//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
			// set pixel color
			//*(char *)pixel_ptr = pixel_color;	
			VGA_PIXEL(col,row,pixel_color);	
		}
}

/****************************************************************************************
 * Draw a outline rectangle on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_rect(int x1, int y1, int x2, int y2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
	if (x1>x2) SWAP(x1,x2);
	if (y1>y2) SWAP(y1,y2);
	// left edge
	col = x1;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
		
	// right edge
	col = x2;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
	
	// top edge
	row = y1;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);
	}
	
	// bottom edge
	row = y2;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);
	}
}

/****************************************************************************************
 * Draw a horixontal line on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_Hline(int x1, int y1, int x2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (x1>x2) SWAP(x1,x2);
	// line
	row = y1;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
}

/****************************************************************************************
 * Draw a vertical line on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_Vline(int x1, int y1, int y2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (y2<0) y2 = 0;
	if (y1>y2) SWAP(y1,y2);
	// line
	col = x1;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);			
	}
}


/****************************************************************************************
 * Draw a filled circle on the VGA monitor 
****************************************************************************************/

void VGA_disc(int x, int y, int r, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col, rsqr, xc, yc;
	
	rsqr = r*r;
	
	for (yc = -r; yc <= r; yc++)
		for (xc = -r; xc <= r; xc++)
		{
			col = xc;
			row = yc;
			// add the r to make the edge smoother
			if(col*col+row*row <= rsqr+r){
				col += x; // add the center point
				row += y; // add the center point
				//check for valid 640x480
				if (col>639) col = 639;
				if (row>479) row = 479;
				if (col<0) col = 0;
				if (row<0) row = 0;
				//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
				// set pixel color
				//*(char *)pixel_ptr = pixel_color;
				VGA_PIXEL(col,row,pixel_color);	
			}
					
		}
}

/****************************************************************************************
 * Draw a  circle on the VGA monitor 
****************************************************************************************/

void VGA_circle(int x, int y, int r, int pixel_color)
{
	char  *pixel_ptr ; 
	int row, col, rsqr, xc, yc;
	int col1, row1;
	rsqr = r*r;
	
	for (yc = -r; yc <= r; yc++){
		//row = yc;
		col1 = (int)sqrt((float)(rsqr + r - yc*yc));
		// right edge
		col = col1 + x; // add the center point
		row = yc + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
		// left edge
		col = -col1 + x; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
	}
	for (xc = -r; xc <= r; xc++){
		//row = yc;
		row1 = (int)sqrt((float)(rsqr + r - xc*xc));
		// right edge
		col = xc + x; // add the center point
		row = row1 + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
		// left edge
		row = -row1 + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
	}
}

// =============================================
// === Draw a line
// =============================================
//plot a line 
//at x1,y1 to x2,y2 with color 
//Code is from David Rodgers,
//"Procedural Elements of Computer Graphics",1985
void VGA_line(int x1, int y1, int x2, int y2, short c) {
	int e;
	signed int dx,dy,j, temp;
	signed int s1,s2, xchange;
     signed int x,y;
	char *pixel_ptr ;
	
	/* check and fix line coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
        
	x = x1;
	y = y1;
	
	//take absolute value
	if (x2 < x1) {
		dx = x1 - x2;
		s1 = -1;
	}

	else if (x2 == x1) {
		dx = 0;
		s1 = 0;
	}

	else {
		dx = x2 - x1;
		s1 = 1;
	}

	if (y2 < y1) {
		dy = y1 - y2;
		s2 = -1;
	}

	else if (y2 == y1) {
		dy = 0;
		s2 = 0;
	}

	else {
		dy = y2 - y1;
		s2 = 1;
	}

	xchange = 0;   

	if (dy>dx) {
		temp = dx;
		dx = dy;
		dy = temp;
		xchange = 1;
	} 

	e = ((int)dy<<1) - dx;  
	 
	for (j=0; j<=dx; j++) {
		//video_pt(x,y,c); //640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (y<<10)+ x; 
		// set pixel color
		//*(char *)pixel_ptr = c;
		VGA_PIXEL(x,y,c);			
		 
		if (e>=0) {
			if (xchange==1) x = x + s1;
			else y = y + s2;
			e = e - ((int)dx<<1);
		}

		if (xchange==1) y = y + s2;
		else x = x + s1;

		e = e + ((int)dy<<1);
	}
}