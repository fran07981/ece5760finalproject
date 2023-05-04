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
	// pthread_t thread1;
	pthread_t thread2, thread3, thread4;

	// pthread_create(&thread1, NULL, plotHeatThread, NULL);
    pthread_create(&thread2, NULL, readMouseThread, NULL);
    pthread_create(&thread3, NULL, readKeyboardThread, NULL);
	// pthread_create(&thread4, NULL, sendDataThread, NULL);

    // join threads and free resources when done
    // pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    pthread_join(thread3, NULL);
	// pthread_join(thread4, NULL);

	freeResources();    // free memory when program ends
    return 0;
}

