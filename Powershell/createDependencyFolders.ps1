#################################################################################################################################
#  Name        : createDependencyFolders.ps1                                                                                    #
#                                                                                                                               #
#  Description : Create dependency folder structures for solvency .NET Application by parsing web.config                        #
#                This Script will create the folders in web.config based on the start & end string that is provided             #
#                                                                                                                               #
#  Arguments   : configFilePath, argument to specify the website/webapp physical path                                           #
#                startString, argument to specify the "unique start string" to parse folder paths for creation                  #
#                endString, argument to specify the "unique end string" to parse folder paths for creation                      #
#################################################################################################################################

param(
    $configFilePath,
    $startString1,
    $endString1,
    $startString2,
    $endString2
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$ErrorActionPreference="Stop"

function Find-InputValid {
    param (
        $inputValue
    )

    if (! $inputValue) {
        Write-Warning "Argument not provided!"
        Write-Output $helpMsg
        Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
    }
}

function New-DirectoryCreaton {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $dirLocation
    )
    if ($PSCmdlet.ShouldProcess("$dirLocation", "Create-Folder")) {

        Write-Output "Checking if $dirLocation exists.."
        if (Test-Path $dirLocation ){
            Write-Output "Directory $dirLocation exists.. skipping creation"
        }
        else{
            Write-Output "Directory $dirLocation doesnot exists. , creating.. "
            New-Item -Path $dirLocation -ItemType directory
        }
    }
}

function Get-Create-FolderPaths {
    param (
        $configFilePath,
        $startString,
        $endString
    )

        $startfound = $false
        foreach($line in Get-Content $configFilePath){
            if ($null -ne ($line | Select-String -Pattern "$startString")){
                $startfound = $true
            }
            elseif ($null -ne ($line | Select-String -Pattern "$endString")) {
                $startfound = $false
            }
            elseif ($startfound -eq $true) {
                $outputLineArray= "$line" -split "value="
                $outputLine = $outputLineArray[1]
                $folderPathArray = $outputLine -split '"'
                $folderPath = $folderPathArray[1]
                Write-Output "Extracted folder path: "$folderPath""
                if ($null -ne "$folderPath"){
                    Write-Output "Creating directory : "$folderPath""

                    ## Calling folder creaation function to create folder ##
                    New-DirectoryCreaton -dirLocation $folderPath

                }
            }
        }
}


#################################################################################################################################
#                                              Create Dependency Folders                                                        #
#################################################################################################################################

Find-InputValid -inputValue $configFilePath
Find-InputValid -inputValue $startString1
Find-InputValid -inputValue $endString1
Find-InputValid -inputValue $startString2
Find-InputValid -inputValue $endString2

$configfile = "$configFilePath\Web.config"

# check if file exists and create dependency folders
if (Test-path $configfile) {
    Write-Output "$configfile found creating dependency folders..."

    Get-Create-FolderPaths -configFilePath $configfile -startString $startString1 -endString $endString1
    Get-Create-FolderPaths -configFilePath $configfile -startString $startString2 -endString $endString2

    Write-Output "Successfully created required dependency folders!"
}
else {
    Write-Error "$configfile not found" -ErrorAction Stop
}





#################################################################################################################################
#################################################################################################################################