<#
.SYNOPSIS
    Retrieves detailed Active Directory user information.

.DESCRIPTION
    This script queries Active Directory for user objects and returns a collection of user properties,
    such as name, email address, group memberships and other relevant attributes. Can be used for
    inventory, reporting or auditing purposes.

.PARAMETER Identity
    Specifies the user or users to retrieve. Accepts an AD distinguished name, GUID, security identifier,
    SAM account name or user principal name. Supports pipeline input.

.EXAMPLE
    .\userInformations.ps1 

.NOTES
    Author: Real Shibi
    Date: 2025-06-01
    Version: 1.0
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

    Check-RequiredModules -Modules "ActiveDirectory"

}

process {

    try {
        Log-Information "Processing script userInformations..."
        Check-ExportPath -Path "C:\temp"
        # all users with all properties

        $users = Get-ADUser -Properties * -Filter * | Select-Object *
        $users | Export-Csv -Path $csvpath -NoTypeInformation -Delimiter $delimiter -Encoding $encoding
        Log-Information "Exported all users to $csvpath with encoding $encoding and delimiter $delimiter."

        # show only relevant informations
        $users | Select-Object Name, GivenName, Surname, SamAccountName, PasswordNeverExpires, PasswordExpired, LockedOut, UserPrincipalName, DisplayName, EmailAddress, Title, Department, Company, Manager, LastLogonDate, LastLogonTimestamp, PasswordLastSet, AccountExpirationDate, Enabled, WhenCreated, WhenChanged, SID | Out-GridView -Title "AD Users"

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