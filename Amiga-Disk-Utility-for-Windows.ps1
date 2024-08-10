<#
.SYNOPSIS
    A script to copy Amiga files from an Amiga disk to a Windows machine or vice versa

.DESCRIPTION
    This PowerShell script provides a GUI for copying Amiga files from an Amiga disk to a Windows machine or vice versa using the Greaseweazle tool.

.NOTES
    Author: Claude PETERS

.LINK
    https://github.com/Morgoth01/Amiga-Disk-Utility-for-Windows

.VERSION
v1.1

.CHANGELOG
    v1.0
        - Initial release
    v1.1
        - Both functions Amiga to Windows and Windows to Amiga are now combined in the script
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Function to open a file dialog for selecting the gw.exe file
function Get-GwExePath {
    $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $FileDialog.Filter = "Executable Files (*.exe)|*.exe|All Files (*.*)|*.*"
    $FileDialog.Title = "Select gw.exe"
    
    if ($FileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $FileDialog.FileName
    } else {
        return $null
    }
}

# Function to open a file dialog for selecting the ADF file
function Get-AdfFilePath {
    $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $FileDialog.Filter = "ADF Files (*.adf)|*.adf|All Files (*.*)|*.*"
    $FileDialog.Title = "Select ADF File"
    
    if ($FileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $FileDialog.FileName
    } else {
        return $null
    }
}

# Function to open a folder dialog for selecting the save directory
function Get-SaveDirectory {
    $FolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderDialog.Description = "Select the folder where you want to save the ADF file"
    
    if ($FolderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $FolderDialog.SelectedPath
    } else {
        return $null
    }
}

# Create the Window
$window = New-Object Windows.Window
$window.Title = "Amiga Disk Utility v1.1"
$window.SizeToContent = "WidthAndHeight"
$window.ResizeMode = "NoResize"
$window.WindowStartupLocation = "CenterScreen"

# Create a Grid Layout
$grid = New-Object Windows.Controls.Grid
$grid.Margin = "10"
$window.Content = $grid

# Define Rows and Columns
$grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition)) # Row 0
$grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition)) # Row 1
$grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition)) # Row 2
$grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition)) # Row 3
$grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition)) # Row 4
$grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition)) # Row 5
$grid.RowDefinitions.Add((New-Object Windows.Controls.RowDefinition)) # Row 6

$grid.ColumnDefinitions.Add((New-Object Windows.Controls.ColumnDefinition)) # Column 0
$grid.ColumnDefinitions.Add((New-Object Windows.Controls.ColumnDefinition)) # Column 1
$grid.ColumnDefinitions.Add((New-Object Windows.Controls.ColumnDefinition)) # Column 2

# Create Labels and TextBoxes
$labels = @("Select Function:", "Path to gw.exe:", "ADF File Path:", "ADF File Name:", "Disk Number (optional):", "Save Directory:")
$textBoxes = @()
$labelsControls = @()

for ($i = 1; $i -lt $labels.Length; $i++) {
    # Create Label
    $label = New-Object Windows.Controls.Label
    $label.Content = $labels[$i]
    $label.Margin = "5"
    $label.VerticalAlignment = "Center"
    $grid.Children.Add($label)
    $label.SetValue([Windows.Controls.Grid]::RowProperty, $i)
    $label.SetValue([Windows.Controls.Grid]::ColumnProperty, 0)
    $labelsControls += $label

    # Create TextBox with larger width
    $textBox = New-Object Windows.Controls.TextBox
    $textBox.Margin = "5"
    $textBox.Width = 300 # Set the width of the TextBox
    $grid.Children.Add($textBox)
    $textBox.SetValue([Windows.Controls.Grid]::RowProperty, $i)
    $textBox.SetValue([Windows.Controls.Grid]::ColumnProperty, 1)
    $textBoxes += $textBox
}

# Add Browse Button for gw.exe
$gwBrowseButton = New-Object Windows.Controls.Button
$gwBrowseButton.Content = "Browse"
$gwBrowseButton.Margin = "5"
$grid.Children.Add($gwBrowseButton)
$gwBrowseButton.SetValue([Windows.Controls.Grid]::RowProperty, 1)
$gwBrowseButton.SetValue([Windows.Controls.Grid]::ColumnProperty, 2)

$gwBrowseButton.Add_Click({
    $gwPath = Get-GwExePath
    if ($gwPath) {
        $textBoxes[0].Text = $gwPath
    }
})

