#include "helpers.h"
#include <math.h>
#include "stdio.h" // Temporary

// Convert image to grayscale
void grayscale(int height, int width, RGBTRIPLE image[height][width])
{
    // Loop for each row
    for (int i = 0; i < height; i++)
    {
        // Loop columns within each row
        for (int j = 0; j < width; j++)
        {
            // Calc average of 3 RGB and update the average to each pixel
            int average = round((image[i][j].rgbtBlue + image[i][j].rgbtGreen + image[i][j].rgbtRed) / 3.0);
            image[i][j].rgbtBlue = image[i][j].rgbtGreen = image[i][j].rgbtRed = average;
        }
    }
    return;
}

// Convert image to sepia
void sepia(int height, int width, RGBTRIPLE image[height][width])
{
    // Loop for each row
    for (int i = 0; i < height; i++)
    {
        // Loop columns within each row
        for (int j = 0; j < width; j++)
        {
            // Calculate sepia value by using formula
            int sepiaBlue = round(.272 * image[i][j].rgbtRed + .534 * image[i][j].rgbtGreen + .131 * image[i][j].rgbtBlue);
            int sepiaGreen = round(.349 * image[i][j].rgbtRed + .686 * image[i][j].rgbtGreen + .168 * image[i][j].rgbtBlue);
            int sepiaRed = round(.393 * image[i][j].rgbtRed + .769 * image[i][j].rgbtGreen + .189 * image[i][j].rgbtBlue);

            // Determine limits and assign new sepia values
            image[i][j].rgbtBlue = (sepiaBlue > 255 ? 255 : sepiaBlue);
            image[i][j].rgbtGreen = (sepiaGreen > 255 ? 255 : sepiaGreen);
            image[i][j].rgbtRed = (sepiaRed > 255 ? 255 : sepiaRed);
        }
    }
    return;
}

// Reflect image horizontally
void reflect(int height, int width, RGBTRIPLE image[height][width])
{
    // Loop for each row
    for (int i = 0; i < height; i++)
    {
        // Loop columns within each row, only need to loop halfway since each step is flipping both sides
        for (int j = 0; j < width / 2; j++)
        {
            // Create a temp place holder for the flip
            RGBTRIPLE temp = image[i][j];
            // If width is 5 columns, array is actually at index 4 thus add 1 (j+1)
            image[i][j] = image[i][width - (j + 1)];
            image[i][width - (j + 1)] = temp;
        }
    }
    return;
}

// Blur image
void blur(int height, int width, RGBTRIPLE image[height][width])
{
    // Create a temp image
    RGBTRIPLE temp[height][width];

    // Loop for each individual pixel
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            // 9x9 box algorithm
            // Define variables outside 9x9 loop to keep track of RGB & active pixels
            int sumRed = 0, sumGreen = 0, sumBlue = 0;
            float counter = 0.00;
            // Create 9x9 box to loop over
            for (int x = -1; x < 2; x++)
            {
                for (int y = -1; y < 2; y++)
                {
                    // Check if valid pixel (within ranges (0 to height-1) & (0 to width-1))
                    int rowX = i + x;
                    int columnY = j + y;
                    if (!(rowX < 0 || rowX > (height - 1) || columnY < 0 || columnY > (width - 1)))
                    {
                        // Valid pixel logic
                        sumRed += image[rowX][columnY].rgbtRed;
                        sumGreen += image[rowX][columnY].rgbtGreen;
                        sumBlue += image[rowX][columnY].rgbtBlue;
                        counter++;
                    }
                }
            }
            temp[i][j].rgbtRed = round(sumRed / counter);
            temp[i][j].rgbtGreen = round(sumGreen / counter);
            temp[i][j].rgbtBlue = round(sumBlue / counter);
        }
    }
    // Write temp image to the new image
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image[i][j].rgbtRed = temp[i][j].rgbtRed;
            image[i][j].rgbtGreen = temp[i][j].rgbtGreen;
            image[i][j].rgbtBlue = temp[i][j].rgbtBlue;
        }
    }
    return;
}
