# shibis-pwsh-admin-module

This PowerShell module provides shared helper functions used by all scripts in the repository. It handles logging, error management, success feedback, prerequisite checks, and export path validation.

## Exported Functions

### Check-RequiredModules
Verifies that one or more PowerShell modules are installed. Writes an error for each missing module.

**Parameters:**
- **Modules** *(string[])*: Names of the modules to check.

### Log-Information
Appends a timestamped message to a daily log file under the log directory.

**Parameters:**
- **Message** *(string)*: The text to log.
- **LogDirectory** *(string, optional)*: Directory for log files. Default: `C:\shibilogs`.

Log files are named `shibis_log_YYYY-MM-DD.txt` (e.g., `shibis_log_2025-05-05.txt`). The directory is created automatically if it does not exist.

### Handle-Error
Logs the error message via `Log-Information` and then throws it so the calling script can catch or terminate.

**Parameters:**
- **ErrorMessage** *(string)*: The error text.

### Handle-Success
Writes a green-coloured success message to the console.

**Parameters:**
- **SuccessMessage** *(string)*: The success text.

### Check-ExportPath
Ensures that the target directory exists, creating it if necessary.

**Parameters:**
- **Path** *(string, optional)*: Directory to verify. Default: `C:\temp`.

## Module Manifest
The accompanying `shibis-pwsh-admin-module.psd1` defines module metadata (version `1.0.0.0`, author **Real Shibi**) and exports all functions, cmdlets, variables, and aliases.

## Prerequisites
- PowerShell 7 or later (the module aborts loading on older versions).

## Installation
```powershell
Install-Module -Name shibis-pwsh-admin-module
```

Or import directly from the repository:
```powershell
Import-Module .\Module\shibis-pwsh-admin-module\shibis-pwsh-admin-module.psm1
```

## Notes
- Version: 1.0
