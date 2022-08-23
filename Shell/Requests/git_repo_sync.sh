#!/bin/bash
#This script is used to sync git repository to Azure repo.
echo "######list files in checked out dir"
dir
git branch -r  | sed 's/origin\///'  |  sed -e 's/^[ \t]*//'> github_branchlist.txt
echo " Displaying the directory"
ls -l
pwd
echo " Displaying the content of GitHub file"
cat github_branchlist.txt
token=###################
git remote set-url origin "https://${token}@dev.azure.com/techielins/AzDevOps/_git/SyncRepo" --push
git remote -v
for i in $(cat github_branchlist.txt)
do
echo "Pushing the Code.."
echo "branch name is $i "
git checkout $i
git pull
git push origin $i -f -v
done
echo  "#### writing the azure repo branches to azure_branchlist.txt"
git remote set-url origin "https://${token}@dev.azure.com/techielins/AzDevOps/_git/SyncRepo"
git remote -v
git pull
git branch -r  | sed 's/origin\///'  |  sed -e 's/^[ \t]*//'> azure_branchlist.txt
echo "Displaying the directory"
ls -l
pwd
echo "displaying the content of Azure repo file"
cat azure_branchlist.txt
git remote set-url origin "https://${token}@dev.azure.com/techielins/AzDevOps/_git/SyncRepo" --push
comm -23 <(sort azure_branchlist.txt) <(sort github_branchlist.txt) > azure_remove_branchlist.txt
echo " Displaying the different branches"
cat azure_remove_branchlist.txt
for i in $(cat azure_remove_branchlist.txt)
do
echo "Deleting the removed branches of Github repo.."
echo "branch name is $i "
git push origin --delete $i
done
