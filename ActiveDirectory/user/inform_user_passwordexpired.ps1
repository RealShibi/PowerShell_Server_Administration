<#
.SYNOPSIS
    Sends email notifications to AD users whose passwords will expire soon.

.DESCRIPTION
    This script queries Active Directory for users whose passwords were last set more than the specified number of days ago and whose passwords are not set to never expire. It then sends an email to each user with a valid email address, notifying them that their password will expire in the configured number of days. The script supports configurable CSV path, encoding, delimiter, SMTP server, port, expiration threshold, email subject, and sender address.

.PARAMETER csvpath
    (Optional) Path to the CSV file where results or logs can be saved. Default is "C:\temp\output.csv".

.PARAMETER encoding
    (Optional) Encoding for CSV or log output. Valid values: "UTF8", "ASCII", "UTF7", "UTF32", "Default", "Unicode". Default is "UTF8".

.PARAMETER delimiter
    (Optional) Delimiter used for CSV output. Valid values: ";", ",", "`t", "|". Default is ";".

.PARAMETER smtpServer
    (Required) Hostname or IP address of the SMTP server to use for sending emails.

.PARAMETER smtpPort
    (Required) Port number of the SMTP server (e.g., 25, 587). Default is 25.

.PARAMETER passwordExpireInDays
    (Required) Number of days before expiration to warn users. For example, 7 will notify users whose passwords were last set more than 7 days ago and can still expire.

.PARAMETER emailSubject
    (Required) Subject line for the outgoing emails. Default is "Password Expiration Notification".

.PARAMETER smtpmailuser
    (Required) Email address to use as the sender in the "From" field.

.EXAMPLE
    PS C:\> .\Notify-PasswordExpiration.ps1 `
        -smtpServer "smtp.contoso.com" `
        -smtpPort 587 `
        -passwordExpireInDays 5 `
        -emailSubject "Your Password Is About to Expire" `
        -smtpmailuser "no-reply@contoso.com"

    This example finds all AD users whose passwords were last set more than 5 days ago and sends each a custom email with the subject "Your Password Is About to Expire".

.EXAMPLE
    PS C:\> .\Notify-PasswordExpiration.ps1 `
        -csvpath "D:\Logs\PasswordWarnings.csv" `
        -encoding "Unicode" `
        -delimiter "," `
        -smtpServer "mail.example.com" `
        -smtpPort 25 `
        -passwordExpireInDays 10 `
        -emailSubject "Password Warning" `
        -smtpmailuser "admin@example.com"

    In this example, the script also writes output to "D:\Logs\PasswordWarnings.csv" in Unicode format using a comma delimiter.

.NOTES
    Author: Real Shibi
    Date: 2025-06-01
    Version: 1.0

    Prerequisites:
        • PowerShell 7 or higher
        • ActiveDirectory PowerShell module (validated via check-RequiredModules)

    Workflow:
        1. Start-Transcript begins logging script output.
        2. Verify that PowerShell version is 7 or higher.
        3. Retrieve AD users filtered by PasswordLastSet and PasswordNeverExpires.
        4. Send email to each user with a valid email address.
        5. Stop-Transcript and exit.
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
    [string]$delimiter = ";",

    # smtp server
    [Parameter(Mandatory = $true)]
    [string]$smtpServer,

    # smtp port
    [Parameter(Mandatory = $true)]
    [int]$smtpPort = 25,

    # password will expire in days
    [Parameter(Mandatory = $true)]
    [int]$passwordExpireInDays = 7,
    # email subject
    [Parameter(Mandatory = $true)]
    [string]$emailSubject = "Password Expiration Notification",

    # smtp user
    [Parameter(Mandatory = $true)]
    [string]$smtpmailuser
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
    check-RequiredModules -Modules "ActiveDirectory"
}

process {

    try {
        Log-Information "Processing inform users password will be expired..."
        
        $users = Get-ADUser -Filter * -Properties PasswordLastSet, PasswordNeverExpires | Where-Object { $_.PasswordLastSet -lt (Get-Date).AddDays(-$passwordExpireInDays) -and $_.PasswordNeverExpires -eq $false }
        if ($users.Count -eq 0) {
            Write-Information "No users found with passwords that will expire in $passwordExpireInDays days."
            return
        }
        $users | ForEach-Object {
            $user = $_
            $email = $user.EmailAddress
            if ($email) {
                $body = "Dear $($user.Name),`n`nYour password will expire in $passwordExpireInDays days. Please change your password as soon as possible.`n`nBest regards,`nIT Team"
                Send-MailMessage -To $email -From $smtpmailuser -Subject $emailSubject -Body $body -SmtpServer $smtpServer -Port $smtpPort 
                Write-Information "Email sent to $($user.Name) at $email."
            } else {
                Write-Information "No email address found for $($user.Name)."
            }
        }

                

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