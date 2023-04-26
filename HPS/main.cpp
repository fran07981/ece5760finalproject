// ------------------------------------------------------------
// Main.cpp
//
// Plots the heat equation to a VGA screan through the FPGA
// Expanded functionality with mouse and keyyboard
// 
// ------------------------------------------------------------
// Written by Guadalupe and Franny and Nikitah
// Made for ECE 5760 Final Project at Cornell University
// 
// compile with
// 		g++ -o gr main.cpp -pthread


#include "VGAConsts.h"
#include "VGAHelperFunctions.h"
#include "sim.h"

#include <stdio.h>
#include <fcntl.h>
#include <pthread.h>

#define white (0xffff)
#define black (0x0000)

void *readMouseThread(void *arg) {
    int fd2, bytes_mouse;
    unsigned char data[3];
    const char *pDevice = "/dev/input/mice";

    // Open Mouse
    fd2 = open(pDevice, O_RDWR);
    if(fd2 == -1)
    {
        printf("ERROR Opening %s\n", pDevice);
        //return -1;
    }
	
	int flags = fcntl(fd2, F_GETFL, 0);
	fcntl(fd2, F_SETFL, flags | O_NONBLOCK); 
	
    signed char x, y;
	int x_coord,y_coord;
	int left_click =0;
    int right_click =0;
	//int source [][];
	int incr_so = 0;
	//int sink [][];
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
        	
			x_coord = x_coord + (int)x;
			y_coord = y_coord - (int)y;

			if (x_coord < 0) x_coord = 0; 
			else if (x_coord > 640) x_coord = 640;
			if (y_coord < 0) y_coord = 0;
			else if (y_coord > 480) y_coord = 640;

			//printf("%d, %d \n",x_coord,y_coord);
			//draw cursor
			VGA_Hline(0,y_coord,640,white);
			VGA_Vline(x_coord,0,480,white);

			//mark as heat source or sinnk
			// if (left_click == 1) 
			// 	int x;
			// 	printf("Source (1) or sink (2)?");
   			// 	scanf("%d", &x);

				//store into a matrix 
				// if (x == 1) {
				// 	source [incr_so][1] = x_coord;
				// 	source [incr_so][2] = y_coord};
				// 	incr_so += 1;
				// 	printf('Added as a source');
				// } else if (x == 2) {
				//  	sink [incr_si][1] = x_coord;
				// 	sink [incr_si][2] = y_coord};
				// 	incr_si += 1;
				// 	printf('Added as a sink');
				// }
        } 
		usleep(17000);
    }
}

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

			usleep(17000);
		}

		// free memory when program ends
		freeResources();
		return 0;

}

int main(void)
{
	if (setupConnection() == 1) return(1);	

	// clear the screen & text
	VGA_box (0, 0, 639, 479, 0x0000);
	VGA_text_clear();

	// set up grid & initial values
	grid_size = 100;
    allocateResources();
    intializeGrid();

	pthread_t thread1,thread2;
	pthread_create(&thread1, NULL, plotHeatThread, NULL);
    pthread_create(&thread2, NULL, readMouseThread, NULL);
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
	
}

