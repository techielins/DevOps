# 🚨 Don't change the code below 👇
age = input("What is your current age? : ")
# 🚨 Don't change the code above 👆

#Write your code below this line

#Calculate days
life_days = 90 * 365
days = int(age) * 365
remaining_days = life_days - days

#Calculate weeks
life_weeks = 90 * 52
weeks = int(age) * 52
remaining_weeks = life_weeks - weeks

#Calculate months
life_months = 90 * 12
months = int(age) * 12
remaining_months = life_months - months

#Print Output
print(f"You have {remaining_days} days, {remaining_weeks} weeks, and {remaining_months} months left.")
