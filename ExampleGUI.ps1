# Load assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


function Invoke-Test {
    Start-Sleep -Milliseconds 20
}
function Invoke-Test2 {
    Start-Sleep -Milliseconds 20
}

function Invoke-Sanity-Checks {
    param (
        [System.Windows.Forms.TextBox]$textBox
    )
    $subProgressBar.Value = 1
    $subProgressBarStatus.Text = "Checking powershell version"
    $textBox.AppendText("Checking powershell version`r`n")
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        $textBox.AppendText("Your powershell is too old!`r`n")
    }
    $subProgressBar.Value = 50
    $subProgressBarStatus.Text = "Checking winget"
    $textBox.AppendText("Checking winget`r`n")
    # Check if winget is installed
    try {
        $wingetCheck = Get-Command winget -ErrorAction Stop
    }
    catch {
        $resultBox.AppendText = "Winget has blocking issues!`r`n"
    }
    $subProgressBar.Value = 100
    $subProgressBarStatus.Text = "Done`r`n"
}

function Invoke-Base-Updates {
    param(
        [System.Windows.Forms.TextBox]$textBox,
        [System.Windows.Forms.ProgressBar]$subProgressBar,
        [System.Windows.Forms.Label]$subProgressBarStatus
    )
    $subProgressBar.Value = 1
    $subProgressBarStatus.Text = "Running winget source update"
    $textBox.AppendText("Running winget source update`r`n")
    winget source update
    $subProgressBar.Value = 50
    $subProgressBarStatus.Text = "Running winget updates"
    $textBox.AppendText("Running winget updates`r`n")
    winget update --all --silent
    $subProgressBar.Value = 100
    $subProgressBarStatus.Text = "Done`r`n"
}
function Initialize-Form {
    param(
        [hashtable] $ObjectDimensions = @{ Width=1024; Height=768 },
        [System.Windows.Forms.Form]$Form,
        [string]$Text = "My Form"
    )
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Text
    $form.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)
    $form.StartPosition = "CenterScreen"
    return $form
}

function Initialize-Control {
    param(
        [hashtable] $ObjectDimensions = @{ Width=200; Height=20 },
        [PSCustomObject]$CurrentLocation = @{ X=50; Y=70 },
        [System.Windows.Forms.Form]$Form,
        [string]$ControlType,
        [string]$Text = ""
    )
    switch ($ControlType) {
        "ProgressBar" {
            $control = New-Object System.Windows.Forms.ProgressBar
            $control.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)
            $control.Value = 1
        }
        "TextBox" {
            $control = New-Object System.Windows.Forms.TextBox
            $control.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)
            $control.Readonly = $true
        }
        "SpinnerLabel" {
            $control = New-Object System.Windows.Forms.Label
            $control.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)
            $control.Text = $Text
        }
        "Log" {
            $control = New-Object System.Windows.Forms.TextBox
            $control.Size = New-Object System.Drawing.Size(200, 100)
            $control.Multiline = $true
            $control.ScrollBars = 'Vertical'
            $control.Readonly = $true   
        }
    }
    $control.Location = New-Object System.Drawing.Point($CurrentLocation.X, $CurrentLocation.Y)
    $CurrentLocation.X = 10
    $CurrentLocation.Y += $ObjectDimensions.Height

    return $control
}

function Initialize-PictureBox {
    param(
        [hashtable] $ObjectDimensions = @{ Width=60; Height=30 },
        [PSCustomObject]$CurrentLocation,
        [System.Windows.Forms.Form]$Form,
        [string]$Text,
        $url = "https://trustbiztech.com/public/logos/biztech.png"
    )
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $webClient = New-Object System.Net.WebClient
    $imagePath = [System.IO.Path]::GetTempFileName()
    $webClient.DownloadFile($url, $imagePath)
    $pictureBox.Image = [System.Drawing.Image]::Fromfile($imagePath)
    $pictureBox.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)  # Change this to your desired size
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $pictureBox.Location = New-Object System.Drawing.Point(($CurrentLocation.X - $pictureBox.Width - 20),($CurrentLocation.Y - $pictureBox.Height - 40)) 

    return $pictureBox
}

