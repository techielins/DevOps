#Python script that you can use to find the largest folder in size on a Linux machine
import os
import sys

def get_folder_size(folder_path):
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(folder_path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            total_size += os.path.getsize(fp)
    return total_size

def get_largest_folder(start_path):
    folder_sizes = []
    for dirpath, dirnames, filenames in os.walk(start_path):
        folder_size = get_folder_size(dirpath)
        folder_sizes.append((dirpath, folder_size))
    
    largest_folder = max(folder_sizes, key=lambda x: x[1])
    return largest_folder

def format_size(size):
    power = 2**10
    n = 0
    size_labels = {0: 'B', 1: 'KB', 2: 'MB', 3: 'GB', 4: 'TB'}
    while size > power:
        size /= power
        n += 1
    return f"{size:.2f} {size_labels[n]}"

if len(sys.argv) != 2:
    print("Usage: python3 largest_folder.py <start_path>")
    sys.exit(1)

start_path = sys.argv[1]

largest_folder = get_largest_folder(start_path)
folder_path, folder_size = largest_folder

formatted_size = format_size(folder_size)

print(f"The largest folder is: {folder_path}")
print(f"Size: {formatted_size}")

############ Usage #########
# python3 largest_folder.py /path/to/start
#############################
