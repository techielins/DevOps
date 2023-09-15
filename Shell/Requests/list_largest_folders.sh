#!/bin/bash
### The script will list the folders in the specified source path in descending order of size and display the results in a table format.
# Prompt the user for the source path
read -p "Enter the source path: " source_path

# Check if the source path exists
if [ ! -d "$source_path" ]; then
  echo "Source path does not exist."
  exit 1
fi

# Output header for the table
echo -e "Folder Name\tSize (KB)"

# Use the 'find' command to list directories, and 'du' to calculate their size
find "$source_path" -type d -exec du -sk {} + | sort -nr | while read size path; do
  # Format and print the results in a table format
  echo -e "$(basename "$path")\t$size"
done
