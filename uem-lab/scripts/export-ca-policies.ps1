# export-ca-policies.ps1
# Exports all Conditional Access policies from Entra ID to JSON files.
# Requires: Microsoft.Graph PowerShell module
#
# Install:  Install-Module Microsoft.Graph -Scope CurrentUser
# Usage:    .\export-ca-policies.ps1

# Connect to Microsoft Graph with the required scope
Connect-MgGraph -Scopes "Policy.Read.All"

# Create output directory if it doesn't exist
$outputDir = Join-Path $PSScriptRoot "..\policies\conditional-access"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Fetch all Conditional Access policies
$policies = Get-MgIdentityConditionalAccessPolicy

foreach ($policy in $policies) {
    # Sanitize the display name for use as a filename
    $safeName = $policy.DisplayName -replace '[^\w\-]', '-' -replace '-+', '-'
    $filePath = Join-Path $outputDir "$safeName.json"

    # Convert the policy object to clean JSON
    $policyJson = $policy | ConvertTo-Json -Depth 10

    # Write to file
    Set-Content -Path $filePath -Value $policyJson -Encoding UTF8

    Write-Host "Exported: $($policy.DisplayName) -> $filePath"
}

Write-Host "`nDone. Exported $($policies.Count) policies to $outputDir"

# Disconnect
Disconnect-MgGraph
