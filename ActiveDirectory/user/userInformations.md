# userInformations.ps1

This script retrieves detailed information about Active Directory user accounts and exports the results to a CSV file. Selected properties are also displayed in an Out-GridView window.

## How It Works
1. Starts a transcript to log the script's output.
2. Verifies that PowerShell 7 or later is running and that the **ActiveDirectory** module is available.
3. Retrieves all user objects with all properties from AD (`Get-ADUser -Properties * -Filter *`).
4. Exports the data to `$csvpath` using the specified `-Delimiter` and `-Encoding`.
5. Displays key properties in a graphical table (Out-GridView).
6. Logs start and end times as well as any errors.

## Parameters
- **csvpath** *(optional)*: Output file path. Default: `c:\temp\output.csv`.
- **encoding** *(optional)*: Encoding for the CSV file. Valid values: `UTF8`, `ASCII`, `UTF7`, `UTF32`, `Default`, `Unicode`.
- **delimiter** *(optional)*: Delimiter for the CSV file. Options: `;`, `,`, ``t`, `|`.

## Dependencies
- PowerShell 7 or later
- Module **shibis-pwsh-admin-module** (provides `Check-RequiredModules`, `Handle-Error`, `Log-Information`)
- ActiveDirectory module

## Example
```powershell
./userInformations.ps1 -csvpath "C:\temp\users.csv" -encoding UTF8 -delimiter ";"
```

## Notes
- Version: 1.0
