# Convert submitted_date from datetime to day/month/year format

Write-Host "Converting date format from datetime to day/month/year..."
Write-Host "======================================================"

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$rowCount = $csv.Count

Write-Host "Processing $rowCount rows"

# Create new data with formatted dates
$formattedData = @()
foreach ($row in $csv) {
    $newRow = @{}
    foreach ($prop in $row.PSObject.Properties) {
        $columnName = $prop.Name
        $value = $prop.Value
        
        # Format the submitted_date column
        if ($columnName -eq "submitted_date" -and $value -ne "NA" -and ![string]::IsNullOrWhiteSpace($value)) {
            try {
                # Parse the datetime and format as day/month/year
                $dateTime = [DateTime]::Parse($value)
                $newRow[$columnName] = $dateTime.ToString("dd/MM/yyyy")
            } catch {
                # If parsing fails, keep original value
                $newRow[$columnName] = $value
            }
        } else {
            $newRow[$columnName] = $value
        }
    }
    $formattedData += [PSCustomObject]$newRow
}

# Export the formatted data
$formattedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "`nDate formatting complete!"
Write-Host "submitted_date column now shows day/month/year format"
Write-Host "Updated wpf_processed.csv"

# Show a sample of the formatted dates
Write-Host "`nSample formatted dates:"
$formattedData | Select-Object -First 5 | ForEach-Object { 
    Write-Host "  $($_.submitted_date)"
}