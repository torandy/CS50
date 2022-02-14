#include <cs50.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

int count_letters(string text);
int count_words(string text);
int count_sentences(string text);

int main(void)
{

    // get intput Text
    string inputText = get_string("Text: ");

    // print number of Letters
    int numberOfLetters = count_letters(inputText);

    // print number of Words
    int numberOfWords = count_words(inputText);

    // print number of Sentences
    int numberOfSentences = count_sentences(inputText);

    // Coleman-Liau Index: index = 0.0588 * L - 0.296 * S - 15.8
    // L = avg letters per 100 words
    float L = (float)numberOfLetters / (float)numberOfWords * 100;

    // S = avg sentences per 100 words
    float S = (float)numberOfSentences / (float)numberOfWords * 100;

    // Calculate index and round
    float index = 0.0588 * L - 0.296 * S - 15.8;
    int indexRounded = (int)round(index);

    // Print statements based on index value
    if (indexRounded < 1)
    {
        printf("Before Grade 1\n");
    }
    else if (indexRounded >= 16)
    {
        printf("Grade 16+\n");
    }
    else
    {
        printf("Grade %i\n", indexRounded);
    }
}

int count_letters(string text)
{
    // Letter count
    int letterCount = 0;

    // Check if character is alphabetical, if so add 1 to letterCount
    for (int i = 0, textLength = strlen(text); i < textLength; i++)
    {
        if (isalpha(text[i]))
        {
            letterCount++;
        }
    }
    return letterCount;
}

int count_words(string text)
{
    // Word count, since the last word won't end with a space, need to account for last word, thus start count at 1 instead of 0
    int wordCount = 1;

    // Check if character is space, if so, add 1 to the word count
    for (int i = 0, textLength = strlen(text); i < textLength; i++)
    {
        if ((text[i]) == ' ')
        {
            wordCount++;
        }
    }
    return wordCount;
}

int count_sentences(string text)
{
    // Word count, since the last word won't end with a space, need to account for last word, thus start count at 1 instead of 0
    int sentencesCount = 0;

    // Check if character is space, if so, add 1 to the word count
    for (int i = 0, textLength = strlen(text); i < textLength; i++)
    {
        if (((text[i]) == '.') || ((text[i]) == '!') || ((text[i]) == '?'))
        {
            sentencesCount++;
        }
    }
    return sentencesCount;
}