#################################################################################################################################
#  Name        : silentInstallIIS.ps1                                                                                           #
#                                                                                                                               #
#  Description : Perfom silent install of IIS                                                                                   #
#                                                                                                                               #
#  Arguments   : IIS, argument to specify IIS installation                                                                      #
#################################################################################################################################

param (
    [string]$windowsFeature
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$ErrorActionPreference="Stop"


$helpMsg = "Usage:
            To install IIS:
                ./silentInstallIIS.ps1 IIS"

function Find-InputValid {

    $isInputValid = $true

    if(! ($windowsFeature -eq "IIS")){
        $isInputValid = $false
        Write-Output "Argument "IIS" not provided!"
    }
    return $isInputValid
}

function Set-FirewallRule {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Low"
        )]
    param (
        $ruleName,
        $portNo
    )

    if ($PSCmdlet.ShouldProcess("$ruleName", "$portNo")) {

        try {
            $firewallrule = Get-NetFirewallrule -DisplayName "$ruleName" | Get-NetFirewallAddressFilter -ErrorAction SilentlyContinue
        }
        catch {
            Write-Output "$rulename not found"
        }

        if ($firewallrule) {
            Write-Output " Firewall rule - $ruleName exists"
        }
        else {
            Write-Output "$ruleName creating....."

            New-NetFirewallRule -DisplayName "$ruleName" -Profile @('Domain', 'Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @($portNo)
        }
    }
}


#################################################################################################################################
#                                              Install IIS                                                                      #
#################################################################################################################################


# ** Validate script arguments **
if(-not (Find-InputValid)) {

    Write-Warning "Invalid Argument exception:"
    Write-Output $helpMsg

    # return
    Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
}

Write-Output "Starting IIS Install"
# Install IIS
Install-WindowsFeature -Name Web-WebServer, Web-Common-Http, Web-Security, Web-Filtering, Web-Static-Content, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-App-Dev, Web-Net-Ext45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Asp-Net45, Web-ASP, Web-Includes, Web-Health, Web-Http-Logging, Web-CertProvider, Web-Basic-Auth, Web-Windows-Auth, Web-Digest-Auth, Web-Cert-Auth, Web-Url-Auth, Web-IP-Security, Web-Performance, Web-Stat-Compression, Web-Mgmt-Tools, Web-Scripting-Tools, Web-Mgmt-Service

# Configure the IIS service to start automatically
Write-Output "Configuring the IIS service to start automatically"
Set-Service -name W3SVC -startupType Automatic

# check if firewall rule added and create it
Write-Output "Checking and adding firewall rules"
$firewallRuleName = "IIS-Inbound"
$firewallPortNo = "80"
Set-FirewallRule -ruleName $firewallRuleName -portNo $firewallPortNo

#################################################################################################################################
#################################################################################################################################