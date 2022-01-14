#If the bill was $150.00, split between 5 people, with 12% tip. 

#Each person should pay (150.00 / 5) * 1.12 = 33.6
#Format the result to 2 decimal places = 33.60

#Write your code below this line 👇

#Provide the input
print("Welcome to the tip calculator.")
bill = (input("What was the total bill? $"))
tip = (input("What percentage tip would you like to give? 10, 12, or 15? "))
split_no = input("How many people to split the bill? ")

#Calculate the pay for each person
percentage_calculator = int(tip) / 100
total_bill = float(bill) * (1 + percentage_calculator)
pay = round(total_bill / int(split_no), 2)

#Print Output
print(f"Each person should pay: ${pay}")
