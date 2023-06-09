#pragma once

#include <string.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include "VGAHelperFunctions.h"
#include "sim.h"

float delay  	  = 10000;	// default delay value
int   paused 	  = 0;
int   send   	  = 0;
int   source_mode = 0;
int   sink_mode   = 0;

int **source = NULL;
int **sink = NULL;
int **heat = NULL;

// iteratiors
int sinkIt = 0;
int sourIt = 0;
int heatIt = 0;

void allocateGridResources(){
    // define two grids (rows)
    source = (int **) malloc(255 * sizeof(int *));
    sink   = (int **) malloc(255 * sizeof(int *));
	heat   = (int **) malloc(255 * sizeof(int *));

    // 2D array, so each row needs to be allocated (cols)
    for (int i = 0; i < 255; i++) {
        source[i] = (int *) calloc(2, sizeof(int));
        sink[i]   = (int *) calloc(2, sizeof(int));
		heat[i]   = (int *) calloc(2, sizeof(int));
    }
}

void *readMouseThread(void *arg) {
	unsigned char white = 0b11111111;
	unsigned char black = 0b00000000;

	printf("entering mouse thread \n");
    int fd2, bytes_mouse;
    unsigned char data[3];
    const char *pDevice = "/dev/input/mice";

    // Open Mouse
    fd2 = open(pDevice, O_RDWR);
    if(fd2 == -1) { printf("ERROR Opening %s\n", pDevice); }
	
	int flags = fcntl(fd2, F_GETFL, 0);
	fcntl(fd2, F_SETFL, flags | O_NONBLOCK); 
	
	// initialize parameters
    signed char x, y;
	int x_coord = 20; 
	int y_coord = 20;
	int left_click 		 = 0;
    int right_click 	 = 0;
	
	// arrays that can be filledby users & sent to FPGA through dual SRAM block
	allocateGridResources();

    while (1) {
		bytes_mouse = read(fd2, data, sizeof(data));

        if(bytes_mouse > 0)
        {
			// erase old cursor
			VGA_Hline(0,y_coord,640,black);
			VGA_Vline(x_coord,0,480,black);

            left_click  = data[0] & 0x1;
            right_click = data[0] & 0x2;
            
            x = data[1];
            y = data[2];

			// printf(" x = %d, y = %d === ", (int)x, (int)y);

			if( (x_coord + (int) x)<640 && (x_coord + (int) x) >= 0 ) { x_coord += (int) x; }
			if( (y_coord - (int) y)<480 && (y_coord - (int) y) >= 0 ) { y_coord -= (int) y; }

			// printf(" x = %d, y = %d \n", (int)x_coord, (int)y_coord);

			// draw new cursor
			VGA_Hline(0,(int)y_coord,640,white);
			VGA_Vline((int)x_coord,0,480,white);

			int x_cal = ceil(x_coord / 7) - 1;
			int y_cal = ceil(y_coord / 7) - 1;

			if (x_cal > 63) x_cal = 63;
			if (y_cal > 63) y_cal = 63;

			// mark as heat source or sink and send to FPGA
			if (left_click == 1) {
				if (source_mode == 1) { 			// SOURCE
					source[sourIt][0] =  x_cal;  
					source[sourIt][1] =  y_cal;

					printf("Making Source: ");
					for (int j = 0; j < 2; ++j) {
						printf("%d ", source[sourIt][j]);
					}

					sourIt = sourIt + 1;
				} 
				else if (sink_mode == 1 ) {		// SINK
					sink[sinkIt][0] =  x_cal;
					sink[sinkIt][1] =  y_cal;

					printf("Making Sink: ");
					for (int j = 0; j < 2; ++j) {
						printf("%d ", sink[sinkIt][j]);
					}
					

					sinkIt = sinkIt + 1;
				}
				printf("\n");
			}
        }
		usleep(delay);
    }
}

