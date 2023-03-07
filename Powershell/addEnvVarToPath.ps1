#################################################################################################################################
#  Name        : addEnvVarToPath.ps1                                                                                            #
#                                                                                                                               #
#  Description : Add Environment Variables to Path                                                                              #
#                                                                                                                               #
#  Arguments   : Each provided Environment Variable will be added to path                                                       #
#################################################################################################################################

$ErrorActionPreference="Stop"

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$helpMsg = "Usage:
To Set Environment Variable:
./addEnvVarToPath.ps1 <env variable> <env variable> <env variable> ........"

function Add-EnvVarToPath {
    param (
        $EnvVariable
    )
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$EnvVariable", "Machine")
}
function Find-InputValid {
    param (
        $notNull
    )

    $isInputValid = $true

    if(! $notNull){
        $isInputValid = $false
        Write-Output "No EnvironmentVariables Provided "
    }

    return $isInputValid
}

function Search-EnvVariable {
    param (
        [string]$searchVariable
    )
    $isVariablePresent = $false

    $pathContent = [Environment]::GetEnvironmentVariable('path', 'Machine')

    if ($pathContent -ne $null){
        if ($pathContent -split ';'  -contains  $searchVariable){

            $isVariablePresent = $true
        }
    }

    return $isVariablePresent

    }


#################################################################################################################################
#                                              Set Environment Variable                                                         #
#################################################################################################################################

Write-Output "Arguments Provided are"
Write-Output "$args"


# ** Validate script arguments **
$scriptArgs = $args
if(-not (Find-InputValid -notNull $scriptArgs)) {

    Write-Output  "##vso[task.LogIssue type=warning;]No argumets provided by user"
    Write-Warning "No argumets provided by user"
    Write-Output $helpMsg

    Write-Output  "##vso[task.LogIssue type=error;]Invalid Argument Provided by User"
    Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
}


# ** Set Environment Variable
$addToPath = $null
foreach($envVars in $args){
    Write-Output "Checking $envVars is present in Path"
    if(-not (Search-EnvVariable -searchVariable $envVars)) {
        Write-Output "$envVars not present in path"
        $addToPath = "$addToPath;$envVars"
    }
    else{
        Write-Output "$envVars already present"
    }
}


if ($null -ne $addToPath){
    Write-Output "Adding $addToPath to Path"
    Add-EnvVarToPath -EnvVariable $addToPath
}
else{
    Write-Output "Provided Variables already present in Path"
}

#################################################################################################################################
#################################################################################################################################