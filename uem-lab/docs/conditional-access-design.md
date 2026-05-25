# Conditional Access policy design

## Policy matrix

| ID | Policy name | Users | Apps | Conditions | Grant | Session |
|----|------------|-------|------|------------|-------|---------|
| CA001 | Require MFA for Azure management | All users | Azure Management | None | Require MFA | — |
| CA002 | Block access outside US | All users | All cloud apps | Location: outside "US Only" named location | Block | — |
| CA003 | Require compliant device for M365 | All users | Office 365 | None | Require compliant device | — |
| CA004 | Respond to high-risk sign-ins | All users | All cloud apps | Sign-in risk: High | Require MFA + password change | — |

## Deployment sequence

All policies follow a three-stage deployment:

1. **Report-Only** — Policy is evaluated but not enforced. Results appear in sign-in logs under "Report-only" status. Run for at least 48 hours to assess impact.
2. **What If validation** — Use the Conditional Access "What If" tool to simulate specific users, apps, and conditions. Verify the expected policy applies.
3. **Enabled** — Switch to enforcement only after confirming no unintended blocks.

## Named locations

| Name | Type | Definition |
|------|------|-----------|
| US Only | Countries/regions | United States |

## Design rationale

**CA001 — Why MFA for Azure Portal specifically?** The Azure management plane controls infrastructure. Compromised credentials used to access the portal can spin up resources, modify networking, or escalate privileges. MFA adds a second factor that's independent of the password.

**CA002 — Why geo-blocking?** Northgate Solutions operates exclusively in the US. Sign-in attempts from outside the country are almost certainly unauthorized. This is a coarse filter — sophisticated attackers can use VPNs — but it blocks opportunistic credential-stuffing attacks originating overseas.

**CA003 — Why compliant device, not just MFA?** MFA verifies the *user* but not the *device*. A user could pass MFA on an unmanaged personal laptop with no encryption, no antivirus, and an outdated OS. Requiring a compliant device ensures the endpoint meets security baselines before corporate data touches it.

**CA004 — Why password change on high risk?** Entra ID Identity Protection uses machine learning to score sign-in risk (impossible travel, anonymous IP, malware-linked IP, etc.). A high-risk score suggests the credentials may already be compromised. Forcing a password change (in addition to MFA) ensures the attacker's stolen credentials are invalidated.

## Exclusions

The Global Admin break-glass account is excluded from CA002 (geo-blocking) to prevent lockout during travel or emergency access scenarios. In production, this account would be monitored with alerts on any sign-in activity.

## Testing checklist

- [ ] CA001: Sign in to portal.azure.com as a test user → MFA prompt appears
- [ ] CA002: Use "What If" with location set to outside US → access blocked
- [ ] CA003: Sign in from non-compliant device to Outlook → access denied
- [ ] CA003: Sign in from compliant device to Outlook → access granted
- [ ] CA004: Simulate high-risk sign-in in Identity Protection → MFA + password change required
