# Unified Endpoint Management Lab

> A simulated enterprise environment demonstrating production-grade identity governance, endpoint compliance, and zero-trust access controls using Microsoft Azure, Entra ID, and Intune.

![Azure](https://img.shields.io/badge/Azure-0078D4?style=flat-square&logo=microsoftazure&logoColor=white)
![Entra ID](https://img.shields.io/badge/Entra_ID-0078D4?style=flat-square&logo=microsoftazure&logoColor=white)
![Intune](https://img.shields.io/badge/Intune-0078D4?style=flat-square&logo=microsoftazure&logoColor=white)
![SAML](https://img.shields.io/badge/SAML_2.0-DC382D?style=flat-square)
![OIDC](https://img.shields.io/badge/OIDC%2FOAuth_2.0-F78C40?style=flat-square)

---

## Overview

This project simulates the IT infrastructure for **Northgate Solutions**, a fictional mid-size organization (~15 users across 5 departments). Built entirely on Microsoft's cloud stack using free-tier resources, it covers the full lifecycle of enterprise endpoint management — from tenant provisioning through device compliance enforcement.

### What's implemented

- **Azure governance** — Management groups, resource groups, tagging strategy, and Azure Policy baselines (location restrictions, VM SKU limits, mandatory tagging)
- **Identity & access management** — 15 users across 5 security groups, dynamic group membership, RBAC with least-privilege roles, Privileged Identity Management (PIM) with just-in-time activation
- **Zero-trust access controls** — 4 Conditional Access policies: MFA for Azure Portal, geo-blocking, compliant-device enforcement, and risk-based sign-in response
- **Federated SSO** — SAML 2.0 enterprise app integration with claim mapping, OIDC/OAuth 2.0 app registration with token inspection
- **Endpoint management** — Windows 11 device enrollment via Azure AD Join, compliance policies (BitLocker, Defender, firewall, OS version), configuration profiles (endpoint protection, device restrictions, Windows Update rings), and application deployment (M365 suite, Win32 apps, web links)
- **Monitoring & diagnostics** — Sign-in log analysis, audit trail review, and structured troubleshooting scenarios

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Management Group                    │
│                    "Northgate Solutions"                      │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              Azure Subscription                        │  │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐   │  │
│  │  │ RG-Identity  │ │ RG-Networking│ │ RG-Workloads │   │  │
│  │  └──────────────┘ └──────────────┘ └──────────────┘   │  │
│  └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────┐       ┌──────────────────────────┐
│    Microsoft Entra ID │       │    Microsoft Intune       │
│  ┌────────────────┐   │       │  ┌────────────────────┐  │
│  │ Users & Groups  │   │       │  │ Compliance Policies │  │
│  │ Dynamic Groups  │   │◄─────►│  │ Config Profiles     │  │
│  │ RBAC / PIM      │   │       │  │ App Deployment      │  │
│  │ Cond. Access    │   │       │  │ Update Rings        │  │
│  └────────────────┘   │       │  └────────────────────┘  │
│  ┌────────────────┐   │       │  ┌────────────────────┐  │
│  │ Enterprise Apps │   │       │  │ Managed Devices     │  │
│  │ SAML / OIDC SSO│   │       │  │ Windows 11 (VM)     │  │
│  └────────────────┘   │       │  └────────────────────┘  │
└──────────────────────┘       └──────────────────────────┘
```

---

## Lab environment

| Component | Details |
|-----------|---------|
| **Host machine** | macOS with Parallels Desktop |
| **Managed endpoint** | Windows 11 VM (Parallels) — Azure AD Joined, Intune enrolled |
| **Cloud tenant** | Microsoft 365 E5 trial + Azure free account ($200 credit) |
| **Admin access** | Azure Portal, Entra admin center, Intune admin center via browser on macOS host |

---

## Repository structure

```
uem-lab/
├── README.md                          # This file
├── docs/
│   ├── architecture.md                # Detailed architecture decisions
│   ├── identity-design.md             # User/group/role design rationale
│   ├── conditional-access-design.md   # CA policy matrix and design logic
│   ├── compliance-baseline.md         # What "compliant" means and why
│   ├── troubleshooting-runbook.md     # Diagnostic procedures for common issues
│   ├── lessons-learned.md             # What broke, how it was fixed
│   └── screenshots/                   # Annotated screenshots of key configs
│       ├── entra-conditional-access.png
│       ├── intune-compliance-policy.png
│       ├── intune-device-enrolled.png
│       ├── saml-sso-config.png
│       └── pim-activation.png
├── policies/
│   └── conditional-access/            # Exported CA policies (JSON)
│       ├── CA001-mfa-azure-portal.json
│       ├── CA002-block-outside-us.json
│       ├── CA003-require-compliant-device.json
│       └── CA004-high-risk-signin.json
├── scripts/
│   ├── export-ca-policies.ps1         # PowerShell script to export CA policies
│   ├── create-users.ps1               # Bulk user creation script
│   └── audit-log-query.ps1            # KQL queries for sign-in analysis
└── .github/
    └── CODEOWNERS                     # Repo ownership
```

---

## Conditional Access policy matrix

| Policy | Target users | Target apps | Conditions | Grant controls |
|--------|-------------|-------------|------------|----------------|
| CA001 | All users | Azure Management | — | Require MFA |
| CA002 | All users | All cloud apps | Outside US | Block access |
| CA003 | All users | Office 365 | — | Require compliant device |
| CA004 | All users | All cloud apps | High sign-in risk | Require MFA + password change |

Exported policy JSON files are in [`policies/conditional-access/`](policies/conditional-access/).

---

## Key design decisions

1. **Single Global Admin** — Only one account holds Global Admin. All other administrative access uses scoped roles (User Admin, Intune Admin) with PIM for just-in-time elevation.

2. **Dynamic groups over static** — The "All Engineers" group uses a dynamic membership rule (`user.department -eq "Engineering"`) so group membership stays accurate as users are onboarded or change departments.

3. **Compliance before access** — Conditional Access Policy CA003 enforces device compliance as a prerequisite for Microsoft 365 access. A non-compliant device (missing BitLocker, outdated OS, disabled firewall) is blocked regardless of the user's identity.

4. **Report-Only first** — All Conditional Access policies were deployed in Report-Only mode, validated with the "What If" tool, then switched to Enabled — matching the production deployment pattern.

---

## Certifications this prepares you for

| Exam | Title | Relevance |
|------|-------|-----------|
| **AZ-900** | Azure Fundamentals | Tenant, subscriptions, resource groups, governance, pricing |
| **SC-900** | Security, Compliance, Identity Fundamentals | Entra ID, MFA, Conditional Access, Zero Trust |
| **MD-102** | Endpoint Administrator | Intune enrollment, compliance, profiles, app deployment |
| **SC-300** | Identity and Access Administrator | Entra ID, PIM, SSO (SAML/OIDC), Conditional Access |

---

## How to reproduce

1. Sign up for a [Microsoft 365 E5 trial](https://www.microsoft.com/en-us/microsoft-365/enterprise/e5) (30 days free)
2. Create an [Azure free account](https://azure.microsoft.com/en-us/free/) ($200 credit)
3. Follow the step-by-step guide in [`docs/architecture.md`](docs/architecture.md)
4. Use a Windows 11 VM (Parallels, Hyper-V, or VMware) as the managed endpoint

---

## License

This project is for educational and portfolio purposes. No proprietary code or credentials are included.
