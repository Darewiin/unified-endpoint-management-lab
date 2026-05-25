# Identity design — Northgate Solutions

## User matrix

| User | Department | Job title | Groups | Admin roles |
|------|-----------|-----------|--------|-------------|
| admin@… | IT | IT Director | IT-Administrators | Global Administrator |
| j.martinez@… | IT | Systems Engineer | IT-Administrators | User Administrator |
| s.chen@… | IT | Endpoint Engineer | IT-Administrators | Intune Administrator (PIM eligible) |
| d.wilson@… | Engineering | Lead Developer | Engineering, All Engineers (dynamic) | — |
| a.johnson@… | Engineering | Software Engineer | Engineering, All Engineers (dynamic) | — |
| m.garcia@… | Engineering | DevOps Engineer | Engineering, All Engineers (dynamic) | Contributor (RG-Workloads only) |
| r.patel@… | Engineering | QA Engineer | Engineering, All Engineers (dynamic) | — |
| l.thompson@… | Sales | Account Executive | Sales | — |
| k.brown@… | Sales | Sales Manager | Sales | — |
| c.davis@… | Sales | SDR | Sales | — |
| n.miller@… | Human Resources | HR Manager | Human-Resources | — |
| p.anderson@… | Human Resources | Recruiter | Human-Resources | — |
| t.lee@… | Executive | CEO | Executive-Leadership | — |
| j.white@… | Executive | CTO | Executive-Leadership | — |
| b.taylor@… | Executive | CFO | Executive-Leadership | — |

## Group design

| Group | Type | Membership | Purpose |
|-------|------|-----------|---------|
| IT-Administrators | Security (assigned) | 3 users | Admin role assignment, Intune admin access |
| Engineering | Security (assigned) | 4 users | App assignment (AWS SSO), config profiles |
| All Engineers | Security (dynamic) | Auto-populated | Rule: `user.department -eq "Engineering"` |
| Sales | Security (assigned) | 3 users | App assignment (Salesforce), targeted policies |
| Human-Resources | Security (assigned) | 2 users | Data access controls |
| Executive-Leadership | Security (assigned) | 3 users | Elevated Conditional Access policies |
| Project-Alpha | Microsoft 365 | Cross-department | Collaboration (Teams, SharePoint) |

## Role assignments

| Role | Scope | Assigned to | Assignment type |
|------|-------|------------|-----------------|
| Global Administrator | Tenant | admin@… | Permanent (active) |
| User Administrator | Tenant | j.martinez@… | Permanent (active) |
| Intune Administrator | Tenant | s.chen@… | Eligible (PIM) — 4hr max, requires justification |
| Contributor | RG-Workloads | m.garcia@… | Permanent (active) |

### PIM configuration for Intune Administrator

- **Assignment type:** Eligible (not active)
- **Maximum activation duration:** 4 hours
- **Require justification:** Yes
- **Require MFA on activation:** Yes
- **Require approval:** No (would add in production)
- **Notification:** Email sent to Global Admin on activation

## Design rationale

**Why only one Global Admin?** The Global Administrator role has unrestricted access to everything in the tenant. In production, organizations typically have 2-3 emergency break-glass accounts, but day-to-day administration uses scoped roles. This lab enforces that discipline.

**Why PIM for Intune Admin?** The Intune Administrator role can push configuration to every managed device. Making it eligible (not permanently active) means the engineer must deliberately activate the role with a justification before making changes — creating an audit trail.

**Why dynamic groups?** When a new engineer is hired and their `Department` attribute is set to "Engineering," they automatically join the "All Engineers" group. This eliminates manual group management and reduces the risk of access gaps or over-provisioning.
