#################################################################################################################################
#  Name        : downloadJfrog.ps1                                                                                              #
#                                                                                                                               #
#  Description : Download jfrog.exe from artifactory                                                                            #
#                                                                                                                               #
#  Arguments   : fileArtifactoryUrl, specifies the url of the file to be downloaded                                             #
#                agentToolsDirectory, specifies the path to download the file                                                   #
#                authUserName, specifies the artifactory usename                                                                #
#                authPassword, specifies the artifactory password                                                               #
#################################################################################################################################

param (
    [string] $fileArtifactoryUrl,
    [string] $agentToolsDirectory,
    [string] $authUserName,
    [string] $authPass
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$ErrorActionPreference="Stop"


$helpMsg = "Usage:
            To download a file from artifactory:
                ./downloadJfrog.ps1 <fileArtifactoryUrl> <agentToolsDirectory> <authUserName> <authPassword>"

function Find-InputValid {

    $isInputValid = $true

    if(! $fileArtifactoryUrl){
        $isInputValid = $false
        Write-Output "Argument: Artifactory download URL  not provided!"
    }
    elseif (! $agentToolsDirectory) {
        $isInputValid = $false
        Write-Output "Argument: File Fownload Path  not provided!"
    }
    elseif (! $authUserName) {
        $isInputValid = $false
        Write-Output "Argument: Username  not provided!"
    }
    elseif (! $authPass) {
        $isInputValid = $false
        Write-Output "Argument: Password  not provided!"
    }

    return $isInputValid
}

function New-DirectoryCreation {
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

function Get-FileFromArtifactory {
    param (
        $fileUrl,
        $downloadPath,
        $userName,
        $pswd
    )
    $pair = "$($userName):$($pswd)"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $basicAuthValue = "Basic $base64"
    $headers = @{ Authorization = $basicAuthValue }
    Invoke-WebRequest -Uri $fileUrl -Headers $headers -OutFile $downloadPath -UseBasicParsing
}

#################################################################################################################################
#                                              Download File                                                                    #
#################################################################################################################################

# ** Validate script arguments **
if(-not (Find-InputValid)) {

    Write-Warning "Invalid Argument exception:"
    Write-Output $helpMsg
    Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
}

$fileDownloadPath = "$($agentToolsDirectory)/_jfrog/current/jfrog.exe"
$fileDownloadDirectory = "$($agentToolsDirectory)/_jfrog/current/"


# ** Checking whether jfrog.exe already exists... **
if (Test-Path $fileDownloadDirectory ){
    Write-Output "jfrog.exe already exists... skipping download.."
}
else {

    New-DirectoryCreation -dirLocation $fileDownloadDirectory

    # Download file
    Get-FileFromArtifactory -fileUrl $fileArtifactoryUrl -downloadPath $fileDownloadPath -userName $authUserName -pswd "$authPass"
}

#################################################################################################################################
#################################################################################################################################