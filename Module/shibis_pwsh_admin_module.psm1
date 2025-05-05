
function Check-RequiredModules {
    param (
        [string[]]$Modules
    )
    
    foreach ($module in $Modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Error "Required module '$module' is not installed."
        }
    }
}

function Log-Information {
    param (
        [string]$Message,
        [string]$LogFile = "C:\logs\shibis_log.txt"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogFile -Append
}

function Handle-Error {
    param (
        [string]$ErrorMessage
    )
    
    Log-Information -Message $ErrorMessage
    throw $ErrorMessage
}

function Handle-Success {
    param (
        [string]$SuccessMessage
    )
    # color of the message will be green
    Write-Host $SuccessMessage -ForegroundColor Green
}

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Handle-Error -ErrorMessage "PowerShell version 7.0 or higher is required."
}
else {
    Handle-Success "PowerShell version should be good."
}

# Exported functions
Export-ModuleMember -Function Check-RequiredModules, Log-Information, Handle-Error