<#
.SYNOPSIS
    Cleans up log files in a specified directory that are older than a specified number of days.

.DESCRIPTION
    The Log_Cleaning.ps1 script deletes log files with a specific file extension in a given directory that are older than a specified number of days.
    It logs the script's actions and errors to a transcript file and exports details of deleted files to a CSV file.

.PARAMETER Path
    The path to the directory or file to be cleaned.

.PARAMETER Days
    The number of days to use as the threshold for deleting files. Files older than this number of days will be deleted.

.PARAMETER FileEnding
    The file extension of the log files to be deleted.

.PARAMETER csvpath
    The path to the CSV file where the output will be saved. Default is "$PSScriptRoot\output.csv".

.PARAMETER encoding
    The encoding to be used for the CSV file. Default is "UTF8".

.PARAMETER delimiter
    The delimiter to be used in the CSV file. Default is ";".

.EXAMPLE
    .\Log_Cleaning.ps1 -Path "C:\Logs" -Days 30 -FileEnding "log"
    This example deletes all .log files in the C:\Logs directory that are older than 30 days.

.NOTES
    Author: RealShibi
    Date: 2024-09-28
    Version: 1.1
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, [int]::MaxValue)]
    [int]$Days,

    [Parameter(Mandatory = $true)]
    [ValidatePattern("^\w+$")]
    [string]$FileEnding,

    [Parameter(Mandatory = $false)]
    [string]$csvpath = "$PSScriptRoot\output.csv",

    [Parameter(Mandatory = $false)]
    [ValidateSet("UTF8", "ASCII", "UTF7", "UTF32", "Default", "Unicode")]
    [string]$encoding = "UTF8",

    # `t is tab btw
    [Parameter(Mandatory = $false)]
    [ValidateSet(";", ",", "`t", "|")]
    [string]$delimiter = ";"
)

begin {
    $InformationPreference = 'Continue'
    # $VerbosePreference = 'Continue' # Uncomment if verbose messages are needed.

    # Get date in format yyyy-MM-dd-HH-mm-ss
    $date = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"

    # Determine the script directory
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
    [string]$lastRunLogFilePath = "$scriptDirectory\Log_Cleaning_$date.LastRun.log"
    Start-Transcript -Path $lastRunLogFilePath

    [DateTime]$startTime = Get-Date
    Write-Information "Starting script at '$($startTime.ToString('u'))'."

    # Initialize an array to store deleted file info
    $deletedFiles = @()

    # Function to handle errors
    function Handle-Error {
        param (
            [string]$Message
        )
        Write-Error $Message
        # Optionally log to a separate error log
        # Add additional error handling logic if needed
    }

    # Function to log information
    function Log-Information {
        param (
            [string]$Message
        )
        Write-Information $Message
    }

    # Check if PowerShell 7 or higher is running
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Handle-Error "This script requires PowerShell 7 or higher to run."
    }

    # Define required modules
    $requiredModules = @("ModuleName1", "ModuleName2")

    function Check-RequiredModules {
        param (
            [string[]]$requiredModules
        )
        foreach ($module in $requiredModules) {
            if (-not (Get-Module -ListAvailable -Name $module)) {
                Handle-Error "Required module '$module' is not installed. Please install it using 'Install-Module -Name $module' before running this script."
            }
        }
    }

    #Check-RequiredModules -requiredModules $requiredModules
}

process {
    try {
        Log-Information "Processing..."

        # Check if the path exists
        if (-not (Test-Path $Path)) {
            Handle-Error "Path '$Path' does not exist."
            return
        }

        # Determine if the path is a file or directory
        $item = Get-Item -Path $Path
        if ($item.PSIsContainer) {
            # Path is a directory
            Log-Information "Path is a directory. Processing files in directory."
            $files = Get-ChildItem -Path $Path -Recurse -Filter "*.$FileEnding" -ErrorAction Stop
        }
        else {
            # Path is a file
            Log-Information "Path is a file."
            if ($item.Extension -ne ".$FileEnding") {
                Log-Information "File '$($item.FullName)' does not match the specified file ending '.$FileEnding'. Skipping."
                return
            }
            $files = @($item)
        }

        Log-Information "Found $($files.Count) file(s) with extension '.$FileEnding'."

        # Calculate the threshold date
        $thresholdDate = (Get-Date).AddDays(-$Days)

        # Filter files older than $Days
        $oldFiles = $files | Where-Object { $_.LastWriteTime -lt $thresholdDate }

        Log-Information "Found $($oldFiles.Count) file(s) older than $Days day(s)."

        foreach ($file in $oldFiles) {
            try {
                Log-Information "Deleting file '$($file.FullName)'."
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                # Store deleted file info for CSV
                $deletedFiles += [PSCustomObject]@{
                    FileName      = $file.Name
                    FullPath      = $file.FullName
                    LastWriteTime = $file.LastWriteTime
                    DeletedAt     = Get-Date
                }
            }
            catch {
                Handle-Error "Failed to delete file '$($file.FullName)'. Error: $_"
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
    Write-Information "Finished script at '$($finishTime.ToString('u'))'. Took '$($elapsedTime)' to run."

    # Export deleted files to CSV if any
    if ($deletedFiles.Count -gt 0) {
        try {
            $deletedFiles | Export-Csv -Path $csvpath -Encoding $encoding -Delimiter $delimiter -NoTypeInformation
            Write-Information "Deleted files exported to '$csvpath'."
        }
        catch {
            Write-Warning "Failed to export deleted files to CSV. Error: $_"
        }
    }
    else {
        Write-Information "No files were deleted. No CSV file was created."
    }

    Stop-Transcript
}
