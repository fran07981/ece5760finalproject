///////////////////////////////////////////////////////////////////////
// Mouse test from 
// http://stackoverflow.com/questions/11451618/how-do-you-read-the-mouse-button-state-from-dev-input-mice
//
// Native ARM GCC Compile: gcc mouse_test.c -o mouse
//
///////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char** argv)
{
    int fd2, bytes_mouse;
    unsigned char data[3];

    const char *pDevice = "/dev/input/mice";

    // Open Mouse
    fd2 = open(pDevice, O_RDWR);
    if(fd2 == -1)
    {
        printf("ERROR Opening %s\n", pDevice);
        return -1;
    }

    int left, middle, right,idk;
    signed char x, y;
    while(1)
    {
        // Read Mouse     

        //needed for nonblocking read()
        int flags = fcntl(fd2, F_GETFL, 0);
        fcntl(fd2, F_SETFL, flags | O_NONBLOCK); 

        bytes_mouse = read(fd2, data, sizeof(data));

        if(bytes_mouse > 0)
        {
            left = data[0] & 0x1;
            right = data[0] & 0x2;
            middle = data[0] & 0x4;

            x = data[1];
            y = data[2];
            printf("x=%d, y=%d, left=%d, middle=%d, right=%d\n", x, y, left, middle, right);
        }   
    }
    return 0; 
}
	