import random
user_wins = 0
computer_wins = 0
options = ["rock", "paper", "scissors"]

while True:
  user_input = input("Enter Rock/Paper/Scissors :").lower()
  print(f"You chose {user_input}")
  if user_input not in options:
      print("You choose wrong choice and program will exit here.")
      print(f"You won {user_wins} times") 
      print(f"Computer won {computer_wins}")
      print("Quit")
      break
  random_number = random.randint(0,2)
  # rock = 0 , paper = 1, scissors = 2
  computer_input = options[random_number]
  print(f"Computer chose {computer_input}")
  if user_input == "rock" and computer_input == "scissors":
      print("You won")
      user_wins +=1
      continue
  if user_input == "paper" and computer_input == "rock":
      print("You won")
      user_wins +=1
      continue
  if user_input == "scissors" and computer_input == "paper":
      print("You won")
      user_wins +=1
  else:
      print("Computer won")   
      computer_wins +=1 

                 
 