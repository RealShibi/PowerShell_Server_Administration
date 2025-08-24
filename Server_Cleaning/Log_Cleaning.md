# Log_Cleaning.ps1

This script deletes log files with a specific extension that are older than a defined number of days. Information about deleted files can be exported to a CSV file.

## How It Works
1. Starts a transcript and records start and end times.
2. Checks whether the provided path exists and whether it is a file or directory.
3. Recursively searches for files with the given extension whose `LastWriteTime` is older than the threshold.
4. Deletes the old files and collects details (name, path, last modified time).
5. Optionally exports the list of deleted files as a CSV (`csvpath`, `encoding`, `delimiter`).

## Parameters
- **Path** *(required)*: File or directory to clean.
- **Days** *(required)*: Age in days beyond which files are removed.
- **FileEnding** *(required)*: File extension to delete.
- **csvpath** *(optional)*: Output path for the CSV file. Default: `output.csv` in the script directory.
- **encoding** *(optional)*: Encoding for the CSV file.
- **delimiter** *(optional)*: Delimiter for the CSV file.

## Dependencies
- PowerShell 7 or later
- Module **shibis-pwsh-admin-module** (e.g., `Handle-Error`, `Log-Information`)

## Example
```powershell
./Log_Cleaning.ps1 -Path "C:\Logs" -Days 30 -FileEnding "log"
```

## Notes
- Version: 1.0
