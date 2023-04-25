#define GL_SILENCE_DEPRECATION
#include <GLUT/glut.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define TIME_STEPS 1000
#define DELTA_T 0.01
#define ALPHA 0.8

int size;
double **grid;

void display() {
    glClear(GL_COLOR_BUFFER_BIT);

    float cell_size = 2.0 / size;

    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            float heat = grid[i][j] / 100.0;
            glColor3f(heat, 0, 0);
            glBegin(GL_QUADS);
            glVertex2f(-1.0 + cell_size * i, -1.0 + cell_size * j);
            glVertex2f(-1.0 + cell_size * (i + 1), -1.0 + cell_size * j);
            glVertex2f(-1.0 + cell_size * (i + 1), -1.0 + cell_size * (j + 1));
            glVertex2f(-1.0 + cell_size * i, -1.0 + cell_size * (j + 1));
            glEnd();
        }
    }

    glutSwapBuffers();
}

void init() {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);
}

int main(int argc, char **argv) {
    printf("Enter the size of the grid: ");
    scanf("%d", &size);

    grid = (double **) malloc(size * sizeof(double *));
    double **new_grid = (double **) malloc(size * sizeof(double *));
    for (int i = 0; i < size; i++) {
        grid[i] = (double *) calloc(size, sizeof(double));
        new_grid[i] = (double *) calloc(size, sizeof(double));
    }

    // Set the heat source in the center
    grid[size / 2][size / 2] = 500.0;

    // Simulate the heat equation
    for (int t = 0; t < TIME_STEPS; t++) {
        for (int i = 1; i < size - 1; i++) {
            for (int j = 1; j < size - 1; j++) {
                new_grid[i][j] = grid[i][j] + ALPHA * DELTA_T * (grid[i - 1][j] + grid[i + 1][j] + grid[i][j - 1] + grid[i][j + 1] - 4 * grid[i][j]);
            }
        }

        memcpy(grid, new_grid, size * sizeof(double *));
    }

    // Initialize GLUT
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
    glutInitWindowSize(600, 600);
    glutInitWindowPosition(100, 100);
    glutCreateWindow("Heat Distribution");

    init();

    glutDisplayFunc(display);
    glutMainLoop();

    for (int i = 0; i < size; i++) {
        free(grid[i]);
        free(new_grid[i]);
    }
    free(grid);
    free(new_grid);

    return 0;
}
