#################################################################################################################################
#  Name        : createIISWebsite.ps1                                                                                          #
#                                                                                                                               #
#  Description : Create Solvency IIS Website                                                                                    #
#                                                                                                                               #
#  Arguments   : sitename, argument to specify website name                                                                     #
#                physicalpath, argument to specify physical path of the website                                                 #
#                appPoolName, argument to specify application-pool of the website                                               #
#                Portno, argument to specify the port number where website is exposed                                           #
#                sitehostname, argument to specify hostname for the website                                                     #
#################################################################################################################################

# define parameters
param(
    [string]$siteName,
    [string]$physicalPath,
    [string]$appPoolName,
    [string]$portNo,
    [string]$siteHostname
)

# Import  IIS Module
if ($null -eq (Get-Module "WebAdministration" -ErrorAction SilentlyContinue)){
    Import-Module WebAdministration
}

$ErrorActionPreference ="Stop"

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$helpMsg = "Usage:
            To Create IIS Website.ps1:
                ./createIISWebsite.ps1 DEV1 C:\inetpub\DEV1 DEV1-POOL 80 localhost"

function Find-InputValid {
    param (
        $inputValue
    )

    if(! $inputValue){

        Write-Output  "##vso[task.LogIssue type=warning;]Argument not provided!"
        Write-Warning "Argument not provided!"
        Write-Output $helpMsg

        Write-Output  "##vso[task.LogIssue type=error;]Invalid Argument Provided by User"
        Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
    }
}

function Find-SiteExists {
    param (
        $websiteName
    )

    $isWebsitePresent = $true

    try {
        $siteExists = Get-Website -Name "$siteName" -ErrorAction SilentlyContinue
    }
    catch {
        {Write-Output "Website $websiteName does not exist"}
    }

    if (! $siteExists) {
        $isWebsitePresent = $false
    }

    return $isWebsitePresent
}

function Find-AppPoolExists {
    param (
        $appPoolName
    )

    $isAppPoolPresent = $false

    if (Test-Path ("IIS:\AppPools\" + $appPoolName)) {
        $isAppPoolPresent = $true
        Write-Output  "##vso[task.LogIssue type=warning;]The App Pool $appPoolName exists...."
        Write-Warning "The App Pool $appPoolName exists...."
    }

    return $isAppPoolPresent
}

function Remove-ApplicationPool {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $poolName
    )
    if ($PSCmdlet.ShouldProcess("$poolName", "Remove-ApplicationPool")) {
        Write-Output  "##vso[task.LogIssue type=warning;]Removing Application Pool $poolName"
        Write-Warning "Removing Application Pool $poolName"
        Remove-WebAppPool -Name $poolName
        Write-Output "Removed Application Pool $poolName"
    }
}

function Remove-SiteAndPool {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $site
    )
    if ($PSCmdlet.ShouldProcess("$site", "Remove-SiteAndPool")) {
        $findPoolName = $(Get-Item IIS:\Sites\$site).ApplicationPool
        Write-Output  "##vso[task.LogIssue type=warning;]Removing Website $site"
        Write-Warning "Removing Website $site"
        Remove-Website -Name $site
        Write-Output "Removed Website $site"
        Remove-ApplicationPool -poolName $findPoolName
    }
}

# Create Directory
function Add-Directory {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $directory
    )

    if ($PSCmdlet.ShouldProcess("$directory", "Add-Directory")) {
        if (Test-Path $directory) {
            Write-Output  "##vso[task.LogIssue type=warning;]$directory exists...."
            Write-Warning "$directory exists...."
        }
        else {
            Write-Output "$directory doesnot exists. , creating.. "
            New-Item $directory -Type Directory -Force
            Write-Output "Created $directory"
        }
    }
}

function Add-ApplicationPool {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $applicationPoolName
    )

    if ($PSCmdlet.ShouldProcess("$applicationPoolName", "Add-ApplicationPool")) {
        Write-Output "Creating application pool $applicationPoolName"
        New-WebAppPool -Name $applicationPoolName
        if ((Get-WebAppPoolState -Name $applicationPoolName).Value -ne "Started") {
            Write-Error "App pool $applicationPoolName was created but did not start automatically. Probably something is broken!" -ErrorAction Stop
        }
        Write-Output "Created Application Pool $applicationPoolName"
    }
}

function Add-Website {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $name,
        $path,
        $poolName,
        $port,
        $hostname
    )

    if ($PSCmdlet.ShouldProcess("$name", "Add-Website")) {
        Write-Output "Creating Website : $name"
        New-WebSite -Name $name -PhysicalPath $path -ApplicationPool $poolName -port $port -hostheader $hostname -Force
        Write-Output "Website : $name created successfully"
    }
}

function Set-DefaultDocument {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $docName
    )

    if ($PSCmdlet.ShouldProcess("$docName", "Set-DefaultDocument")) {
        if ((Get-WebConfigurationProperty -Filter //defaultDocument/files/add -PSPath 'IIS:\' -Name value).value -contains "$docName") {
            Write-Output "Default Document $docName already exists."
        }
        else{
            Write-Output "Default Document $docName doesnot exist adding...."
            add-webconfigurationproperty /system.webServer/defaultDocument -name files -value @{value="$docName"}
        }
    }
}

