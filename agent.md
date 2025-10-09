# Codex Agent Guide

This repository hosts reusable PowerShell 7 tooling for Windows Server administration. Scripts lean on a shared helper module for logging, guardrails, and user feedback. Use this guide while building or updating automation with Codex.

## Repository Map
- `Module/shibis-pwsh-admin-module` – Core helper module; import this before running any scripts.
- `ActiveDirectory/user` – Scripts that query or notify AD users (`userInformations.ps1`, `inform_user_passwordexpired.ps1`).
- `Server_Cleaning` – Log grooming automation (`Log_Cleaning.ps1`).
- `Server_Docs` – Server inventory / maintenance scripts (`list_all_Services.ps1`, `scheduled_task_management.ps1`).
- `GuiExamples` – Out-GridView based demos and a menu launcher (`start_gui.ps1`).
- `Tests` – Pester scaffolding for the module (currently placeholder expectations).
- `Template_pwsh.ps1` & `Template_pwsh.md` – Canonical starting point for new scripts.

## Module Essentials (`shibis-pwsh-admin-module.psm1`)
- `Check-RequiredModules` checks that named modules are installed.
- `Log-Information` appends timestamped entries to `C:\shibilogs\shibis_log_<date>.txt`, creating the folder on demand.
- `Handle-Error` logs and throws; build script error paths around it.
- `Handle-Success` writes green success messages for operators.
- `Check-ExportPath` makes sure CSV targets (default `C:\temp`) exist.
- The module aborts load on PowerShell version < 7 and announces successful import.

Always import the module (`Import-Module .\Module\shibis-pwsh-admin-module\shibis-pwsh-admin-module.psm1`) before running scripts or invoking helper functions.

## Script Conventions
- Target PowerShell 7+: every script validates `$PSVersionTable.PSVersion.Major -ge 7`.
- Begin blocks start transcripts (`Start-Transcript`) with a timestamped log file (`<script>.LastRun.log`).
- Common parameters: `csvpath`, `encoding` (`ValidateSet`), and `delimiter`; keep defaults consistent unless a script has special needs.
- Logging: use `Log-Information` for progress, `Handle-Success` for positive outcomes, `Handle-Error` for failures.
- Exit paths call `Stop-Transcript` and `exit 0` to signal clean termination.
- AD scripts must call `Check-RequiredModules -Modules "ActiveDirectory"` before invoking `Get-ADUser`.
- GUI helpers rely on `Out-GridView`; they require a desktop or remoting session with GUI support.

## Adding or Updating Scripts
1. Copy `Template_pwsh.ps1` and adjust comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, etc.).
2. Keep the structured `begin/process/end` layout with transcripts, logging, and PS 7 guard.
3. Invoke `Check-ExportPath` for any file output directories.
4. For new dependencies, extend `Check-RequiredModules` calls instead of ad-hoc checks.
5. Prefer exporting data with `Export-Csv` using the shared parameter set to preserve automation expectations.
6. Update or add a matching Markdown explainer in the relevant folder (`*.md`) documenting usage and prerequisites.

## Scheduled Task Automation Highlights
`Server_Docs/scheduled_task_management.ps1` supports `-Mode Export|Import|Validate`, scoping by `-TaskName`/`-TaskPath`, and includes validation helpers (`Get-NormalizedTaskPath`, `Resolve-ScheduledTasks`). Respect the `ShouldProcess` pattern already implemented when extending logic.

## Testing
- Tests live in `Tests/shibis_pwsh_admin_module.Tests.ps1` and are structured for Pester v5.
- The current tests are placeholders. When adding real functionality, replace the dummy expectations with concrete assertions (e.g., verify log file creation or module error handling).
- Run tests with `Invoke-Pester -Script .\Tests\shibis_pwsh_admin_module.Tests.ps1`.

## Known External Requirements
- ActiveDirectory module (`RSAT-AD-PowerShell`) for AD scripts.
- SMTP access for `inform_user_passwordexpired.ps1` (`Send-MailMessage`).
- Scheduled task cmdlets require local admin / appropriate rights.
- `Out-GridView` needs the Windows PowerShell ISE add-on or Windows desktop components.

## Working With Codex
- Use `pwsh` commands in the repo root (`c:\_shibiadmin\PowerShell_Server_Administration`).
- Favor `Get-ChildItem`, `Get-Content`, or `rg` for discovery; avoid editing outside the workspace root.
- Keep changes ASCII unless the target file already uses other encodings.
- When touching multiple scripts, stage modular commits logically (though commits are not created by Codex directly).

## Operational Notes
- Central logs accumulate in `C:\shibilogs`; there is no cleanup routine—avoid generating noisy logs during tests.
- Many scripts export CSVs to `C:\temp`; ensure environments running the automation have permissions and free space.
- GUI-oriented scripts are examples; production automation should favor non-interactive patterns unless an operator console is expected.

Refer back to this guide before modifying scripts so new work stays consistent with the established patterns.
