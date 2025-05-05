<#
    .SYNOPSIS
    PUT SHORT SCRIPT DESCRIPTION HERE AND ADD ANY ADDITIONAL KEYWORD SECTIONS AS NEEDED (.PARAMETER, .EXAMPLE, ETC.).

    .DESCRIPTION
    Provide a more detailed description of what the script does here.

    .PARAMETER ParameterName
    Description of the parameter.

    .EXAMPLE
    Example of how to use this script.

    .NOTES
    Author: Real Shibi
    Date: YYYY-MM-DD
    Version: 1.1
#>
[CmdletBinding()]
param (
    # Define parameters here and delete this comment.
    [Parameter(Mandatory = $false)]
    [string]$csvpath = "c:\temp\output.csv",

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
    # $VerbosePreference = 'Continue' # Uncomment this line if you want to see verbose messages.

    # get date in format yyyy-MM-dd-HH-mm-ss
    $date = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"

    # Log all script output to a file for easy reference later if needed.
    [string] $lastRunLogFilePath = "$PSCommandPath.$date.LastRun.log"
    Start-Transcript -Path $lastRunLogFilePath

    # Display the time that this script started running.
    [DateTime] $startTime = Get-Date
    Write-Information "Starting script at '$($startTime.ToString('u'))'."

    # check if powershell 7 is running
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Handle-Error "This script requires PowerShell 7 or higher to run."
    }
}

process {

    try {
        Log-Information "Processing..."
        # Code Here

    }
    catch {
        Handle-Error $_.Exception.Message
    }
}

end {
    # Display the time that this script finished running, and how long it took to run.
    [DateTime] $finishTime = Get-Date
    [TimeSpan] $elapsedTime = $finishTime - $startTime
    Write-Information "Finished script at '$($finishTime.ToString('u'))'. Took '$elapsedTime' to run."

    Stop-Transcript

    # exit 0 because cleanup 
    exit 0
}