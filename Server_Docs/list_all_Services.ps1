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
    Date: 2025-06-05
    Version: 1.1
#>
[CmdletBinding()]
param (
    # Define parameters here and delete this comment.
    [Parameter(Mandatory = $false)]
    [string]$csvpath = "c:\temp\output.csv",
    [Parameter(Mandatory = $false)]
    [string]$encoding = "UTF8",
    [Parameter(Mandatory = $false)]
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

    if (-not (Get-Module -Name "shibis_pwsh_admin_module")) {
        Write-Host "Required module 'shibis_pwsh_admin_module' is not imported. Please import it before running this script." -ForegroundColor Red
        exit 1
    }
}

process {

    try {
        Log-Information "Processing Script list_all_Services..."
        
        # Get all services on the local system
        $services = Get-Service | Select-Object -Property DisplayName, Name, Status, StartType, ServiceType, UserName, BinaryPathName
        # Export the services to a CSV file
        $services | Export-Csv -Path $csvpath -NoTypeInformation -Encoding $encoding -Delimiter $delimiter
        Log-Information "Exported services to '$csvpath'."
        Handle-Success "Successfully exported services to '$csvpath'."

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

    log-Information "End of list_all_Services Script..."
    Stop-Transcript

    exit 0
}