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
        [int]$minutes
    )

    $colors = @("Red", "Yellow", "Green", "Cyan", "Blue", "Magenta")
    for ($i = $minutes; $i -gt 0; $i--) {
        $color = $colors[$i % $colors.Count]
        Write-Host "Next update in $i minutes." -ForegroundColor $color -NoNewline
        Start-Sleep -Seconds 60
        Write-Host "`r`n"
    }
}

# Enumerate all .vtf files in the script's directory
$vtfFiles = Get-ChildItem -Path . -Filter *.vtf

if ($vtfFiles.Count -eq 0) {
    Write-Host "No .vtf files found in the directory. Please place the .vtf files in the directory and try again."
    exit
}

# Add each file name into an array and randomize the order
$fileArray = $vtfFiles | ForEach-Object { $_.FullName }
$fileArray = $fileArray | Sort-Object { Get-Random }

# Check if 'spraylist.csv' exists
$csvFile = "spraylist.csv"
if (Test-Path $csvFile) {
    $existingEntries = Import-Csv $csvFile
    Write-Host "spraylist.csv exists with $($existingEntries.Count) entries."
} else {
    $existingEntries = @()
}

# Add each item in the array to the CSV file
foreach ($file in $fileArray) {
    $existingEntries += [PSCustomObject]@{ FilePath = $file }
}
$existingEntries | Export-Csv -Path $csvFile -NoTypeInformation

Write-Host "Added $($fileArray.Count) entries to spraylist.csv."

# Function to update spray.vtf every 15 minutes
function Update-Spray {
    while ($true) {
        $entries = Import-Csv $csvFile
        if ($entries.Count -eq 0) {
            Write-Host "No entries left in spraylist.csv. Deleting the file and restarting enumeration."
            Remove-Item $csvFile
            Start-Sleep -Seconds 5
            # Restart the script
            & $PSCommandPath
            exit
        }

        $entry = $entries[0]
        Copy-Item -Path $entry.FilePath -Destination "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Source\cstrike\materials\vgui\logos\spray.vtf"
        $entries = $entries | Where-Object { $_.FilePath -ne $entry.FilePath }
        $entries | Export-Csv -Path $csvFile -NoTypeInformation

        Write-Host "Changed spray.vtf file. $($entries.Count) entries left in spraylist.csv."

        # Rainbow progress bar
        Show-RainbowProgressBar -minutes 15
    }
}

# Start the update function
Update-Spray
