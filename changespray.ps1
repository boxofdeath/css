<#
.SYNOPSIS
    This script enumerates all .vtf files in the script's directory, adds them to a CSV file, and periodically updates a specific file in the Counter-Strike Source directory.

.DESCRIPTION
    - Enumerates all .vtf files in the script's directory.
    - Adds each file name into an array and randomizes the order.
    - Checks if 'spraylist.csv' exists and updates it with the file paths.
    - Every 15 minutes, copies one of the .vtf files to the specified directory and updates the CSV file.
    - Prints messages to the screen to inform the user of the script's actions and the number of entries left in the CSV file.
    - Includes a text-based rainbow progress bar counting down the time until the next iteration.

.PARAMETERS
    None

.EXAMPLE
    .\YourScriptName.ps1
    This will run the script and start the enumeration and update process.

.NOTES
    Ensure you have the necessary permissions to copy files to the specified directory.
    The script will restart the enumeration process once all entries in the CSV file are processed.
#>

# Function to display a rainbow progress bar
function Show-RainbowProgressBar {
    param (
        [int]$Seconds
    )
    $colors = @("Red", "Yellow", "Green", "Cyan", "Blue", "Magenta")
    for ($i = $Seconds; $i -ge 0; $i--) {
        $color = $colors[$i % $colors.Length]
        Write-Host -NoNewline -ForegroundColor $color "`rProgress: $i seconds remaining"
        Start-Sleep -Seconds 1
    }
    Write-Host "`rProgress: Complete!`n"
}

# Function to enumerate .vtf files and handle CSV
function Enumerate-VTFs {
    $vtfFiles = Get-ChildItem -Path . -Filter *.vtf
    if ($vtfFiles.Count -eq 0) {
        Write-Host "No .vtf files found. Please place them in the directory."
        return
    }

    $csvFile = "spraylist.csv"
    if (Test-Path $csvFile) {
        $entries = Import-Csv $csvFile
        Write-Host "$($entries.Count) entries left in the CSV file."
    } else {
        $vtfArray = @()
        foreach ($file in $vtfFiles) {
            $vtfArray += $file.Name
        }
        $vtfArray = $vtfArray | Sort-Object {Get-Random}
        $vtfArray | Export-Csv -Path $csvFile -NoTypeInformation
        Write-Host "Added $($vtfArray.Count) .vtf files to the CSV file."
    }
}

# Function to update spray.vtf every 15 minutes
function Update-Spray {
    $csvFile = "spraylist.csv"
    while (Test-Path $csvFile) {
        $entries = Import-Csv $csvFile
        if ($entries.Count -eq 0) {
            Remove-Item $csvFile
            Enumerate-VTFs
            continue
        }

        $nextSpray = $entries[0]."Name"
        Copy-Item -Path $nextSpray -Destination "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Source\cstrike\materials\vgui\logos\spray.vtf"
        $entries = $entries | Where-Object { $_.Name -ne $nextSpray }
        $entries | Export-Csv -Path $csvFile -NoTypeInformation
        Write-Host "Changed spray.vtf file. $($entries.Count) entries left in the CSV file."

        Show-RainbowProgressBar -Seconds 900
    }
}

# Main script execution
Enumerate-VTFs
Update-Spray
