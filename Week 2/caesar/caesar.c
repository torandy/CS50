// Input the key and this program encrypts the message using Caesar’s cipher
#include <cs50.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

bool only_digits(string cliArgument);
char rotate(char c, int n);

int main(int argc, string argv[])
{
    if ((argc == 1) || (argc > 2))
    {
        printf("Usage: ./caesar key\n");
        // return 1 represents an error (#1 error in this case)
        return 1;
    }

    // call function to return if it is digits
    bool isDigit = only_digits(argv[1]);

    if (isDigit == false)
    {
        printf("Usage: ./caesar key\n");
        // return 1 represents an error (#1 error in this case)
        return 1;
    }
    else
    {
        // convert string input to an integer
        int key = atoi(argv[1]);
        string getInput = get_string("plaintext:  ");

        // create a new string to store the updated ciphered text
        string cipherText = getInput;

        // interate through and replace each character with the rotated value
        for (int i = 0, inputLength = strlen(getInput); i < inputLength; i++)
        {
            cipherText[i] = (char)rotate(getInput[i], key);
        }
        printf("ciphertext: %s\n", cipherText);

        // return 0 represents everything worked
        return 0;
    }
}

bool only_digits(string cliArgument)
{
    // use counter to keep track if digit check
    int digitCount = 0;
    bool digit = true;

    // iterate through each character to determine if it is a number
    for (int i = 0, argumentLength = strlen(cliArgument); i < argumentLength; i++)
    {
        // if not a digit, add one to the counter
        if (isdigit(cliArgument[i]) == 0)
        {
            digitCount++;
        }
    }
    // if counter has at least 1 more more then the argument contains non-digits
    if (digitCount > 0)
    {
        digit = false;
    }
    return digit;
}

char rotate(char c, int n)
{
    // store new character
    char newChar = c;

    if (isalpha(c))
    {
        if (isupper(c))
        {
            newChar = (((c - 65) + n) % 26) + 65;
        }
        else if (islower(c))
        {
            newChar = (((c - 97) + n) % 26) + 97;
        }
    }
    return newChar;
}
