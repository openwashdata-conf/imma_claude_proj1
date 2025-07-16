# Step 1: Standardize Categorical Values

Write-Host "Step 1: Standardizing categorical values..."
Write-Host "=========================================="

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$rowCount = $csv.Count

Write-Host "Processing $rowCount rows"

# Create new data with standardized values
$standardizedData = @()
foreach ($row in $csv) {
    $newRow = @{}
    foreach ($prop in $row.PSObject.Properties) {
        $columnName = $prop.Name
        $value = $prop.Value
        
        # Standardize functional_status
        if ($columnName -eq "functional_status") {
            switch ($value) {
                "Functional" { $newRow[$columnName] = "FUNC" }
                "Partially functional but in need of repair" { $newRow[$columnName] = "PARTIAL" }
                "Not functional" { $newRow[$columnName] = "NOT_FUNC" }
                "No longer exists or abandoned" { $newRow[$columnName] = "ABANDONED" }
                default { $newRow[$columnName] = $value }
            }
        }
        # Standardize boolean fields (remove extra spaces, standardize case)
        elseif ($columnName -in @("has_quality_issues", "has_service_provider", "has_water_committee", "has_seasonal_variation")) {
            $cleanValue = $value.Trim()
            switch ($cleanValue.ToLower()) {
                "yes" { $newRow[$columnName] = "Yes" }
                "no" { $newRow[$columnName] = "No" }
                "don't know" { $newRow[$columnName] = "Unknown" }
                default { $newRow[$columnName] = $value }
            }
        }
        else {
            $newRow[$columnName] = $value
        }
    }
    $standardizedData += [PSCustomObject]$newRow
}

# Export the standardized data
$standardizedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "`nStep 1 Complete: Categorical values standardized"
Write-Host "- functional_status: Functional -> FUNC, Partially functional -> PARTIAL, etc."
Write-Host "- Boolean fields: Cleaned and standardized Yes/No format"
Write-Host "Updated wpf_processed.csv"