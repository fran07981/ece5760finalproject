///////////////////////////////////////
/// 640x480 version!
/// test VGA with hardware video input copy to VGA
// compile with
// gcc mandelbrot_control.c -o gr -O2 -lm
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
volatile unsigned int * lw_pio_ptr = NULL;
volatile unsigned int * lw_pio_read_ptr = NULL;


volatile unsigned int * pio_rst_ptr  = NULL; 	// send reset flag to FPGA arbriter 
volatile signed int   * pio_maxiter_ptr = NULL; // send N to FPGA 
volatile signed int   * pio_dx_ptr = NULL; 		// send dx to FPGA 
volatile signed int   * pio_dy_ptr = NULL; 		// send dy to FPGA 
volatile signed int   * pio_zm_ptr = NULL; 		// send zoom # to FPGA 

volatile unsigned int * pio_tmr_ptr  = NULL;	    // timer from FPGA
volatile unsigned int * pio_doneplot_ptr  = NULL; 	// Done plotting FROM fpga
volatile unsigned int * pio_done_ptr  = NULL; 	    // Done resetting FROM fpGA

// read offset is 0x10 for both busses
// remember that eaxh axi master bus needs unique address
#define FPGA_PIO_READ	0x10
#define FPGA_PIO_WRITE	0x00

#define DX_OFFSET       0X20
#define DY_OFFSET       0X30
#define ZM_OFFSET       0X40
#define DONE_OFFSET      0X50
#define RESET_OFFSET    0X60
#define MAXITER_OFFSET  0X70
#define TIMER_OFFSET    0X80
#define DONEPLOT_OFFSET      0X90

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


// #define fix2float(a) ((float)(a) / 1048576) 

