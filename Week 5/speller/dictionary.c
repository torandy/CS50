// Implements a dictionary's functionality

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>

#include "dictionary.h"

// Represents a node in a hash table
typedef struct node
{
    char word[LENGTH + 1];
    struct node *next;
} node;

// TODO: Choose number of buckets in hash table
const unsigned int N = 729;
unsigned int wordCount = 0;

// Hash table
node *table[N];

// Returns true if word is in dictionary, else false
bool check(const char *word)
{
    // TODO
    // Hash word to obtain hash value
    unsigned int index = hash(word);

    // Access linked list at that index in the hash table, create temp node called cursor
    node *cursor = table[index];

    // Traverse linked list, looking for the word (strcasecmp)
    while (cursor != NULL)
    {
        // Strcasecmp applies case-insensitivity
        if (strcasecmp(cursor->word, word) == 0)
        {
            return true;
        }
        // Advance to the next node if not found
        cursor = cursor->next;
    }

    return false;
}

// Hashes word to a number
unsigned int hash(const char *word)
{
    // TODO: Improve this hash function
    // Input: word, with alphabetical characters and (possibly) apostrophes
    // Will sum first 2 characters including apostrophes (27 * 27), apostrophe will be 0
    unsigned int sum = 0;

    for (int i = 0; i < 2; i++)
    {
        if (word[i] == '\0')
        {
            break;
        }
        else if (isalpha(toupper(word[i])))
        {
            sum += toupper(word[i]) - 'A' + 1;
        }
        else if (toupper(word[i]) == '\'')
        {
            sum += toupper(word[i]) - '\'';
        }
    }

    // Output: numerical index between 0 and N-1, inclusive
    return sum % N;
}

// Loads dictionary into memory, returning true if successful, else false
bool load(const char *dictionary)
{
    // TODO
    // Open dictionary file
    FILE *dFile = fopen(dictionary, "r");
    if (dFile == NULL)
    {
        return false;
    }

    // Read strings from file one at a time
    char dWord[LENGTH + 1];
    int hashIndex;
    while (fscanf(dFile, "%s", dWord) != EOF)
    {
        // Create a new node for each word
        node *n = malloc(sizeof(node));
        if (n == NULL)
        {
            return false;
        }
        strcpy(n->word, dWord);

        // Hash word to obtain a hash value
        hashIndex = hash(n->word);
        wordCount++;

        // Insert node into hash table at that location
        n->next = table[hashIndex];
        table[hashIndex] = n;
    }
    fclose(dFile);
    return true;
}

// Returns number of words in dictionary if loaded, else 0 if not yet loaded
unsigned int size(void)
{
    // TODO
    if (wordCount > 0)
    {
        return wordCount;
    }
    return 0;
}

// Unloads dictionary from memory, returning true if successful, else false
bool unload(void)
{
    // TODO
    // Iterate over each linked list to free
    node *cursor, *tmp = NULL;

    // Iterate through table array
    for (int i = 0; i < N; i++)
    {
        // Iterate over each linked list
        cursor = table[i], tmp = table[i];
        while (cursor != NULL)
        {
            cursor = cursor->next;
            free(tmp);
            tmp = cursor;
        }

        // Return true once the whole table array has been freed
        if (cursor == NULL && i == N - 1)
        {
            return true;
        }
    }
    return false;
}
