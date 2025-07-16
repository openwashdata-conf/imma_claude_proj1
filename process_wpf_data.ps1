# Water Point Survey Data Processing Script
# Following instructions from CLAUDE.md

Write-Host "Processing WPF Survey Data..."
Write-Host "=============================="

# Step 1: Define columns to remove (from cols.md)
$columnsToDelete = @(
    "Deployment",
    "Enumerator", 
    "Status",
    "Response Code",
    "Drafted On",
    "Draft Name",
    "Last Modified On",
    "Last Modified By",
    "Approval Level",
    "Approval Level 1 By",
    "Approval Level 1 On",
    "Rejection message",
    "Number of Rejections",
    "Number of Edits",
    "IP Address",
    "Do I have your permission to proceed with the survey?",
    "Do I have your permission to proceed with the survey? (Time Answered)",
    "Do I have your permission to proceed with the survey? (Location Answered) (latitude)",
    "Do I have your permission to proceed with the survey? (Location Answered) (longitude)",
    "Do I have your permission to proceed with the survey? (Location Answered - accuracy)",
    "Do I have your permission to proceed with the survey? (Location Answered - altitude)",
    "What was the reason that the interviewee declined?"
)

# Read CSV
$csv = Import-Csv "wpf.csv"
$originalColumns = $csv[0].PSObject.Properties.Name
Write-Host "Original CSV has $($originalColumns.Count) columns"

# Step 1: Remove specified columns
$columnsToKeep = $originalColumns | Where-Object { $columnsToDelete -notcontains $_ }
$deletedCount = $originalColumns.Count - $columnsToKeep.Count

Write-Host "`nStep 1: Removing $deletedCount columns from cols.md"
Write-Host "Keeping $($columnsToKeep.Count) columns"

# Select only the columns we want to keep
$filteredData = $csv | Select-Object $columnsToKeep

# Step 2: Column renaming with meaningful names
$columnRenameMap = @{
    "Submitted On" = "submitted_date"
    "Water point linked to this survey" = "water_point_id"
    "Interviewee role" = "interviewee_role"
    "Take a photo of the water point" = "water_point_photo"
    "Take a photo of the water point (Location Answered) (latitude)" = "photo_latitude"
    "Take a photo of the water point (Location Answered) (longitude)" = "photo_longitude"
    "Take a photo of the water point (Location Answered - accuracy)" = "photo_gps_accuracy"
    "Take a photo of the water point (Location Answered - altitude)" = "photo_altitude"
    "OBSERVE: Functional status" = "functional_status"
    "What is the current problem?" = "current_problem"
    "What is the current problem? (Other (please specify)) - specify" = "problem_other_details"
    "Are there any water quality issues with this water point?" = "has_quality_issues"
    "What are the water quality issues on the water point" = "quality_issues_type"
    "What are the water quality issues on the water point (Other (please specify)) - specify" = "quality_issues_other"
    "How many households usually use this water point?" = "households_count"
    "Are there times of the year when water is not available from this source due to seasonal variation?" = "has_seasonal_variation"
    "When is water not available from this source?" = "unavailable_period"
    "Is there a service provider or someone responsible for operating and/or maintaining this water point or water system?" = "has_service_provider"
    "What is the type of service provider?" = "service_provider_type"
    "Does the water point have an active Water Point Committee?" = "has_water_committee"
}

Write-Host "`nStep 2: Renaming columns with meaningful names"

# Create new data with renamed columns
$renamedData = @()
foreach ($row in $filteredData) {
    $newRow = @{}
    foreach ($prop in $row.PSObject.Properties) {
        $oldName = $prop.Name
        if ($columnRenameMap.ContainsKey($oldName)) {
            $newName = $columnRenameMap[$oldName]
        } else {
            # Auto-generate name following rules for unmapped columns
            $newName = $oldName.ToLower()
            # Remove non-UTF8 characters and special characters
            $newName = $newName -replace '[^\w\s]', ''
            # Replace spaces with underscores
            $newName = $newName -replace '\s+', '_'
            # Limit to 3 words
            $words = $newName -split '_'
            if ($words.Count -gt 3) {
                $newName = ($words[0..2] -join '_')
            }
        }
        $newRow[$newName] = $prop.Value
    }
    $renamedData += [PSCustomObject]$newRow
}

# Step 3: Export processed data
$renamedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "`nProcessing Complete!"
Write-Host "==================="
Write-Host "Original columns: $($originalColumns.Count)"
Write-Host "Deleted columns: $deletedCount"
Write-Host "Final columns: $(@($renamedData[0].PSObject.Properties).Count)"
Write-Host "Total rows: $($renamedData.Count)"
Write-Host "Output file: wpf_processed.csv"

# Display final column names
Write-Host "`nFinal column names:"
$renamedData[0].PSObject.Properties.Name | Sort-Object | ForEach-Object { Write-Host "  - $_" }