<#
    .SYNOPSIS
    Manage Windows Scheduled Tasks with export, import, and validation capabilities.

    .DESCRIPTION
    Provides an automation wrapper for exporting existing scheduled tasks to disk, importing tasks from XML definitions,
    and validating that designated tasks are running successfully within an expected window.

    .PARAMETER Mode
    Selects which action to perform: Export, Import, or Validate.

    .PARAMETER TaskName
    Optional list of task names to scope the selected action. When omitted, actions apply to all tasks in scope.

    .PARAMETER TaskPath
    Limits operations to tasks under the provided task folder. Defaults to the root ("\").

    .PARAMETER ExportDirectory
    Destination folder used when Mode is Export. Created automatically when needed.

    .PARAMETER ImportPath
    One or more XML files or directories containing XML exports to import when Mode is Import.

    .PARAMETER ValidationThresholdMinutes
    Maximum allowed minutes since the last successful run when Mode is Validate.

    .PARAMETER IncludeDisabled
    Includes disabled tasks during validation when specified; otherwise disabled tasks are skipped.

    .PARAMETER Force
    Overwrites existing scheduled tasks during import when specified.

    .EXAMPLE
    .\scheduled_task_management.ps1 -Mode Export -ExportDirectory C:\Backups\Tasks

    .EXAMPLE
    .\scheduled_task_management.ps1 -Mode Import -ImportPath C:\Backups\Tasks -Force

    .EXAMPLE
    .\scheduled_task_management.ps1 -Mode Validate -TaskName "Nightly Backup" -ValidationThresholdMinutes 120

    .NOTES
    Author: Real Shibi
    Date: 2025-10-03
    Version: 1.0
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Export", "Import", "Validate")]
    [string]$Mode,

    [Parameter(Mandatory = $false)]
    [string[]]$TaskName,

    [Parameter(Mandatory = $false)]
    [string]$TaskPath = "\",

    [Parameter(Mandatory = $false)]
    [string]$ExportDirectory = "C:\\Temp\\ScheduledTasks",

    [Parameter(Mandatory = $false)]
    [string[]]$ImportPath,

    [Parameter(Mandatory = $false)]
    [int]$ValidationThresholdMinutes = 60,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeDisabled,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

begin {
    function Get-NormalizedTaskPath {
        param (
            [string]$PathValue
        )

        if ([string]::IsNullOrWhiteSpace($PathValue) -or $PathValue -eq "\") {
            return "\"
        }

        $normalized = $PathValue.Trim()
        if (-not $normalized.StartsWith("\")) {
            $normalized = "\" + $normalized
        }

        if ($normalized.Length -gt 1 -and -not $normalized.EndsWith("\")) {
            $normalized += "\"
        }

        return $normalized
    }

    function Resolve-ScheduledTasks {
        param (
            [string[]]$Names,
            [string]$PathScope
        )

        $tasks = @()

        if ($Names -and $Names.Count -gt 0) {
            foreach ($name in $Names) {
                try {
                    $task = Get-ScheduledTask -TaskName $name -ErrorAction Stop
                }
                catch {
                    throw "Scheduled task '$name' was not found."
                }

                if ($PathScope -and $PathScope -ne "\" -and $task.TaskPath -ne $PathScope) {
                    continue
                }

                $tasks += $task
            }
        }
        elseif ($PathScope -and $PathScope -ne "\") {
            $tasks = Get-ScheduledTask -TaskPath $PathScope -ErrorAction Stop
        }
        else {
            $tasks = Get-ScheduledTask -ErrorAction Stop
        }

        return $tasks | Sort-Object -Property TaskPath, TaskName -Unique
    }
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'

    $date = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    [string]$lastRunLogFilePath = "$PSCommandPath.$date.LastRun.log"
    Start-Transcript -Path $lastRunLogFilePath | Out-Null

    [DateTime]$startTime = Get-Date
    Write-Information "Starting script at '$($startTime.ToString('u'))'."

    if (-not (Get-Module -Name "shibis-pwsh-admin-module")) {
        Write-Host "Required module 'shibis-pwsh-admin-module' is not imported. Please import it before running this script." -ForegroundColor Red
        Stop-Transcript | Out-Null
        exit 1
    }

    $normalizedTaskPath = Get-NormalizedTaskPath -PathValue $TaskPath
}

process {
    try {
        Log-Information "Processing scheduled_task_management.ps1 in Mode '$Mode'."

        switch ($Mode) {
            'Export' {
                $tasksToExport = Resolve-ScheduledTasks -Names $TaskName -PathScope $normalizedTaskPath

                if (-not $tasksToExport -or $tasksToExport.Count -eq 0) {
                    throw "No scheduled tasks matched the provided criteria for export."
                }

                if (-not (Test-Path -Path $ExportDirectory -PathType Container)) {
                    Log-Information "Creating export directory '$ExportDirectory'."
                    New-Item -ItemType Directory -Path $ExportDirectory -Force | Out-Null
                }

                $exportedFiles = @()

                foreach ($task in $tasksToExport) {
                    $relativePath = $task.TaskPath.Trim('\')
                    $targetDirectory = if ([string]::IsNullOrWhiteSpace($relativePath)) { $ExportDirectory } else { Join-Path -Path $ExportDirectory -ChildPath $relativePath }

                    if (-not (Test-Path -Path $targetDirectory -PathType Container)) {
                        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
                    }

                    $targetFile = Join-Path -Path $targetDirectory -ChildPath ("{0}.xml" -f $task.TaskName)
                    $exportContent = Export-ScheduledTask -TaskPath $task.TaskPath -TaskName $task.TaskName -ErrorAction Stop
                    $exportContent | Out-File -FilePath $targetFile -Encoding UTF8

                    $exportedFiles += $targetFile
                    Log-Information "Exported task '$($task.TaskPath)$($task.TaskName)' to '$targetFile'."
                }

                Handle-Success "Exported $($exportedFiles.Count) scheduled task(s) to '$ExportDirectory'."
            }

            'Import' {
                if (-not $ImportPath -or $ImportPath.Count -eq 0) {
                    throw "ImportPath must be provided when Mode is set to Import."
                }

                $importFiles = @()
                foreach ($path in $ImportPath) {
                    if (-not (Test-Path -Path $path)) {
                        throw "Import source '$path' does not exist."
                    }

                    if (Test-Path -Path $path -PathType Container) {
                        $importFiles += Get-ChildItem -Path $path -Filter *.xml -File -Recurse
                    }
                    else {
                        if ([IO.Path]::GetExtension($path) -ne '.xml') {
                            throw "File '$path' is not an XML scheduled task definition."
                        }

                        $importFiles += Get-Item -Path $path
                    }
                }

                if (-not $importFiles -or $importFiles.Count -eq 0) {
                    throw "No XML files were found to import."
                }

                $importedTasks = @()

                foreach ($file in $importFiles) {
                    $xmlContent = Get-Content -Path $file.FullName -Raw
                    [xml]$xmlDocument = $xmlContent
                    $uri = $xmlDocument.Task.RegistrationInfo.URI

                    if ([string]::IsNullOrWhiteSpace($uri)) {
                        throw "Unable to determine task name or path from '$($file.FullName)'."
                    }

                    $uriSegments = $uri.Split('\') | Where-Object { $_ }
                    $taskNameToRegister = $uriSegments[-1]
                    $taskPathToRegister = if ($uriSegments.Length -gt 1) { "\" + ($uriSegments[0..($uriSegments.Length - 2)] -join '\') + "\" } else { "\" }

                    $registerParams = @{
                        TaskName = $taskNameToRegister
                        TaskPath = $taskPathToRegister
                        Xml = $xmlContent
                        ErrorAction = 'Stop'
                    }

                    if ($Force) {
                        $registerParams['Force'] = $true
                    }

                    $targetDescription = "{0}{1}" -f $taskPathToRegister, $taskNameToRegister

                    if ($PSCmdlet.ShouldProcess($targetDescription, 'Register-ScheduledTask')) {
                        Register-ScheduledTask @registerParams | Out-Null
                        $importedTasks += $targetDescription
                        Log-Information "Imported scheduled task '$targetDescription' from '$($file.FullName)'."
                    }
                }

                Handle-Success "Imported $($importedTasks.Count) scheduled task(s)."
            }

            'Validate' {
                $tasksToValidate = Resolve-ScheduledTasks -Names $TaskName -PathScope $normalizedTaskPath

                if (-not $tasksToValidate -or $tasksToValidate.Count -eq 0) {
                    throw "No scheduled tasks matched the provided criteria for validation."
                }

                if (-not $IncludeDisabled) {
                    $tasksToValidate = $tasksToValidate | Where-Object { $_.State -ne 'Disabled' -and $_.Settings.Enabled }

                    if (-not $tasksToValidate -or $tasksToValidate.Count -eq 0) {
                        throw "All scheduled tasks matching the provided criteria are disabled. Use -IncludeDisabled to force validation."
                    }
                }

                $threshold = New-TimeSpan -Minutes $ValidationThresholdMinutes
                $now = Get-Date
                $validationResults = @()

                foreach ($task in $tasksToValidate) {
                    $taskInfo = Get-ScheduledTaskInfo -TaskName $task.TaskName -TaskPath $task.TaskPath

                    $lastRunTime = $taskInfo.LastRunTime
                    $lastResult = $taskInfo.LastTaskResult
                    $state = $task.State
                    $pathDescriptor = "{0}{1}" -f $task.TaskPath, $task.TaskName

                    $hasRunRecently = $lastRunTime -ne [DateTime]::MinValue -and ($now - $lastRunTime) -le $threshold
                    $isSuccessful = $lastResult -eq 0
                    $isCurrentlyHealthy = ($state -in @('Running', 'Ready')) -and $isSuccessful -and $hasRunRecently

                    $validationResults += [PSCustomObject]@{
                        Task = $pathDescriptor
                        State = $state
                        LastRunTime = $lastRunTime
                        LastTaskResult = $lastResult
                        WithinThreshold = $hasRunRecently
                        IsHealthy = $isCurrentlyHealthy
                    }

                    if ($isCurrentlyHealthy) {
                        Log-Information "Validation successful for task '$pathDescriptor'."
                    }
                    else {
                        Log-Information "Validation FAILED for task '$pathDescriptor'. State='$state', LastResult='$lastResult', LastRun='$lastRunTime'."
                    }
                }

                $failedTasks = $validationResults | Where-Object { -not $_.IsHealthy }

                if ($failedTasks.Count -gt 0) {
                    $failureSummary = $failedTasks | ForEach-Object { "`"$($_.Task)`" (State=$($_.State), LastResult=$($_.LastTaskResult), LastRun=$($_.LastRunTime))" }
                    throw "Validation failed for $($failedTasks.Count) task(s): $($failureSummary -join '; ')."
                }

                Handle-Success "All validated tasks passed health checks within $ValidationThresholdMinutes minute(s)."
                $validationResults
            }
        }
    }
    catch {
        Handle-Error $_.Exception.Message
    }
}

end {
    [DateTime]$finishTime = Get-Date
    [TimeSpan]$elapsedTime = $finishTime - $startTime
    Write-Information "Finished script at '$($finishTime.ToString('u'))'. Took '$elapsedTime' to run."

    Log-Information "End of scheduled_task_management.ps1 script run."
    Stop-Transcript | Out-Null

    exit 0
}
