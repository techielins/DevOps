MAX_LINES = 3
def deposit():
    while True:
        amount = input("Enter the amount you wish to deposit (in $): ")
        if amount.isdigit():
            amount = int(amount)
            if amount > 0:
               print("The amount is an integer.")
               break
            else:
               print("Amount must be greater than 0.")
        else:
            print("Please enter the valid digit. It must be an interger.")
    return amount                

def get_lines():
    while True:
        lines = input("Enter numberf of lines. (It should be 1-" + str(MAX_LINES) + ")" )
        if lines.isdigit():
            lines = int(lines) 
            if 1 <= lines <=3:
                break
            else:
                print("Provide the valid number of lines.")
        else:
            print("Enter valid number for lines. (It should be 1-" + str(MAX_LINES) + ")" )        
    return lines
def main():
    balance = deposit()
    lines = get_lines()
    print("Balance is " + str(balance))
    print("Line is " + str(lines))
main()      