void *sendDataThread(void *arg) {
	printf("entering data send thread\n");
	int count = 0;
    while(1) 
	{
		if (send == 1) {	
			printf(" ~sending data~ \n\n");
			uint16_t sourceVal =  10;
			uint16_t heatVal   =   5;
			int8_t   sinkVal   = -10;
			
			// y   =    0 : 479 (9  bits ->  512    ) 12 bits
			// x   =    0 : 639 (10 bits -> 1024    ) 12 bits
			// val = -128 : 128 (7 bits + 1 sign bit) 8  bits 
			// 32 bits: |0000|0000|0000 | 0000|0000|0000 | 0000|0000
			//		    [-------X-------] [-------Y------] [--VAL--]

			// 1st value in the M10K block is the "data-ready" flag
			// 2nd value in the M10K block is the # of values? (still deciding on this or using an )
			
			//----------------------------------------------------------------
			// printf("  Adding source: ");
			// for (int i = 0; i < sourIt; ++i) {
			// 	for (int j = 0; j < 2; ++j) {
			// 		printf("    %d ", source[i][j]);
			// 	}
			// 	printf("\n");
			// }

			for (int i = 0; i < sourIt; ++i) {	
				uint32_t x_coord = source[i][0] << 20;
				uint32_t y_coord = source[i][1] << 8 ;

				uint32_t value   = static_cast<uint8_t>(sourceVal);

				uint32_t sendValue = x_coord | y_coord | value;
				printf(" x: %08x y: %08x val: %08x sent: %08x \n", x_coord, y_coord, value, sendValue);
				*( sram_ptr + i + 2 ) = sendValue;
			}

			// Adding source: x = 181 y = 233 : in hex : x = b5 and y = e9 

			// x: b500000 y: e900 val: a sent: b50e90a = 0B5|0E9|0A 
			
			//----------------------------------------------------------------
			// printf("  Adding sink: ");
			// for (int i = 0; i < sourIt; ++i) {
			// 	for (int j = 0; j < 2; ++j) {
			// 		printf("    %d ", sink[i][j]);
			// 	}
			// 	printf("\n");
			// }

			for (int i = 0; i < sinkIt; ++i) {	
				uint32_t x_coord = sink[i][0] << 20;
				uint32_t y_coord = sink[i][1] << 8;
				uint32_t value   = static_cast<uint8_t>(sinkVal);

				uint32_t sendValue = x_coord | y_coord | value;

				*( sram_ptr + i + 2 + sourIt) = sendValue;
			}
			
			//----------------------------------------------------------------
			uint32_t num = sinkIt + sourIt;
			*( sram_ptr + 1) = num;	// tell FPGA how many sources we have
			*( sram_ptr ) 	 = 1; 		// "data-ready" flag
			while (*(sram_ptr)==1);		// wait for FPGA to zero the "data_ready" flag
			send = 0;
			printf(" ~done sending~ \n\n");
		}
		usleep(delay);
	}
}

void *readKeyboardThread(void *arg) {
	printf("entering keyboard thread\n");
    fcntl(STDIN_FILENO, F_SETFL, (int)fcntl(STDIN_FILENO, F_GETFL, 0) | O_NONBLOCK);
	fd_set read_message;

    // buffer for the typed text
    char buf[1024];
    int buf_index = 0;

    while(1) {
        FD_ZERO(&read_message);
        FD_SET(STDIN_FILENO, &read_message);

        struct timeval tv;
        tv.tv_sec = 0;
        tv.tv_usec = 0;

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
                
				// Commands for "stop, go, speed up, slow down" 
			    if      (strcmp(buf, "stop"  ) == 0)  paused = 1;
                else if (strcmp(buf, "go"    ) == 0)  paused = 0;
         	  	else if (strcmp(buf, "w"     ) == 0)  delay  = (delay / 10 < 0.0001) ? 0.0001 : delay / 10;
				else if (strcmp(buf, "send"  ) == 0)  send   = 1;
				else if (strcmp(buf, "s"     ) == 0)  delay  = (delay * 10 >= FLT_MAX / 10) ? FLT_MAX / 10 : delay * 10;  
				
				else if (strcmp(buf, "source") == 0) {
					source_mode = 1;
					sink_mode   = 0;
				}
				else if (strcmp(buf, "sink"  ) == 0) {
					source_mode = 0;
					sink_mode   = 1;
				}
                    
				// since entire buffer has been read, set index back to 0 to overwrite previous values
				buf_index = 0;
			}
			// if enter was not pressed just add text to the buffer and continue
			else {
				buf[buf_index] = c;// c;	
				buf_index++;
			}
        }
		usleep(delay);
    }
}

void *plotHeatThread(void *arg) {
	printf("entering plot thread\n");
	// set up grid & initial values
	grid_size = 100;
    allocateResources();
    intializeGrid();

	while(1){
		simulate();
		for (int i = 1; i < grid_size - 1; i++) {
			for (int j = 1; j < grid_size - 1; j++) {
				float heat = currGrid[i][j];
				int colorIndex = (int)(heat * (numColors - 1));
				colorIndex = fmax(0, fmin(numColors - 1, colorIndex));
				plotPoint(i, j, colorIndex);
			}
		}
		usleep(delay);
	}
}