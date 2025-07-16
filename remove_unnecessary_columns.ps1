# Remove altitude, gps_accuracy, and interviewee_role columns

Write-Host "Removing unnecessary columns..."
Write-Host "==============================="

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$originalColumnCount = $csv[0].PSObject.Properties.Name.Count

Write-Host "Original column count: $originalColumnCount"

# Define columns to remove
$columnsToRemove = @("photo_altitude", "photo_gps_accuracy", "interviewee_role")

Write-Host "Removing columns:"
$columnsToRemove | ForEach-Object { Write-Host "  - $_" }

# Get all column names except the ones to remove
$allColumns = $csv[0].PSObject.Properties.Name
$columnsToKeep = $allColumns | Where-Object { $columnsToRemove -notcontains $_ }

Write-Host "`nKeeping $($columnsToKeep.Count) columns"

# Select only the columns we want to keep
$filteredData = $csv | Select-Object $columnsToKeep

# Export the filtered data
$filteredData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "`nColumn removal complete!"
Write-Host "Updated wpf_processed.csv with $($columnsToKeep.Count) columns"

# Show remaining columns
Write-Host "`nRemaining columns:"
$columnsToKeep | ForEach-Object { Write-Host "  - $_" }