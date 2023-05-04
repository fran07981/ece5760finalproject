#pragma once

#include <string.h>
#include <float.h>
#include "VGAHelperFunctions.h"
#include "sim.h"

void *readMouseThread(void *arg) {
	printf("entering launched thread");
    int fd2, bytes_mouse;
    unsigned char data[3];
    const char *pDevice = "/dev/input/mice";

    // Open Mouse
    fd2 = open(pDevice, O_RDWR);
    if(fd2 == -1) { printf("ERROR Opening %s\n", pDevice); }
	
	int flags = fcntl(fd2, F_GETFL, 0);
	fcntl(fd2, F_SETFL, flags | O_NONBLOCK); 
	
    signed char x, y;
	int x_coord,y_coord = 0;
	int left_click =0;
    int right_click =0;
	float source [10][2]; //just put 10 to see if it works
	int incr_so = 0;
	float sink [10][2]; //just put 10 to see if it works
	int incr_si = 0;

    while (1) {

        bytes_mouse = read(fd2, data, sizeof(data));

        if(bytes_mouse > 0)
        {
			VGA_Hline(0,y_coord,640,black);
			VGA_Vline(x_coord,0,480,black);

            left_click = data[0] & 0x1;
            right_click = data[0] & 0x2;
            
            x = data[1];
            y = data[2];

			if( (x_coord + (int) x)<640 && (x_coord + (int) x) >= 0 ) { x_coord += (int) x; }
			if( (y_coord - (int) y)<480 && (y_coord - (int) y) >= 0 ) { y_coord -= (int) y; }

			//draw cursor
			VGA_Hline(0,y_coord,640,white);
			VGA_Vline(x_coord,0,480,white);
        }
		usleep(17000);
    }
}

float delay = 10000;	// default delay value
int pause_sys = 0;

void *readKeyboardThread(void *arg) {
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
                
				 // Commands for "stop, go, speed up, slow down" 
			    if      (strcmp(buf, "stop") == 0)  pause_sys = 1;
                else if (strcmp(buf, "go"  ) == 0)  pause_sys = 0;
         	  	else if (strcmp(buf, "w"   ) == 0) delay = (delay / 10 < 0.0001) ? 0.0001 : delay / 10;
				else if (strcmp(buf, "e"   ) == 0) delay = (delay * 10 >= FLT_MAX / 10) ? FLT_MAX / 10 : delay * 10;  
                    
				// since entire buffer has been read, set index back to 0 to overwrite previous values
				buf_index = 0;
			}
			// if enter was not pressed just add text to the buffer and continue
			else {
				buf[buf_index] = c;// c;	
				buf_index++;
			}
        }
		usleep(17000);

    } //while loop
} //keyboard thread

void *plotHeatThread(void *arg) {
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

		// free memory when program ends
		freeResources();
		return 0;

}