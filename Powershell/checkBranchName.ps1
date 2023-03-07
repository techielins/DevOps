#################################################################################################################################
#  Name        : checkBranchName.ps1                                                                                            #
#                                                                                                                               #
#  Description : checkBranchName: checking if branch is refs/heads/release/*                                                    #
#                                                                                                                               #
#  Arguments   : branchName, argument to specify the branchName                                                                 #
#                                                                                                                               #
#  Usage       : ./checkBranchName.ps1 <Branch Name>                                                                            #
#################################################################################################################################

param(
    $branchName
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$helpMsg = "Usage:
                ./checkBranchName.ps1 <Branch Name>"

function Find-InputValid {
    param (
        $value
    )
    if (! $value) {
        Write-Output  "NULL Argument provided"
        Write-Output $helpMsg
        Write-Error  "Invalid Arument Provided" -ErrorAction Stop
    }
}

#################################################################################################################################
#                                              Check-BranchName                                                                 #
#################################################################################################################################

Find-InputValid -value $branchName

Write-Output "Branch Name = $branchName"

if ($null -ne ($branchName | Select-String -Pattern "refs/heads/release/")){
    Write-Output "Current deployment branch is release branch"
}
else {
    Write-Output "Current deployment branch is not release branch"
    Write-Output "##vso[task.LogIssue type=error;]Current deployment branch is not release branch"
    Write-Error  "Current deployment branch is not release branch" -ErrorAction Stop
}

#################################################################################################################################
#################################################################################################################################