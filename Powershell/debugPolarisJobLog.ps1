#################################################################################################################################
#  Name        : debugPolarisJobLog.ps1                                                                                         #
#                                                                                                                               #
#  Description : This Script will parse the log of the Polaris Scan                                                             #
#                Script has to be called after the execution of Synopsis Polaris                                                #
#                                                                                                                               #
#  Warning     : This script will only parse the log of the previous step                                                            #
#                                                                                                                               #
#  Arguments   : maxHighErrorCount, argument to specify the maxnumber of allowed HighErrorCount                                 #
#################################################################################################################################

param(
    [int] $maxHighErrorCount
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$ErrorActionPreference="Stop"

$helpMsg = "Usage:
            .\debugPolarisJobLog.ps1 0"

function Find-InputValid {
    param (
        $inputValue
    )
    if($inputValue -eq 0){
    }
    elseif (! $inputValue) {
        Write-Warning "Argument not provided!"
        Write-Output $helpMsg
        Write-Error "Invalid Argument Provided by User"
    }
}

function Get-Previous-Task-Log {

    $pipelineLogsUrl = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/build/builds/$env:BUILD_BUILDID/logs?api-version=6.0"
    Write-Output "Pipeline logs URL: $pipelineLogsUrl"

    $pipelineLogs = Invoke-RestMethod -Uri $pipelineLogsUrl -Headers @{
        Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"
    }
    Write-Output "Pipeline Logs= $($pipelineLogs | ConvertTo-Json -Depth 100)"

    $prevTaskLogUrl = $pipelineLogs.value[-1].url
    Write-Output "Previous task URL: $prevTaskLogUrl"

    $separator='?$format=text'
    Write-Output "Previous task TEXT FORMAT LOG URL: $prevTaskLogUrl$separator"
    $prevTaskLogs = Invoke-RestMethod -Uri $prevTaskLogUrl$separator -Headers @{
        Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"
    }
    return $prevTaskLogs
}


function Debug-Job-Output {
    param (
        $jobLogs,
        $startString,
        $endString,
        $maxCriticalErrorCount,
        $maxHighErrorCount
    )

    if ($null -eq ($jobLogs | Select-String -Pattern "$startString")){
        Write-Warning "Start string: $startString not found in log"
        Write-Error "Start string: $startString not found in log"
    }
    if ($null -eq ($jobLogs | Select-String -Pattern "$endString")) {
        Write-Warning "End string: $endString not found in log"
        Write-Error "End string: $endString not found in log"
    }

    $startfound = $false
    $logs = $jobLogs -split "`n"
    foreach($line in $logs){
        if ($null -ne ($line | Select-String -Pattern "$startString")){
            $startfound = $true
        }
        elseif ($null -ne ($line | Select-String -Pattern "$endString")) {
            $startfound = $false
        }
        elseif ($startfound -eq $true) {
            $outputLine= "$line" -split ' ', 2
            Write-Output $outputLine[1]
            if ($null -ne ($outputLine[1] | Select-String -Pattern "Critical")){
                $logOutput = [int]$($outputLine[1] -replace "[^0-9]", '')
                if ($logOutput -gt $maxCriticalErrorCount){
                    Write-Warning "$logOutput Critical Errors Found"
                    Write-Error "$logOutput Critical Errors Found"
                }
            }
            elseif ($null -ne ($outputLine[1] | Select-String -Pattern "High")){
                $logOutput = [int]$($outputLine[1] -replace "[^0-9]", '')
                if ($logOutput -gt $maxHighErrorCount){
                    Write-Warning "$logOutput High Errors Found"
                    Write-Error "$logOutput High Errors Found"
                }
            }
        }
    }
}

#################################################################################################################################
#                                              Parse Logs                                                                       #
#################################################################################################################################

$previousJobLogs = Get-Previous-Task-Log

Find-InputValid -inputValue $maxHighErrorCount

$maxCriticalErrorCount = 0
Write-Output "Max allowed critical errors: $maxCriticalErrorCount"
Write-Output "Max allowed high errors: $maxHighErrorCount"

Debug-Job-Output -jobLogs "$previousJobLogs" -startString "Job issue summary" -endString "SummaryUrl" -maxCriticalErrorCount $maxCriticalErrorCount -maxHighErrorCount $maxHighErrorCount

#################################################################################################################################
#################################################################################################################################