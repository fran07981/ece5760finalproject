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
// 		g++ -o gr main.cpp -pthread -pthread -lm

// gcc -pthread DualSRAMTest.c -o fp1 -lm


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

#include <pthread.h>
#include <string.h>
#include <float.h>

#include "address_map_arm_brl4.h"
#include "interface.h"
#include "sim.h"
#include "VGAHelperFunctions.h"


// measure time
struct timeval t1, t2;
double elapsedTime;
struct timespec delay_time ;


int main(void)
{
	delay_time.tv_nsec = 10;
	delay_time.tv_sec  = 0;

	if (setupConnection() == 1) return(1);
	// clear the screen & text
	VGA_box (0, 0, 639, 479, 0x0000);
	VGA_text_clear();

	// set up grid & initial values
	grid_size = 100;
    allocateResources();
    intializeGrid();

    // launch all the threads
	pthread_t thread1,thread2,thread3;
	pthread_create(&thread1, NULL, plotHeatThread, NULL);
    pthread_create(&thread2, NULL, readMouseThread, NULL);
    pthread_create(&thread3, NULL, readKeyboardThread, NULL);

    // join threads and free resources when done
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    pthread_join(thread3, NULL);

	freeResources();    // free memory when program ends
    return 0;



	// while(count++ < 1000) 
	// {
	// 	int x1, y1, x2, y2, color ;
	// 	// sram buffer
	// 	// addr=0 start bit
	// 	// addr=1 x1, addr=2 y1
	// 	// addr=3 x2, addr=4 y2
	// 	// addr=5 color
	// 	// query for x1,y1,x2,y2, color(1-byte hex)
	// 	//scanf("%d %d %d %d %d", &x1, &y1, &x2, &y2, &color);
	// 	//printf("data entered\n\r");
	// 	x1 = rand() & 0x7f;
	// 	x2 = x1 + (rand() & 0x7f);
	// 	y1 = (rand() & 0xff) ;
	// 	y2 = y1 + (rand() & 0xff) ;
	// 	color = rand() & 0xff ;
	// 	// // start the timer
	// 	// gettimeofday(&t1, NULL);
	// 	// // set up parameters
	// 	// *(sram_ptr+1) = x1;
	// 	// *(sram_ptr+2) = y1;
	// 	// *(sram_ptr+3) = x2;
	// 	// *(sram_ptr+4) = y2;
	// 	// *(sram_ptr+5) = color;
	// 	// *(sram_ptr) = 1; // the "data-ready" flag
	
	// 	// // wait for FPGA to zero the "data_ready" flag
	// 	// while (*(sram_ptr)==1) ;
		
	// 	// time the FPGA
	// 	gettimeofday(&t2, NULL);
	// 	elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0;      // sec to us
	// 	elapsedTime += (t2.tv_usec - t1.tv_usec) ;   // us to 
	// 	//sprintf(num_string, "# = %d     ", total_count);
	// 	sprintf(time_string, "T=%8.0f uSec  ", elapsedTime);
	// 	//VGA_text (10, 3, num_string);
	// 	VGA_text (10, 4, time_string);
		
	// 	// start the timer
	// 	gettimeofday(&t1, NULL);
	// 	// note that this version of VGA_disk
	// 	// has THROTTLED pixel write disabled
	// 	VGA_box (x1+320, y1, x2+320, y2, color) ;
	// 	// time the FPGA
	// 	gettimeofday(&t2, NULL);
		
	// 	elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0;      // sec to us
	// 	elapsedTime += (t2.tv_usec - t1.tv_usec) ;   // us to 
	// 	//sprintf(num_string, "# = %d     ", total_count);
	// 	sprintf(time_string, "T=%8.0f uSec  ", elapsedTime);
	// 	//VGA_text (10, 3, num_string);
	// 	VGA_text (40, 4, time_string);
		
	// }
}

