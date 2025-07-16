# Remove rows with null photo_latitude or photo_longitude from wpf_processed.csv

Write-Host "Filtering out rows with null photo coordinates..."
Write-Host "================================================"

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$originalCount = $csv.Count

Write-Host "Original row count: $originalCount"

# Filter out rows where photo_latitude or photo_longitude are null/empty
$filteredData = $csv | Where-Object { 
    $_.photo_latitude -ne "" -and 
    $_.photo_longitude -ne "" -and
    $_.photo_latitude -ne $null -and 
    $_.photo_longitude -ne $null
}

$filteredCount = $filteredData.Count
$removedCount = $originalCount - $filteredCount

Write-Host "Filtered row count: $filteredCount"
Write-Host "Removed rows: $removedCount"

# Save the filtered data
$filteredData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "`nFiltering complete! wpf_processed.csv has been updated."
Write-Host "Rows with null photo_latitude or photo_longitude have been removed."