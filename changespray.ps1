<#
.SYNOPSIS
    This script enumerates all .vtf files in the script's directory, adds them to a TXT file, and periodically updates a specific file in the Counter-Strike Source directory.

.DESCRIPTION
    - Enumerates all .vtf files in the script's directory.
    - Adds each file name into an array and randomizes the order.
    - Checks if 'spraylist.txt' exists and updates it with the file paths.
    - Every 'x' seconds, copies one of the .vtf files to the specified directory and updates the TXT file.
    - Prints messages to the screen to inform the user of the script's actions and the number of entries left in the TXT file.
    - Includes a text-based rainbow progress bar counting down the time until the next iteration.

.PARAMETERS
    None

.EXAMPLE
    .\changespray.ps1
    This will run the script and start the enumeration and update process.

.NOTES
    Ensure you have the necessary permissions to copy files to the specified directory.
    The script will restart the enumeration process once all entries in the TXT file are processed.
#>

$destinationPath = 'C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Source\cstrike\materials\vgui\logos\spray.vtf'

# Rotation in Seconds 900  = 20 minutes
$rotateTime = 800

# Function to display a rainbow progress bar
function Show-RainbowProgressBar {
    param (
        [int]$Seconds
    )
    $colors = @("Red", "Yellow", "Green", "Cyan", "Blue", "Magenta")
    for ($i = $Seconds; $i -ge 0; $i--) {
        $color = $colors[$i % $colors.Length]
        Write-Host -NoNewline -ForegroundColor $color "`r$i seconds remaining"
        Start-Sleep -Seconds 1
    }
    Write-Host "`rProgress: Complete!`n"
}

function Randoms {
    # Get all .vtf filenames in the current directory
    $files = Get-ChildItem -Filter "*.vtf" | Select-Object -ExpandProperty Name
    
    # Randomize the list of filenames
    $randomizedFiles = $files | Sort-Object {Get-Random}
    
    # Output the list of filenames to sprays.txt
    $randomizedFiles | Out-File -FilePath "sprays.txt"

    ProcessSpraysFile
}

function ProcessSpraysFile {
    $filePath = "sprays.txt"
    if (Test-Path $filePath) {
        $lines = Get-Content $filePath
        
        if ($lines.Count -gt 1) {
            $chosenLine = $lines[0]
            
            # Output the chosen line to a variable
            Write-Output "Current Spray: $chosenLine"
            Copy-Item -Path $chosenLine -Destination $destinationPath -Force
            # Remove the chosen line and update sprays.txt
            $lines = $lines[1..($lines.Count - 1)]
            $lines | Set-Content $filePath
            
            # Check if sprays.txt is now empty and delete if so
            if ((Get-Content $filePath).Count -eq 0) {
                Remove-Item $filePath
                Randoms
            }
        } else {
            Remove-Item $filePath
            Randoms
        }
    } else {
        Randoms
    }



}


while ($true) {
    ProcessSpraysFile
    Show-RainbowProgressBar -Seconds $rotateTime
    clear    
}
