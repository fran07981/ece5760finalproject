#pragma once

#include <string.h>
#include <float.h>
#include "VGAHelperFunctions.h"
#include "sim.h"

float delay = 10000;	// default delay value
int   paused = 0;

float **source = NULL;
float **sink = NULL;
float **heat = NULL;

void allocateGridResources(){
    // define two grids (rows)
    source = (float **) malloc(10 * sizeof(float *));
    sink   = (float **) malloc(10 * sizeof(float *));
	heat   = (float **) malloc(10 * sizeof(float *));

    // 2D array, so each row needs to be allocated (cols)
    for (int i = 0; i < 10; i++) {
        source[i] = (float *) calloc(2, sizeof(float));
        sink[i]   = (float *) calloc(2, sizeof(float));
		heat[i]   = (float *) calloc(2, sizeof(float));
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

	// iteratiors
	int sinkIt = 0;
	int sourIt = 0;
	int heatIt = 0;

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

			// mark as heat source or sink and send to FPGA
			if (left_click == 1) {
				int selectedType;
				int change = 0;
				
				// wait until user types new max iterations value
				printf("Source or Sink? (1 or 2) \n");
				while (change == 0) { if (scanf("%d", &selectedType) == 1 ) change = 1; }
				
				if (selectedType == 1) { 	// SOURCE
					source[sourIt][0] =  x_coord;  
					source[sourIt][1] =  y_coord;

					sourIt = sourIt + 1;
					
					printf("Making Source: \n");
					for (int i = 0; i < sourIt; ++i) {
						for (int j = 0; j < 2; ++j) {
							printf("%f ", source[i][j]);
						}
						printf("\n");
					}
				} 
				else if (selectedType == 2 ) {		// SINK
					sink[sinkIt][0] =  x_coord;
					sink[sinkIt][1] =  y_coord;

					sinkIt = sinkIt + 1;

					printf("Making Sink: \n");
					for (int i = 0; i < sinkIt; ++i) {
						for (int j = 0; j < 2; ++j) {
							printf("%f ", sink[i][j]);
						}
						printf("\n");
					}
				} 
				else {
					printf("Invalid Input");
				}
			}
        }
		usleep(delay);
    }
}

void *sendDataThread(void *arg) {
	printf("entering data send thread");
	int count = 0;
    while(1) 
	{
		if (paused == 0) {	
			int sourceVal =  10;
			int heatVal   =   5;
			int sinkVal   = -10;
			
			// y = 0-479 (8  bits ->  512) 12
			// x = 0-639 (10 bits -> 1024) 12
			// val = -100 - 100 (4 bits + 1 sign bit) 8 bits 
			// 32 bits: |0000|0000|0000 | 0000|0000|0000 | 0000|0000
			//		    [-------X-------] [-------Y------] [--VAL--]

			// TODO:: FIGURE OUT SECTION BELOW:::
			for (int i = 0; i < sourIt; ++i) {
				unsigned short x_coord = static_cast<unsigned short>( source[i][1] * 8.0f);
				unsigned short y_coord = static_cast<unsigned short>( source[i][1] * 8.0f);
				unsigned short value   = static_cast<unsigned short>( sourceVal    * 4.0f);

				
			}

			
			r = r << 5;
			g = g << 2;
			b = b ; 
			unsigned short pixel_color = b | g | r;
			
			// set up parameters
			*( sram_ptr + 1 ) = x1;
			*( sram_ptr + 2 ) = y1;
			*( sram_ptr + 3 ) = x2;
			*( sram_ptr + 4 ) = y2;
			*( sram_ptr + 5 ) = color;
			*( sram_ptr ) = 1; 			// the "data-ready" flag
		
			while (*(sram_ptr)==1);		// wait for FPGA to zero the "data_ready" flag
		}
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
			    if      (strcmp(buf, "stop") == 0)  paused = 1;
                else if (strcmp(buf, "go"  ) == 0)  paused = 0;
         	  	else if (strcmp(buf, "w"   ) == 0)  delay = (delay / 10 < 0.0001) ? 0.0001 : delay / 10;
				else if (strcmp(buf, "s"   ) == 0)  delay = (delay * 10 >= FLT_MAX / 10) ? FLT_MAX / 10 : delay * 10;  
                    
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