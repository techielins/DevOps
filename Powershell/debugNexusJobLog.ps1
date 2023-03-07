#########################################################################################################################################
#  Name        : debugNexusJobLog.ps1                                                                                                   #
#                                                                                                                                       #
#  Description : This Script will parse the log of the Nexus Scan                                                                       #
#                Script has to be called after the execution of Nexus OSS Scan                                                          #
#                                                                                                                                       #
#  Warning     : This script will only parse the log of the previous step                                                               #
#                                                                                                                                       #
#  Arguments   : maxComponentsAffectedSevereErrorCount, argument to specify the maxnumber of allowed severely affected components       #
#                maxComponentsAffectedModerateErrorCount, argument to specify the maxnumber of allowed moderately affected components   #
#                maxPolicyViolationsSevereErrorCount, argument to specify the maxnumber of allowed severe policy voilations             #
#                maxPolicyViolationsModerateErrorCount, argument to specify the maxnumber of allowed moderate policy voilations         #
#########################################################################################################################################

param(
    [int]$maxComponentsAffectedSevereErrorCount,
    [int]$maxComponentsAffectedModerateErrorCount,
    [int]$maxPolicyViolationsSevereErrorCount,
    [int]$maxPolicyViolationsModerateErrorCount
)

#################################################################################################################################
#                                             Helper Functions                                                                  #
#################################################################################################################################

$ErrorActionPreference="Stop"

$helpMsg = "Usage:
            .\debugNexusJobLog.ps1 0"

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
        $maxComponentsAffectedCriticalErrorCount,
        $maxComponentsAffectedSevereErrorCount,
        $maxComponentsAffectedModerateErrorCount,
        $maxGrandfatheredPolicyViolations,
        $maxPolicyViolationsCriticalErrorCount,
        $maxPolicyViolationsSevereErrorCount,
        $maxPolicyViolationsModerateErrorCount
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
            $outputLine= "$line" -split ' ', 3
            $output = $outputLine[2]
            if ($null -ne $output) {
                Write-Output $output
            }
            if ($null -ne ($output | Select-String -Pattern "components affected")){

                $checkLine= $output -split '[:,]'
                foreach ($item in $checkLine) {
                    if ($null -ne ($item | Select-String -Pattern "critical")){

                        $logOutput = [int]$($item -replace "[^0-9]", '')
                        Write-Output "Components affected critical: $logOutput"
                        if ($logOutput -gt $maxComponentsAffectedCriticalErrorCount){
                            Write-Output  "##vso[task.LogIssue type=error;]$logOutput components critically affected "
                            Write-Error "$logOutput components critically affected"
                        }
                    }
                    elseif ($null -ne ($item | Select-String -Pattern "severe")){

                        $logOutput = [int]$($item -replace "[^0-9]", '')
                        Write-Output "Components affected severe: $logOutput"
                        if ($logOutput -gt $maxComponentsAffectedSevereErrorCount){
                            Write-Output  "##vso[task.LogIssue type=error;]$logOutput components severely affected severe"
                            Write-Error "$logOutput components severely affected"
                        }

                    }
                    elseif ($null -ne ($item | Select-String -Pattern "moderate")){

                        $logOutput = [int]$($item -replace "[^0-9]", '')
                        Write-Output "Components affected moderate: $logOutput"
                        if ($logOutput -gt $maxComponentsAffectedModerateErrorCount){
                            Write-Output  "##vso[task.LogIssue type=error;]$logOutput components moderately affected"
                            Write-Error "$logOutput components moderately affected"
                        }

                    }
                }
            }
            elseif ($null -ne ($output | Select-String -Pattern "grandfathered policy violations")){
                $logOutput = [int]$($output -replace "[^0-9]", '')
                if ($logOutput -gt $maxGrandfatheredPolicyViolations){
                    Write-Output  "##vso[task.LogIssue type=error;]$logOutput grandfathered policy violations"
                    Write-Error "$logOutput grandfathered policy violations"
                }
            }
            elseif ($null -ne ($output | Select-String -Pattern "policy violations")){

                $checkLine= $output -split '[:,]'
                foreach ($item in $checkLine) {
                    if ($null -ne ($item | Select-String -Pattern "critical")){

                        $logOutput = [int]$($item -replace "[^0-9]", '')
                        Write-Output "Critical policy violations $logOutput"
                        if ($logOutput -gt $maxPolicyViolationsCriticalErrorCount){
                            Write-Output  "##vso[task.LogIssue type=error;]$logOutput Critical policy violations"
                            Write-Error "$logOutput Critical policy violations"
                        }
                    }
                    elseif ($null -ne ($item | Select-String -Pattern "severe")){

                        $logOutput = [int]$($item -replace "[^0-9]", '')
                        Write-Output "severe policy violations $logOutput"
                        if ($logOutput -gt $maxPolicyViolationsSevereErrorCount){
                            Write-Output  "##vso[task.LogIssue type=error;]$logOutput severe policy violations"
                            Write-Error "$logOutput severe policy violations"
                        }

                    }
                    elseif ($null -ne ($item | Select-String -Pattern "moderate")){

                        $logOutput = [int]$($item -replace "[^0-9]", '')
                        Write-Output "moderate policy violations $logOutput"
                        if ($logOutput -gt $maxPolicyViolationsModerateErrorCount){
                            Write-Output  "##vso[task.LogIssue type=error;]$logOutput moderate policy violations"
                            Write-Error "$logOutput moderate policy violations"
                        }

                    }
                }
            }
        }
    }
}

