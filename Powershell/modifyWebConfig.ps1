#################################################################################################################################
#  Name        : modifyWebConfig.ps1                                                                                            #
#                                                                                                                               #
#  Description : Modify/Create Solvency IIS Webapplication/Website Web.config                                                   #
#                This script will replace the strings SITENAME, SITEPATH, DBCONNECTIONNAME & AKVURL in the template file        #
#                                                                                                                               #
#  Arguments   : envType, argument to specify the type of env - PROD/NONPROD                                                    #
#                configFilePath, argument to specify the filepath of Web-Template.config $ Web.config                           #
#                siteName, argument to specify website name                                                                     #
#                siteParentPath, argument to specify website root folder path                                                   #
#                dbConName, argument to specify TNS name - specified in tnsnames.ora                                            #
#                $akvUrl, argument to specify the Azure Key Vault URL                                                           #
#################################################################################################################################

# define parameters
param (
    $envType,
    $configFilePath,
    $siteName,
    $siteParentPath,
    $dbConName,
    $akvUrl
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$ErrorActionPreference = "stop"

$helpMsg = "Usage:
            To Modify Web.config:
            .\modifyWebConfig.ps1 <path to config file> <sitename> <db connection name> <akv url>"

function Find-InputValid {
    param (
        $inputValue
    )

    if (! $inputValue) {
        Write-Warning "Argument not provided!"
        Write-Output $helpMsg
        Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
    }
}

#################################################################################################################################
#                                              Modify Web.Config                                                                #
#################################################################################################################################

Find-InputValid -inputValue $envType
Find-InputValid -inputValue $siteName
Find-InputValid -inputValue $siteParentPath
Find-InputValid -inputValue $dbConName
Find-InputValid -inputValue $akvUrl
Find-InputValid -inputValue $configFilePath

# Select templatefile based on the environment
if ($envType -cmatch "NONPROD"){
    $templateFile = "$configFilePath\Web-NONPROD-Template.config"
}
elseif ($envType -cmatch "PROD") {
    $templateFile = "$configFilePath\Web-PROD-Template.config"
}
else {
    Write-Error "Invalid Environment type provided by User" -ErrorAction Stop
}

Write-Output "Environment type is $envType"
Write-Output "Template file: $templateFile"

$configFile = "$configFilePath\Web.config"

# check if file exists and replace hard code values in the template file
if (Test-path $templateFile) {
    Write-Output "$templateFile found and replacing "
    (Get-content $templateFile  -Raw ) -Replace ("SITENAME", "$siteName") -Replace ("SITEPATH", "$siteParentPath") -Replace ("DBCONNECTIONNAME", "$dbConName") -Replace ("AKVURL", "$akvUrl") | set-content $templateFile
    Write-Output "Replaced SITENAME with $siteName, SITEPATH with $siteParentPath, DBCONNECTIONNAME with $dbConName AND AKVURL with $akvUrl"
}
else {
    Write-Error "$templateFile not found" -ErrorAction Stop
}

# Remove the web.config file, rename the template file to web.config
if (Test-Path $configFile) {
    Write-Output "Removing config file"
    Remove-Item $configFile
    Rename-Item -path $templateFile -NewName Web.config
    Write-Output " Renamed $templateFile to $configFile"
}
else {
    Write-Output "$configFile not found"
    Rename-Item -path $templateFile -NewName Web.config
    Write-Output " Renamed $templateFile to $configFile"
}

# Display contents of web.config
Get-content $configFile

#######################################################################################################################################################################################
#######################################################################################################################################################################################

