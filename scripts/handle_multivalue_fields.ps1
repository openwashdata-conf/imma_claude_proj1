# Step 4: Handle Multi-Value Service Provider Fields

Write-Host "Step 4: Handling multi-value service provider fields..."
Write-Host "====================================================="

# Read the CSV
$csv = Import-Csv "wpf_processed.csv"
$rowCount = $csv.Count

Write-Host "Processing $rowCount rows"

# Create new data with expanded service provider fields
$expandedData = @()
foreach ($row in $csv) {
    $newRow = @{}
    
    foreach ($prop in $row.PSObject.Properties) {
        $columnName = $prop.Name
        $value = $prop.Value
        
        # Handle service_provider_type field
        if ($columnName -eq "service_provider_type") {
            # Initialize boolean columns for different provider types
            $newRow["has_area_mechanic"] = "No"
            $newRow["has_water_committee"] = "No"
            $newRow["has_community_members"] = "No"
            $newRow["has_institution"] = "No"
            $newRow["has_private_owner"] = "No"
            $newRow["has_local_govt"] = "No"
            $newRow["has_bush_mechanic"] = "No"
            
            if ($value -ne "NA" -and ![string]::IsNullOrWhiteSpace($value)) {
                $providers = $value -split ','
                foreach ($provider in $providers) {
                    $cleanProvider = $provider.Trim().ToLower()
                    
                    if ($cleanProvider -match "area.*mechanic") {
                        $newRow["has_area_mechanic"] = "Yes"
                    }
                    if ($cleanProvider -match "water.*committee") {
                        $newRow["has_water_committee"] = "Yes"
                    }
                    if ($cleanProvider -match "community.*members") {
                        $newRow["has_community_members"] = "Yes"
                    }
                    if ($cleanProvider -match "institution") {
                        $newRow["has_institution"] = "Yes"
                    }
                    if ($cleanProvider -match "owner.*private.*household") {
                        $newRow["has_private_owner"] = "Yes"
                    }
                    if ($cleanProvider -match "local.*government") {
                        $newRow["has_local_govt"] = "Yes"
                    }
                    if ($cleanProvider -match "bush.*mechanic") {
                        $newRow["has_bush_mechanic"] = "Yes"
                    }
                }
            }
            
            # Keep original field as well for reference
            $newRow[$columnName] = $value
        } else {
            $newRow[$columnName] = $value
        }
    }
    
    $expandedData += [PSCustomObject]$newRow
}

# Export the expanded data
$expandedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation -Force

Write-Host "`nStep 4 Complete: Multi-value service provider fields handled"
Write-Host "- Added boolean columns for each provider type:"
Write-Host "  * has_area_mechanic"
Write-Host "  * has_water_committee"
Write-Host "  * has_community_members"
Write-Host "  * has_institution"
Write-Host "  * has_private_owner"
Write-Host "  * has_local_govt"
Write-Host "  * has_bush_mechanic"
Write-Host "- Original service_provider_type field preserved"

# Show sample of expanded data
Write-Host "`nSample of expanded service provider data:"
$expandedData | Select-Object -First 3 | Select-Object water_point_id, service_provider_type, has_area_mechanic, has_water_committee | Format-Table