# inform_user_passwordexpired.ps1

This script notifies Active Directory users by email when their passwords will expire soon.

## How It Works
1. Starts a transcript and logs the start and end of the run.
2. Verifies that PowerShell 7 or later and the **ActiveDirectory** module are available.
3. Finds all users whose passwords were set more than `passwordExpireInDays` days ago and do not have "Password never expires" enabled.
4. Sends an email for each user through the provided SMTP server.
5. Outputs information about each send attempt and logs any errors.

## Parameters
- **csvpath** *(optional)*: Path for optional CSV export. Default: `c:\temp\output.csv`.
- **encoding** *(optional)*: CSV encoding (`UTF8`, `ASCII`, `UTF7`, `UTF32`, `Default`, `Unicode`).
- **delimiter** *(optional)*: CSV delimiter (`;`, `,`, ``t`, `|`).
- **smtpServer** *(required)*: Address of the SMTP server.
- **smtpPort** *(required)*: Port of the SMTP server. Default: `25`.
- **passwordExpireInDays** *(required)*: Days before expiry to start notifying users.
- **emailSubject** *(required)*: Subject line of the notification.
- **smtpmailuser** *(required)*: Sender address.

## Dependencies
- PowerShell 7 or later
- Module **shibis-pwsh-admin-module**
- ActiveDirectory module

## Example
```powershell
./inform_user_passwordexpired.ps1 -smtpServer "smtp.domain.tld" -smtpPort 587 -passwordExpireInDays 5 -emailSubject "Password expiring" -smtpmailuser "admin@domain.tld"
```

## Notes
- Version: 1.0
