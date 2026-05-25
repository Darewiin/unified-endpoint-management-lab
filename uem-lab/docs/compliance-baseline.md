# Compliance baseline — Northgate Solutions

## What "compliant" means

A device is considered compliant when it meets all of the following requirements. These settings are enforced via Microsoft Intune compliance policies and evaluated continuously.

## Windows 11 compliance policy

| Setting | Required value | Rationale |
|---------|---------------|-----------|
| BitLocker | Enabled | Full-disk encryption protects data at rest if the device is lost or stolen |
| Minimum OS version | 10.0.22000 (Windows 11) | Ensures access to current security patches and features |
| Password required | Yes, 8+ characters | Basic credential hygiene |
| Windows Firewall | Enabled | Prevents unauthorized inbound network connections |
| Microsoft Defender Antimalware | Active and up to date | Real-time threat detection |
| TPM 2.0 | Present | Required for BitLocker and Windows Hello for Business |

## Non-compliance actions

| Timeline | Action |
|----------|--------|
| Immediately | Mark device as non-compliant |
| After 1 day | Send email notification to user |
| After 7 days | Send email notification to user's manager |
| After 30 days | Retire device (remove corporate data) |

## Configuration profiles deployed

| Profile | Type | Key settings |
|---------|------|-------------|
| Endpoint Protection | Device configuration | Defender real-time protection, cloud-delivered protection, PUA blocking, tamper protection |
| Device Restrictions | Device configuration | USB storage disabled, Windows Hello required, 5-min screen lock, Registry Editor blocked |
| Windows Update Ring | Update policy | Feature update deferral: 7 days, quality update deferral: 3 days, active hours: 8 AM–6 PM |

## How compliance ties to access

The Conditional Access policy CA003 ("Require compliant device for M365") checks the device's compliance state in Intune before granting access to Office 365 applications. The flow:

1. User signs in to Outlook/Teams/SharePoint
2. Entra ID evaluates Conditional Access policies
3. CA003 checks: is this device registered in Intune and marked compliant?
4. If compliant → access granted
5. If non-compliant or unregistered → access denied with remediation link

This creates a closed loop: the device must be enrolled (Azure AD Join + Intune auto-enrollment), meet all compliance requirements, and stay compliant to access corporate data.

## Parallels-specific notes

- **TPM 2.0**: Must be enabled in Parallels hardware settings (Hardware > TPM Chip) for BitLocker compliance to pass
- **Snapshots**: Take a pre-enrollment snapshot to test enrollment and compliance evaluation repeatedly
- **Networking**: Use bridged mode so the VM has its own IP for location-based CA policy testing
