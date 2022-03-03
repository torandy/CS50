# Program that determines whether a provided credit card number is valid according to Luhn’s algorithm.
import re

# Dictionary of credit card values
creditCards = {
    '4': "VISA\n",
    '34': "AMEX\n",
    '37': "AMEX\n",
    '51': "MASTERCARD\n",
    '52': "MASTERCARD\n",
    '53': "MASTERCARD\n",
    '54': "MASTERCARD\n",
    '55': "MASTERCARD\n"
}


def main():
    # Create regular expression to explicity check 13, 15, 16 digits
    regex = r"^(\d{13}|\d{15}|(\d{16}))$"
    creditCard = input("Number: ")
    match = re.search(regex, creditCard)
    if match:
        # pass through lahn calculator and return credit card type if passes
        # Convert creditCard to a list get first 2 digits of card
        firstTwo = creditCard[:2]
        creditCard = list(creditCard)
        if luhn(creditCard):
            if firstTwo[:1] == '4':
                print("VISA\n")
            elif firstTwo in creditCards:
                print(creditCards[firstTwo])
            else:
                print("INVALID\n")
        else:
            print("INVALID\n")
    else:
        print("INVALID\n")


# Returns True if legit number, otherwise false
def luhn(ccNumber):
    # Reverse cc number then take second last every other digit
    reverseCC = ccNumber[::-1]
    secondToLast = reverseCC[1::2]

    # Multiply each digit by 2 then split the double digits into a new list
    productDigits = []
    for i in range(len(secondToLast)):
        secondToLast[i] = int(secondToLast[i])*2
        if secondToLast[i] > 9:
            x = [int(a) for a in str(secondToLast[i])]
            productDigits.append(x[0])
            productDigits.append(x[1])
        else:
            productDigits.append(secondToLast[i])

    # add all the single product; digits together

    productDigitsTotal = 0
    for i in range(len(productDigits)):
        productDigitsTotal += productDigits[i]

    # Take last every other digit
    last = reverseCC[::2]

    # Add sum of last every other digit to the product digits total
    for i in range(len(last)):
        productDigitsTotal += int(last[i])

    # if ends in 0, it's a valid CC
    if productDigitsTotal % 10 == 0:
        return True
    else:
        return False


if __name__ == "__main__":
    main()
