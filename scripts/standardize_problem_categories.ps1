# Step 7: Standardize Problem/Issue Categories

Write-Host "Step 7: Standardizing problem/issue categories..."
Write-Host "=============================================="

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$rowCount = $csv.Count

Write-Host "Processing $rowCount rows"

# Define problem category mappings
$problemCategories = @{
    "Broken parts" = "EQUIPMENT_FAILURE"
    "Worn out parts" = "EQUIPMENT_FAILURE"
    "Low water flow - Low water pressure" = "LOW_FLOW"
    "Low yield" = "LOW_FLOW"
    "Structural problems - Civil works, apron, etc" = "STRUCTURAL_ISSUE"
    "Inadequate number of pipes" = "INFRASTRUCTURE_ISSUE"
    "Other (please specify)" = "OTHER"
    "NA" = "NA"
}

# Define quality issue mappings
$qualityIssueCategories = @{
    "Odor or Smell" = "ODOR"
    "Salinity or salty water" = "SALINITY"
    "Turbidity or cloudy water" = "TURBIDITY"
    "Sediment presence" = "SEDIMENT"
    "Taste" = "TASTE"
    "Colour" = "COLOR"
    "NA" = "NA"
}

# Create standardized data
$standardizedData = @()
foreach ($row in $csv) {
    $newRow = @{}
    
    foreach ($prop in $row.PSObject.Properties) {
        $columnName = $prop.Name
        $value = $prop.Value
        
        # Standardize current_problem
        if ($columnName -eq "current_problem") {
            $standardizedProblem = "OTHER"
            
            if ($value -eq "NA") {
                $standardizedProblem = "NA"
            } else {
                # Check for multiple problems (comma-separated)
                $problems = $value -split ','
                $categorizedProblems = @()
                
                foreach ($problem in $problems) {
                    $cleanProblem = $problem.Trim()
                    $found = $false
                    
                    foreach ($key in $problemCategories.Keys) {
                        if ($cleanProblem -match [regex]::Escape($key)) {
                            $categorizedProblems += $problemCategories[$key]
                            $found = $true
                            break
                        }
                    }
                    
                    if (-not $found -and $cleanProblem -ne "") {
                        $categorizedProblems += "OTHER"
                    }
                }
                
                # Join unique categories
                $standardizedProblem = ($categorizedProblems | Select-Object -Unique) -join ", "
                if ([string]::IsNullOrWhiteSpace($standardizedProblem)) {
                    $standardizedProblem = "OTHER"
                }
            }
            
            $newRow[$columnName] = $standardizedProblem
        }
        # Standardize quality_issues_type
        elseif ($columnName -eq "quality_issues_type") {
            $standardizedQuality = "OTHER"
            
            if ($value -eq "NA") {
                $standardizedQuality = "NA"
            } else {
                $found = $false
                foreach ($key in $qualityIssueCategories.Keys) {
                    if ($value -match [regex]::Escape($key)) {
                        $standardizedQuality = $qualityIssueCategories[$key]
                        $found = $true
                        break
                    }
                }
                
                if (-not $found -and $value -ne "") {
                    $standardizedQuality = "OTHER"
                }
            }
            
            $newRow[$columnName] = $standardizedQuality
        }
        else {
            $newRow[$columnName] = $value
        }
    }
    
    $standardizedData += [PSCustomObject]$newRow
}

# Export standardized data
$standardizedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "`nStep 7 Complete: Problem/issue categories standardized"
Write-Host "- Current problem categories:"
Write-Host "  * EQUIPMENT_FAILURE (broken/worn parts)"
Write-Host "  * LOW_FLOW (low pressure/yield)"
Write-Host "  * STRUCTURAL_ISSUE (civil works problems)"
Write-Host "  * INFRASTRUCTURE_ISSUE (inadequate pipes)"
Write-Host "  * OTHER (unspecified problems)"
Write-Host "- Quality issue categories:"
Write-Host "  * ODOR, SALINITY, TURBIDITY, SEDIMENT, TASTE, COLOR"
Write-Host "  * OTHER (unspecified quality issues)"

# Show distribution of problem categories
Write-Host "`nProblem Category Distribution:"
$problemDistribution = $standardizedData | Group-Object current_problem | Sort-Object Count -Descending
$problemDistribution | ForEach-Object { Write-Host "  $($_.Name): $($_.Count)" }

Write-Host "`nQuality Issue Distribution:"
$qualityDistribution = $standardizedData | Group-Object quality_issues_type | Sort-Object Count -Descending
$qualityDistribution | ForEach-Object { Write-Host "  $($_.Name): $($_.Count)" }

Write-Host "`nAll data quality improvements completed!"