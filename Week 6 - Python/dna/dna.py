# Program that identifies a person based on their DNA
import csv
import sys


def main():

    # Check for command-line usage
    if len(sys.argv) != 3:
        print("Usage: python dna.py data.csv sequence.txt")
        exit(1)

    # Read database file into a variable
    str_data_file = sys.argv[1]
    str_full_list = []
    with open(str_data_file, "r") as strfile:
        readerDict = csv.DictReader(strfile)
        str_full_list = list(readerDict)

    # Read DNA sequence file into a variable
    dna_list_file = sys.argv[2]
    dna_list = []
    with open(dna_list_file, "r") as dnafile:
        dna_list = dnafile.read()

    # Find longest match of each STR in DNA sequence
    # build a list of just the STR headers
    str_header_list = []
    with open(str_data_file, "r") as strfile:
        reader = csv.reader(strfile)
        str_header_list = list(reader)[0][1::]

    # For each STR, add into dna string longest match value
    dna_str = {}
    for i in range(len(str_header_list)):
        match_length = longest_match(dna_list, str_header_list[i])
        dna_str[str_header_list[i]] = match_length

    # Check database for matching profiles
    # For each person
    for i in range(len(str_full_list)):
        # For each found DNA value
        for j in range(len(dna_str)):
            person_sta_length = int(str_full_list[i][str_header_list[j]])
            dna_sta_length = dna_str[str_header_list[j]]
            # If not match break to next person
            if person_sta_length != dna_sta_length:
                break
            # If match found continue matching all STR values until all 3 match
            elif j == (len(dna_str)-1):
                print(str_full_list[i]["name"])
                return str_full_list[i]["name"]
    # Default is No match unless all matches found above
    print("No match.")
    return


def longest_match(sequence, subsequence):
    """Returns length of longest run of subsequence in sequence."""

    # Initialize variables
    longest_run = 0
    subsequence_length = len(subsequence)
    sequence_length = len(sequence)

    # Check each character in sequence for most consecutive runs of subsequence
    for i in range(sequence_length):

        # Initialize count of consecutive runs
        count = 0

        # Check for a subsequence match in a "substring" (a subset of characters) within sequence
        # If a match, move substring to next potential match in sequence
        # Continue moving substring and checking for matches until out of consecutive matches
        while True:

            # Adjust substring start and end
            start = i + count * subsequence_length
            end = start + subsequence_length

            # If there is a match in the substring
            if sequence[start:end] == subsequence:
                count += 1

            # If there is no match in the substring
            else:
                break

        # Update most consecutive matches found
        longest_run = max(longest_run, count)

    # After checking for runs at each character in seqeuence, return longest run found
    return longest_run


main()
