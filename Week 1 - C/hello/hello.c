#include <cs50.h>
#include <stdio.h>

// Input name and returns a hello with name

int main(void)
{
    string name = get_string("What is your name?: ");
    printf("hello, %s\n", name);
}
