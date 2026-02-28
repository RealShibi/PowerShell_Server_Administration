# scheduled_task_management.ps1

This script manages Windows Scheduled Tasks with export, import, and validation capabilities. It provides an automation wrapper for backing up task definitions to XML, restoring them, and verifying that tasks are running successfully.

## How It Works
1. Starts a transcript and logs start and end times.
2. Checks whether the **shibis-pwsh-admin-module** is imported.
3. Normalizes the provided `TaskPath` and resolves matching scheduled tasks.
4. Depending on the selected `Mode`:
   - **Export**: exports each matching task as an XML file to `ExportDirectory`, preserving the task folder hierarchy.
   - **Import**: reads XML task definitions from `ImportPath` files or directories and registers them via `Register-ScheduledTask`. Supports `-Force` to overwrite existing tasks and honors `ShouldProcess`.
   - **Validate**: retrieves task run information and checks that each task ran successfully within `ValidationThresholdMinutes`. Reports healthy or failed tasks and throws on any failure.
5. Logs progress with `Log-Information` and reports results with `Handle-Success` or `Handle-Error`.

## Parameters
- **Mode** *(required)*: Action to perform — `Export`, `Import`, or `Validate`.
- **TaskName** *(optional)*: One or more task names to scope the action. When omitted, all tasks in scope are processed.
- **TaskPath** *(optional)*: Limits operations to a specific task folder. Default: `\` (root).
- **ExportDirectory** *(optional)*: Destination folder for exported XML files. Default: `C:\Temp\ScheduledTasks`.
- **ImportPath** *(optional, required for Import)*: One or more XML files or directories containing task definitions.
- **ValidationThresholdMinutes** *(optional)*: Maximum minutes since the last successful run during validation. Default: `60`.
- **IncludeDisabled** *(optional)*: Include disabled tasks during validation.
- **Force** *(optional)*: Overwrite existing tasks during import.

## Dependencies
- PowerShell 7 or later
- Module **shibis-pwsh-admin-module**

## Examples
```powershell
# Export all scheduled tasks to a backup folder
.\scheduled_task_management.ps1 -Mode Export -ExportDirectory C:\Backups\Tasks

# Import tasks from a backup folder, overwriting existing definitions
.\scheduled_task_management.ps1 -Mode Import -ImportPath C:\Backups\Tasks -Force

# Validate that a specific task ran successfully within the last two hours
.\scheduled_task_management.ps1 -Mode Validate -TaskName "Nightly Backup" -ValidationThresholdMinutes 120
```

## Notes
- Version: 1.0
