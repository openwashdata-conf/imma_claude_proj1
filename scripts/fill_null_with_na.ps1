# Fill all null/empty fields with "NA"

Write-Host "Filling null fields with 'NA'..."
Write-Host "=================================="

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$rowCount = $csv.Count

Write-Host "Processing $rowCount rows"

# Create new data with NA filled in for empty fields
$filledData = @()
foreach ($row in $csv) {
    $newRow = @{}
    foreach ($prop in $row.PSObject.Properties) {
        $columnName = $prop.Name
        $value = $prop.Value
        
        # Replace empty strings, null values, and whitespace-only strings with "NA"
        if ([string]::IsNullOrWhiteSpace($value)) {
            $newRow[$columnName] = "NA"
        } else {
            $newRow[$columnName] = $value
        }
    }
    $filledData += [PSCustomObject]$newRow
}

# Export the filled data
$filledData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "`nCompleted filling null fields with 'NA'"
Write-Host "Updated wpf_processed.csv"

# Count how many fields were filled
$originalNullCount = 0
$csv | ForEach-Object {
    $_.PSObject.Properties | ForEach-Object {
        if ([string]::IsNullOrWhiteSpace($_.Value)) {
            $originalNullCount++
        }
    }
}

Write-Host "Filled $originalNullCount empty fields with 'NA'"