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

function Create-ProgressBar {
    param(
        [hashtable] $ObjectDimensions = @{ Width=200; Height=20 },
        [PSCustomObject]$CurrentLocation = @{ X=50; Y=70 },
        [System.Windows.Forms.Form]$Form,
        [string]$Text
    )
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point($CurrentLocation.X, $CurrentLocation.Y)
    $progressBar.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)
    $CurrentLocation.X = 10
    $CurrentLocation.Y += $ObjectDimensions.Height

    return $progressBar
}

function Create-TextBox {
    param(
        [hashtable] $ObjectDimensions = @{ Width=200; Height=20 },
        [PSCustomObject]$CurrentLocation = @{ X=50; Y=100 },
        [System.Windows.Forms.Form]$Form
    )
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point($CurrentLocation.X, $CurrentLocation.Y)
    $textBox.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)
    $CurrentLocation.X = 10
    $CurrentLocation.Y += $ObjectDimensions.Height
    
    return $textBox
}

function Create-SpinnerLabel {
    param(
        [hashtable] $ObjectDimensions = @{ Width=200; Height=20 },
        [PSCustomObject]$CurrentLocation = @{ X=50; Y=130 },
        [System.Windows.Forms.Form]$Form,
        [string]$Text = ""
    )
    $spinnerLabel = New-Object System.Windows.Forms.Label
    $spinnerLabel.Location = New-Object System.Drawing.Point($CurrentLocation.X, $CurrentLocation.Y)
    $spinnerLabel.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)
    $spinnerLabel.Text = $Text
    $CurrentLocation.X = 10
    $CurrentLocation.Y += $ObjectDimensions.Height
    
    return $spinnerLabel
}

function Create-PictureBox {
    param(
        [hashtable] $ObjectDimensions = @{ Width=60; Height=30 },
        [PSCustomObject]$CurrentLocation,
        [System.Windows.Forms.Form]$Form,
        [string]$Text
    )
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $webClient = New-Object System.Net.WebClient
    $imagePath = [System.IO.Path]::GetTempFileName()
    $webClient.DownloadFile("https://trustbiztech.com/public/logos/biztech.png", $imagePath)
    $pictureBox.Image = [System.Drawing.Image]::Fromfile($imagePath)
    $pictureBox.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)  # Change this to your desired size
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $pictureBox.Location = New-Object System.Drawing.Point(($CurrentLocation.X - $pictureBox.Width - 20),($CurrentLocation.Y - $pictureBox.Height - 40))
    $CurrentLocation.X = 10
    $CurrentLocation.Y += $ObjectDimensions.Height 

    return $pictureBox
}

function Create-Button {
    param(
        [hashtable] $ObjectDimensions = @{ Width=100; Height=20 },
        [PSCustomObject]$CurrentLocation = @{ X=100; Y=35 },
        [System.Windows.Forms.Form]$Form,
        [string]$Text = "Click me",
        $AddClick
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point($CurrentLocation.X, $CurrentLocation.Y)
    $button.Size = New-Object System.Drawing.Size($ObjectDimensions.Width, $ObjectDimensions.Height)
    $button.Text = $Text
    
    $button.Add_Click({
        Run-UIIndicators -textBox $textBox -spinnerLabel $spinnerLabel -progressBar $progressBar -overallProgressBar $overallProgressBar
        $job = Start-Job -ScriptBlock {
            $AddClick
        }
        Wait-Job $job
        $results = Receive-Job $job
        Remove-Job $job
        $button.Enabled = $false
    })

    $CurrentLocation.X = 10
    $CurrentLocation.Y += $ObjectDimensions.Height
    
    return $button
}

function Run-Test {
    for ($i = 0; $i -le 100; $i++) {
        Start-Sleep -Milliseconds 20
    } 
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

function Run-UIIndicators {
    param (
        $spinnerLabel,
        $textBox,
        $progressBar,
        $overallProgressBar
    )
    $progressBar.Value = 0
    for ($i = 0; $i -le 100; $i++) {
        Run-ProgressBar -progressBar $progressBar -textBox $textBox -currentStep $i
        Run-Spinner -spinnerLabel $spinnerLabel -textBox $textBox -currentStep $i
        Start-Sleep -Milliseconds 20
    }
    $overallProgressBar.Value += 10
}

$location = New-Object -TypeName psobject -Property @{ X=10; Y=10 }
# Create form and controls
$form = Create-Form -CurrentLocation $location
$button = Create-Button -CurrentLocation $location -Text "Sanity Check" -AddClick Run-Test
$overallProgressBar = Create-ProgressBar -CurrentLocation $location
$progressBar = Create-ProgressBar -CurrentLocation $location
$textBox = Create-TextBox -CurrentLocation $location
$spinnerLabel = Create-SpinnerLabel -CurrentLocation $location
$location.X = $form.Width
$location.Y = $form.Height
$pictureBox = Create-PictureBox -CurrentLocation $location


# Add controls to form
$form.Controls.Add($button)
$form.Controls.Add($overallProgressBar)
$form.Controls.Add($progressBar)
$form.Controls.Add($textBox)
$form.Controls.Add($spinnerLabel)
$form.Controls.Add($pictureBox)

# Show form
$form.ShowDialog()
