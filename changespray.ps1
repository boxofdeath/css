<# 
Update-Spray

This script will:
Enumerate all .vtf files in the script's directory and add their full paths to a CSV file called spraylist.csv.
Randomize the items in the CSV file.
Check if the spraylist.csv file exists before creating it. If it exists, the script will continue without doing anything.
Print messages to the screen to inform the user about the script's actions.
Every 15 minutes, take the file path of one of the .vtf files in the CSV file and copy it to the specified directory, then print a message to the user.
Remove the entry from the CSV file after copying.
Once there are no entries left in the CSV file, delete the spraylist.csv file and start the enumeration section again.
#>




# Define the directory and CSV file path
$directory = Get-Location
$csvFile = "$directory\spraylist.csv"
$sprayPath = "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Source\cstrike\materials\vgui\logos\spray.vtf"

# Function to enumerate .vtf files and create the CSV file
function Create-SprayList {
    Write-Output "Enumerating .vtf files in the directory..."
    $vtfFiles = Get-ChildItem -Path $directory -Filter *.vtf | Select-Object -ExpandProperty FullName
    $vtfFiles | Get-Random | Export-Csv -Path $csvFile -NoTypeInformation
    Write-Output "Created spraylist.csv with randomized .vtf file paths."
}

# Check if the CSV file exists
if (-Not (Test-Path -Path $csvFile)) {
    Create-SprayList
} else {
    Write-Output "spraylist.csv already exists. Continuing with the script..."
}

# Function to update the spray.vtf file every 15 minutes
function Update-Spray {
    while ($true) {
        if (Test-Path -Path $csvFile) {
            $sprayList = Import-Csv -Path $csvFile
            if ($sprayList.Count -gt 0) {
                $nextSpray = $sprayList.FullName
                Copy-Item -Path $nextSpray -Destination $sprayPath -Force
                Write-Output "Changed spray.vtf to $nextSpray"
                $sprayList = $sprayList | Where-Object { $_.FullName -ne $nextSpray }
                $sprayList | Export-Csv -Path $csvFile -NoTypeInformation
								Write-Output "Sprays left: $($sprayList.Count)"
            } else {
                Remove-Item -Path $csvFile
                Write-Output "No entries left in spraylist.csv. Deleting the file and starting enumeration again."
                Create-SprayList
            }
        }
        Start-Sleep -Seconds 900
    }
}
