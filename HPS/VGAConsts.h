#pragma once

/* function prototypes */
void VGA_text (int, int, char *);
void VGA_text_clear();
void VGA_box (int, int, int, int, short);
void VGA_line(int, int, int, int, short) ;
void draw_delay(void) ;
void VGA_Vline(int, int, int, short) ;
void VGA_Hline(int, int, int, short) ;

// the light weight buss base
void *h2p_lw_virtual_base;

// RAM FPGA command buffer
volatile unsigned int * sram_ptr = NULL ;
void *sram_virtual_base;

// pixel buffer
volatile unsigned int * vga_pixel_ptr = NULL ;
void *vga_pixel_virtual_base;

// character buffer
volatile unsigned int * vga_char_ptr = NULL ;
void *vga_char_virtual_base;

// /dev/mem file id
int fd;

// pixel macro
// !!!PACKED VGA MEMORY!!!
#define VGA_PIXEL(x,y,color) do{\
	char  *pixel_ptr ;\
	pixel_ptr = (char *)vga_pixel_ptr + ((y)*640) + (x) ;\
	*(char *)pixel_ptr = (color);\
} while(0)

// not packed VGA 
// #define VGA_PIXEL(x,y,color) do{\
// 	int  *pixel_ptr ;\
// 	pixel_ptr = (int*)((char *)vga_pixel_ptr + (((y)*640+(x))<<1)) ; \
// 	*(short *)pixel_ptr = (color);\
// } while(0)

#define white (0xffff)
#define black (0x0000)