// Inputs for cents and calculates the least amount of each coin that should be returned
#include <cs50.h>
#include <stdio.h>
#include <math.h>

int get_cents(void);
int calculate_quarters(int cents);
int calculate_dimes(int cents);
int calculate_nickels(int cents);
int calculate_pennies(int cents);

int main(void)
{

    // Ask how many cents the customer is owed
    int cents = get_cents();

    // Calculate the number of quarters to give the customer
    int quarters = calculate_quarters(cents);
    cents = cents - quarters * 25;

    // Calculate the number of dimes to give the customer
    int dimes = calculate_dimes(cents);
    cents = cents - dimes * 10;

    // Calculate the number of nickels to give the customer
    int nickels = calculate_nickels(cents);
    cents = cents - nickels * 5;

    // Calculate the number of pennies to give the customer
    int pennies = calculate_pennies(cents);
    cents = cents - pennies * 1;

    // Sum coins
    int coins = quarters + dimes + nickels + pennies;

    // Print total number of coins to give the customer
    printf("%i\n", coins);
}

int get_cents(void)
{
    int cents;
    do
    {
        cents = get_int("Enter number of cents: ");
    }
    while (cents < 0);
    return cents;
}

int calculate_quarters(int cents)
{
    // round down to whole number gives us # of quarters
    int numberOfQuarters = (int)floor(cents / 25);
    return numberOfQuarters;
}

int calculate_dimes(int cents)
{
    // round down to whole number gives us # of dimes
    int numberOfDimes = (int)floor(cents / 10);
    return numberOfDimes;
}

int calculate_nickels(int cents)
{
    // round down to whole number gives us # of nickels
    int numberOfNickels = (int)floor(cents / 5);
    return numberOfNickels;
}

int calculate_pennies(int cents)
{
    // round down to whole number gives us # of pennies
    int numberOfPennies = (int)floor(cents / 1);
    return numberOfPennies;
}
