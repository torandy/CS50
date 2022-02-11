#include <cs50.h>
#include <stdio.h>

int main(void)
{
    // Ask for the Height
    int height;
    do
    {
        height = get_int("Height: ");
    }
    while (height < 1 || height > 8);

    // Each row
    for (int i = 0; i < height; i++)
    {

        // Each column print spaces
        for (int k = (height - i); k > 1; k--)
        {
            printf(" ");
        }
        // Each column print #
        for (int j = 0; j <= i; j++)
        {
            printf("#");
        }
        // Move to next line
        printf("\n");
    }
}