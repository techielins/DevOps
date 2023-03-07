#################################################################################################################################
#  Name        : setCustomVariables.ps1                                                                                         #
#                                                                                                                               #
#  Description : Set-CustomVariables: ArtifactUploadPath, JenkinsJobName                                                        #
#                                                                                                                               #
#  Arguments   : branchName, argument to specify the branchName                                                                 #
#                                                                                                                               #
#  Usage       : ./setCustomVariables.ps1 <Branch Name>                                                                         #
#################################################################################################################################

param(
    $branchName
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$helpMsg = "Usage:
                ./setCustomVariables.ps1 <Branch Name>"

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
#                                              Set-CustomVariables                                                              #
#################################################################################################################################

Find-InputValid -value $branchName

Write-Output "Branch Name = $branchName"

Write-Output "Replacing "refs/heads/" with """
$convertedBranchName = $("$branchName" -replace "refs/heads/", "")
Write-Output "Branch Name: $convertedBranchName"

Write-Output "Replacing "/" with "-" & converting to upper and setting variable ***ArtifactUploadPath***"
$ArtifactUploadPath = $("$convertedBranchName" -replace "/", "-")
$ArtifactUploadPath = $ArtifactUploadPath.ToUpper()
Write-Output "Variable ArtifactUploadPath = $ArtifactUploadPath"
Write-Output "##vso[task.setvariable variable=ArtifactUploadPath;isOutput=true]$ArtifactUploadPath"

Write-Output "Replacing "/" with "-" & converting to upper and setting variable ***JenkinsJobName***"
$JenkinsJobName = $("$convertedBranchName" -replace "/", "%2F")
Write-Output "Variable JenkinsJobName = $JenkinsJobName"
Write-Output "##vso[task.setvariable variable=JenkinsJobName;isOutput=true]$JenkinsJobName"

#################################################################################################################################
#################################################################################################################################