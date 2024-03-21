# Load assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Create-Form {
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

function Create-Control {
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
        }
        "TextBox" {
            $control = New-Object System.Windows.Forms.TextBox
        }
        "SpinnerLabel" {
            $control = New-Object System.Windows.Forms.Label
            $control.Text = $Text
        }
    }
    $control.Location = New-Object System.Drawing.Point($CurrentLocation.X, $CurrentLocation.Y)
    $control.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)
    $CurrentLocation.X = 10
    $CurrentLocation.Y += $ObjectDimensions.Height

    return $control
}

function Create-PictureBox {
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
    $CurrentLocation.X = 10
    $CurrentLocation.Y += $ObjectDimensions.Height 

    return $pictureBox
}

function Run-Test {
    for ($i = 0; $i -le 100; $i++) {
        Run-ProgressBar -progressBar $progressBar -textBox $textBox -currentStep $i
        Run-Spinner -spinnerLabel $spinnerLabel -textBox $textBox -currentStep $i
        Start-Sleep -Milliseconds 20
    } 
}
function Run-Test2 {
    for ($i = 0; $i -le 100; $i++) {
        Run-ProgressBar -progressBar $progressBar -textBox $textBox -currentStep $i
        Run-Spinner -spinnerLabel $spinnerLabel -textBox $textBox -currentStep $i
        Start-Sleep -Milliseconds 20
    } 
}

function Create-Button {
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

function Run-Spinner {
    param(
        $spinnerLabel,
        $currentStep
    )
    $spinnerChars = @('/', '|', '\', '-')
    $spinnerLabel.Text = $spinnerChars[$currentStep % $spinnerChars.Length]

}

function Run-ProgressBar {
    param(
        $progressBar,
        $currentStep
    )
    $progressBar.Value = $currentStep
}

$location = New-Object -TypeName psobject -Property @{ X=10; Y=10 }
# Create form and controls
$form = Create-Form -CurrentLocation $location
$firstButton = Create-Button -CurrentLocation $location -Text "Button1"
$secondButton = Create-Button -CurrentLocation $location -Text "Button2"
$overallProgressBar = Create-Control -ControlType "ProgressBar" -CurrentLocation $location -Form $form
$progressBar = Create-Control -ControlType "ProgressBar" -CurrentLocation $location -Form $form
$textBox = Create-Control -ControlType "TextBox" -CurrentLocation $location -Form $form
$spinnerLabel = Create-Control -ControlType "SpinnerLabel" -CurrentLocation $location -Form $form
$location.X = $form.Width
$location.Y = $form.Height
$pictureBox = Create-PictureBox -CurrentLocation $location

#now we add the commands for the buttons
$firstButton.Add_Click({
    $progressBar.Value = 0
    Run-Test
    $overallProgressBar.Value += 10
    $this.Enabled = $false
}) 
$secondButton.Add_Click({
    $progressBar.Value = 0
    Run-Test2
    $overallProgressBar.Value += 10
    $this.Enabled = $false
}) 

# Add controls to form
$form.Controls.Add($firstButton)
$form.Controls.Add($secondButton)
$form.Controls.Add($overallProgressBar)
$form.Controls.Add($progressBar)
$form.Controls.Add($textBox)
$form.Controls.Add($spinnerLabel)
$form.Controls.Add($pictureBox)

# Show form
$form.ShowDialog()
