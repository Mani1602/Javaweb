#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <svn_link> <folder_name>"
    exit 1
fi

# Step 1: Create a folder with the name of the repo in SVN
svn_link="$1"
folder="$2"
mkdir "$folder"

# Move to the specified folder
cd "$folder" || exit 1

# Step 2: Git SVN clone and navigate to the specified folder
git svn clone --ignore-paths='(\.jar$|\.exe$|\.log$|\.sql$|\.dll$|\.pdf$|\.dot$)' "$svn_link"
cd "trunk" || exit 1

# Step 3: Git filter-repo
git filter-repo --path-glob '*.jar *.exe *.log *.dll *.sql *.pdf *.dot' --invert-paths --force

# Step 4: Check the size
repo_size=$(du -s | cut -f1) 
echo "Repository size: ${repo_size}K"

# Step 5: Check if the size is more than 40MB (converted to kilobytes)
if ((repo_size > 40000)); then
    echo "Repository size is more than 40MB. Stop migration."
    exit 1
fi

echo "Repository size is less than 40MB. Start Migrate"
