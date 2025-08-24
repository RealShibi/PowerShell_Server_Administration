# get_all_processes_GUI.ps1

This short example script displays all running processes in an Out-GridView window and prints additional information for any selected process.

## How It Works
1. Retrieves currently running processes with `Get-Process`.
2. Opens an Out-GridView window listing the processes. Using `-PassThru`, one or more processes can be selected.
3. For each selected process, the console outputs its name, ID, and CPU time.

## Example
```powershell
./get_all_processes_GUI.ps1
```

## Notes
- Version: 1.0
