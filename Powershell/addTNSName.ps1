#################################################################################################################################
#  Name        : addTNSName.ps1                                                                                                 #
#                                                                                                                               #
#  Description : Create Oracle net service names or aliases for each database server                                            #
#                                                                                                                               #
#  Arguments   : dataSourceAlias, argument to specify net service name for database server                                      #
#                dbHostname, argument to specify host name                                                                      #
#                portNumber, argument to specify portnumber                                                                     #
#                databaseServiceName,argument to specify service name                                                           #
#################################################################################################################################

#define parameters
param(
    $dataSourceAlias,
    $dbHostname,
    $portNumber,
    $databaseServiceName
    )

$tnsFilePath = "C:\oracle\network\admin\tnsnames.ora"

$ErrorActionPreference = "Stop"

$helpMsg = "Usage:
To create oracle net servicename:
            .\addTNSName.ps1<dataSourceAlias> <db hostName> <portNumber> <databaseServiceName>"

            #validate input
function Find-InputValid {
    param (
        $inputValue
    )

    if(! $inputValue){
        Write-Warning "Argument not provided!"
        Write-Output $helpMsg
        Write-Error "Invalid Argument Provided by User" -ErrorAction Stop
    }
}

Find-inputValid $dataSourceAlias
Find-inputValid $dbHostname
Find-inputValid $portNumber
Find-inputValid $databaseServiceName


#check if tnsnames.ora file exists else create it
Write-Output "Checking if alias $tnsFilePath exists, else creating..."
if (Test-Path $tnsFilePath) {
    Write-Warning "tnsnames.ora already exists "
}
else {
    Write-Output "tnsnames.ora not found.creating..."
    New-Item -path $tnsFilePath
}

# check if $dataSourceAlias exists else creating..
Write-Output "Checking if TNS Name $dataSourceAlias aleady exists, else creating.."
$ifAlias = Select-String -path $tnsFilePath -pattern "$dataSourceAlias"
if ($null -ne $ifAlias) {
    Write-Warning "$tnsFilePath already contains alias $dataSourceAlias"
    Write-Warning "No Changes Made."
}
else {
    Write-Output "$tnsFilePath doesnot contains TNSName $dataSourceAlias"
    Write-Output "Adding alias: $dataSourceAlias, hostname: $dbHostname, port: $portNumber, servicename: $databaseServiceName"
    Add-content -path $tnsFilePath "$dataSourceAlias =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = $dbHostname)(PORT = $portNumber))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = $databaseServiceName)
    )
  ) "
}

Write-Output "Displaying contents of tnsnames.ora file"
Get-Content $tnsFilePath

#################################################################################################################################
#################################################################################################################################