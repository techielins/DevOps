#Write a program that adds the digits in a 2 digit number. e.g. if the input was 35, then the output should be 3 + 5 = 8

# 🚨 Don't change the code below 👇
two_digit_number = input("Type a two digit number: ")
# 🚨 Don't change the code above 👆

####################################
#Write your code below this line 👇
#print(type(two_digit_number))
sum_of_digit = two_digit_number
a = int(sum_of_digit[0])
b = int (sum_of_digit[1])
result = a+b
#print(type(result))
print("The sume of two digit is: " + str(result))
