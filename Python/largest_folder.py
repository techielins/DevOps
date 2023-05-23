#Python script that you can use to find the largest folder in size on a Linux machine
import os
import sys
"""
The get_folder_size function calculates the total size of a folder by recursively traversing through its contents (including subfolders) and summing up the sizes of all the files within it. 
It takes the folder_path as an argument and returns the total size in bytes.
"""
def get_folder_size(folder_path):
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(folder_path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            total_size += os.path.getsize(fp)
    return total_size

"""
The get_largest_folder function is responsible for finding the largest folder within a given starting path. It iterates through all the directories and subdirectories using os.walk, 
calculates the size of each folder using the get_folder_size function, and stores the folder path and size as a tuple in the folder_sizes list. 
Finally, it uses the max function to find the tuple with the largest size based on the second element (size), using a lambda function as the key. 
The function returns the tuple representing the largest folder.
"""
def get_largest_folder(start_path):
    folder_sizes = []
    for dirpath, dirnames, filenames in os.walk(start_path):
        folder_size = get_folder_size(dirpath)
        folder_sizes.append((dirpath, folder_size))
    
    largest_folder = max(folder_sizes, key=lambda x: x[1])
    return largest_folder

"""
The format_size function takes a size in bytes and formats it into a human-readable string representation. It uses a dictionary size_labels to determine the appropriate unit (e.g., KB, MB, GB, etc.) 
based on the size. The function divides the size by 1024 (2^10) until it reaches a size less than 1024 and returns the formatted string.
"""
def format_size(size):
    power = 2**10
    n = 0
    size_labels = {0: 'B', 1: 'KB', 2: 'MB', 3: 'GB', 4: 'TB'}
    while size > power:
        size /= power
        n += 1
    return f"{size:.2f} {size_labels[n]}"

#The script checks the number of command-line arguments passed. If the number is not equal to 2 (script name + start path), it prints a usage message and exits with a non-zero status code
if len(sys.argv) != 2:
    print("Usage: python3 largest_folder.py <start_path>")
    sys.exit(1)

#The script retrieves the start path from the command-line argument using sys.argv[1].    
start_path = sys.argv[1]

#The get_largest_folder function is called with the start path to find the largest folder. The folder path and size are stored in the largest_folder variable.
largest_folder = get_largest_folder(start_path)
folder_path, folder_size = largest_folder

#The format_size function is used to format the folder size into a human-readable string representation.
formatted_size = format_size(folder_size)

#Finally, the script prints the path and size of the largest folder.
print(f"The largest folder is: {folder_path}")
print(f"Size: {formatted_size}")

############ Usage #########
# python3 largest_folder.py /path/to/start
#############################
