# shibis_pwsh_admin_module.Tests.ps1

This Pester test script verifies core functions of the `shibis_pwsh_admin_module`.

## How It Works
1. Imports the module under test from `..\Module\shibis_pwsh_admin_module.psm1`.
2. Contains multiple `Describe` blocks with tests:
   - **Required Modules**: checks that necessary modules are available.
   - **Logging**: tests `Log-Information` by writing to and reading from a log file.
   - **Error Handling**: expects a function to throw an error.
   - **Parameter Validation**: ensures `Validate-Parameters` accepts valid parameters.
   - **Function Output**: confirms `Process-Csv` returns results for valid input.

## Execution
```powershell
Invoke-Pester -Script ./shibis_pwsh_admin_module.Tests.ps1
```

## Notes
- Version: 1.0
