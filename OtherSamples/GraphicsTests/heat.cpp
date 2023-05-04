#include "colorPallet.h"

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

void intializeGrid()
{
    // add some heat to the the center
    currGrid[grid_size / 2][grid_size / 2] = 2.0f;
}

void setBoundaries()
{
    // sources & zero value areas (sinks?)
    currGrid[grid_size / 2][grid_size / 2] = 8.0f;
    currGrid[grid_size / 4][grid_size / 2] = 4.0;
    currGrid[grid_size / 4][grid_size / 3] = 8.0;
    currGrid[grid_size / 4][grid_size / 4] = -2.0f;
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

void drawGrid()
{
    float cell_size = 2.0 / grid_size;

    for (int i = 0; i < grid_size; i++) {
        for (int j = 0; j < grid_size; j++) {
            float heat = currGrid[i][j];

            // Calculate the color index based on the temperature value
            int colorIndex = (int)(heat * (numColors - 1));
            colorIndex = fmax(0, fmin(numColors - 1, colorIndex));

            // Set the color to the corresponding value in the fire palette
            glColor3f(firePalette[colorIndex][0], firePalette[colorIndex][1], firePalette[colorIndex][2]);

            // glColor3f(heat, 0, 0);
            glBegin(GL_QUADS);
            glVertex2f(-1.0 + cell_size * i, -1.0 + cell_size * j);
            glVertex2f(-1.0 + cell_size * (i + 1), -1.0 + cell_size * j);
            glVertex2f(-1.0 + cell_size * (i + 1), -1.0 + cell_size * (j + 1));
            glVertex2f(-1.0 + cell_size * i, -1.0 + cell_size * (j + 1));
            glEnd();

            // plot grid
            // glColor3f(0.5, 0.5, 0.5);
            // glBegin(GL_LINE_LOOP);
            // glVertex2f(-1.0 + cell_size * i, -1.0 + cell_size * j);
            // glVertex2f(-1.0 + cell_size * (i + 1), -1.0 + cell_size * j);
            // glVertex2f(-1.0 + cell_size * (i + 1), -1.0 + cell_size * (j + 1));
            // glVertex2f(-1.0 + cell_size * i, -1.0 + cell_size * (j + 1));
            // glEnd();
        }
    }
}


void display()
{
    simulate();
    glClear(GL_COLOR_BUFFER_BIT);
    drawGrid();
    glutSwapBuffers();
    glutPostRedisplay();
}

void init() 
{
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);
}

int main(int argc, char **argv) {
    // get grid size parameter from user
    printf("Enter the size of the grid: ");
    scanf("%d", &grid_size);

    // set up grid & initial values
    allocateResources();
    intializeGrid();
    
    // start GLUT
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
    glutInitWindowSize(window_width, window_height);
    glutInitWindowPosition(100, 100);
    glutCreateWindow("Heat Distribution");

    init();

    glutDisplayFunc(display);
    glutMainLoop();

    // free memory when program ends
    freeResources();

    return 0;
}
