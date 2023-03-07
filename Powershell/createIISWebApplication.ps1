#################################################################################################################################
#  Name        : createIISWebApplication.ps1                                                                                    #
#                                                                                                                               #
#  Description : Creating Web application in IIS                                                                                #
#                                                                                                                               #
#  Arguments   : $siteName - specifies the name of the site in IIS                                                              #
#                $applicationPhysicalPath - specifies the physical path of web application                                      #
#                $webAppPoolName- specifies the App pool name of web application                                                #
#                $WebApp - specifies the name of web application                                                                #
#################################################################################################################################

# define parameters
param(
    $siteName,
    $applicationPhysicalPath,
    $webAppPoolName,
    $webAppName
)

# Import  IIS Module
if ($null -eq (Get-Module "WebAdministration" -ErrorAction SilentlyContinue)){
    Import-Module WebAdministration
}

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$ErrorActionPreference="Stop"

$helpMsg = "Usage:
            To Create-IISWebApplication:
                ./createIISWebApplication.ps1 <Website Name> <App Physical Path> <App Pool Name> <Web App Name>"

function Find-InputValid {
    param (
        $value
    )
    if (! $value) {
        Write-Output  "NULL Argument provided"
        Write-Output $helpMsg
        Write-Error  "Invalid Aruments Provided" -ErrorAction Stop
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

function Find-WebAppExists {
    param (
        $websiteName,
        $webAppName
    )

    $isWebAppPresent = $false

    try {
        $webAppExists = Get-WebApplication -Name "$webAppName" -Site "$websiteName" -ErrorAction SilentlyContinue
    }
    catch {
        {Write-Output "Website $webAppNameName does not exist"}
    }

    if ($webAppExists) {
        $isWebAppPresent = $true
    }

    return $isWebAppPresent
}

function Find-AppPoolExists {
    param (
        $appPoolName
    )

    $isAppPoolPresent = $false

    if (Test-Path ("IIS:\AppPools\" + $appPoolName)) {
        $isAppPoolPresent = $true
        Write-Warning "The App Pool $appPoolName exists...."
    }

    return $isAppPoolPresent
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

function Add-WebApplication {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $websiteName,
        $physicalPath,
        $applicationPoolName,
        $webApplicationName
    )

    if ($PSCmdlet.ShouldProcess("$webApplicationName", "$websiteName")) {

        # Checking whether virtual directory with same name is present
        if (Test-Path ("IIS:\Sites\$websiteName\$webApplicationName")) {
            Write-Warning "Path: IIS:\Sites\$websiteName\$webApplicationName already exists"
            Write-Error "Virtual Directory: $webApplicationName exists, Use a different WebApplication Name" -ErrorAction Stop
        }
        else {
            Write-Output "Creating Web Application: $webApplicationName pool: $applicationPoolName path: $physicalPath site: $websiteName"
            New-WebApplication -Site $websiteName -name $webApplicationName  -PhysicalPath $physicalPath -ApplicationPool $applicationPoolName
            Write-Output "Created Web Application $webApplicationName"
        }
    }
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

function Remove-WebAppAndPool {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $site,
        $webApp
    )

    if ($PSCmdlet.ShouldProcess("$webApp", "$site")) {
        $findPoolName = $(Get-Item IIS:\Sites\$site\$webApp).ApplicationPool
        Write-Warning "Removing Webapplication $webApp inside site $site"
        Remove-WebApplication -Name $webApp -Site $site
        Write-Output "Removed Webapplication $webApp"
        Remove-ApplicationPool -poolName $findPoolName
    }
}


#################################################################################################################################
#                                              Create Web Application                                                           #
#################################################################################################################################

Find-InputValid -value $siteName
Find-InputValid -value $applicationPhysicalPath
Find-InputValid -value $webAppPoolName
Find-InputValid -value $webAppName

# Creating IIS Configuration Backup
$backupName = "$(Get-date -format "yyyyMMdd-HHmmss")-$siteName-$webAppName"
Backup-WebConfiguration $backupName
Write-Output "IIS Configuration backup created $backupname"

try {

    # Check if site exits
    if(-not (Find-SiteExists $siteName)){

        Write-Warning "Website $siteName does not exist"
        Write-Output $helpMsg
        Write-Error "Web site : $siteName site does not exist " -ErrorAction Stop
    }

    # Check if webapp exits and remove it...
    if(Find-WebAppExists $siteName $webAppName){

        Write-Warning "Webapp $webAppName exists"
        Remove-WebAppAndPool -site $siteName -webApp $webAppName
    }

    # Check if app-pool exits and remove it...
    if(Find-AppPoolExists $webAppPoolName){

        Write-Warning "Application Pool $webAppPoolName exists,, removing..."
        Remove-ApplicationPool -poolName $webAppPoolName
    }

    # Check if physical path exists else create it
    Add-Directory -directory $applicationPhysicalPath

    # check if applicationpool exists else create it
    Add-ApplicationPool -applicationPoolName $webAppPoolName

    # check if Web Application exists else create it
    Add-WebApplication -websiteName $siteName -physicalPath $applicationPhysicalPath -applicationPoolName $webAppPoolName -webApplicationName $webAppName

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