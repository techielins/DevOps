#################################################################################################################################
#  Name        : silentInstallApps.ps1                                                                                          #
#                                                                                                                               #
#  Description : Perfom silent install of apps                                                                                  #
#                                                                                                                               #
#  Arguments   : zipFilePath, specifies the path of the installer zip in the machine                                            #
#                installerPath, specifies the location of installer inside the zip                                              #
#                silentInstallOptions, specifies the silent install options of the application                                  #
#                optionsFile, '-not Mandatory' specifies the location of the options file for the application                   #
#################################################################################################################################

param (
    [string] $zipFilePath,
    [string] $installerPath,
    [string] $silentInstallOptions,
    [string] $optionsFile
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$ErrorActionPreference="Stop"

$helpMsg = "Usage:
            To install an application:
                ./silentInstallApps.ps1 <zip file path> <installer location in zip> <silent install options> <options file>"

function Find-InputValid {

    $isInputValid = $true

    if(-not (Test-Path -Path $zipFilePath)){
        $isInputValid = $false
        Write-Output "Installer zip: $zipFilePath not found!"
    }
    elseif (! $installerPath) {
        $isInputValid = $false
        Write-Output "Argument: Installer Path not provided!"
    }
    elseif (! $silentInstallOptions) {
        $isInputValid = $false
        Write-Output "Argument: Silent Install Options  not provided!"
    }
    elseif ($optionsFile) {
        if(-not (Test-Path -Path $optionsFile)){
            $isInputValid = $false
            Write-Output "Options file: $optionsFile not found!"
        }
    }

    return $isInputValid
}

function Expand-InstallerZip {
    param (
        $zipFileLocation,
        $unzipFileLocation
    )

    if (Test-Path -Path "$unzipFileLocation") {
        Write-Warning "$unzipFileLocation Path exists! removing....."
        Remove-Item -Path "$unzipFileLocation" -Force -Confirm:$false -Recurse
    }

    new-item -ItemType Directory -Force -Path $unzipFileLocation
    Write-Output "Path created! $unzipFileLocation" -foregroundColor Yellow

    Write-Output "Expanding archive $zipFileLocation to $unzipFileLocation" -foregroundColor Yellow
    Expand-Archive "$zipFileLocation" -DestinationPath $unzipFileLocation -Force
}

function Invoke-ApplicationInstaller {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $installerDirectory,
        $installerLocation,
        $commandLineOptions
    )

    if ($PSCmdlet.ShouldProcess("$installerDirectory", "Install")) {

        set-location "$installerDirectory"
    
        if (Test-Path -Path "$installerLocation"){
    
            $installerLocation = Resolve-Path $installerLocation
            Write-Output "Installing $installerLocation silently, please wait...." -foregroundColor Yellow
            Start-Process -FilePath $installerLocation -ArgumentList $commandLineOptions -Wait -NoNewWindow
            Write-Output "Installation of $installerLocation completed" -foregroundColor Green
        }
        else {
            Write-Error "INSTALLER $installerLocation NOT FOUND" -ErrorAction Stop
        }
    }
}


#################################################################################################################################
#                                              Install Application                                                              #
#################################################################################################################################

$workDir = "D:\DevOps\temp\"
$unzipFolder = $zipFilePath.split('\.')[-2]
$unzipDestination= "$workDir$unzipFolder"

Write-Output "Local path to installer zip: $zipFilePath"
Write-Output "Installer location inside zip: $installerPath"
Write-Output "Silent Install Options:s $silentInstallOptions"
if ($optionsFile) {
    Write-Output "Options File: $optionsFile"
}


# ** Validate script arguments **
if(-not (Find-InputValid)) {

    Write-Warning "Invalid Argument exception:"
    Write-Output $helpMsg
    Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
}

# ** Unzip Installer.zip **
Expand-InstallerZip -zipFileLocation $zipFilePath -unzipFileLocation $unzipDestination

# ** Install Application **
Invoke-ApplicationInstaller -installerDirectory $unzipDestination -installerLocation $installerPath -commandLineOptions "$silentInstallOptions"

#################################################################################################################################
#################################################################################################################################