# Add Browse Button for ADF File
$adfBrowseButton = New-Object Windows.Controls.Button
$adfBrowseButton.Content = "Browse"
$adfBrowseButton.Margin = "5"
$grid.Children.Add($adfBrowseButton)
$adfBrowseButton.SetValue([Windows.Controls.Grid]::RowProperty, 2)
$adfBrowseButton.SetValue([Windows.Controls.Grid]::ColumnProperty, 2)

$adfBrowseButton.Add_Click({
    $adfFilePath = Get-AdfFilePath
    if ($adfFilePath) {
        $textBoxes[1].Text = $adfFilePath
    }
})

# Add Browse Button for Save Directory
$saveBrowseButton = New-Object Windows.Controls.Button
$saveBrowseButton.Content = "Browse"
$saveBrowseButton.Margin = "5"
$grid.Children.Add($saveBrowseButton)
$saveBrowseButton.SetValue([Windows.Controls.Grid]::RowProperty, 5)
$saveBrowseButton.SetValue([Windows.Controls.Grid]::ColumnProperty, 2)

$saveBrowseButton.Add_Click({
    $saveDirectory = Get-SaveDirectory
    if ($saveDirectory) {
        $textBoxes[4].Text = $saveDirectory
    }
})

# Create Mode Selection Dropdown
$modeComboBox = New-Object Windows.Controls.ComboBox
$modeComboBox.Margin = "5"
$modeComboBox.Items.Add("Select Function")
$modeComboBox.Items.Add("Amiga to Windows")
$modeComboBox.Items.Add("Windows to Amiga")
$modeComboBox.SelectedIndex = 0
$grid.Children.Add($modeComboBox)
$modeComboBox.SetValue([Windows.Controls.Grid]::RowProperty, 0)
$modeComboBox.SetValue([Windows.Controls.Grid]::ColumnProperty, 1)
$modeComboBox.SetValue([Windows.Controls.Grid]::ColumnSpanProperty, 2)

# Mode Selection Event Handler
$modeComboBox.Add_SelectionChanged({
    # Clear all fields except for Path to gw.exe
    for ($i = 1; $i -lt $textBoxes.Length; $i++) {
        $textBoxes[$i].Text = ""
    }

    if ($modeComboBox.SelectedItem -eq "Amiga to Windows") {
        # Disable ADF File Path field
        $textBoxes[1].IsEnabled = $false
        $adfBrowseButton.IsEnabled = $false
        
        # Enable save directory and related fields
        $textBoxes[2].IsEnabled = $true
        $textBoxes[3].IsEnabled = $true
        $textBoxes[4].IsEnabled = $true
        $saveBrowseButton.IsEnabled = $true
    } elseif ($modeComboBox.SelectedItem -eq "Windows to Amiga") {
        # Enable ADF File Path field
        $textBoxes[1].IsEnabled = $true
        $adfBrowseButton.IsEnabled = $true
        
        # Disable save directory and related fields
        $textBoxes[2].IsEnabled = $false
        $textBoxes[3].IsEnabled = $false
        $textBoxes[4].IsEnabled = $false
        $saveBrowseButton.IsEnabled = $false
    }
})

# Create the Run Button
$runButton = New-Object Windows.Controls.Button
$runButton.Content = "Run"
$runButton.Margin = "5"
$grid.Children.Add($runButton)
$runButton.SetValue([Windows.Controls.Grid]::RowProperty, 6)
$runButton.SetValue([Windows.Controls.Grid]::ColumnSpanProperty, 2)

# Add Button Click Event
$runButton.Add_Click({
    $mode = $modeComboBox.SelectedItem
    $gwPath = $textBoxes[0].Text

    if ($mode -eq "Amiga to Windows") {
        $saveDirectory = $textBoxes[4].Text
        $adfFileName = $textBoxes[2].Text
        $diskNumber = $textBoxes[3].Text

        if ($diskNumber) {
            $fullAdfFileName = "$adfFileName" + "_Disk$diskNumber.adf"
        } else {
            $fullAdfFileName = "$adfFileName.adf"
        }

        if ($saveDirectory[-1] -ne "\") {
            $saveDirectory += "\"
        }

        $command = "`"$gwPath`" read --format=amiga.amigados $saveDirectory$fullAdfFileName --drive=A"
    } elseif ($mode -eq "Windows to Amiga") {
        $adfFilePath = $textBoxes[1].Text
        $command = "`"$gwPath`" write --format=amiga.amigados `"$adfFilePath`" --drive=A"
    } else {
        [System.Windows.MessageBox]::Show("Please select a valid function.")
        return
    }

    Start-Process "cmd.exe" -ArgumentList "/c `"$command`"" -NoNewWindow -Wait
    [System.Windows.MessageBox]::Show("Process completed successfully. Please check the console logs.")
})

# Show the Window
$window.ShowDialog()
