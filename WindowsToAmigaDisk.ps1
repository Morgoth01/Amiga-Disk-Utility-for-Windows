# Description:
# This PowerShell script provides a GUI for writing ADF files from a Windows machine to an Amiga disk using the Greaseweazle tool. 

# Script created by Claude Peters
# https://github.com/Morgoth01/Amiga-Disk-Utility-for-Windows

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

# Create the Window
$window = New-Object Windows.Window
$window.Title = "Amiga to Windows Disk Utility"
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

$grid.ColumnDefinitions.Add((New-Object Windows.Controls.ColumnDefinition)) # Column 0
$grid.ColumnDefinitions.Add((New-Object Windows.Controls.ColumnDefinition)) # Column 1
$grid.ColumnDefinitions.Add((New-Object Windows.Controls.ColumnDefinition)) # Column 2

# Create Labels and TextBoxes
$labels = @("Path to gw.exe:", "ADF File Path:")
$textBoxes = @()

for ($i = 0; $i -lt $labels.Length; $i++) {
    # Create Label
    $label = New-Object Windows.Controls.Label
    $label.Content = $labels[$i]
    $label.Margin = "5"
    $label.VerticalAlignment = "Center"
    $grid.Children.Add($label)
    $label.SetValue([Windows.Controls.Grid]::RowProperty, $i)
    $label.SetValue([Windows.Controls.Grid]::ColumnProperty, 0)

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
$gwBrowseButton.SetValue([Windows.Controls.Grid]::RowProperty, 0)
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
$adfBrowseButton.SetValue([Windows.Controls.Grid]::RowProperty, 1)
$adfBrowseButton.SetValue([Windows.Controls.Grid]::ColumnProperty, 2)

$adfBrowseButton.Add_Click({
    $adfFilePath = Get-AdfFilePath
    if ($adfFilePath) {
        $textBoxes[1].Text = $adfFilePath
    }
})

# Create the Run Button
$runButton = New-Object Windows.Controls.Button
$runButton.Content = "Run"
$runButton.Margin = "5"
$grid.Children.Add($runButton)
$runButton.SetValue([Windows.Controls.Grid]::RowProperty, 2)
$runButton.SetValue([Windows.Controls.Grid]::ColumnSpanProperty, 2)

# Add Button Click Event
$runButton.Add_Click({
    $gwPath = $textBoxes[0].Text
    $adfFilePath = $textBoxes[1].Text

    $command = "$gwPath write --format=amiga.amigados `"$adfFilePath`" --drive=A"

    Start-Process "cmd.exe" -ArgumentList "/c `"$command`"" -NoNewWindow -Wait
    [System.Windows.MessageBox]::Show("Process completed successfully. Please check the console logs.")
})

# Show the Window
$window.ShowDialog()
