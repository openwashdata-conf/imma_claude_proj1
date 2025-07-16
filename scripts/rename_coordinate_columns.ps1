# Rename photo_latitude and photo_longitude to latitude and longitude

Write-Host "Renaming coordinate columns..."
Write-Host "=============================="

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$rowCount = $csv.Count

Write-Host "Processing $rowCount rows"

# Create new data with renamed columns
$renamedData = @()
foreach ($row in $csv) {
    $newRow = @{}
    foreach ($prop in $row.PSObject.Properties) {
        $columnName = $prop.Name
        $value = $prop.Value
        
        # Rename the coordinate columns
        if ($columnName -eq "photo_latitude") {
            $newRow["latitude"] = $value
        } elseif ($columnName -eq "photo_longitude") {
            $newRow["longitude"] = $value
        } else {
            $newRow[$columnName] = $value
        }
    }
    $renamedData += [PSCustomObject]$newRow
}

# Save the renamed data
$renamedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "`nColumn renaming complete!"
Write-Host "photo_latitude -> latitude"
Write-Host "photo_longitude -> longitude"
Write-Host "`nUpdated wpf_processed.csv with renamed columns."