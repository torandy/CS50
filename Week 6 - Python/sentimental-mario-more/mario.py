# Program that prints out a half-pyramid of a specified height

def main():
    # Loop for input if outside range 1-8
    while True:
        try:
            get_int = int(input("Height: "))
            if get_int >= 1 and get_int <= 8:
                break
            else:
                print("Enter a number between 1-8")
        except ValueError:
            print("Enter a number between 1-8")

    # Loop through height input, for each line, print space and pound symbols
    for row in range(get_int):
        spaceCount = get_int - (row+1)
        poundCount = row+1
        printSpace(spaceCount)
        printPound(poundCount)
        print("  ", end="")
        printPound(poundCount)
        print()

# Function to print spaces


def printSpace(spaces):
    for i in range(spaces):
        print(" ", end="")
    return

# Function to print pound symbol


def printPound(pound):
    for i in range(pound):
        print("#", end="")
    return


if __name__ == "__main__":
    main()
