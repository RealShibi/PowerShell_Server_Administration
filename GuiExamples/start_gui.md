# start_gui.ps1

This script creates a Windows Forms interface that launches PowerShell scripts via buttons. Available scripts are read from a configuration file and can be managed through a dialog.

## How It Works
1. Loads the required .NET assemblies for **System.Windows.Forms** and **System.Drawing**.
2. Reads the `scripts.cfg` file in the script directory. Each entry generates a button.
3. The **Config** button opens a dialog where scripts can be added, edited, removed, and saved.
4. The form adjusts dynamically to the number of script buttons.
5. Clicking a script button launches the corresponding script in a new PowerShell instance.

## Configuration File
The `scripts.cfg` file uses the following format:
```
[ScriptName]
Path=C:\Path\to\Script.ps1
```

## Example
```powershell
./start_gui.ps1
```

## Notes
- Version: 1.0
