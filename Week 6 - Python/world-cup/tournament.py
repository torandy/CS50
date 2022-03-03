# Simulate a sports tournament

import csv
import sys
import random

# Number of simluations to run
N = 1000


def main():

    # Ensure correct usage
    if len(sys.argv) != 2:
        sys.exit("Usage: python tournament.py FILENAME")

    teams = []
    # TODO: Read teams into memory from file
    filename = sys.argv[1]
    # Open the file
    with open(filename, "r") as f:
        # Create a reader as a Dictionary
        reader = csv.DictReader(f)
        # Loop through each line of the reader
        for row in reader:
            # Convert each string rating value to integer
            row["rating"] = int(row["rating"])
            # Update teams list with the row
            teams.append(row)

    counts = {}
    # TODO: Simulate N tournaments and keep track of win counts
    # Loop through N tournaments
    for i in range(N):
        winningTeam = simulate_tournament(teams)
        if winningTeam in counts:
            # Increase existing value by 1
            counts[winningTeam] += 1
        else:
            # Add a new value pair
            counts[winningTeam] = 1

    # Print each team's chances of winning, according to simulation
    for team in sorted(counts, key=lambda team: counts[team], reverse=True):
        print(f"{team}: {counts[team] * 100 / N:.1f}% chance of winning")


def simulate_game(team1, team2):
    """Simulate a game. Return True if team1 wins, False otherwise."""
    rating1 = team1["rating"]
    rating2 = team2["rating"]
    probability = 1 / (1 + 10 ** ((rating2 - rating1) / 600))
    return random.random() < probability


def simulate_round(teams):
    """Simulate a round. Return a list of winning teams."""
    winners = []

    # Simulate games for all pairs of teams
    for i in range(0, len(teams), 2):
        if simulate_game(teams[i], teams[i + 1]):
            winners.append(teams[i])
        else:
            winners.append(teams[i + 1])
    return winners


def simulate_tournament(teams):
    """Simulate a tournament. Return name of winning team."""
    # TODO
    # As long we has have 2 teams
    while len(teams) > 1:
        # Simulate the round and update team list
        teams = simulate_round(teams)
    # Return the final team name
    return teams[0]["team"]


if __name__ == "__main__":
    main()
