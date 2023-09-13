MIN_BET = 1
MAX_BET = 100
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

def get_bet():
    while True:
        amount = input(f"Enter the amount you'd like to bet per lines (valid number for bet is ${MIN_BET}-${MAX_BET}):")
        if amount.isdigit():
            amount = int(amount)
            if MIN_BET <= amount <= MAX_BET:
               break
            else:
               print(f"Please enter the valid amount. Valid number for bet is ${MIN_BET}-${MAX_BET}")
        else:
             print(f"Please enter the valid amount. Valid number for bet is ${MIN_BET}-${MAX_BET}")
    return amount      
            

def main():
    balance = deposit()
    lines = get_lines()
    while True:    
        bet = get_bet()
        total = lines * bet
        if total > balance:
            print(f"You don't have enough amount to bet. You current balance is ${balance}")
        else:
            break    
    print("Balance is " + str(balance))
    print("Line is " + str(lines))
    print(f"You're betting on ${bet} for lines {lines}. Total bet is = {total}")
main()      