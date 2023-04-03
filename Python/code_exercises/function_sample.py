length = int(input("Enter length:"))

width = int(input("Enter Width:"))

height = int(input("Enter Height:"))


def volume(length, width, height):
    return length*width*height


volume(length, width, height)

print("Volume is " + str(volume(length, width, height)))