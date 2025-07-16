# Step 5: Cross-Field Validation for Logical Consistency

Write-Host "Step 5: Cross-field validation for logical consistency..."
Write-Host "====================================================="

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$rowCount = $csv.Count

Write-Host "Processing $rowCount rows"

$inconsistencies = @()
$validatedData = @()

foreach ($row in $csv) {
    $newRow = @{}
    $hasInconsistency = $false
    $inconsistencyReasons = @()
    
    foreach ($prop in $row.PSObject.Properties) {
        $newRow[$prop.Name] = $prop.Value
    }
    
    # Validation Rule 1: If functional_status = "FUNC", current_problem should be "NA"
    if ($newRow.functional_status -eq "FUNC" -and $newRow.current_problem -ne "NA") {
        $inconsistencyReasons += "Functional water point has reported problems"
        $hasInconsistency = $true
        # Auto-fix: Set current_problem to NA for functional water points
        $newRow.current_problem = "NA"
    }
    
    # Validation Rule 2: If has_quality_issues = "No", quality_issues_type should be "NA"
    if ($newRow.has_quality_issues -eq "No" -and $newRow.quality_issues_type -ne "NA") {
        $inconsistencyReasons += "No quality issues but quality issue type specified"
        $hasInconsistency = $true
        # Auto-fix: Set quality_issues_type to NA
        $newRow.quality_issues_type = "NA"
        $newRow.quality_issues_other = "NA"
    }
    
    # Validation Rule 3: If has_service_provider = "No", service_provider_type should be "NA"
    if ($newRow.has_service_provider -eq "No" -and $newRow.service_provider_type -ne "NA") {
        $inconsistencyReasons += "No service provider but provider type specified"
        $hasInconsistency = $true
        # Auto-fix: Set service provider fields to NA
        $newRow.service_provider_type = "NA"
        $newRow.has_area_mechanic = "No"
        $newRow.has_water_committee = "No"
        $newRow.has_community_members = "No"
        $newRow.has_institution = "No"
        $newRow.has_private_owner = "No"
        $newRow.has_local_govt = "No"
        $newRow.has_bush_mechanic = "No"
    }
    
    # Validation Rule 4: If functional_status = "FUNC", problem_other_details should be "NA"
    if ($newRow.functional_status -eq "FUNC" -and $newRow.problem_other_details -ne "NA") {
        $inconsistencyReasons += "Functional water point has problem details"
        $hasInconsistency = $true
        # Auto-fix: Set problem_other_details to NA
        $newRow.problem_other_details = "NA"
    }
    
    # Validation Rule 5: If functional_status = "ABANDONED", most fields should be NA
    if ($newRow.functional_status -eq "ABANDONED") {
        if ($newRow.current_problem -ne "NA" -or $newRow.has_quality_issues -ne "No") {
            $inconsistencyReasons += "Abandoned water point has operational data"
            $hasInconsistency = $true
            # Auto-fix: Set relevant fields to NA for abandoned points
            $newRow.current_problem = "NA"
            $newRow.has_quality_issues = "No"
            $newRow.quality_issues_type = "NA"
            $newRow.quality_issues_other = "NA"
            $newRow.households_count = "NA"
        }
    }
    
    if ($hasInconsistency) {
        $inconsistencyRecord = [PSCustomObject]@{
            water_point_id = $newRow.water_point_id
            inconsistency_reasons = ($inconsistencyReasons -join "; ")
            functional_status = $row.functional_status
            current_problem = $row.current_problem
            has_quality_issues = $row.has_quality_issues
            has_service_provider = $row.has_service_provider
        }
        $inconsistencies += $inconsistencyRecord
    }
    
    $validatedData += [PSCustomObject]$newRow
}

Write-Host "`nValidation Results:"
Write-Host "Total records: $($validatedData.Count)"
Write-Host "Records with inconsistencies (auto-fixed): $($inconsistencies.Count)"

# Export validated data
$validatedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

# Export inconsistencies log
if ($inconsistencies.Count -gt 0) {
    $inconsistencies | Export-Csv -Path "logical_inconsistencies.csv" -NoTypeInformation -Force
    Write-Host "Logical inconsistencies log saved to logical_inconsistencies.csv"
}

Write-Host "`nStep 5 Complete: Cross-field validation implemented"
Write-Host "- Rule 1: Functional water points have no current problems"
Write-Host "- Rule 2: No quality issues means no quality issue types"
Write-Host "- Rule 3: No service provider means no provider details"
Write-Host "- Rule 4: Functional water points have no problem details"
Write-Host "- Rule 5: Abandoned water points have minimal operational data"
Write-Host "- All inconsistencies auto-fixed and logged"