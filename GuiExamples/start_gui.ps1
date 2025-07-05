# create a gui with buttons that start scripts
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# general form properties
$form = New-Object System.Windows.Forms.Form
$form.Text = "Script Manager GUI"
$form.StartPosition = "CenterScreen"

# read config file for scripts
$configFile = "$PSScriptRoot\scripts.cfg"
$scripts = @()

if (Test-Path $configFile) {
    $configContent = Get-Content $configFile
    $currentScript = @{}
    
    foreach ($line in $configContent) {
        if ($line -match "^\[(.+)\]$") {
            if ($currentScript.Count -gt 0) {
                $scripts += [PSCustomObject]$currentScript
                $currentScript = @{}
            }
            $currentScript.Name = $matches[1]
        } elseif ($line -match "^(.+)=(.+)$") {
            $currentScript[$matches[1]] = $matches[2]
        }
    }
    
    if ($currentScript.Count -gt 0) {
        $scripts += [PSCustomObject]$currentScript
    }
}

# If no scripts found, add a default entry
if ($scripts.Count -eq 0) {
    $scripts = @([PSCustomObject]@{Name = "Default Script"; Path = ""})
}

# function to save configuration
function Save-Config {
    param (
        [array]$scriptList
    )
    
    $configContent = ""
    foreach ($script in $scriptList) {
        $configContent += "[$($script.Name)]`n"
        $configContent += "Path=$($script.Path)`n`n"
    }
    
    Set-Content -Path $configFile -Value $configContent.TrimEnd()
}

# function to show configuration dialog
function Show-ConfigDialog {
    $configForm = New-Object System.Windows.Forms.Form
    $configForm.Text = "Script Configuration Manager"
    $configForm.Size = New-Object System.Drawing.Size(600, 400)
    $configForm.StartPosition = "CenterParent"
    
    # Scripts ListView
    $listView = New-Object System.Windows.Forms.ListView
    $listView.Location = New-Object System.Drawing.Point(10, 10)
    $listView.Size = New-Object System.Drawing.Size(460, 200)
    $listView.View = [System.Windows.Forms.View]::Details
    $listView.FullRowSelect = $true
    $listView.GridLines = $true
    
    $listView.Columns.Add("Script Name", 200) | Out-Null
    $listView.Columns.Add("Path", 260) | Out-Null
    
    # Populate ListView
    foreach ($script in $scripts) {
        $item = New-Object System.Windows.Forms.ListViewItem($script.Name)
        $item.SubItems.Add($script.Path)
        $item.Tag = $script
        $listView.Items.Add($item) | Out-Null
    }
    
    # Add Button
    $addButton = New-Object System.Windows.Forms.Button
    $addButton.Text = "Add Script"
    $addButton.Location = New-Object System.Drawing.Point(480, 10)
    $addButton.Size = New-Object System.Drawing.Size(100, 30)
    $addButton.Add_Click({
        $newScript = [PSCustomObject]@{Name = "New Script"; Path = ""}
        $item = New-Object System.Windows.Forms.ListViewItem($newScript.Name)
        $item.SubItems.Add($newScript.Path)
        $item.Tag = $newScript
        $listView.Items.Add($item) | Out-Null
        $listView.SelectedItems.Clear()
        $item.Selected = $true
    })
    
    # Edit Button
    $editButton = New-Object System.Windows.Forms.Button
    $editButton.Text = "Edit Script"
    $editButton.Location = New-Object System.Drawing.Point(480, 50)
    $editButton.Size = New-Object System.Drawing.Size(100, 30)
    $editButton.Add_Click({
        if ($listView.SelectedItems.Count -eq 1) {
            $selectedItem = $listView.SelectedItems[0]
            $script = $selectedItem.Tag
            
            $editForm = New-Object System.Windows.Forms.Form
            $editForm.Text = "Edit Script"
            $editForm.Size = New-Object System.Drawing.Size(450, 200)
            $editForm.StartPosition = "CenterParent"
            
            # Name
            $nameLabel = New-Object System.Windows.Forms.Label
            $nameLabel.Text = "Script Name:"
            $nameLabel.Location = New-Object System.Drawing.Point(10, 20)
            $nameLabel.Size = New-Object System.Drawing.Size(80, 20)
            
            $nameTextBox = New-Object System.Windows.Forms.TextBox
            $nameTextBox.Location = New-Object System.Drawing.Point(100, 20)
            $nameTextBox.Size = New-Object System.Drawing.Size(320, 20)
            $nameTextBox.Text = $script.Name
            
            # Path
            $pathLabel = New-Object System.Windows.Forms.Label
            $pathLabel.Text = "Script Path:"
            $pathLabel.Location = New-Object System.Drawing.Point(10, 60)
            $pathLabel.Size = New-Object System.Drawing.Size(80, 20)
            
            $pathTextBox = New-Object System.Windows.Forms.TextBox
            $pathTextBox.Location = New-Object System.Drawing.Point(100, 60)
            $pathTextBox.Size = New-Object System.Drawing.Size(250, 20)
            $pathTextBox.Text = $script.Path
            
            # Browse
            $browseButton = New-Object System.Windows.Forms.Button
            $browseButton.Text = "Browse"
            $browseButton.Location = New-Object System.Drawing.Point(360, 58)
            $browseButton.Size = New-Object System.Drawing.Size(60, 25)
            $browseButton.Add_Click({
                $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
                $openFileDialog.Filter = "PowerShell Scripts (*.ps1)|*.ps1|All Files (*.*)|*.*"
                $openFileDialog.Title = "Select PowerShell Script"
                if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                    $pathTextBox.Text = $openFileDialog.FileName
                }
            })
            
            # Save
            $saveEditButton = New-Object System.Windows.Forms.Button
            $saveEditButton.Text = "Save"
            $saveEditButton.Location = New-Object System.Drawing.Point(250, 110)
            $saveEditButton.Size = New-Object System.Drawing.Size(80, 30)
            $saveEditButton.Add_Click({
                $script.Name = $nameTextBox.Text
                $script.Path = $pathTextBox.Text
                $selectedItem.Text = $script.Name
                $selectedItem.SubItems[1].Text = $script.Path
                $editForm.Close()
            })
            
            # Cancel
            $cancelEditButton = New-Object System.Windows.Forms.Button
            $cancelEditButton.Text = "Cancel"
            $cancelEditButton.Location = New-Object System.Drawing.Point(340, 110)
            $cancelEditButton.Size = New-Object System.Drawing.Size(80, 30)
            $cancelEditButton.Add_Click({ $editForm.Close() })
            
            $editForm.Controls.AddRange(@($nameLabel, $nameTextBox, $pathLabel, $pathTextBox, $browseButton, $saveEditButton, $cancelEditButton))
            $editForm.ShowDialog() | Out-Null
        }
    })
    
    # Remove Button
    $removeButton = New-Object System.Windows.Forms.Button
    $removeButton.Text = "Remove Script"
    $removeButton.Location = New-Object System.Drawing.Point(480, 90)
    $removeButton.Size = New-Object System.Drawing.Size(100, 30)
    $removeButton.Add_Click({
        if ($listView.SelectedItems.Count -eq 1) {
            $listView.Items.Remove($listView.SelectedItems[0])
        }
    })
    
    # Save All Button
    $saveAllButton = New-Object System.Windows.Forms.Button
    $saveAllButton.Text = "Save & Close"
    $saveAllButton.Location = New-Object System.Drawing.Point(400, 320)
    $saveAllButton.Size = New-Object System.Drawing.Size(100, 30)
    $saveAllButton.Add_Click({
        $newScripts = @()
        foreach ($item in $listView.Items) {
            $newScripts += $item.Tag
        }
        Save-Config -scriptList $newScripts
        $script:scripts = $newScripts
        $configForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $configForm.Close()
    })
    
    # Cancel Button
    $cancelAllButton = New-Object System.Windows.Forms.Button
    $cancelAllButton.Text = "Cancel"
    $cancelAllButton.Location = New-Object System.Drawing.Point(510, 320)
    $cancelAllButton.Size = New-Object System.Drawing.Size(80, 30)
    $cancelAllButton.Add_Click({ 
        $configForm.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $configForm.Close() 
    })
    
    $configForm.Controls.AddRange(@($listView, $addButton, $editButton, $removeButton, $saveAllButton, $cancelAllButton))
    
    return $configForm.ShowDialog()
}