#define float2fix(a) (fix)(a * 8388608)	// 2^23

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
	lw_pio_ptr 		= (unsigned int *)(h2p_lw_virtual_base);
	lw_pio_read_ptr = (unsigned int *)(h2p_lw_virtual_base + FPGA_PIO_READ);
	
	pio_done_ptr 	= (unsigned int *)(h2p_lw_virtual_base + DONE_OFFSET     );
    pio_rst_ptr 	= (unsigned int *)(h2p_lw_virtual_base + RESET_OFFSET   );
    pio_maxiter_ptr = (signed   int *)(h2p_lw_virtual_base + MAXITER_OFFSET );
   	pio_dx_ptr 		= (signed   int *)(h2p_lw_virtual_base + DX_OFFSET		);
    pio_dy_ptr 		= (signed   int *)(h2p_lw_virtual_base + DY_OFFSET		);
    pio_zm_ptr   	= (signed   int *)(h2p_lw_virtual_base + ZM_OFFSET		);
	pio_tmr_ptr   	= (unsigned int *)(h2p_lw_virtual_base + TIMER_OFFSET   );

	pio_doneplot_ptr = (unsigned int *)(h2p_lw_virtual_base + DONEPLOT_OFFSET     );

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
	axi_pio_ptr 	 = (unsigned int *)(h2p_virtual_base);
	axi_pio_read_ptr = (unsigned int *)(h2p_virtual_base + FPGA_PIO_READ);
	
	// ===========================================

	// setbuf(stdout, NULL); // IDK WHAT THIS DOES BUT IT GOT THE TERINAL WORKING AGAIN
	
	// set the default vaules of Max Iterations
	printf("Setting Max Iterations to 1000 \n");
	*(pio_maxiter_ptr) = 1000; //Check if it is okay to do this. 
	*(pio_zm_ptr) = 0; //Check if it is okay to do this. 

	// Reset the module in VERILOG by making sure the clock & reset is set to low
  	// clock_t begin = clock();
	usleep(1);
	*(pio_rst_ptr) = 0; // set reset to 1
	usleep(1);

	printf("Pointer Set to Reset \n");
 	*(pio_rst_ptr) = 1; // set reset to 1
	usleep(1);
	*(pio_rst_ptr) = 0; // set reset to 1
	// printf("%d",*(pio_done_ptr));
	
	

	// ----------------------------------------------------------------
	// code for grabbing terminal inputs
	// ----------------------------------------------------------------
	
	// non-blocking mode
    fcntl(STDIN_FILENO, F_SETFL, (int)fcntl(STDIN_FILENO, F_GETFL, 0) | O_NONBLOCK);
	fd_set read_message;

    // buffer for the typed text
    char buf[1024];
    int buf_index = 0;

	float delay = 10000;	// default delay value
	int pause = 0; 			// 0 = go 1 = paused

	int zoom = 0;
	int max_iter = 1000;

	printf("CURENT STATUS ==> zoom = %d  max_iter = %d\n", zoom, max_iter);
	
	
	// ----------------------------------------------------------------
	// while loop that repeats indefinately
	// ----------------------------------------------------------------
	printf("Setting up Mouse file \n");
	int fd2, bytes_mouse;
    unsigned char data[3];
    const char *pDevice = "/dev/input/mice";

    // Open Mouse
    fd2 = open(pDevice, O_RDWR);
    if(fd2 == -1)
    {
        printf("ERROR Opening %s\n", pDevice);
        return -1;
    }
	signed char x_delta, y_delta;

	printf("Entering loop \n");
	while(1) {	

		int flags = fcntl(fd2, F_GETFL, 0);
        fcntl(fd2, F_SETFL, flags | O_NONBLOCK); 

        bytes_mouse = read(fd2, data, sizeof(data));

        if(bytes_mouse > 0)
        {
        	x = data[1];
            y = data[2];
            printf("x=%d, y=%d", x, y);
        } 


		// read the terminal values and store in read_message
		FD_ZERO(&read_message);
        FD_SET(STDIN_FILENO, &read_message);

        struct timeval tv;
        tv.tv_sec = 0;
        tv.tv_usec = 0;	// formally set to 100

        // check the file with a timeout time of 0 to perform non-blocking task of displaying 
        int select_result = select(STDIN_FILENO + 1, &read_message, NULL, NULL, &tv);

        //printf("Are we here");
        // if a new char was read, check it
        if (select_result > 0) {
            char c;
            int read_result = read(STDIN_FILENO, &c, sizeof(c));

             // only fully ready message if pressed enter
             // else just add to the buffer and continue
            if (c == '\n') {
				
                buf[buf_index] = '\0';
                
                // If the command "iter" is typed, the user can redefine the iterations 
			    if (strcmp(buf, "iter") == 0) {
        			int tempmaxiter;
					int change = 0;
					// wait until user types new max iterations value
					printf("new max iterations = ");
					while (change == 0) { if (scanf("%d", &tempmaxiter) == 1 ) change = 1; }
					max_iter = tempmaxiter;
        			*(pio_maxiter_ptr) = tempmaxiter;
            		*(pio_rst_ptr) = 1; // set reset to 1
					usleep(1);
					*(pio_rst_ptr) = 0; // set reset to 1
					usleep(1);
         	  	}
				 // If the command "iter" is typed, the user can redefine the iterations 
			    if (strcmp(buf, "zoom") == 0) {
                	int tempzoom;
					int change = 0;
					// wait until user types new max iterations value
					printf("new zoom = ");
					while (change == 0) { if (scanf("%d", &tempzoom) == 1 ) change = 1; }
        			zoom = tempzoom;
					*(pio_zm_ptr) = tempzoom;
            		*(pio_rst_ptr) = 1; // set reset to 1
					usleep(1);
					*(pio_rst_ptr) = 0; // set reset to 1
					usleep(1);
         	  	}

				printf("CURENT STATUS ==> zoom = %d  max_iter = %d\n", zoom, max_iter);
				printf("waiting = %d \n", *(pio_doneplot_ptr));
				while ( *(pio_doneplot_ptr) != 1 ) { }
				printf("Done at Clock Cycles = %d\n",(int) (*(pio_tmr_ptr)));
                
				// since entire buffer has been read, set index back to 0
				// to overwrite previous values
				buf_index = 0;
			}
			// if enter was not pressed just add text to the buffer and continue
			else {
				buf[buf_index] = c;// c;	
				buf_index++;
			}
        }
        
        //if (*(pio_done_ptr)==1){
        //        clock_t end = clock();
        //        double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
        //        sprintf(time_string, "Time Render = %lf", time_spent);
		//        VGA_text (10, 56, time_string);
        //}

		// sleep for the set delay amount
		usleep(delay);
	}
} // end main