function Set-AnonymousAuthentication {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param(
        [bool]$value
    )

    if ($PSCmdlet.ShouldProcess("$value", "Set-AnonymousAuthentication")) {
        $anonAuthFilter = "/system.WebServer/security/authentication/AnonymousAuthentication"
        $anonAuth = Get-WebConfigurationProperty -filter $anonAuthFilter -name Enabled -PSPath IIS:\
        if( $anonAuth.Value -eq $value ){
            Write-Output "IIS Anonymous Authentication is already $value"
        } else {
            Write-Output "Setting IIS Anonymous Authentication to $value "
            Set-WebConfigurationProperty -filter $anonAuthFilter -name enabled -value $value -PSPath IIS:\
        }
    }
}

function Set-WindowsAuthentication {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param(
        [bool]$value
    )

    if ($PSCmdlet.ShouldProcess("$value", "Set-WindowsAuthentication")) {
        $windowsAuthFilter = "/system.WebServer/security/authentication/windowsAuthentication"
        $windowAuth = Get-WebConfigurationProperty -filter $windowsAuthFilter -name Enabled -PSPath IIS:\
        if( $windowAuth.Value -eq $value ){
            Write-Output "IIS Windows Authentication is already $value"
        }
        else {
            Write-Output "Setting IIS Windows Authentication to $value "
            Set-WebConfigurationProperty -filter $windowsAuthFilter -name enabled -value $value -PSPath IIS:\
        }
    }
}

#################################################################################################################################
#                                              Create Website                                                                   #
#################################################################################################################################

# ** Validate script arguments **
Find-InputValid -inputValue $siteName
Find-InputValid -inputValue $physicalPath
Find-InputValid -inputValue $appPoolName
Find-InputValid -inputValue $portNo
### Skipping hostname validation, because it can be null ###
# Find-InputValid -inputValue $siteHostname

Write-Output "Arguments provided:
        Site Name: $siteName
        Physical Path: $physicalPath
        Application Pool Name: $appPoolName
        Port No: $portNo
        Hostname: $siteHostname"

# Listing all websites
Write-Output "Listing all websites in IIS"
Get-IISSite

# Creating IIS Configuration Backup
$backupName = "$(Get-date -format "yyyyMMdd-HHmmss")-$siteName"
Backup-WebConfiguration $backupName
Write-Output "IIS Configuration backup created $backupname"

try {

    # Checkin whether site present and removing..
    if(Find-SiteExists -websiteName $siteName){
        Write-Output  "##vso[task.LogIssue type=warning;]Website $siteName exists removing..."
        Write-Warning "Website $siteName exists removing..."
        Remove-SiteAndPool -site $siteName
    }

    # Checking for sites using same bindings and removing them..
    foreach($site in Get-ChildItem IIS:\Sites) {
        if( $site.Bindings.Collection.bindingInformation -eq ("*:" + $portNo + ":" + "$siteHostname")){
            Write-Output  "##vso[task.LogIssue type=warning;]Found an existing site '$($site.Name)' already using port: $portNo and hostname: $siteHostname. Removing it..."
            Write-Warning "Found an existing site '$($site.Name)' already using port: $portNo and hostname: $siteHostname. Removing it..."
            Remove-SiteAndPool  -site $site.Name
        }
    }

    # Check if app-pool exits and removing..
    if(Find-AppPoolExists -appPoolName $appPoolName){
        Write-Output  "##vso[task.LogIssue type=warning;]Application Pool $appPoolName exists"
        Write-Warning "Application Pool $appPoolName exists"
        Remove-ApplicationPool -poolName $appPoolName
    }

    # Create Physical Path
    Write-Output "Creating Physical Path $physicalPath"
    Add-Directory -directory $physicalPath

    # Set IIS Level AnonymousAuthentication to false
    Set-AnonymousAuthentication -value $false

    # Set IIS Level WindowsAuthentication to true
    Set-WindowsAuthentication  -value $true

    # Setting Default Document - IIS Level
    # Set-DefaultDocument -docName Home.aspx

    # Create Application Pool
    Add-ApplicationPool -applicationPoolName $appPoolName

    # Create Website
    Add-Website -name $siteName -path $physicalPath -poolName $appPoolName -port $portNo -hostname $siteHostname
    Write-Output "Website $siteName successfully created..."

}
catch {
    Write-Output "Error detected, running command 'Restore-WebConfiguration $backupName' to restore the web server to its initial state. Please wait..."
    # Get-Service returns null if no service is found, when $ErrorActionPreference is set to stop it will throw error.
    $ErrorActionPreference ="Continue"
    Restore-WebConfiguration $backupName
    $ErrorActionPreference ="Stop"
    Write-Output "IIS Restore complete. Throwing original error......"
    Write-Error $_
}

#################################################################################################################################
#################################################################################################################################