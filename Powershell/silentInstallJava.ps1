#################################################################################################################################
#  Name        : silentInstallJava.ps1                                                                                         #
#                                                                                                                               #
#  Description : Perfom silent install of java                                                                                  #
#                                                                                                                               #
#  Arguments   : zipFilePath, specifies the path of the installer zip in the machine                                            #
#                installerPath, specifies the location of installer inside the zip                                              #
#                jdkVersion, specifies the jdk version to be installed                                                          #
#                uninstallString, specifies the Uninstall Srting to check if this version is installed                          #
#################################################################################################################################

param (
    [string] $zipFilePath,
    [string] $installerPath,
    [string] $jdkVersion,
    [string] $uninstallString
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################


$ErrorActionPreference="Stop"


$helpMsg = "Usage:
            To install an application:
                ./silentInstallJava.ps1 <zip file path> <installer location in zip> <JDK Version> <Uninstall String>
                ./silentInstallJava.ps1 'D:\temp\jdk-8u202-windows-x64.zip' 'jdk-8u202-windows-x64.exe' '8' 'Java 8 Update 202 (64-bit)'"

function Find-InputValid {

    $isInputValid = $true

    if(! $zipFilePath){
        $isInputValid = $false
        Write-Output "Argument: $zipFilePath not provided!"
    }
    elseif(-not (Test-Path -Path $zipFilePath)){
        $isInputValid = $false
        Write-Output "Installer zip: $zipFilePath not found!"
    }
    elseif (! $installerPath) {
        $isInputValid = $false
        Write-Output "Argument: Installer Path not provided!"
    }
    elseif (! $jdkVersion) {
        $isInputValid = $false
        Write-Output "Argument: JDK Version  not provided!"
    }
    elseif (! $uninstallString) {
        $isInputValid = $false
        Write-Output "Argument: Uninstall String  not provided!"
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
    param (
        $installerDirectory,
        $installerLocation,
        $commandLineOptions
    )

    Set-Location "$installerDirectory"


    if (Test-Path -Path "$installerLocation"){

        $installerLocation = Resolve-Path $installerLocation
        Write-Output "Installing $installerLocation silently, please wait...." -foregroundColor Yellow
        Start-Process -FilePath $installerLocation -ArgumentList "$commandLineOptions" -Wait -NoNewWindow
        Write-Output "Installation of $installerLocation completed" -foregroundColor Green
    }
    else {
        Write-Error "INSTALLER $installerLocation NOT FOUND" -ErrorAction Stop
    }
}

function Get-JavaUninstallString($productName) {
    $x64items = @(Get-ChildItem "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")
    ($x64items + @(Get-ChildItem "HKLM:SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall") `
        | ForEach-object { Get-ItemProperty Microsoft.PowerShell.Core\Registry::$_ } `
        | Where-Object { $_.DisplayName -and $_.DisplayName -eq "$productName" } `
        | Select-Object UninstallString).UninstallString
}

function Invoke-UninstallJava {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param(
        $productName
    )
    if ($PSCmdlet.ShouldProcess("$productName", "Invoke-UninstallJava")) {

        $uninstallCommand = (Get-JavaUninstallString $productName)
        if($uninstallCommand) {
            Write-Output "Uninstalling $productName"

            $uninstallCommand = $uninstallCommand.replace('MsiExec.exe /I{', '/x{').replace('MsiExec.exe /X{', '/x{')
            cmd /c start /wait msiexec.exe $uninstallCommand /quiet

            Write-Output "Uninstalled $productName" -ForegroundColor Green
        }
    }
}

function Set-SilentInstallOptions {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    [OutputType([String])]
    param (
        $jdkVersion
    )
    if ($PSCmdlet.ShouldProcess("$jdkVersion", "Set-SilentInstallOptions")) {

        $jdkPath = "$env:ProgramFiles\Java\jdk1.$jdkVersion.0"
        $jrePath = "$env:ProgramFiles\Java\jre$jdkVersion"
        Write-Output "JDK install path: $jdkPath"
        Write-Output "JRE install path: $jrePath"

        # generating silent install options
        if($jdkVersion -eq 6) {
            $arguments = "/s ADDLOCAL=`"ToolsFeature,PublicjreFeature`" INSTALLDIR=`"\`"$jdkPath\`"`""
        } elseif ($jdkVersion -eq 7) {
            $arguments = "/s ADDLOCAL=`"ToolsFeature,PublicjreFeature`" /INSTALLDIR=`"$jdkPath`" /INSTALLDIRPUBJRE=`"\`"$jrePath\`"`""
        } else {
            $arguments = "/s ADDLOCAL=`"ToolsFeature,PublicjreFeature`" INSTALLDIR=`"$jdkPath`" /INSTALLDIRPUBJRE=`"$jrePath`""
        }
        Write-Output "Silent Install Options: $arguments"
        return $arguments
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


# ** Validate script arguments **
if(-not (Find-InputValid)) {

    Write-Warning "Invalid Argument exception:"
    Write-Output $helpMsg
    Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
}

$isJavaPresent = (Get-JavaUninstallString $uninstallString)
if($isJavaPresent) {
    Write-Output "Java $jdkVersion already installed" -ForegroundColor Green
}
else {
    # ** Unzip Installer.zip **
    Expand-InstallerZip $zipFilePath $unzipDestination

    # **Select Silent options based on java version **
    $silentInstallOptions = $(Set-SilentInstallOptions $jdkVersion)

    # ** Install Application **
    Invoke-ApplicationInstaller -installerDirectory $unzipDestination -installerLocation $installerPath -commandLineOptions "$silentInstallOptions"

    # Set Java home
    $javaHome = "C:\Progra~1\Java\jdk1.$jdkVersion.0"
    Write-Output "Setting JAVA_HOME: $javaHome"
    [Environment]::SetEnvironmentVariable("JAVA_HOME", "$javaHome", "machine")
    $env:JAVA_HOME="$javaHome"

    # Disable Java updater
    Write-Output "Disabling Java updater.."
    try {
	Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run' -Name 'SunJavaUpdateSched' -ErrorAction Ignore
    }
    catch {
        Write-Output "Unable to remove property SunJavaUpdateSched under HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
    }
    try {
	Disable-ScheduledTask -TaskPath '\' -TaskName 'JavaUpdateSched' -ErrorAction Ignore
    }
    catch {
        Write-Output "Unable to remove Scheduled task: JavaUpdateSched"
    }
}



#################################################################################################################################
#################################################################################################################################