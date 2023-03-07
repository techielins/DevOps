#################################################################################################################################
#  Name        : actionIIS.ps1                                                                                                  #
#                                                                                                                               #
#  Description : Perform start/stop if IIS, IIS Website, IIS Application Pool                                                   #
#                                                                                                                               #
#  Arguments   : action, argument to specify the action start-site, stop-site, start-iis, stop-iis, start-pool, stop-pool       #
#                appPoolName, argument to specify the application pool name                                                     #
#                siteName, argument to specify website name                                                                     #
#                webAppName, argument to specify the webapplication name                                                        #
#                                                                                                                               #
#  Usage       : To Start Website:                                                                                              #
#                    ./actionIIS.ps1 start-site <App Pool Name> <Website Name>                                                  #
#                To Stop Website:                                                                                               #
#                    ./actionIIS.ps1 stop-site <App Pool Name> <Website Name>                                                   #
#                To Start Application Pool:                                                                                     #
#                    ./actionIIS.ps1 start-pool <App Pool Name>                                                                 #
#                To Stop Application Pool:                                                                                      #
#                    ./actionIIS.ps1 stop-pool <App Pool Name>                                                                  #
#                To Start IIS:                                                                                                  #
#                    ./actionIIS.ps1 start-iis                                                                                  #
#                To Stop IIS:                                                                                                   #
#                    ./actionIIS.ps1 stop-iis                                                                                   #
#################################################################################################################################

param(
    $action,
    $appPoolName,
    $siteName,
    $webAppName
)

# Import  IIS Module
if ($null -eq (Get-Module "WebAdministration" -ErrorAction SilentlyContinue)){
    Import-Module WebAdministration
}

$ErrorActionPreference ="stop"

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$helpMsg = "Usage:
    ./actionIIS.ps1 <action> <Website Name> <App Pool Name> <Web App Name>
            To Start Website:
                ./actionIIS.ps1 start-site <App Pool Name> <Website Name>
            To Stop Website:
                ./actionIIS.ps1 stop-site <App Pool Name> <Website Name>
            To Start Application Pool:
                ./actionIIS.ps1 start-pool <App Pool Name>
            To Stop Application Pool:
                ./actionIIS.ps1 stop-pool <App Pool Name>
            To Start IIS:
                ./actionIIS.ps1 start-iis
            To Stop IIS:
                ./actionIIS.ps1 stop-iis"

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
function Start-IISwebsite {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param ($siteName)

    if ($PSCmdlet.ShouldProcess("$siteName", "Start-IIS-Website")) {

        if (Test-Path ("IIS:\sites\" + $siteName )) {
            Write-Output "The  $siteName exists .starting..."
            if ((Get-WebsiteState -Name $siteName).Value -ne "Started") {
                Start-IISSite -Name "$siteName"
                Write-Output "Started Website $siteName"
            }
            else {
                Write-Warning "$siteName already started!"
            }
        }
        else {
            Write-Output "$siteName doesnot exist."
            Write-Error "Invalid Argument Provided by User - $siteName doesnot exist" -ErrorAction Stop
        }
    }
}

function Stop-IISWebsite {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param ($siteName)

    if ($PSCmdlet.ShouldProcess("$siteName", "Stop-IIS-Website")) {

        if (Test-Path ("IIS:\sites\" + $siteName )) {
            Write-Output "The  $siteName exists .stopping..."
            if ((Get-WebsiteState -Name $siteName).Value -ne "Stopped") {
                Stop-IISSite -Name $siteName -Confirm:$false
                Write-Output "Stopped Website $siteName"
            }
            else {
                Write-Warning "$siteName already stopped!"
            }
        }
        else {
            Write-Output "$siteName doesnot exist."
            Write-Error "Invalid Argument Provided by User - $siteName doesnot exist" -ErrorAction Stop
        }
    }
}

function Stop-IIS {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param()
    if ($PSCmdlet.ShouldProcess("IIS", "Stop")) {
        iisreset /stop
    }
}

function Start-IIS {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param()
    if ($PSCmdlet.ShouldProcess("IIS", "Start")) {
        iisreset /start
    }
}

function Restart-IIS {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param()
    if ($PSCmdlet.ShouldProcess("IIS", "Restart")) {
        iisreset /restart
    }
}

function Stop-AppPool {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $applicationPoolName
    )
    if ($PSCmdlet.ShouldProcess("$applicationPoolName", "Stop-Application-Pool")) {

        Write-Output "Stopping Application Pool $applicationPoolName"
        if (Test-Path ("IIS:\AppPools\" + $applicationPoolName)) {
            if ((Get-WebAppPoolState -Name $applicationPoolName).Value -ne "Stopped") {
                    Stop-WebAppPool -Name $applicationPoolName
                    Write-Output "Stopped AppPool '$applicationPoolName'"
                } else {
                    Write-Warning "WARNING: AppPool '$applicationPoolName' was already stopped!"
                }
        }
        else {
            Write-Output "WARNING: Could not find an AppPool called '$applicationPoolName' to stop."
            Write-Error "Invalid Argument Provided by User - $applicationPoolName doesnot exist" -ErrorAction Stop
        }
    }

}

function Start-AppPool {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $applicationPoolName
    )
    if ($PSCmdlet.ShouldProcess("$applicationPoolName", "Start-Application-Pool")) {

        Write-Output "Starting Application Pool $applicationPoolName"
        if (Test-Path ("IIS:\AppPools\" + $applicationPoolName)) {
            if ((Get-WebAppPoolState -Name $applicationPoolName).Value -ne "Started") {
                    Start-WebAppPool -Name $applicationPoolName
                    Write-Output "Started AppPool '$applicationPoolName'"
                } else {
                    Write-Warning "WARNING: AppPool '$applicationPoolName' was already Started!"
                }
        }
        else {
            Write-Output "WARNING: Could not find an AppPool called '$applicationPoolName' to start."
            Write-Error "Invalid Argument Provided by User - $applicationPoolName doesnot exist" -ErrorAction Stop
        }
    }

}

#################################################################################################################################
#                                              Start/Stop                                                                       #
#################################################################################################################################


if ($action -eq "stop-iis") {
    Stop-IIS
}
elseif ($action -eq "start-iis") {
    Start-IIS
}
elseif ($action -eq "restart-iis") {
    Restart-IIS
}
else{
    Find-InputValid -value $appPoolName
    if ($action -eq "start-pool") {
        Start-AppPool -applicationPoolName $appPoolName
    }
    elseif ($action -eq "stop-pool") {
        Stop-AppPool -applicationPoolName $appPoolName
    }
    else{
        Find-InputValid $siteName
        if ($action -eq "start-site") {
            Start-AppPool -applicationPoolName $appPoolName
            Start-IISwebsite -siteName $siteName
        }
        elseif ($action -eq "stop-site") {
            Stop-IISWebsite -siteName $siteName
            Stop-AppPool -applicationPoolName $appPoolName
        }
        else {
            Write-Warning "Invalid Argument Provided"
            Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
        }
    }
}

#################################################################################################################################
#################################################################################################################################