#################################################################################################################################
#                                              Parse Logs                                                                       #
#################################################################################################################################

$previousJobLogs = Get-Previous-Task-Log

Find-InputValid -inputValue $maxPolicyViolationsSevereErrorCount
Find-InputValid -inputValue $maxComponentsAffectedSevereErrorCount
Find-InputValid -inputValue $maxPolicyViolationsModerateErrorCount
Find-InputValid -inputValue $maxComponentsAffectedModerateErrorCount

$maxComponentsAffectedCriticalErrorCount = 0
$maxPolicyViolationsCriticalErrorCount = 0
$maxGrandfatheredPolicyViolations = 0

Write-Output "maxPolicyViolationsCriticalErrorCount: $maxPolicyViolationsCriticalErrorCount"
Write-Output "maxComponentsAffectedCriticalErrorCount: $maxComponentsAffectedCriticalErrorCount"
Write-Output "maxComponentsAffectedModerateErrorCount: $maxComponentsAffectedModerateErrorCount"
Write-Output "maxGrandfatheredPolicyViolations: $maxGrandfatheredPolicyViolations"
Write-Output "maxPolicyViolationsSevereErrorCount: $maxPolicyViolationsSevereErrorCount"
Write-Output "maxComponentsAffectedSevereErrorCount: $maxComponentsAffectedSevereErrorCount"
Write-Output "maxPolicyViolationsModerateErrorCount: $maxPolicyViolationsModerateErrorCount"

Debug-Job-Output -jobLogs $previousJobLogs -startString "Policy evaluation completed" -endString "Build successful" -maxComponentsAffectedCriticalErrorCount $maxComponentsAffectedCriticalErrorCount -maxComponentsAffectedSevereErrorCount $maxComponentsAffectedSevereErrorCount -maxComponentsAffectedModerateErrorCount $maxComponentsAffectedModerateErrorCount -maxGrandfatheredPolicyViolations $maxGrandfatheredPolicyViolations -maxPolicyViolationsCriticalErrorCount $maxPolicyViolationsCriticalErrorCount -maxPolicyViolationsSevereErrorCount $maxPolicyViolationsSevereErrorCount -maxPolicyViolationsModerateErrorCount $maxPolicyViolationsModerateErrorCount

#################################################################################################################################
#################################################################################################################################