# Direct removal of specific columns

# Read CSV
$csv = Import-Csv "wpf_processed.csv"

# Select only the columns we want to keep (excluding photo_altitude, photo_gps_accuracy, interviewee_role)
$cleanedData = $csv | Select-Object water_point_id, quality_issues_other, has_quality_issues, water_point_photo, latitude, current_problem, unavailable_period, has_water_committee, service_provider_type, households_count, submitted_date, problem_other_details, has_seasonal_variation, longitude, functional_status, quality_issues_type, has_service_provider

# Export the cleaned data
$cleanedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "Removed columns: photo_altitude, photo_gps_accuracy, interviewee_role"
Write-Host "Updated wpf_processed.csv with cleaned data"