# function to create a button
function New-ScriptButton {
    param (
        [string]$text,
        [System.Drawing.Size]$size,
        [System.Drawing.Point]$location,
        [scriptblock]$clickAction
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Size = $size
    $button.Location = $location
    $button.Add_Click($clickAction)
    return $button
}

# function to refresh the form with script buttons
function Update-FormButtons {
    # Clear existing script buttons (keep only config button)
    $buttonsToRemove = @()
    foreach ($control in $form.Controls) {
        if ($control -is [System.Windows.Forms.Button] -and $control.Text -ne "Config") {
            $buttonsToRemove += $control
        }
    }
    foreach ($button in $buttonsToRemove) {
        $form.Controls.Remove($button)
    }
    
    # Calculate layout
    $buttonWidth = 120
    $buttonHeight = 35
    $buttonSpacing = 10
    $buttonsPerRow = 5
    $startY = 60  # Start below config button
    $startX = 10
    
    # Create script buttons
    for ($i = 0; $i -lt $scripts.Count; $i++) {
        $script = $scripts[$i]
        $row = [Math]::Floor($i / $buttonsPerRow)
        $col = $i % $buttonsPerRow
        
        $x = $startX + ($col * ($buttonWidth + $buttonSpacing))
        $y = $startY + ($row * ($buttonHeight + $buttonSpacing))
        
        $scriptButton = New-ScriptButton -text $script.Name `
            -size (New-Object System.Drawing.Size($buttonWidth, $buttonHeight)) `
            -location (New-Object System.Drawing.Point($x, $y)) `
            -clickAction ([scriptblock]::Create(@"
                if (Test-Path '$($script.Path)') {
                    Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', '$($script.Path)')
                } else {
                    [System.Windows.Forms.MessageBox]::Show('Script not found: $($script.Path)', 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
"@))
        
        $form.Controls.Add($scriptButton)
    }
    
    # Calculate form size based on number of buttons
    $rows = [Math]::Ceiling($scripts.Count / $buttonsPerRow)
    $formWidth = ($buttonsPerRow * ($buttonWidth + $buttonSpacing)) + $buttonSpacing + 20
    $formHeight = $startY + ($rows * ($buttonHeight + $buttonSpacing)) + 50
    
    # Minimum form size
    if ($formWidth -lt 300) { $formWidth = 300 }
    if ($formHeight -lt 150) { $formHeight = 150 }
    
    $form.Size = New-Object System.Drawing.Size($formWidth, $formHeight)
}

# Create config button (top-left corner)
$configButton = New-ScriptButton -text "Config" `
    -size (New-Object System.Drawing.Size(80, 30)) `
    -location (New-Object System.Drawing.Point(10, 10)) `
    -clickAction {
        $result = Show-ConfigDialog
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            Update-FormButtons
        }
    }



# form add controls and event handlers
$form.Controls.Add($configButton)

# Initialize the form with script buttons
Update-FormButtons

$form.Add_Shown({$form.Activate()})
$form.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
        $form.Close()
    }
})
$form.Add_FormClosing({
    $form.Dispose()
})
$form.ShowDialog() | Out-Null