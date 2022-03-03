// This program recovers JPEG images from an input file saves them as separate JPG files

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#define BLOCK_SIZE 512

int main(int argc, char *argv[])
{
    // Validate proper command
    if (argc != 2)
    {
        printf("Usage: ./recover filename\n");
        return 1;
    }

    // Open memory card
    FILE *file = fopen(argv[1], "r");
    if (file == NULL)
    {
        printf("Opening file failed\n");
        return 1;
    }

    // Create counters
    typedef uint8_t BYTE;
    BYTE buffer[BLOCK_SIZE];
    int fileCounter = 0;
    char filename[8];
    FILE *imgPointer;

    // Repeat until end of card: This actually reads as well (no need for a 2nd fread)
    // Loop through each block looking for specific JPEG signature
    while (fread(buffer, sizeof(BYTE), BLOCK_SIZE, file) == BLOCK_SIZE)
    {
        // If start of new JPEG
        if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff && (buffer[3] & 0xf0) == 0xe0)
        {
            // If first JPEG
            if (fileCounter == 0)
            {
                sprintf(filename, "%03i.jpg", fileCounter);
                imgPointer = fopen(filename, "w");
                if (imgPointer == NULL)
                {
                    printf("Opening file counter 0 failed\n");
                    return 1;
                }
                fwrite(buffer, sizeof(BYTE), BLOCK_SIZE, imgPointer);
            }
            // Else if it's not the very first JPEG file
            else
            {
                fclose(imgPointer);
                sprintf(filename, "%03i.jpg", fileCounter);
                imgPointer = fopen(filename, "w");
                if (imgPointer == NULL)
                {
                    printf("Opening file counter %i failed\n", fileCounter);
                    return 1;
                }
                fwrite(buffer, sizeof(BYTE), BLOCK_SIZE, imgPointer);
            }
            fileCounter++;
        }
        // Else if already found JPEG, keep writing
        else if (fileCounter > 0)
        {
            fwrite(buffer, sizeof(BYTE), BLOCK_SIZE, imgPointer);
        }
    }
    fclose(file);
}