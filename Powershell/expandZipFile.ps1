#################################################################################################################################
#  Name        : expandZipFile.ps1                                                                                              #
#                                                                                                                               #
#  Description : Extract zip file                                                                                               #
#                                                                                                                               #
#  Arguments   : zipFilePath, specifies the path of the zip file in the machine                                                 #
#                unzipDestination, specifies the location to unzip                                                              #
#################################################################################################################################

param (
    [string] $zipFilePath,
    [string] $unzipDestination
)

$ErrorActionPreference="Stop"

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$helpMsg = "Usage:
            To Extract a zip file:
                ./expandZipFile.ps1 <zip file path> <unzip location>"

function Find-InputValid {
    param(
        $zipFileLocation,
        $unzipLocation
    )

    $isInputValid = $true

    if(-not (Test-Path -Path $zipFileLocation)){
        $isInputValid = $false
        Write-Output "Zip file: $zipFileLocation not found!"
    }
    elseif (! $unzipLocation) {
        $isInputValid = $false
        Write-Output "Argument: Zip extraction to Path not provided!"
    }

    return $isInputValid
}

function Expand-InstallerZip {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $zipFileLocation,
        $unzipFileLocation
    )
    if ($PSCmdlet.ShouldProcess("$zipFileLocation", "$unzipFileLocation")) {

        if (Test-Path -Path "$unzipFileLocation") {
            Write-Warning "$unzipFileLocation Path exists! removing....."
            Remove-Item -Path "$unzipFileLocation" -Force -Confirm:$false -Recurse
        }

        new-item -ItemType Directory -Force -Path $unzipFileLocation
        Write-Output "Path created! $unzipFileLocation" -foregroundColor Yellow

        Write-Output "Expanding archive $zipFileLocation to $unzipFileLocation" -foregroundColor Yellow
        Expand-Archive "$zipFileLocation" -DestinationPath $unzipFileLocation -Force
    }
}


#################################################################################################################################
#                                              Install Application                                                              #
#################################################################################################################################

# ** Validate script arguments **
if(-not (Find-InputValid -zipFileLocation $zipFilePath -unzipLocation $unzipDestination)) {

    Write-Warning "Invalid Argument exception:"
    Write-Output $helpMsg
    Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
}

# ** Unzip Installer.zip **
Expand-InstallerZip -zipFileLocation $zipFilePath -unzipFileLocation $unzipDestination

#################################################################################################################################
#################################################################################################################################