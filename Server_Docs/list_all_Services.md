# list_all_Services.ps1

This script exports information about all services on the local system to a CSV file.

## How It Works
1. Starts a transcript and logs start and end times.
2. Checks whether the custom `shibis_pwsh_admin_module` is loaded.
3. Retrieves all services via `Get-Service` and selects relevant properties.
4. Exports the data to a CSV file using the `csvpath`, `encoding`, and `delimiter` parameters.
5. Uses `Log-Information` and `Handle-Success` for logging.

## Parameters
- **csvpath** *(optional)*: Location of the CSV file. Default: `c:\temp\output.csv`.
- **encoding** *(optional)*: Encoding of the CSV file. Default: `UTF8`.
- **delimiter** *(optional)*: Delimiter used in the CSV file. Default: `;`.

## Dependencies
- Module **shibis-pwsh-admin-module**
- PowerShell 7 or later

## Example
```powershell
./list_all_Services.ps1 -csvpath "C:\temp\services.csv"
```

## Notes
- Version: 1.0
