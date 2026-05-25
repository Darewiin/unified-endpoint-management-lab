# Troubleshooting runbook

Diagnostic procedures for common issues encountered in the Northgate Solutions UEM environment.

---

## Scenario A — User can't access Microsoft 365

**Symptom:** User reports "You can't access this right now" when opening Outlook or Teams.

**Diagnostic steps:**

1. Check the user's most recent sign-in in Entra ID > Sign-in logs. Filter by the user's UPN.
2. Look at the Conditional Access column — which policies were evaluated and what was the result?
3. If CA003 (compliant device) shows "Failure," check the device in Intune > Devices > All devices.
4. Click the device and review the compliance state. Which setting is non-compliant?
5. Common failures:
   - BitLocker not enabled → Enable via Settings > Privacy & Security > Device Encryption
   - OS version too old → Run Windows Update
   - Defender disabled → Re-enable via Windows Security app
6. After remediation, the device re-evaluates compliance within 8 hours (or force sync: Settings > Accounts > Access work or school > Info > Sync).

**Resolution:** Fix the non-compliant setting on the device, force a sync, wait for compliance re-evaluation, then retry access.

---

## Scenario B — Win32 app install failure

**Symptom:** An app assigned as "Required" shows "Failed" in Intune app install status.

**Diagnostic steps:**

1. In Intune > Apps > All apps, find the app and click Monitor > Device install status.
2. Note the error code (e.g., 0x87D1041C = detection rule not met after install).
3. On the Windows 11 VM, navigate to:
   ```
   C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\
   ```
4. Open `IntuneManagementExtension.log` in a text editor. Search for the app name.
5. Look for:
   - Download errors (network timeout, CDN unreachable)
   - Install command failures (wrong silent switch, missing dependency)
   - Detection rule mismatches (wrong file path, wrong registry key)
6. Common fixes:
   - Detection rule: Verify the file path or registry key matches what the installer actually creates
   - Install command: Test the command manually in an elevated PowerShell prompt
   - Content prep: Re-package with the latest Win32 Content Prep Tool

**Resolution:** Fix the detection rule or install command, update the app in Intune, and trigger a re-sync.

---

## Scenario C — SAML SSO failure

**Symptom:** User clicks the app tile in myapps.microsoft.com and gets an error page from the service provider.

**Diagnostic steps:**

1. Open browser Developer Tools (F12) before clicking the app tile.
2. Go to the Network tab. Click the app tile.
3. Find the POST request to the app's ACS URL. Click it.
4. In the Form Data, copy the `SAMLResponse` value.
5. Decode it (Base64) at https://www.samltool.com/decode.php or similar.
6. Check:
   - Is the `Destination` in the assertion the correct ACS URL? (Must match exactly, including trailing slashes)
   - Are the required attributes/claims present? (NameID, email, department, etc.)
   - Is the signing certificate valid and not expired?
   - Does the `Audience` restriction match the Entity ID configured in the app?
7. In Entra ID > Enterprise Applications > [App] > Single sign-on > SAML, verify:
   - Identifier (Entity ID) matches the app's configuration exactly
   - Reply URL (ACS URL) matches the app's configuration exactly
   - Claims are mapped correctly

**Resolution:** Fix the mismatched URL or claim mapping, save the SAML configuration, and retry SSO.

---

## Scenario D — PIM role activation fails

**Symptom:** An admin with an eligible role can't activate it in PIM.

**Diagnostic steps:**

1. In Entra ID > Identity Governance > Privileged Identity Management, check the user's eligible assignments.
2. Is the assignment expired? Eligible assignments have an end date.
3. Does the role require approval? Check PIM > Settings for the role.
4. Is MFA failing? PIM activation requires MFA by default — check if the user's MFA methods are configured.
5. Check the PIM audit log for the activation attempt — what error was returned?

**Resolution:** Renew the eligible assignment if expired, fix MFA registration if incomplete, or approve the pending request if approval is required.

---

## Scenario E — Device doesn't appear in Intune after enrollment

**Symptom:** Windows 11 VM was Azure AD Joined, but doesn't appear in Intune > Devices.

**Diagnostic steps:**

1. On the VM, open Settings > Accounts > Access work or school. Confirm the Azure AD connection shows "Connected to [tenant] Azure AD."
2. Click "Info" under the connection. Look for the MDM enrollment status.
3. If MDM enrollment is missing, check Entra ID > Mobility (MDM and MAM):
   - Is the MDM user scope set to "All" or a group that includes this user?
   - Is the MDM URLs auto-populated? (They should be for Intune)
4. On the VM, open Task Scheduler > Microsoft > Windows > EnterpriseMgmt. Check for enrollment tasks and their last run status.
5. Check Event Viewer > Applications and Services Logs > Microsoft > Windows > DeviceManagement-Enterprise-Diagnostics-Provider for enrollment errors.
6. Parallels-specific: Confirm the VM has internet access (try pinging portal.azure.com).

**Resolution:** Fix the MDM scope to include the user, ensure network connectivity, and re-attempt enrollment (may need to disconnect and rejoin Azure AD).

---

## Useful log locations

| Log | Location | What it shows |
|-----|----------|---------------|
| Intune Management Extension | `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\` | App installs, script execution, Win32 app processing |
| Device Management | Event Viewer > DeviceManagement-Enterprise-Diagnostics-Provider | Enrollment, policy sync, compliance evaluation |
| Azure AD (device side) | `dsregcmd /status` (run in cmd) | Azure AD Join status, MDM enrollment status, device certificate |
| Sign-in logs (cloud) | Entra admin center > Sign-in logs | Authentication results, CA policy evaluation, MFA status |
| Audit logs (cloud) | Entra admin center > Audit logs | Administrative changes, role activations, policy modifications |
