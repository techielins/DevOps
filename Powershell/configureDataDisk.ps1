#################################################################################################################################
#  Name        : configureDataDisk.ps1                                                                                          #
#                                                                                                                               #
#  Description : Perfom initialization, format & assign drive letter to attached DataDisk - Msft Virtual Disk                   #
#                                                                                                                               #
#  Arguments   : true, argument to confirm format/initialization of attached DataDisk                                           #
#################################################################################################################################

param (
    [string]$confirmDiskFormat
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$ErrorActionPreference="Stop"

$helpMsg = "Usage:
            To initialize Data Disk:
                ./configureDataDisk.ps1 true"

function Find-InputValid {

    $isInputValid = $true

    if(! ($confirmDiskFormat -eq "true")){
        $isInputValid = $false
        Write-Output "Argument 'true' not provided!"
    }
    return $isInputValid
}


#################################################################################################################################
#                                              Configure Data Disk                                                              #
#################################################################################################################################


# ** Validate script arguments **
if(-not (Find-InputValid)) {

    Write-Output  "##vso[task.LogIssue type=warning;]Invalid Argument exception:"
    Write-Warning "Invalid Argument exception:"
    Write-Output $helpMsg

    Write-Output  "##vso[task.LogIssue type=error;]Invalid Argument Provided by User"
    Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
}

Write-Output "Checking and removing previous disk initialization..."
# Remove Disk initialization (if partition style -ne raw)
try {
    Get-Disk | Where-Object FriendlyName -eq 'Msft Virtual Disk' | Where-Object PartitionStyle -ne 'RAW' | Clear-Disk -RemoveData -Confirm:$false
    Write-Output "Removed previous disk initialization..."
}
catch {
    Write-Output "Disk not initialized before.."
}


Write-Output "Initializing Disk, formatting to NTFS & assigning drive letter 'F'"
# Initialize Disk, Format Drive & Assign Drive Letter
Get-Disk | Where-Object FriendlyName -eq 'Msft Virtual Disk' | Initialize-Disk -PartitionStyle MBR -PassThru -Confirm:$true| New-Partition -UseMaximumSize -DriveLetter F | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false

#################################################################################################################################
#################################################################################################################################