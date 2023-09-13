# Quiz Game for football lovers. Quiz Data provided as of 13-09-2023.
score = 0
go = input("Are you a football lover and would like to participate in this FIFA World cup quiz game ? (yes/no) ")
#while True:
if go == "yes":
    print("Alright. Lets play the quiz :-)")
else:
    print("Alright. Looks like you're not interested in playing the game. Have a good day!")
    quit()

answer = input("Who won the World cup in 2022 ?")
if answer.lower() == 'argentina':
    print("You got it. Answer is correct")
    score +=1
else:
    print("Looks like you haven't watched the Qatar World cup. Answer is wrong.")
            
answer = input("Only country that has played in all the World cup ?")
if answer.lower() == "brazil":
    print("You got it. Answer is correct")
    score +=1
else:
    print("Looks like you aren't not Brazil fan ;-). Answer is wrong.")
    
answer = input("Who scored most goals in World cup ?")
if answer.lower() == "mirozlav klose":
    print("You got it. Answer is correct")
    score +=1
else:
    print("Come on you should be knowing this German striker. Answer is wrong.")
                  
    
answer = input("Which african country hosted the World cup is 2010 ?")
if answer.lower() == "south africa":
    print("You got it. Answer is correct")
    score +=1
else:
    print("Don't you remember Shakira song?. Answer is wrong.")
    
answer = input("The players who has made most appearance in FIFA World Cups ?")
if answer.lower() == "lionel messi":
    print("You got it. Answer is correct")
    score +=1
else:
    print("You forgot the GOAT Messi?. Answer is wrong.")
    
print("Thats the end of the quiz. Thank you for participating.")
print(f"Your score is {score} out of 6 with percentage of " + str((score/5) * 100) + "%")



                    
