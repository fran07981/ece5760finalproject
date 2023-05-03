#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/ipc.h> 
#include <sys/shm.h> 
#include <sys/mman.h>
#include <sys/time.h> 
#include <math.h> 

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

volatile unsigned int * pio_done_ptr  = NULL; 	// Done resetting
volatile unsigned int * pio_rst_ptr  = NULL; 	// send reset flag to FPGA arbriter 
volatile signed int   * pio_maxiter_ptr = NULL; // send N to FPGA 

volatile unsigned int * pio_tmr_ptr  = NULL;	// timer from FPGA

volatile unsigned int * pio_doneplot_ptr  = NULL; 	// Done plotting

// read offset is 0x10 for both busses
// remember that eaxh axi master bus needs unique address
#define FPGA_PIO_READ	0x10
#define FPGA_PIO_WRITE	0x00

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


// the light weight buss base
void *h2p_lw_virtual_base;

// /dev/mem file id
int fd;

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
   	
	pio_tmr_ptr   	= (unsigned int *)(h2p_lw_virtual_base + TIMER_OFFSET   );

	pio_doneplot_ptr = (unsigned int *)(h2p_lw_virtual_base + DONEPLOT_OFFSET     );

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
	axi_pio_ptr 	 = (unsigned int *)(h2p_virtual_base);
	axi_pio_read_ptr = (unsigned int *)(h2p_virtual_base + FPGA_PIO_READ);

	 *(pio_maxiter_ptr) = 1000; //Check if it is okay to do this. 

	printf("Pointer Set to Reset");
 	*(pio_rst_ptr) = 1; 
	while(*(pio_done_ptr)==0);
  	*(pio_rst_ptr) = 0;
              
  	printf("Entering loop");

	while(*(pio_doneplot_ptr)==0);
	printf("Done at Clock Cycles - %d\n",*(pio_tmr_ptr));
} 
