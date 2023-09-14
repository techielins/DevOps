import random
tries = 0

while True:
    
    type_number = input("Enter the number: ")

    if type_number.isdigit():
        type_number = int(type_number)
        random_number = random.randint(0,type_number)
        #print(f"Random number is : {random_number}")   for logic checks/debug
        break
    else:
        print("Please enter the valid number! ")
    
while True:
    tries +=1    
    guess_number = input("Make a guess: ")
    if guess_number.isdigit():
        guess_number = int(guess_number)
        if random_number == guess_number:
            print(f"You got it. The number is {random_number}")
            print(f"You got the correct answer in {tries} tries.")
            break
        else:
            print("You got it wrong.")
            if guess_number > random_number:
                print("Guessed number is greater than the answer.")
            else:
                print("Guessed number is less than the answer.")
            continue
            

    else:
        print("Please enter the valid number! ")

                   
    