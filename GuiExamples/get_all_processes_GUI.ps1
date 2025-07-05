# get all processes
$processes = Get-Process
# filter processes by name
$processes | out-gridview -Title "All Processes" -PassThru | ForEach-Object {
    # display process information
    Write-Host "Process Name: $($_.Name), ID: $($_.Id), CPU: $($_.CPU)"
}