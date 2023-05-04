// PTHREADS Switches

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

#include <pthread.h>

typedef int fix;

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
#define fix2float(a) ((float)(a) / 8388608) 	// 2^23

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

// PLOTING INFORMATION:
int zoom = 0;
int max_iter = 1000;

float x_c_corner = -2.0;
float y_c_corner = 1.0;

void *thread_func1(void *arg) {
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
    float x, y;
    int left_click =0;
    int right_click =0;
	printf("Entering Mouse Loop \n");

    float temp_x_sum;
    float temp_y_sum;

    int adding = 0;
    
    while (1) {
        int flags = fcntl(fd2, F_GETFL, 0);
        fcntl(fd2, F_SETFL, flags | O_NONBLOCK); 

        bytes_mouse = read(fd2, data, sizeof(data));

        if(bytes_mouse > 0)
        {
            left_click = data[0] & 0x1;
            right_click = data[0] & 0x2;
            
            signed char temp_x = data[1];
            signed char temp_y = data[2];
        	
            x = (float)temp_x;
            y = (float)temp_y;
            // printf("x=%f, y=%f, left=%d, right=%d\n", x, y, left_click, right_click);

            if ( left_click > 0) {
                adding = 1;
            }
            if ( adding == 1) {
                temp_x_sum += x;
                temp_y_sum += y;
            }
            if ( right_click > 0) {
                // scale down the inputs from the mouse 
                temp_x_sum = temp_x_sum / 500; 
                temp_y_sum = temp_y_sum / 500;

                // update the current X, y corner values 
                x_c_corner += temp_x_sum;
                y_c_corner += temp_y_sum;

                if ( x_c_corner < -2) x_c_corner = -2; 
                if ( x_c_corner >  1) x_c_corner =  1; 
                if ( y_c_corner >  1) y_c_corner =  1; 
                if ( y_c_corner < -1) y_c_corner = -1; 

                // send the new values in fix point to the FPGA
                *(pio_dx_ptr) = float2fix(x_c_corner); // 0.04 - 0.2
                *(pio_dy_ptr) = float2fix(y_c_corner); // 0.04 - 0.2

                printf("new and improvd: dx = %f  dy = %f \n", x_c_corner, y_c_corner);

                *(pio_rst_ptr) = 1; // set reset to 1
                usleep(1);
                *(pio_rst_ptr) = 0; // set reset to 1
                usleep(1);

                while ( *(pio_doneplot_ptr) != 1 ) { }
                printf("STATUS ::: zoom = %d  max_iter = %d time in ms = %d at top left corner [x, y] = [%f, %f]\n", zoom, max_iter, ((int) (*(pio_tmr_ptr))), x_c_corner, y_c_corner);

                temp_x_sum = 0;
                temp_y_sum = 0;
                adding = 0;
            }
        } 
    }
}

void *thread_func2(void *arg) {
    fcntl(STDIN_FILENO, F_SETFL, (int)fcntl(STDIN_FILENO, F_GETFL, 0) | O_NONBLOCK);
	fd_set read_message;

    // buffer for the typed text
    char buf[1024];
    int buf_index = 0;

	float delay = 10000;	// default delay value
	int pause = 0; 			// 0 = go 1 = paused

	
    while(1) {
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
        			
                    float mult = 0;
                    if ( zoom == tempzoom ) {
                        x_c_corner = x_c_corner * 1.0;
                        y_c_corner = y_c_corner * 1.0;
                    }
                    else if ( zoom < tempzoom ) {// we zooming in
                        mult = pow(2, tempzoom - zoom );
                        x_c_corner = x_c_corner / mult;
                        y_c_corner = y_c_corner / mult;
                    }
                    else {
                        mult = pow(2, zoom - tempzoom );
                        x_c_corner = x_c_corner * mult;
                        y_c_corner = y_c_corner * mult;
                    }

                    if ( x_c_corner < -2) { x_c_corner = -2; printf("error"); }
                    if ( x_c_corner >  1) { x_c_corner =  1; printf("error"); }
                    if ( y_c_corner >  1) { y_c_corner =  1; printf("error"); }
                    if ( y_c_corner < -1) { y_c_corner = -1; printf("error"); }

                    zoom          = tempzoom;
					*(pio_zm_ptr) = tempzoom;

                    // send the new values in fix point to the FPGA
                    *(pio_dx_ptr) = float2fix(x_c_corner); // 0.04 - 0.2
                    *(pio_dy_ptr) = float2fix(y_c_corner); // 0.04 - 0.2


            		*(pio_rst_ptr) = 1; // set reset to 1
					usleep(1);
					*(pio_rst_ptr) = 0; // set reset to 1
					usleep(1);
         	  	}

				
				while ( *(pio_doneplot_ptr) != 1 ) { }
                printf("STATUS ::: zoom = %d  max_iter = %d time in ms = %d at top left corner [x, y] = [%f, %f]\n", zoom, max_iter, ((int) (*(pio_tmr_ptr))), x_c_corner, y_c_corner);
                
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
}

int main() {
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
	*(pio_maxiter_ptr) = 1000;
	*(pio_zm_ptr) = 0;
    // send the new values in fix point to the FPGA
    *(pio_dx_ptr) = float2fix(x_c_corner); // 0.04 - 0.2
    *(pio_dy_ptr) = float2fix(y_c_corner); // 0.04 - 0.2

	// Reset the module in VERILOG by making sure the clock & reset is set to low
  	// clock_t begin = clock();
	usleep(1);
	*(pio_rst_ptr) = 0; // set reset to 1
	usleep(1);

 	*(pio_rst_ptr) = 1; // set reset to 1
	usleep(1);
	*(pio_rst_ptr) = 0; // set reset to 1
	// printf("%d",*(pio_done_ptr));

    printf("STATUS ::: zoom = %d  max_iter = %d time in ms = %d at top left corner [x, y] = [%f, %f]\n", zoom, max_iter, ((int) (*(pio_tmr_ptr))), x_c_corner, y_c_corner);

    // ===========================================


    pthread_t thread1, thread2;
    pthread_create(&thread1, NULL, thread_func1, NULL);
    pthread_create(&thread2, NULL, thread_func2, NULL);

    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);

    printf("Threads finished\n");
    return 0;
}
