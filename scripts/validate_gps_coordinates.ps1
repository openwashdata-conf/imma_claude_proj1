# Step 2: Validate GPS Coordinates for Outliers

Write-Host "Step 2: Validating GPS coordinates..."
Write-Host "===================================="

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$rowCount = $csv.Count

Write-Host "Processing $rowCount rows"

# Define reasonable bounds for the survey area (adjust based on actual survey location)
# These appear to be coordinates in Malawi/East Africa region
$validLatMin = -17.0
$validLatMax = -9.0
$validLonMin = 32.0
$validLonMax = 37.0

$outliers = @()
$validatedData = @()

foreach ($row in $csv) {
    $newRow = @{}
    $isOutlier = $false
    
    foreach ($prop in $row.PSObject.Properties) {
        $columnName = $prop.Name
        $value = $prop.Value
        
        # Validate latitude
        if ($columnName -eq "latitude" -and $value -ne "NA") {
            try {
                $lat = [double]$value
                if ($lat -lt $validLatMin -or $lat -gt $validLatMax) {
                    $isOutlier = $true
                    Write-Host "Outlier latitude found: $lat in row with water_point_id: $($row.water_point_id)"
                }
            } catch {
                Write-Host "Invalid latitude value: $value in row with water_point_id: $($row.water_point_id)"
                $isOutlier = $true
            }
        }
        
        # Validate longitude
        if ($columnName -eq "longitude" -and $value -ne "NA") {
            try {
                $lon = [double]$value
                if ($lon -lt $validLonMin -or $lon -gt $validLonMax) {
                    $isOutlier = $true
                    Write-Host "Outlier longitude found: $lon in row with water_point_id: $($row.water_point_id)"
                }
            } catch {
                Write-Host "Invalid longitude value: $value in row with water_point_id: $($row.water_point_id)"
                $isOutlier = $true
            }
        }
        
        $newRow[$columnName] = $value
    }
    
    if ($isOutlier) {
        $outliers += [PSCustomObject]$newRow
    } else {
        $validatedData += [PSCustomObject]$newRow
    }
}

Write-Host "`nValidation Results:"
Write-Host "Valid records: $($validatedData.Count)"
Write-Host "Outlier records: $($outliers.Count)"

# Export validated data (excluding outliers)
$validatedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

# Export outliers for review
if ($outliers.Count -gt 0) {
    $outliers | Export-Csv -Path "gps_outliers.csv" -NoTypeInformation -Force
    Write-Host "Outliers saved to gps_outliers.csv for review"
}

Write-Host "`nStep 2 Complete: GPS coordinates validated"
Write-Host "- Latitude range: $validLatMin to $validLatMax"
Write-Host "- Longitude range: $validLonMin to $validLonMax"
Write-Host "- Outliers removed and saved separately"