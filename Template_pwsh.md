# Template_pwsh.ps1

This script serves as a template for new PowerShell scripts in this repository.

## How It Works
1. Includes comment-based help as a starting point for your own descriptions and examples.
2. Provides a standardized structure with `Begin`, `Process`, and `End` blocks.
3. Starts a transcript and logs start and end times.
4. Checks whether PowerShell 7 or later is running.
5. Offers placeholders for custom logic in the `Process` block and leverages `Log-Information`/`Handle-Error` from the `shibis_pwsh_admin_module`.

## Parameters
- **csvpath** *(optional)*: Default output path `c:\temp\output.csv`.
- **encoding** *(optional)*: Predefined list of possible encodings.
- **delimiter** *(optional)*: Predefined delimiters.

## Usage
Copy and adapt this template when creating a new script.

## Notes
- Version: 1.0
