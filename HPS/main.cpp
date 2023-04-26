// ------------------------------------------------------------
// Main.cpp
//
// Plots the heat equation to a VGA screan through the FPGA
// 
// ------------------------------------------------------------
// Written by Guadalupe and Franny and Nikitah
// Made for ECE 5760 Final Project at Cornell University
// 
// compile with
// 		g++ -o gr main.cpp


#include "VGAConsts.h"
#include "VGAHelperFunctions.h"
#include "sim.h"

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

