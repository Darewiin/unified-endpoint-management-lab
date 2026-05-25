# audit-log-query.ps1
# Useful Microsoft Graph queries for analyzing sign-in and audit logs.
# Requires: Microsoft.Graph PowerShell module
#
# Install:  Install-Module Microsoft.Graph -Scope CurrentUser
# Usage:    .\audit-log-query.ps1

Connect-MgGraph -Scopes "AuditLog.Read.All", "Directory.Read.All"

# ─────────────────────────────────────────────────
# 1. Failed sign-ins in the last 24 hours
# ─────────────────────────────────────────────────
Write-Host "`n=== Failed Sign-Ins (Last 24 Hours) ===" -ForegroundColor Yellow

$cutoff = (Get-Date).AddHours(-24).ToString("yyyy-MM-ddTHH:mm:ssZ")
$failedSignIns = Get-MgAuditLogSignIn `
    -Filter "status/errorCode ne 0 and createdDateTime ge $cutoff" `
    -Top 50

$failedSignIns | Select-Object `
    UserDisplayName, `
    UserPrincipalName, `
    @{N="Error"; E={$_.Status.ErrorCode}}, `
    @{N="Reason"; E={$_.Status.FailureReason}}, `
    CreatedDateTime |
    Format-Table -AutoSize

# ─────────────────────────────────────────────────
# 2. Conditional Access policy evaluations
# ─────────────────────────────────────────────────
Write-Host "`n=== CA Policy Evaluations (Last 24 Hours) ===" -ForegroundColor Yellow

$signIns = Get-MgAuditLogSignIn `
    -Filter "createdDateTime ge $cutoff" `
    -Top 20

foreach ($signIn in $signIns) {
    if ($signIn.AppliedConditionalAccessPolicies.Count -gt 0) {
        Write-Host "`nUser: $($signIn.UserDisplayName) | App: $($signIn.AppDisplayName)" -ForegroundColor Cyan
        foreach ($ca in $signIn.AppliedConditionalAccessPolicies) {
            Write-Host "  Policy: $($ca.DisplayName) | Result: $($ca.Result)"
        }
    }
}

# ─────────────────────────────────────────────────
# 3. PIM role activations
# ─────────────────────────────────────────────────
Write-Host "`n=== PIM Role Activations (Last 7 Days) ===" -ForegroundColor Yellow

$weekAgo = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ")
$auditLogs = Get-MgAuditLogDirectoryAudit `
    -Filter "activityDisplayName eq 'Add member to role completed (PIM activation)' and activityDateTime ge $weekAgo" `
    -Top 20

$auditLogs | Select-Object `
    @{N="User"; E={$_.InitiatedBy.User.DisplayName}}, `
    @{N="Role"; E={$_.TargetResources[0].DisplayName}}, `
    ActivityDateTime |
    Format-Table -AutoSize

# ─────────────────────────────────────────────────
# 4. User creation audit trail
# ─────────────────────────────────────────────────
Write-Host "`n=== User Creation Events (Last 7 Days) ===" -ForegroundColor Yellow

$userCreations = Get-MgAuditLogDirectoryAudit `
    -Filter "activityDisplayName eq 'Add user' and activityDateTime ge $weekAgo" `
    -Top 50

$userCreations | Select-Object `
    @{N="Created By"; E={$_.InitiatedBy.User.DisplayName}}, `
    @{N="New User"; E={$_.TargetResources[0].DisplayName}}, `
    ActivityDateTime |
    Format-Table -AutoSize

Write-Host "`nDone." -ForegroundColor Green
Disconnect-MgGraph
