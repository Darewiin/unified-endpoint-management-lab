# New-NorthgateUsers.ps1
# Bulk creates the 14 Northgate Solutions standard users in Entra ID via Microsoft Graph.
# The admin (Global Admin) account is provisioned separately during tenant setup.
#
# Requires: Microsoft.Graph PowerShell module
#   Install:  Install-Module Microsoft.Graph -Scope CurrentUser
#
# Usage:
#   .\New-NorthgateUsers.ps1 -Domain "yourtenant.onmicrosoft.com"
#   .\New-NorthgateUsers.ps1 -Domain "yourtenant.onmicrosoft.com" -WhatIf

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [string]$Domain
)

#region Connect
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"
Write-Host "Connected.`n" -ForegroundColor Green
#endregion

#region User definitions
# 14 standard users — 5 departments
# UPN format: <first-initial>.<last>@<domain>
$users = @(
    # IT (2 users)
    [PSCustomObject]@{ First = "Jordan";  Last = "Martinez";  Department = "IT";             JobTitle = "Systems Engineer" },
    [PSCustomObject]@{ First = "Sam";     Last = "Chen";      Department = "IT";             JobTitle = "Endpoint Engineer" },

    # Engineering (4 users)
    [PSCustomObject]@{ First = "Dana";    Last = "Wilson";    Department = "Engineering";    JobTitle = "Lead Developer" },
    [PSCustomObject]@{ First = "Alex";    Last = "Johnson";   Department = "Engineering";    JobTitle = "Software Engineer" },
    [PSCustomObject]@{ First = "Morgan";  Last = "Garcia";    Department = "Engineering";    JobTitle = "DevOps Engineer" },
    [PSCustomObject]@{ First = "Riley";   Last = "Patel";     Department = "Engineering";    JobTitle = "QA Engineer" },

    # Sales (3 users)
    [PSCustomObject]@{ First = "Logan";   Last = "Thompson";  Department = "Sales";          JobTitle = "Account Executive" },
    [PSCustomObject]@{ First = "Kai";     Last = "Brown";     Department = "Sales";          JobTitle = "Sales Manager" },
    [PSCustomObject]@{ First = "Casey";   Last = "Davis";     Department = "Sales";          JobTitle = "SDR" },

    # Human Resources (2 users)
    [PSCustomObject]@{ First = "Nico";    Last = "Miller";    Department = "Human Resources"; JobTitle = "HR Manager" },
    [PSCustomObject]@{ First = "Parker";  Last = "Anderson";  Department = "Human Resources"; JobTitle = "Recruiter" },

    # Executive (3 users)
    [PSCustomObject]@{ First = "Taylor";  Last = "Lee";       Department = "Executive";      JobTitle = "CEO" },
    [PSCustomObject]@{ First = "Jamie";   Last = "White";     Department = "Executive";      JobTitle = "CTO" },
    [PSCustomObject]@{ First = "Blake";   Last = "Taylor";    Department = "Executive";      JobTitle = "CFO" }
)
#endregion

#region Password profile
# Users are forced to change password on first sign-in
$passwordProfile = @{
    Password                      = "ChangeMe@2024!"
    ForceChangePasswordNextSignIn = $true
}
#endregion

#region Create users
$results = [System.Collections.Generic.List[PSCustomObject]]::new()
$errors  = [System.Collections.Generic.List[PSCustomObject]]::new()

Write-Host "Creating $($users.Count) users in tenant: $Domain`n" -ForegroundColor Cyan

foreach ($user in $users) {
    $upn         = "$($user.First[0].ToString().ToLower()).$($user.Last.ToLower())@$Domain"
    $displayName = "$($user.First) $($user.Last)"
    $mailNickname = "$($user.First[0].ToString().ToLower())$($user.Last.ToLower())"

    if ($PSCmdlet.ShouldProcess($upn, "New-MgUser")) {
        try {
            $newUser = New-MgUser `
                -DisplayName      $displayName `
                -UserPrincipalName $upn `
                -MailNickname     $mailNickname `
                -Department       $user.Department `
                -JobTitle         $user.JobTitle `
                -PasswordProfile  $passwordProfile `
                -AccountEnabled   `
                -UsageLocation    "US"

            Write-Host "  [OK] $displayName  ($upn)" -ForegroundColor Green

            $results.Add([PSCustomObject]@{
                DisplayName = $displayName
                UPN         = $upn
                Department  = $user.Department
                JobTitle    = $user.JobTitle
                ObjectId    = $newUser.Id
                Status      = "Created"
            })
        }
        catch {
            Write-Warning "  [FAIL] $displayName ($upn): $_"
            $errors.Add([PSCustomObject]@{
                DisplayName = $displayName
                UPN         = $upn
                Error       = $_.Exception.Message
            })
        }
    }
}
#endregion

#region Summary
Write-Host "`n--- Summary ---" -ForegroundColor Cyan
Write-Host "Created : $($results.Count)" -ForegroundColor Green
if ($errors.Count -gt 0) {
    Write-Host "Failed  : $($errors.Count)" -ForegroundColor Red
    $errors | Format-Table DisplayName, UPN, Error -AutoSize
}

# Output result objects for pipeline use
$results | Format-Table DisplayName, Department, JobTitle, UPN -AutoSize
#endregion

Disconnect-MgGraph
Write-Host "`nDone." -ForegroundColor Green
