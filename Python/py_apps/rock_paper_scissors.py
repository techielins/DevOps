import random
user_wins = 0
computer_wins = 0
options = ["rock", "paper", "scissors"]

while True: 
    
  user_input = input("Enter Rock/Paper/Scissors or Q to quit:").lower()

  if user_input == "q":
     break
       
  if user_input not in options:
     print("Please enter valid input.") 
     continue
  
  random_number = random.randint(0,2)
  # rock = 0 , paper = 1, scissors = 2
  computer_input = options[random_number]
  print(f"Computer chose {computer_input}")
  
  if user_input == "rock" and computer_input == "scissors":
      print("You won!")
      user_wins +=1
 
  elif user_input == "paper" and computer_input == "rock":
      print("You won!")
      user_wins +=1

  elif user_input == "scissors" and computer_input == "paper":
      print("You won!")
      user_wins +=1
      
  else:
      print("Computer won!")   
      computer_wins +=1 

print("You have decided to quit.")
print("Here is the result") 
print(f"You won {user_wins} times") 
print(f"Computer won {computer_wins} times") 
print("Thanks for playing. Good Bye!")                  
 