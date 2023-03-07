#################################################################################################################################
#  Name        : startStopVM.ps1                                                                                                #
#                                                                                                                               #
#  Description : Perform start/stop of Virtual Machine                                                                          #
#                                                                                                                               #
#  Arguments   : action, argument to specify the action start/stop                                                              #
#                resourceGroup, argument to specify the resource group                                                          #
#                vmName, argument to specify VM name                                                                            #
#                                                                                                                               #
#  Usage       : To Start VM:                                                                                                   #
#                    ./startStopVM.ps1 start <Resource Group Name> <VM Name>                                                    #
#                To Stop VM:                                                                                                    #
#                    ./startStopVM.ps1 stop <Resource Group Name> <VM Name>                                                     #
#################################################################################################################################

param(
    $action,
    $resourceGroup,
    $vmName
)

# Import  AZ Module
if ($null -eq (Get-Module "Az" -ErrorAction SilentlyContinue)){
    Import-Module -Name Az
}

$ErrorActionPreference ="stop"

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$helpMsg = "Usage:
            To Start VM:                                                                                                   #
                ./startStopVM.ps1 start <Resource Group Name> <VM Name>                                                   #
            To Stop VM:                                                                                                    #
                ./startStopVM.ps1 stop <Resource Group Name> <VM Name>"

function Find-InputValid {
    param (
        $value
    )
    if (! $value) {
        Write-Output "NULL Argument provided"
        Write-Output $helpMsg
        Write-Error "Invalid Aruments Provided" -ErrorAction Stop
    }
}

function Start-VM {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $resourceGroupName,
        $virtualMachineName
    )

    if ($PSCmdlet.ShouldProcess("$virtualMachineName", "Start")) {

        Connect-AzAccount -Identity
        Write-Output "Starting Virtual Machine $virtualMachineName"
        Start-AzVM -ResourceGroupName $resourceGroupName -Name $virtualMachineName
    }
}

function Stop-VM {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $resourceGroupName,
        $virtualMachineName
    )

    if ($PSCmdlet.ShouldProcess("$virtualMachineName", "Stop")) {

        Connect-AzAccount -Identity
        Write-Output "Stopping Virtual Machine $virtualMachineName"
        Stop-AzVM -ResourceGroupName $resourceGroupName -Name $virtualMachineName -StayProvisioned -Force
    }

}

#################################################################################################################################
#                                              Start/Stop                                                                       #
#################################################################################################################################

Find-InputValid -value $resourceGroup
Find-InputValid -value $vmName

if ($action -eq "stop") {
    Stop-VM -resourceGroupName $resourceGroup -virtualMachineName $vmName
}
elseif ($action -eq "start") {
    Start-VM -resourceGroupName $resourceGroup -virtualMachineName $vmName
}
else {
    Write-Warning "Invalid Action Provided"
    Write-Error "Invalid Action Provided by User" -ErrorAction Stop
}



#################################################################################################################################
#################################################################################################################################