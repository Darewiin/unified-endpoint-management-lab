# create-users.ps1
# Creates the Northgate Solutions user accounts and groups in Entra ID.
# Requires: Microsoft.Graph PowerShell module
#
# Install:  Install-Module Microsoft.Graph -Scope CurrentUser
# Usage:    .\create-users.ps1 -Domain "yourtenant.onmicrosoft.com"

param(
    [Parameter(Mandatory = $true)]
    [string]$Domain
)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All"

# Default password (users will be forced to change on first sign-in)
$passwordProfile = @{
    Password                      = "ChangeMe@2024!"
    ForceChangePasswordNextSignIn = $true
}

# Define users
$users = @(
    @{ First = "Jordan";  Last = "Martinez";  Dept = "IT";          Title = "Systems Engineer" },
    @{ First = "Sam";     Last = "Chen";      Dept = "IT";          Title = "Endpoint Engineer" },
    @{ First = "Dana";    Last = "Wilson";     Dept = "Engineering"; Title = "Lead Developer" },
    @{ First = "Alex";    Last = "Johnson";    Dept = "Engineering"; Title = "Software Engineer" },
    @{ First = "Morgan";  Last = "Garcia";     Dept = "Engineering"; Title = "DevOps Engineer" },
    @{ First = "Riley";   Last = "Patel";      Dept = "Engineering"; Title = "QA Engineer" },
    @{ First = "Logan";   Last = "Thompson";   Dept = "Sales";       Title = "Account Executive" },
    @{ First = "Kai";     Last = "Brown";      Dept = "Sales";       Title = "Sales Manager" },
    @{ First = "Casey";   Last = "Davis";      Dept = "Sales";       Title = "SDR" },
    @{ First = "Nico";    Last = "Miller";     Dept = "Human Resources"; Title = "HR Manager" },
    @{ First = "Parker";  Last = "Anderson";   Dept = "Human Resources"; Title = "Recruiter" },
    @{ First = "Taylor";  Last = "Lee";        Dept = "Executive";   Title = "CEO" },
    @{ First = "Jamie";   Last = "White";      Dept = "Executive";   Title = "CTO" },
    @{ First = "Blake";   Last = "Taylor";     Dept = "Executive";   Title = "CFO" }
)

# Create users
$createdUsers = @{}
foreach ($u in $users) {
    $upn = "$($u.First[0].ToString().ToLower()).$($u.Last.ToLower())@$Domain"
    $displayName = "$($u.First) $($u.Last)"

    Write-Host "Creating user: $displayName ($upn)..."

    $newUser = New-MgUser `
        -DisplayName $displayName `
        -UserPrincipalName $upn `
        -MailNickname "$($u.First[0].ToString().ToLower())$($u.Last.ToLower())" `
        -Department $u.Dept `
        -JobTitle $u.Title `
        -PasswordProfile $passwordProfile `
        -AccountEnabled `
        -UsageLocation "US"

    $createdUsers[$upn] = @{ Id = $newUser.Id; Dept = $u.Dept }
    Write-Host "  Created: $($newUser.Id)" -ForegroundColor Green
}

# Define groups
$groups = @(
    @{ Name = "IT-Administrators";     Dept = "IT" },
    @{ Name = "Engineering";           Dept = "Engineering" },
    @{ Name = "Sales";                 Dept = "Sales" },
    @{ Name = "Human-Resources";       Dept = "Human Resources" },
    @{ Name = "Executive-Leadership";  Dept = "Executive" }
)

# Create groups and add members
foreach ($g in $groups) {
    Write-Host "`nCreating group: $($g.Name)..."

    $newGroup = New-MgGroup `
        -DisplayName $g.Name `
        -MailEnabled:$false `
        -MailNickname $g.Name.ToLower() `
        -SecurityEnabled `
        -Description "Northgate Solutions - $($g.Name)"

    Write-Host "  Created: $($newGroup.Id)" -ForegroundColor Green

    # Add matching users to the group
    foreach ($entry in $createdUsers.GetEnumerator()) {
        if ($entry.Value.Dept -eq $g.Dept) {
            New-MgGroupMember -GroupId $newGroup.Id -DirectoryObjectId $entry.Value.Id
            Write-Host "  Added: $($entry.Key)" -ForegroundColor Cyan
        }
    }
}

# Create dynamic group for all engineers
Write-Host "`nCreating dynamic group: All Engineers..."
New-MgGroup `
    -DisplayName "All Engineers" `
    -MailEnabled:$false `
    -MailNickname "all-engineers" `
    -SecurityEnabled `
    -GroupTypes @("DynamicMembership") `
    -MembershipRule '(user.department -eq "Engineering")' `
    -MembershipRuleProcessingState "On" `
    -Description "Dynamic group - auto-populated from department attribute"

Write-Host "`nDone. Created $($users.Count) users and $($groups.Count + 1) groups." -ForegroundColor Green

Disconnect-MgGraph
