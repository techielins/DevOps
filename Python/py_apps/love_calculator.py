#The love score between two people 🤣

#Take both people's names and check for the number of times the letters in the word TRUE occurs. Then check for the number of times the letters in the word LOVE occurs. Then combine these numbers to make a 2 digit number.

#For Love Scores less than 10 or greater than 90, the message should be:

#"Your score is **x**, you go together like coke and mentos."

#For Love Scores between 40 and 50, the message should be:

#"Your score is **y**, you are alright together."

#Otherwise, the message will just be their score. e.g.:

#"Your score is **z**."
# #Example Input 1
# name1 = "Kanye West"
# name2 = "Kim Kardashian"
# Example Output 1
# Your score is 42, you are alright together.
# Example Input 2
# name1 = "Brad Pitt"
# name2 = "Jennifer Aniston"
# Example Output 2
# Your score is 73.

# 🚨 Don't change the code below 👇
print("Welcome to the Love Calculator!")
name1 = input("What is your name? \n")
name2 = input("What is their name? \n")
# 🚨 Don't change the code above 👆

#Write your code below this line 👇

lower_case_name1 = name1.lower()
lower_case_name2 = name2.lower()
combined_name = lower_case_name1 + lower_case_name2

T = combined_name.count("t")
R = combined_name.count("r")
U = combined_name.count("u")
E = combined_name.count("e")

true_score = T+R+U+E

L = combined_name.count("l")
O = combined_name.count("o")
V = combined_name.count("v")
E = combined_name.count("e")

love_score = L+O+V+E

true_love_score = int(str(true_score) + str(love_score))

if true_love_score < 10 or true_love_score > 90:
  print(f"Your score is {true_love_score}, you go together like coke and mentos")
elif true_love_score > 40 and true_love_score < 50:
  print(f"Your score is {true_love_score}, you are alright together.")
else:
  print(f"Your score is {true_love_score}.")
