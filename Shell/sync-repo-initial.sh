echo "###########list files in checked out dir##########"
dir
token=$(System.AccessToken)
git remote set-url origin "https://${token}@dev.azure.com/MyDevOps/MyApp/_git/repo1" --push
git remote -v
echo "pushing..."
branch=`sed "s@refs/heads/@@" <<< $(Build.SourceBranch)`
echo $branch
git checkout $branch
git push origin $branch -f -v


#################

#!/bin/bash
echo "###########list files in checked out dir###########"
dir
git branch -r | sed -r 's|(^.*/)(.*)|\2|' > branchlist.txt
echo "Displaying the content of list file"
cat branchlist.txt
echo ""
token=$(System.AccessToken)
git remote set-url origin "https://${token}@dev.azure.com/MyDevOps/MyApp/_git/repo1" --push
git remote -v
for i in $(cat branchlist.txt)
do
echo "Pushing the code..."
echo "Branch name is $i"
git checkout $i
git pull
git push origin $i -f -v
done