function Initialize-Button {
    param(
        [hashtable] $ObjectDimensions = @{ Width=100; Height=20 },
        [PSCustomObject]$CurrentLocation = @{ X=100; Y=35 },
        [System.Windows.Forms.Form]$Form,
        [string]$Text = "Click me"
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point($CurrentLocation.X, $CurrentLocation.Y)
    $button.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)
    $button.Text = $Text
    $CurrentLocation.X = 10
    $CurrentLocation.Y += $ObjectDimensions.Height
    
    return $button
}

function Invoke-Spinner {
    param(
        $spinnerLabel,
        $currentStep
    )
    $spinnerChars = @('/', '|', '\', '-')
    $spinnerLabel.Text = $spinnerChars[$currentStep % $spinnerChars.Length]

}

function Invoke-ProgressBar {
    param(
        $progressBar,
        $currentStep
    )
    $progressBar.Value = $currentStep
}

$location = New-Object -TypeName psobject -Property @{ X=10; Y=10 }
# Create form and controls
$form = Initialize-Form -CurrentLocation $location
$firstButton = Initialize-Button -CurrentLocation $location -Text "Button1"
$secondButton = Initialize-Button -CurrentLocation $location -Text "Button2"
$overallProgressBar = Initialize-Control -ControlType "ProgressBar" -CurrentLocation $location -Form $form
$progressBar = Initialize-Control -ControlType "ProgressBar" -CurrentLocation $location -Form $form
$textBox = Initialize-Control -ControlType "TextBox" -CurrentLocation $location -Form $form
$logBox = Initialize-Control -ControlType "Log" -CurrentLocation $location -Form $form
#special ui
$location.X = 10
$location.Y = $form.Height-60
$spinnerLabel = Initialize-Control -ControlType "SpinnerLabel" -CurrentLocation $location -Form $form -Text "-"
$location.X = $form.Width
$location.Y = $form.Height
$pictureBox = Initialize-PictureBox -CurrentLocation $location

#now we add the commands for the buttons
$firstButton.Add_Click({
    $progressBar.Value = 0
    $textBox.Text = "Running first button!"
    for ($i = 0; $i -le 100; $i++) {
        Invoke-ProgressBar -progressBar $progressBar -textBox $textBox -currentStep $i
        Invoke-Spinner -spinnerLabel $spinnerLabel -textBox $textBox -currentStep $i
        Invoke-Test
        switch($i){
            25 {
                $textBox.Text = "$i % Done"
                Start-Sleep -Milliseconds 20
            }
            50 {
                $textBox.Text = "$i % Done"
                Start-Sleep -Milliseconds 20
            }
            75 {
                $textBox.Text = "$i % Done"
                Start-Sleep -Milliseconds 20
            }
        }
    }
    $textBox.Text = "Done running first button!"
    $logBox.AppendText("Button 1 Completed`r`n")
    $overallProgressBar.Value += 10
    $this.Enabled = $false
}) 
$secondButton.Add_Click({
    $progressBar.Value = 0
    $textBox.Text = "Running second button!"
    for ($i = 0; $i -le 100; $i++) {
        Invoke-ProgressBar -progressBar $progressBar -textBox $textBox -currentStep $i
        Invoke-Spinner -spinnerLabel $spinnerLabel -textBox $textBox -currentStep $i
        Invoke-Test2
        if($i -eq 50) {
            $logBox.AppendText("Button 2 50% Completed`r`n")
            Start-Sleep -Milliseconds 20
        }
    }
    $textBox.Text = "Done running second button!"
    $logBox.AppendText("Button 2 Completed`r`n")
    $overallProgressBar.Value += 10
    $this.Enabled = $false
}) 

# Add controls to form
$form.Controls.Add($firstButton)
$form.Controls.Add($secondButton)
$form.Controls.Add($overallProgressBar)
$form.Controls.Add($progressBar)
$form.Controls.Add($textBox)
$form.Controls.Add($logBox)

$form.Controls.Add($spinnerLabel)
$form.Controls.Add($pictureBox)

# Show form
$form.ShowDialog()
