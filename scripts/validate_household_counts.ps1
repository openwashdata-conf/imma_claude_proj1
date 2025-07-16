# Step 3: Validate and Clean Household Counts

Write-Host "Step 3: Validating household counts..."
Write-Host "====================================="

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$rowCount = $csv.Count

Write-Host "Processing $rowCount rows"

# Define reasonable bounds for household counts
$minHouseholds = 1
$maxHouseholds = 500  # Adjust based on typical community sizes

$invalidCounts = @()
$validatedData = @()

foreach ($row in $csv) {
    $newRow = @{}
    $isInvalid = $false
    
    foreach ($prop in $row.PSObject.Properties) {
        $columnName = $prop.Name
        $value = $prop.Value
        
        # Validate households_count
        if ($columnName -eq "households_count") {
            if ($value -eq "NA" -or [string]::IsNullOrWhiteSpace($value)) {
                $newRow[$columnName] = "NA"
            } else {
                try {
                    $count = [int]$value
                    if ($count -lt $minHouseholds -or $count -gt $maxHouseholds) {
                        Write-Host "Invalid household count: $count in water_point_id: $($row.water_point_id)"
                        $isInvalid = $true
                        $newRow[$columnName] = "NA"  # Set to NA for invalid values
                    } else {
                        $newRow[$columnName] = $count.ToString()
                    }
                } catch {
                    Write-Host "Non-numeric household count: $value in water_point_id: $($row.water_point_id)"
                    $isInvalid = $true
                    $newRow[$columnName] = "NA"  # Set to NA for non-numeric values
                }
            }
        } else {
            $newRow[$columnName] = $value
        }
    }
    
    if ($isInvalid) {
        $invalidCounts += [PSCustomObject]$row
    }
    
    $validatedData += [PSCustomObject]$newRow
}

Write-Host "`nValidation Results:"
Write-Host "Total records: $($validatedData.Count)"
Write-Host "Records with invalid household counts: $($invalidCounts.Count)"

# Export validated data
$validatedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

# Export invalid counts for review
if ($invalidCounts.Count -gt 0) {
    $invalidCounts | Export-Csv -Path "invalid_household_counts.csv" -NoTypeInformation -Force
    Write-Host "Invalid household counts saved to invalid_household_counts.csv for review"
}

Write-Host "`nStep 3 Complete: Household counts validated"
Write-Host "- Valid range: $minHouseholds to $maxHouseholds households"
Write-Host "- Invalid values converted to NA"
Write-Host "- Non-numeric values converted to NA"