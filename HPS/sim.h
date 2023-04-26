#pragma once

// define constants
#define DELTA_T 0.1
#define ALPHA 0.8

int grid_size = 0;
float **currGrid;
float **grid0 = NULL;
float **grid1 = NULL;
float t = 0;

int window_width = 600;
int window_height = 600;

void intializeGrid()
{
    // add some heat to the the center
    currGrid[grid_size / 2][grid_size / 2] = 100.0f;
}

void setBoundaries()
{
    // sources & zero value areas (sinks?)
    currGrid[grid_size / 2][grid_size / 2] = 8.0f;
    currGrid[grid_size / 4][grid_size / 2] = 4.0;
    currGrid[grid_size / 4][grid_size / 3] = 8.0;
    currGrid[grid_size / 4][grid_size / 4] = -2.0f;
}

void allocateResources()
{
    if (grid0 != NULL && grid1 != NULL || grid_size == 0)
        return;

    // define two grids (rows)
    grid0 = (float **) malloc(grid_size * sizeof(float *));
    grid1 = (float **) malloc(grid_size * sizeof(float *));

    // 2D array, so each row needs to be allocated (cols)
    for (int i = 0; i < grid_size; i++) {
        grid0[i] = (float *) calloc(grid_size, sizeof(float));
        grid1[i] = (float *) calloc(grid_size, sizeof(float));
    }
    currGrid = grid0;
}

void freeResources()
{
    // free the cols
    for (int i = 0; i < grid_size; i++) {
        free(grid0[i]);
        free(grid1[i]);
    }

    // freee the rows
    free(grid0);
    free(grid1);
}

void simulate()
{
    setBoundaries();
    // simulate the heat equation
    for (int i = 1; i < grid_size - 1; i++) {
        for (int j = 1; j < grid_size - 1; j++) {
            grid1[i][j] = currGrid[i][j] + ALPHA * DELTA_T * 
                (currGrid[i - 1][j] + currGrid[i + 1][j] +
                 currGrid[i][j - 1] + currGrid[i][j + 1] 
                                - 4 * currGrid[i][j]);
        }
    }
    currGrid = grid1;
    grid1    = grid0;
    grid0    = currGrid;
}