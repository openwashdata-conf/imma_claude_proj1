# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a water point functionality survey data processing project. The main purpose is to clean and transform CSV data from water point surveys by removing unnecessary columns and renaming remaining columns to be more meaningful and standardized.

## Key Files

- `wpf.csv` - Main water point survey data file (DO NOT DELETE)
- `cols.md` - List of columns to be removed from wpf.csv (DO NOT DELETE)
- `init_prompt.md` - Contains the core processing instructions

## Main Processing Task

When asked to process the data, follow these steps from `init_prompt.md`:

### Step 1: Remove Columns
Remove all columns listed in `cols.md` from `wpf.csv`. The columns to remove are:
- Deployment
- Enumerator
- Status
- Response Code
- Drafted On
- Draft Name
- Last Modified On
- Last Modified By
- Approval Level
- Approval Level 1 By
- Approval Level 1 On
- Rejection message
- Number of Rejections
- Number of Edits
- IP Address
- All "Do I have your permission..." related columns
- "What was the reason that the interviewee declined?"

### Step 2: Rename Columns
Apply these rules to remaining columns:
1. Convert to all lowercase
2. Remove/replace non-UTF8 characters
3. Create meaningful summarized names
4. Maximum 3 words per column name
5. Concatenate words with underscore (_)

## Column Naming Conventions

### Recommended Column Mappings
```
"Submitted On" → "submitted_date"
"Water point linked to this survey" → "water_point_id"
"Interviewee role" → "interviewee_role"
"Take a photo of the water point" → "water_point_photo"
"Take a photo of the water point (Location Answered) (latitude)" → "photo_latitude"
"Take a photo of the water point (Location Answered) (longitude)" → "photo_longitude"
"Take a photo of the water point (Location Answered - accuracy)" → "photo_gps_accuracy"
"Take a photo of the water point (Location Answered - altitude)" → "photo_altitude"
"OBSERVE: Functional status" → "functional_status"
"What is the current problem?" → "current_problem"
"What is the current problem? (Other (please specify)) - specify" → "problem_other_details"
"Are there any water quality issues with this water point?" → "has_quality_issues"
"What are the water quality issues on the water point" → "quality_issues_type"
"What are the water quality issues on the water point (Other (please specify)) - specify" → "quality_issues_other"
"How many households usually use this water point?" → "households_count"
"Are there times of the year when water is not available..." → "has_seasonal_variation"
"When is water not available from this source?" → "unavailable_period"
"Is there a service provider..." → "has_service_provider"
"What is the type of service provider?" → "service_provider_type"
"Does the water point have an active Water Point Committee?" → "has_water_committee"
```

## Common Commands

### PowerShell Script Template
```powershell
# Read CSV
$csv = Import-Csv "wpf.csv"

# Remove columns
$columnsToDelete = @(...) # List from cols.md
$columnsToKeep = $originalColumns | Where-Object { $columnsToDelete -notcontains $_ }
$filteredData = $csv | Select-Object $columnsToKeep

# Rename columns
$columnRenameMap = @{...} # Use mappings above
# Apply renaming logic

# Export
$renamedData | Export-Csv -Path "wpf_processed.csv" -NoTypeInformation
```

### Python Script Template
```python
import pandas as pd

# Read CSV
df = pd.read_csv('wpf.csv')

# Remove columns from cols.md
columns_to_delete = [...] # List from cols.md
df = df.drop(columns=columns_to_delete)

# Rename columns
column_mapping = {...} # Use mappings above
df.rename(columns=column_mapping, inplace=True)

# Save
df.to_csv('wpf_processed.csv', index=False)
```

## Important Notes

1. **Data Preservation**: Always create new files (wpf_processed.csv) rather than overwriting wpf.csv
2. **Column Name Quality**: Ensure renamed columns are self-explanatory (e.g., "photo_latitude" not "take_a_photo_1")
3. **Script Preference**: Use PowerShell on Windows systems as Python may not be available
4. **Validation**: After processing, verify that:
   - All columns from cols.md have been removed
   - All remaining columns have meaningful names
   - No data rows were lost

## Project Structure
```
.
├── wpf.csv              # Original survey data
├── cols.md              # Columns to remove
├── init_prompt.md       # Processing instructions
├── CLAUDE.md           # This file
└── wpf_processed.csv   # Output file (generated)
```

## Common Issues & Solutions

1. **Python not available**: Use PowerShell scripts instead
2. **Column not found**: Some columns in cols.md might have slight variations in wpf.csv - check exact names
3. **Encoding issues**: Ensure UTF-8 encoding when reading/writing CSV files

## Testing the Output

After processing, verify:
```powershell
# Check column count
$processed = Import-Csv "wpf_processed.csv"
$processed[0].PSObject.Properties.Name.Count # Should be ~20 columns

# Check column names are lowercase with underscores
$processed[0].PSObject.Properties.Name | ForEach-Object { Write-Host $_ }
```