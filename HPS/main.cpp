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
#include <string.h>

#include <stdio.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <float.h>

#define white (0xffff)
#define black (0x0000)


//HPS TO FPGA
volatile unsigned int   * pio_so_x_coord = NULL; 		  
volatile unsigned int   * pio_so_y_coord = NULL; 		
volatile unsigned int   * pio_si_x_coord = NULL; 		  
volatile unsigned int   * pio_si_y_coord = NULL; 		
volatile unsigned int   * pio_reset = NULL; 		
volatile unsigned int   * pio_dt = NULL; 		

#define RESET_OFFSET      0X10
#define SO_X_OFFSET       0X20
#define SO_Y_OFFSET       0X30
#define SI_X_OFFSET       0X40
#define SI_Y_OFFSET       0X50
#define DT_OFFSET         0X60


int pause = 0;
float delay = 10000;	// default delay value

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
			if (left_click == 1) {
				    int ss;
					int change = 0;
					// wait until user types new max iterations value
					printf("Source or Sink? (1 or 2) \n");
					while (change == 0) { if (scanf("%d", &ss) == 1 ) change = 1; }
					
                    if (pause == 0) { //simulation is running  
                        if (incr_si == 0 && incr_so == 0) {  //check if simulation was previously paused and values were added to matrix
                            if (ss == 1) { 
                                *(pio_so_x_coord) = x_coord; //add source as simulation is running
                                *(pio_so_y_coord) = y_coord; 
                            } else if (ss == 2) {
                                *(pio_si_x_coord) = x_coord; 
                                *(pio_si_y_coord) = y_coord; 
                            } else {
                                printf("Invalid Input");
                            }
                        } else {//a pause and unpause requires passing data to FPGA for updates 
                            //assumption: enough delay time for FPGA  process between points 
                            if (incr_so > 0)  {
                                for (int i = 0; i < incr_so ; i +=1) {
                                    *(pio_so_x_coord) = source[i][0]; 
                                    *(pio_so_y_coord) = source[i][1];
                                    *(pio_reset) = 0;
                                    *(pio_reset) = 1;
                                    *(pio_reset) = 0;
                                    source[i][0] = 0.0; //clear those values in the source matrix
                                    source[i][1] = 0.0;
                                }
                                incr_so = 0;
                                
                            }

                            if (incr_si > 0)  {
                                for (int i = 0; i < incr_si ; i +=1) {
                                    *(pio_si_x_coord) = sink[i][0]; 
                                    *(pio_si_y_coord) = sink[i][1];
                                    *(pio_reset) = 0;
                                    *(pio_reset) = 1;
                                    *(pio_reset) = 0;
                                    sink[i][0] = 0.0; //clear those values in the source matrix
                                    sink[i][1] = 0.0;                                    
                                }
                                incr_si = 0;
                            }  
                        }   

                    } else if (pause == 1) { //simulation is paused to add sources/sinks
                            //store all values in a matrix --> need to figure out how to send to FPGA
                        	 if (ss == 1) { 
                                source [incr_so][1] =  x_coord;  
                                source [incr_so][2] =  y_coord;
	                            incr_so = incr_so + 1;
                             } 
                             else if (ss == 0 ) {
                                sink [incr_si][1] =  x_coord;
                                sink [incr_si][2] =  y_coord;
	                            incr_si = incr_si + 1;
                            } else {
                            printf("Invalid Input");
                            }

                        }

            } // left click

        } // mouse
		usleep(17000);
    } //while
} //funciton


void *readKeyboardThread(void *arg) {
    fcntl(STDIN_FILENO, F_SETFL, (int)fcntl(STDIN_FILENO, F_GETFL, 0) | O_NONBLOCK);
	fd_set read_message;

    // buffer for the typed text
    char buf[1024];
    int buf_index = 0;

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
                
				 // Commands for "stop, go, speed up, slow down" 
			    if      (strcmp(buf, "stop") == 0) pause = 1;
                else if (strcmp(buf, "go"  ) == 0) pause = 0;
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

int main(void)
{
    pio_so_x_coord 	= (unsigned int *)(h2p_lw_virtual_base + SO_X_OFFSET     );
    pio_so_y_coord 	= (unsigned int *)(h2p_lw_virtual_base + SO_Y_OFFSET     );
    pio_si_x_coord 	= (unsigned int *)(h2p_lw_virtual_base + SI_X_OFFSET     );
    pio_so_y_coord 	= (unsigned int *)(h2p_lw_virtual_base + SI_Y_OFFSET     );
    pio_reset       = (unsigned int *)(h2p_lw_virtual_base + RESET_OFFSET    );
    pio_dt          = (unsigned int *)(h2p_lw_virtual_base + DT_OFFSET       );

	if (setupConnection() == 1) return(1);	

	// clear the screen & text
	VGA_box (0, 0, 639, 479, 0x0000);
	VGA_text_clear();

	// set up grid & initial values
	grid_size = 100;
    allocateResources();
    intializeGrid();

	pthread_t thread1,thread2,thread3;
	pthread_create(&thread1, NULL, plotHeatThread, NULL);
    pthread_create(&thread2, NULL, readMouseThread, NULL);
    pthread_create(&thread3, NULL, readKeyboardThread, NULL);
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    pthread_join(thread3, NULL);
	
}

