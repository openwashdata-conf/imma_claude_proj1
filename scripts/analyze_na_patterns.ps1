# Step 6: Analyze NA Patterns and Completeness

Write-Host "Step 6: Analyzing NA patterns and data completeness..."
Write-Host "===================================================="

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$rowCount = $csv.Count
$columnNames = $csv[0].PSObject.Properties.Name

Write-Host "Analyzing $rowCount rows across $($columnNames.Count) columns"

# Calculate NA counts and percentages for each column
$naAnalysis = @()
foreach ($column in $columnNames) {
    $naCount = 0
    $csv | ForEach-Object {
        if ($_.$column -eq "NA" -or [string]::IsNullOrWhiteSpace($_.$column)) {
            $naCount++
        }
    }
    
    $naPercentage = [math]::Round(($naCount / $rowCount) * 100, 2)
    
    $naAnalysis += [PSCustomObject]@{
        Column = $column
        NA_Count = $naCount
        NA_Percentage = $naPercentage
        Completeness = [math]::Round(100 - $naPercentage, 2)
    }
}

# Sort by NA percentage (highest first)
$naAnalysis = $naAnalysis | Sort-Object NA_Percentage -Descending

Write-Host "`nData Completeness Analysis:"
Write-Host "=========================="
$naAnalysis | Format-Table -AutoSize

# Identify columns with high NA rates (>50%)
$highNAColumns = $naAnalysis | Where-Object { $_.NA_Percentage -gt 50 }
if ($highNAColumns.Count -gt 0) {
    Write-Host "`nColumns with high NA rates (>50%):"
    $highNAColumns | ForEach-Object { Write-Host "  - $($_.Column): $($_.NA_Percentage)%" }
}

# Identify columns with low NA rates (<10%)
$lowNAColumns = $naAnalysis | Where-Object { $_.NA_Percentage -lt 10 }
if ($lowNAColumns.Count -gt 0) {
    Write-Host "`nColumns with excellent completeness (<10% NA):"
    $lowNAColumns | ForEach-Object { Write-Host "  - $($_.Column): $($_.Completeness)% complete" }
}

# Calculate overall data completeness
$totalCells = $rowCount * $columnNames.Count
$totalNACells = ($naAnalysis | Measure-Object -Property NA_Count -Sum).Sum
$overallCompleteness = [math]::Round((($totalCells - $totalNACells) / $totalCells) * 100, 2)

Write-Host "`nOverall Dataset Statistics:"
Write-Host "=========================="
Write-Host "Total data points: $totalCells"
Write-Host "NA values: $totalNACells"
Write-Host "Overall completeness: $overallCompleteness%"

# Export analysis results
$naAnalysis | Export-Csv -Path "data_completeness_analysis.csv" -NoTypeInformation -Force

Write-Host "`nStep 6 Complete: NA pattern analysis finished"
Write-Host "- Completeness analysis saved to data_completeness_analysis.csv"
Write-Host "- Overall dataset completeness: $overallCompleteness%"

# Recommendations based on analysis
Write-Host "`nRecommendations:"
Write-Host "==============="
if ($highNAColumns.Count -gt 0) {
    Write-Host "- Consider removing columns with very high NA rates"
    Write-Host "- Investigate why certain fields have high missing data"
}
if ($overallCompleteness -lt 80) {
    Write-Host "- Consider data collection improvements"
    Write-Host "- Review survey methodology for missing data patterns"
} else {
    Write-Host "- Good overall data completeness achieved"
}