# Simple column rename for coordinates

# Read CSV
$csv = Import-Csv "wpf_processed.csv"

# Rename columns by selecting all columns but renaming the coordinate ones
$renamedData = $csv | Select-Object water_point_id, photo_altitude, quality_issues_other, has_quality_issues, water_point_photo, photo_gps_accuracy, @{Name="latitude"; Expression={$_.photo_latitude}}, current_problem, unavailable_period, has_water_committee, service_provider_type, households_count, submitted_date, problem_other_details, has_seasonal_variation, @{Name="longitude"; Expression={$_.photo_longitude}}, functional_status, quality_issues_type, has_service_provider, interviewee_role

# Export the renamed data
$renamedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "Columns renamed successfully:"
Write-Host "photo_latitude -> latitude"
Write-Host "photo_longitude -> longitude"