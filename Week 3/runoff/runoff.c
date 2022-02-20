#include <cs50.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

// Max voters and candidates
#define MAX_VOTERS 100
#define MAX_CANDIDATES 9

// preferences[i][j] is jth preference for voter i
int preferences[MAX_VOTERS][MAX_CANDIDATES];

// Candidates have name, vote count, eliminated status
typedef struct
{
    string name;
    int votes;
    bool eliminated;
} candidate;

// Array of candidates
candidate candidates[MAX_CANDIDATES];

// Numbers of voters and candidates
int voter_count;
int candidate_count;

// Function prototypes
bool vote(int voter, int rank, string name);
void tabulate(void);
bool print_winner(void);
int find_min(void);
bool is_tie(int min);
void eliminate(int min);

int main(int argc, string argv[])
{
    // Check for invalid usage
    if (argc < 2)
    {
        printf("Usage: runoff [candidate ...]\n");
        return 1;
    }

    // Populate array of candidates
    candidate_count = argc - 1;
    if (candidate_count > MAX_CANDIDATES)
    {
        printf("Maximum number of candidates is %i\n", MAX_CANDIDATES);
        return 2;
    }
    for (int i = 0; i < candidate_count; i++)
    {
        candidates[i].name = argv[i + 1];
        candidates[i].votes = 0;
        candidates[i].eliminated = false;
    }

    voter_count = get_int("Number of voters: ");
    if (voter_count > MAX_VOTERS)
    {
        printf("Maximum number of voters is %i\n", MAX_VOTERS);
        return 3;
    }

    // Keep querying for votes
    for (int i = 0; i < voter_count; i++)
    {

        // Query for each rank
        for (int j = 0; j < candidate_count; j++)
        {
            string name = get_string("Rank %i: ", j + 1);

            // Record vote, unless it's invalid
            if (!vote(i, j, name))
            {
                printf("Invalid vote.\n");
                return 4;
            }
        }

        printf("\n");
    }

    // Keep holding runoffs until winner exists
    while (true)
    {
        // Calculate votes given remaining candidates
        tabulate();

        // Check if election has been won
        bool won = print_winner();
        if (won)
        {
            break;
        }

        // Eliminate last-place candidates
        int min = find_min();
        bool tie = is_tie(min);

        // If tie, everyone wins
        if (tie)
        {
            for (int i = 0; i < candidate_count; i++)
            {
                if (!candidates[i].eliminated)
                {
                    printf("%s\n", candidates[i].name);
                }
            }
            break;
        }

        // Eliminate anyone with minimum number of votes
        eliminate(min);

        // Reset vote counts back to zero
        for (int i = 0; i < candidate_count; i++)
        {
            candidates[i].votes = 0;
        }
    }
    return 0;
}

// Record preference if vote is valid
bool vote(int voter, int rank, string name)
{
    // Search for name
    for (int i = 0; i < candidate_count; i++)
    {
        if (strcmp(name, candidates[i].name) == 0)
        {
            // if name match found, update preferences table with the index # representing the name
            preferences[voter][rank] = i;
            return true;
        }
    }
    // if name not found, return false
    return false;
}

// Tabulate votes for non-eliminated candidates
void tabulate(void)
{
    // loop through preferences table
    // for each voter
    for (int i = 0; i < voter_count; i++)
    {
        // for each candidate
        for (int j = 0; j < candidate_count; j++)
        {
            // if candidate has not been eliminated, add 1 to the candidate
            if (!candidates[preferences[i][j]].eliminated)
            {
                candidates[preferences[i][j]].votes++;
                // exit out of for loop
                break;
            }
            // else it will iterate through to next choice to add to preferences
        }
    }
    return;
}

// Print the winner of the election, if there is one
bool print_winner(void)
{
    // Find the majority # based on # of the votes
    int majority;
    if (voter_count % 2 == 0)
    {
        majority = (int)(voter_count / 2) + 1;
    }
    else
    {
        // Must cast one of the divisor as a double (2.0) for the ceil function to work properly
        majority = (int)ceil(voter_count / 2.0);
    }

    // Loop through each candidate, if any candidate has more than half the vote, print name
    for (int i = 0; i < candidate_count; i++)
    {
        if (candidates[i].votes >= majority)
        {
            printf("%s\n", candidates[i].name);
            return true;
        }
    }
    // Else if nobody has majority votes yet
    return false;
}

// Return the minimum number of votes any remaining candidate has
int find_min(void)
{
    // Set the maximum votes possible to number of voters
    int minVoteCount = voter_count;

    // Loop through each uneliminated candidate to find and set the lowest votes
    for (int i = 0; i < candidate_count; i++)
    {
        if (candidates[i].votes < minVoteCount && candidates[i].eliminated == false)
        {
            minVoteCount = candidates[i].votes;
        }
    }
    return minVoteCount;
}

// Return true if the election is tied between all candidates, false otherwise
bool is_tie(int min)
{
    // Set counter for tie and total active candidates
    int tieCounter = 0;
    int activeCandidates = 0;

    // Loop through each candidate, if found, add 1 to record
    for (int i = 0; i < candidate_count; i++)
    {
        // Add a tie and active counter if it is minimum counter and not eliminated
        if (candidates[i].votes == min && candidates[i].eliminated == false)
        {
            tieCounter++;
            activeCandidates++;
        }
        // Add an active counter if not lowest candidate
        else if (candidates[i].eliminated == false)
        {
            activeCandidates++;
        }
    }

    // If more than 1 tie record exist and the active candidates match (no other higher votes), we know it's a tie
    if (tieCounter > 1 && tieCounter == activeCandidates)
    {
        return true;
    }
    return false;
}

// Eliminate the candidate (or candidates) in last place
void eliminate(int min)
{
    // Loop through each non-eliminated candidate and eliminate based on min votes
    for (int i = 0; i < candidate_count; i++)
    {
        if (candidates[i].votes == min && candidates[i].eliminated == false)
        {
            candidates[i].eliminated = true;
        }
    }
    return;
}